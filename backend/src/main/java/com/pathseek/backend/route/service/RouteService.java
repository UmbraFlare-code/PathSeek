package com.pathseek.backend.route.service;

import com.pathseek.backend.exception.BusinessConflictException;
import com.pathseek.backend.exception.BusinessRuleException;
import com.pathseek.backend.order.entity.Order;
import com.pathseek.backend.order.entity.OrderStatus;
import com.pathseek.backend.order.repository.OrderRepository;
import com.pathseek.backend.route.dto.RouteGenerateRequest;
import com.pathseek.backend.route.dto.RouteGenerateResponse;
import com.pathseek.backend.vehicle.entity.Vehicle;
import com.pathseek.backend.vehicle.repository.VehicleRepository;
import jakarta.annotation.PreDestroy;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;
import java.util.concurrent.atomic.AtomicBoolean;

/**
 * Orquesta la generación con lock + hilo dedicado + timeout 45 s (Sprint 2).
 * {@code GET /api/v1/rutas/lock} expone si hay una generación en curso.
 */
@Service
public class RouteService {

    private static final long TIMEOUT_MS = 45_000L;

    private final VehicleRepository vehicleRepository;
    private final OrderRepository orderRepository;
    private final RouteOptimizationService optimizationService;
    private final RouteMetricsService metricsService;

    private final AtomicBoolean running = new AtomicBoolean(false);
    private final ExecutorService executor = Executors.newSingleThreadExecutor();

    public RouteService(
            VehicleRepository vehicleRepository,
            OrderRepository orderRepository,
            RouteOptimizationService optimizationService,
            RouteMetricsService metricsService) {
        this.vehicleRepository = vehicleRepository;
        this.orderRepository = orderRepository;
        this.optimizationService = optimizationService;
        this.metricsService = metricsService;
    }

    public boolean isRunning() {
        return running.get();
    }

    public RouteGenerateResponse generate(RouteGenerateRequest request) {
        if (!running.compareAndSet(false, true)) {
            throw new BusinessConflictException(
                    "ROUTE_GENERATION_BUSY",
                    "Ya existe una generación de rutas en curso; intente nuevamente");
        }
        long start = System.currentTimeMillis();
        try {
            Callable<RouteGenerateResponse> task = () -> buildPlan(request, 0L);
            Future<RouteGenerateResponse> future = executor.submit(task);
            RouteGenerateResponse withoutTiming;
            try {
                withoutTiming = future.get(TIMEOUT_MS, TimeUnit.MILLISECONDS);
            } catch (TimeoutException e) {
                future.cancel(true);
                throw new BusinessRuleException(
                        "ROUTE_TIMEOUT",
                        "La generación superó el tiempo máximo de 45 segundos");
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                throw new BusinessRuleException(
                        "ROUTE_INTERRUPTED", "La generación fue interrumpida");
            } catch (java.util.concurrent.ExecutionException e) {
                Throwable cause = e.getCause() != null ? e.getCause() : e;
                if (cause instanceof RuntimeException runtime) {
                    throw runtime;
                }
                throw new BusinessRuleException("ROUTE_ERROR", "No se pudo generar rutas");
            }
            long duration = System.currentTimeMillis() - start;
            metricsService.record(duration);
            return withDuration(withoutTiming, duration);
        } finally {
            running.set(false);
        }
    }

