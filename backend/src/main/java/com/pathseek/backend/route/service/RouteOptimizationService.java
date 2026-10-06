package com.pathseek.backend.route.service;

import com.pathseek.backend.order.entity.MotivoNoAsignado;
import com.pathseek.backend.order.entity.Order;
import com.pathseek.backend.order.entity.OrderPriority;
import com.pathseek.backend.vehicle.entity.Vehicle;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * Heurística greedy Sprint 2 (MVP): respeta capacidad, ventanas y placa.
 * No calcula jornada real de conductor (ver DoD historia 1): solo verifica
 * {@code disponible} a nivel de flota mediante los vehículos habilitados.
 *
 * <p>Distancias con Haversine en memoria; sin matriz persistida.
 * Fórmulas MVP (documentadas en README):
 * combustible_l = distancia_km / consumo_km_l ;
 * co2_kg = combustible_l * factor_emision (kg CO2 por litro).
 */
@Service
public class RouteOptimizationService {

    private static final int START_OF_DAY_MIN = 6 * 60;

    private final PlateRestrictionService plateRestrictionService;

    public RouteOptimizationService(PlateRestrictionService plateRestrictionService) {
        this.plateRestrictionService = plateRestrictionService;
    }

    public PlanResult optimize(
            LocalDate fechaOperacion,
            double depotLat,
            double depotLon,
            double velocidadKmh,
            int tiempoServicioMin,
            List<Vehicle> vehicles,
            List<Order> orders) {

        DayOfWeek day = fechaOperacion.getDayOfWeek();
        List<Vehicle> candidates = vehicles.stream()
                .filter(v -> plateRestrictionService.puedeCircular(
                        day, v.getPlaca(), v.getRestriccionPlacaDigito()))
                .toList();
        boolean todosRestringidos = !vehicles.isEmpty() && candidates.isEmpty();

        List<Order> sorted = orders.stream()
                .sorted(Comparator.comparingInt((Order o) -> priorityRank(o.getPrioridad()))
                        .thenComparing(Order::getVentanaInicio))
                .toList();

        Map<UUID, VehicleState> states = new HashMap<>();
        for (Vehicle v : candidates) {
            states.put(v.getId(), new VehicleState(v, depotLat, depotLon));
        }

        List<AssignedStop> assigned = new ArrayList<>();
        List<Unassigned> unassigned = new ArrayList<>();

        for (Order order : sorted) {
            VehicleState best = null;
            double bestExtra = Double.MAX_VALUE;
            int bestArrival = 0;
            double bestLeg = 0;

            for (VehicleState state : states.values()) {
                if (!state.hasCapacity(order)) {
                    continue;
                }
                double leg = GeoUtils.haversineKm(
                        state.lat, state.lon,
                        order.getGpsLat().doubleValue(), order.getGpsLon().doubleValue());
                double travelMin = leg / velocidadKmh * 60.0;
                int arrival = (int) Math.round(state.timeMin + travelMin);
                int windowStart = toMinutes(order.getVentanaInicio());
                int windowEnd = toMinutes(order.getVentanaFin());
                int effective = Math.max(arrival, windowStart);
                if (effective > windowEnd) {
                    continue;
                }
                if (leg < bestExtra) {
                    best = state;
                    bestExtra = leg;
                    bestArrival = effective;
                    bestLeg = leg;
                }
            }

            if (best == null) {
                unassigned.add(new Unassigned(order.getId(), decideMotivo(
                        order, states, todosRestringidos, velocidadKmh, tiempoServicioMin)));
            } else {
                best.assign(order, bestLeg, bestArrival, tiempoServicioMin);
                assigned.add(new AssignedStop(best.vehicle, order, bestLeg, bestArrival));
            }
        }

        return new PlanResult(candidates, assigned, unassigned, states);
    }

    private MotivoNoAsignado decideMotivo(
            Order order, Map<UUID, VehicleState> states, boolean todosRestringidos,
            double velocidadKmh, int tiempoServicioMin) {
        if (todosRestringidos || states.isEmpty()) {
            return MotivoNoAsignado.RESTRICCION_PLACA;
        }
        boolean anyCapacity = states.values().stream().anyMatch(s -> s.hasCapacity(order));
        if (!anyCapacity) {
            return MotivoNoAsignado.CAPACIDAD;
        }
        return MotivoNoAsignado.VENTANA_INALCANZABLE;
    }

    private int priorityRank(OrderPriority priority) {
        if (priority == null) {
            return 1;
        }
        return switch (priority) {
            case EXPRESS -> 0;
            case ESTANDAR -> 1;
            case ECONOMICO -> 2;
        };
    }

    static int toMinutes(String hhmm) {
        String[] parts = hhmm.split(":");
        return Integer.parseInt(parts[0]) * 60 + Integer.parseInt(parts[1]);
    }

    public static String toHhmm(int minutes) {
        int m = ((minutes % 1440) + 1440) % 1440;
        return String.format("%02d:%02d", m / 60, m % 60);
    }

    public static BigDecimal bd(double value, int scale) {
        return BigDecimal.valueOf(value).setScale(scale, RoundingMode.HALF_UP);
    }

    static final class VehicleState {
        final Vehicle vehicle;
        double lat;
        double lon;
        int timeMin = START_OF_DAY_MIN;
        BigDecimal remainingKg;
        BigDecimal remainingM3;
        double distanceKm = 0;
        final List<AssignedStop> stops = new ArrayList<>();

        VehicleState(Vehicle vehicle, double depotLat, double depotLon) {
            this.vehicle = vehicle;
            this.lat = depotLat;
            this.lon = depotLon;
            this.remainingKg = vehicle.getCapacidadKg();
            this.remainingM3 = vehicle.getCapacidadM3();
        }

        boolean hasCapacity(Order order) {
            return remainingKg.compareTo(order.getPeso()) >= 0
                    && remainingM3.compareTo(order.getVolumen()) >= 0;
        }

        void assign(Order order, double legKm, int arrivalMin, int serviceMin) {
            distanceKm += legKm;
            lat = order.getGpsLat().doubleValue();
            lon = order.getGpsLon().doubleValue();
            timeMin = arrivalMin + serviceMin;
            remainingKg = remainingKg.subtract(order.getPeso());
            remainingM3 = remainingM3.subtract(order.getVolumen());
        }
    }

    public record AssignedStop(Vehicle vehicle, Order order, double legKm, int arrivalMin) {
    }

    public record Unassigned(UUID pedidoId, MotivoNoAsignado motivo) {
    }

    public record PlanResult(
            List<Vehicle> candidates,
            List<AssignedStop> assigned,
            List<Unassigned> unassigned,
            Map<UUID, VehicleState> states) {
    }
}