    private RouteGenerateResponse buildPlan(RouteGenerateRequest request, long durationMs) {
        List<Vehicle> vehicles = loadVehicles(request);
        List<Order> orders = loadOrders(request);
        if (orders.isEmpty()) {
            throw new BusinessRuleException(
                    "NO_PENDING_ORDERS",
                    "No hay pedidos pendientes para generar rutas con los filtros indicados");
        }

        RouteOptimizationService.PlanResult plan = optimizationService.optimize(
                request.fechaOperacion(),
                request.deposito().latitud().doubleValue(),
                request.deposito().longitud().doubleValue(),
                request.velocidadOrDefault(),
                request.tiempoServicioOrDefault(),
                vehicles,
                orders);

        Map<UUID, List<RouteOptimizationService.AssignedStop>> byVehicle = new java.util.HashMap<>();
        for (RouteOptimizationService.AssignedStop stop : plan.assigned()) {
            byVehicle.computeIfAbsent(stop.vehicle().getId(), k -> new ArrayList<>()).add(stop);
        }

        List<RouteGenerateResponse.VehicleRouteDto> rutas = new ArrayList<>();
        BigDecimal totalDist = BigDecimal.ZERO;
        BigDecimal totalFuel = BigDecimal.ZERO;
        BigDecimal totalCo2 = BigDecimal.ZERO;

        List<Vehicle> orderedVehicles = new ArrayList<>(plan.candidates());
        orderedVehicles.sort(Comparator.comparing(Vehicle::getPlaca));

        for (Vehicle vehicle : orderedVehicles) {
            List<RouteOptimizationService.AssignedStop> stops =
                    byVehicle.getOrDefault(vehicle.getId(), List.of());
            if (stops.isEmpty()) {
                continue;
            }
            double dist = plan.states().get(vehicle.getId()).distanceKm;
            BigDecimal distBd = RouteOptimizationService.bd(dist, 2);
            BigDecimal fuel = fuelOf(dist, vehicle);
            BigDecimal co2 = co2Of(fuel, vehicle);

            totalDist = totalDist.add(distBd);
            totalFuel = totalFuel.add(fuel);
            totalCo2 = totalCo2.add(co2);

            List<RouteGenerateResponse.StopDto> paradas = new ArrayList<>();
            for (int i = 0; i < stops.size(); i++) {
                RouteOptimizationService.AssignedStop stop = stops.get(i);
                Order order = stop.order();
                paradas.add(new RouteGenerateResponse.StopDto(
                        order.getId(),
                        i + 1,
                        RouteOptimizationService.toHhmm(stop.arrivalMin()),
                        RouteOptimizationService.bd(stop.legKm(), 2),
                        order.getGpsLat(),
                        order.getGpsLon(),
                        order.getClienteId(),
                        order.getDireccion(),
                        order.getVentanaInicio(),
                        order.getVentanaFin(),
                        order.getPeso(),
                        order.getPrioridad()));
            }
            rutas.add(new RouteGenerateResponse.VehicleRouteDto(
                    vehicle.getId(), vehicle.getPlaca(), distBd, fuel, co2, paradas));
        }

        Map<UUID, Order> ordersById = new java.util.HashMap<>();
        for (Order o : orders) {
            ordersById.put(o.getId(), o);
        }
        List<RouteGenerateResponse.UnassignedDto> noAsignados = plan.unassigned().stream()
                .map(u -> {
                    Order order = ordersById.get(u.pedidoId());
                    return new RouteGenerateResponse.UnassignedDto(
                            u.pedidoId(),
                            u.motivo(),
                            order != null ? order.getClienteId() : null,
                            order != null ? order.getDireccion() : null,
                            order != null ? order.getVentanaInicio() : null,
                            order != null ? order.getVentanaFin() : null,
                            suggestionFor(u.motivo()));
                })
                .toList();

        int total = orders.size();
        int assignedCount = plan.assigned().size();
        BigDecimal cumplimiento = total == 0 ? BigDecimal.valueOf(100).setScale(2)
                : BigDecimal.valueOf(assignedCount * 100.0 / total)
                        .setScale(2, java.math.RoundingMode.HALF_UP);

        RouteGenerateResponse.MetricsDto metricas = new RouteGenerateResponse.MetricsDto(
                totalDist.setScale(2, java.math.RoundingMode.HALF_UP),
                totalFuel.setScale(2, java.math.RoundingMode.HALF_UP),
                totalCo2.setScale(2, java.math.RoundingMode.HALF_UP),
                cumplimiento,
                assignedCount,
                noAsignados.size(),
                BigDecimal.valueOf(noAsignados.size()));

        return new RouteGenerateResponse(
                UUID.randomUUID(),
                request.fechaOperacion(),
                durationMs,
                new RouteGenerateResponse.DepositoDto(
                        request.deposito().latitud(), request.deposito().longitud()),
                metricas,
                rutas,
                noAsignados);
    }

    private RouteGenerateResponse withDuration(RouteGenerateResponse base, long durationMs) {
        return new RouteGenerateResponse(
                base.rutaId(), base.fechaOperacion(), durationMs, base.deposito(),
                base.metricas(), base.rutas(), base.noAsignados());
    }

    /**
     * Confirma un plan generado: los pedidos PENDIENTE pasan a EN_RUTA.
     * Sin este paso, generar dos veces planifica lo mismo (cálculo en memoria).
     */
    @Transactional
    public java.util.Map<String, Object> confirm(List<UUID> pedidoIds) {
        if (pedidoIds == null || pedidoIds.isEmpty()) {
            throw new BusinessRuleException(
                    "INVALID_CONFIRM", "Debe enviar al menos un pedido a confirmar");
        }
        List<Order> found = orderRepository.findAllById(pedidoIds);
        int confirmados = 0;
        for (Order order : found) {
            if (order.getEstado() == OrderStatus.PENDIENTE) {
                order.setEstado(OrderStatus.EN_RUTA);
                order.setMotivoNoAsignado(null);
                confirmados++;
            }
        }
        orderRepository.saveAll(found);
        int omitidos = pedidoIds.size() - confirmados;
        return java.util.Map.of("confirmados", confirmados, "omitidos", Math.max(omitidos, 0));
    }

    private List<Vehicle> loadVehicles(RouteGenerateRequest request) {        List<Vehicle> all = vehicleRepository.findAll();
        if (request.vehiculoIds() == null || request.vehiculoIds().isEmpty()) {
            return all;
        }
        Set<UUID> wanted = new HashSet<>(request.vehiculoIds());
        return all.stream().filter(v -> wanted.contains(v.getId())).toList();
    }

    private List<Order> loadOrders(RouteGenerateRequest request) {
        List<Order> all = orderRepository.findAll();
        List<Order> pending = all.stream()
                .filter(o -> o.getEstado() == OrderStatus.PENDIENTE)
                .toList();
        if (request.pedidoIds() == null || request.pedidoIds().isEmpty()) {
            return pending;
        }
        Set<UUID> wanted = new HashSet<>(request.pedidoIds());
        return pending.stream().filter(o -> wanted.contains(o.getId())).toList();
    }

    private String suggestionFor(com.pathseek.backend.order.entity.MotivoNoAsignado motivo) {
        if (motivo == null) {
            return "Revisar datos del pedido y reintentar";
        }
        return switch (motivo) {
            case VENTANA_INALCANZABLE ->
                "Reprogramar la ventana de entrega o agregar un vehículo más cercano al punto";
            case CAPACIDAD ->
                "Fraccionar el pedido o usar un vehículo de mayor capacidad (kg/m³)";
            case RESTRICCION_PLACA ->
                "Reasignar a otro día o usar un vehículo sin restricción de placa ese día";
        };
    }

    private BigDecimal fuelOf(double distanceKm, Vehicle vehicle) {        double consumo = vehicle.getConsumoKmL().doubleValue();
        if (consumo <= 0) {
            return BigDecimal.ZERO.setScale(2);
        }
        return RouteOptimizationService.bd(distanceKm / consumo, 2);
    }

    private BigDecimal co2Of(BigDecimal fuelLiters, Vehicle vehicle) {
        double factor = vehicle.getFactorEmision().doubleValue();
        return fuelLiters.multiply(BigDecimal.valueOf(factor))
                .setScale(2, java.math.RoundingMode.HALF_UP);
    }

    @PreDestroy
    void shutdown() {
        executor.shutdownNow();
    }
}
