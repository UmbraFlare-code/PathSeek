package com.pathseek.backend.route.service;

import com.pathseek.backend.driver.entity.Driver;
import com.pathseek.backend.driver.repository.DriverRepository;
import com.pathseek.backend.exception.ResourceNotFoundException;
import com.pathseek.backend.exception.BusinessConflictException;
import com.pathseek.backend.security.CurrentActor;
import org.springframework.security.access.AccessDeniedException;
import com.pathseek.backend.order.entity.Order;
import com.pathseek.backend.order.entity.OrderStatus;
import com.pathseek.backend.order.repository.OrderRepository;
import com.pathseek.backend.route.dto.DeliveryRouteResponse;
import com.pathseek.backend.route.dto.GenerateRoutesResponse;
import com.pathseek.backend.route.dto.RouteGeometryResponse;
import com.pathseek.backend.route.entity.DeliveryRoute;
import com.pathseek.backend.route.entity.RouteOrder;
import com.pathseek.backend.route.entity.RouteStatus;
import com.pathseek.backend.route.repository.DeliveryRouteRepository;
import com.pathseek.backend.vehicle.entity.Vehicle;
import com.pathseek.backend.vehicle.repository.VehicleRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.Clock;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.UUID;
import java.util.HashSet;
import java.util.Set;

@Service
public class RouteOptimizationService {

    private final DeliveryRouteRepository routeRepository;
    private final OrderRepository orderRepository;
    private final VehicleRepository vehicleRepository;
    private final DriverRepository driverRepository;
    private final RoutingContextService routingContextService;
    private final Clock clock;
    private final RouteSequenceOptimizer sequenceOptimizer;
    private final com.pathseek.backend.route.repository.VehicleBreakdownRepository breakdowns;
    private final com.pathseek.backend.route.repository.RouteProgressRepository progress;

    public RouteOptimizationService(
            DeliveryRouteRepository routeRepository,
            OrderRepository orderRepository,
            VehicleRepository vehicleRepository,
            DriverRepository driverRepository,
            RoutingContextService routingContextService,
            Clock clock, RouteSequenceOptimizer sequenceOptimizer,
            com.pathseek.backend.route.repository.VehicleBreakdownRepository breakdowns,
            com.pathseek.backend.route.repository.RouteProgressRepository progress) {
        this.routeRepository = routeRepository;
        this.orderRepository = orderRepository;
        this.vehicleRepository = vehicleRepository;
        this.driverRepository = driverRepository;
        this.routingContextService = routingContextService;
        this.clock = clock;
        this.sequenceOptimizer = sequenceOptimizer;
        this.breakdowns = breakdowns;
        this.progress = progress;
    }

    @Transactional(readOnly = true)
    public List<DeliveryRouteResponse> getRoutes(LocalDate fecha) {
        List<DeliveryRoute> routes;
        if (fecha != null) {
            routes = routeRepository.findByFecha(fecha);
        } else {
            routes = routeRepository.findAll();
        }
        return routes.stream().filter(this::canRead).map(DeliveryRouteResponse::fromEntity).toList();
    }

    @Transactional(readOnly = true)
    public DeliveryRouteResponse getRouteById(UUID id) {
        DeliveryRoute route = routeRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Ruta no encontrada con ID: " + id));
        if (!canRead(route)) throw new AccessDeniedException("La ruta no está asignada al conductor");
        return DeliveryRouteResponse.fromEntity(route);
    }

    @Transactional
    public void deleteRoute(UUID id) {
        // Same lock order as generation, so a resource cannot be reused before deletion commits.
        vehicleRepository.lockForPlanning();
        DeliveryRoute route = routeRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Ruta no encontrada con ID: " + id));
        if (route.getEstado() != RouteStatus.PLANIFICADA) {
            throw new BusinessConflictException("ROUTE_NOT_DELETABLE", "Solo se pueden eliminar rutas planificadas");
        }
        for (RouteOrder stop : route.getPedidos()) {
            if (stop.getPedido().getEstado() == OrderStatus.EN_RUTA) {
                stop.getPedido().setEstado(OrderStatus.PENDIENTE);
            }
        }
        routeRepository.delete(route);
    }

    @Transactional
    public GenerateRoutesResponse generateRoutes() {
        long startTime = System.currentTimeMillis();
        // Serialize planners across backend instances before reading assignments.
        List<Vehicle> allVehicles = vehicleRepository.lockForPlanning();
        List<DeliveryRoute> activeRoutes = routeRepository.findByEstadoIn(
                List.of(RouteStatus.PLANIFICADA, RouteStatus.EN_PROGRESO));
        Set<UUID> busyVehicles = new HashSet<>();
        Set<UUID> busyDrivers = new HashSet<>();
        Set<UUID> assignedOrders = new HashSet<>();
        for (DeliveryRoute route : activeRoutes) {
            busyVehicles.add(route.getVehiculo().getId());
            busyDrivers.add(route.getConductor().getId());
            route.getPedidos().forEach(stop -> assignedOrders.add(stop.getPedido().getId()));
        }
        List<Order> remaining = new ArrayList<>(orderRepository.lockByEstado(OrderStatus.PENDIENTE).stream()
                .filter(order -> !assignedOrders.contains(order.getId())).toList());
        int candidateCount = remaining.size();
        Set<UUID> unavailableVehicles = new HashSet<>(breakdowns.findActiveVehicleIds());
        List<Vehicle> vehicles = allVehicles.stream()
                .filter(vehicle -> !busyVehicles.contains(vehicle.getId()))
                .filter(vehicle -> !unavailableVehicles.contains(vehicle.getId())).toList();
        List<Driver> drivers = driverRepository.findAll().stream()
                .filter(driver -> Boolean.TRUE.equals(driver.getDisponible()))
                .filter(driver -> !busyDrivers.contains(driver.getId()))
                .sorted(Comparator.comparing(Driver::getId)).toList();
        List<DeliveryRoute> generatedRoutes = new ArrayList<>();
        LocalDate date = LocalDate.now(clock.withZone(ZoneId.of("America/Lima")));
        int driverIndex = 0;

        for (Vehicle vehicle : vehicles) {
            if (remaining.isEmpty() || driverIndex >= drivers.size()) break;
            DeliveryRoute route = null;
            BigDecimal weight = BigDecimal.ZERO;
            BigDecimal volume = BigDecimal.ZERO;
            double totalDistKm = 0;
            double currentLat = RoutingContextService.DEPOT_LAT;
            double currentLon = RoutingContextService.DEPOT_LON;
            LocalDateTime currentTime = date.atTime(8, 0);

            while (!remaining.isEmpty()) {
                Order selected = null;
                LocalDateTime selectedArrival = null;
                double selectedDistance = 0;
                for (Order order : remaining) {
                    if (weight.add(order.getPeso()).compareTo(vehicle.getCapacidadKg()) > 0
                            || volume.add(order.getVolumen()).compareTo(vehicle.getCapacidadM3()) > 0) continue;
                    double distance = routingContextService.calculateRoadDistanceKm(
                            currentLat, currentLon, order.getGpsLat().doubleValue(), order.getGpsLon().doubleValue());
                    LocalDateTime arrival = currentTime.plusMinutes(travelMinutes(distance));
                    LocalDateTime windowStart = date.atTime(LocalTime.parse(order.getVentanaInicio()));
                    LocalDateTime windowEnd = date.atTime(LocalTime.parse(order.getVentanaFin()));
                    if (arrival.isBefore(windowStart)) arrival = windowStart;
                    if (arrival.isAfter(windowEnd)) continue;
                    if (selected == null || order.getPrioridad().compareTo(selected.getPrioridad()) < 0
                            || (order.getPrioridad() == selected.getPrioridad() && distance < selectedDistance)) {
                        selected = order;
                        selectedArrival = arrival;
                        selectedDistance = distance;
                    }
                }
                if (selected == null) break;
                if (route == null) {
                    route = new DeliveryRoute();
                    route.setFecha(date);
                    route.setVehiculo(vehicle);
                    route.setConductor(drivers.get(driverIndex++));
                    route.setEstado(RouteStatus.PLANIFICADA);
                    route = routeRepository.save(route);
                }
                route.addPedido(new RouteOrder(route, selected, route.getPedidos().size() + 1,
                        selectedArrival.toLocalTime(), true));
                selected.setEstado(OrderStatus.EN_RUTA);
                remaining.remove(selected);
                weight = weight.add(selected.getPeso());
                volume = volume.add(selected.getVolumen());
                totalDistKm += selectedDistance;
                currentTime = selectedArrival.plusMinutes(RoutePlanningPolicy.SERVICE_MINUTES);
                currentLat = selected.getGpsLat().doubleValue();
                currentLon = selected.getGpsLon().doubleValue();
            }
            if (route != null) {
                var optimized = sequenceOptimizer.improve(route.getPedidos().stream().map(RouteOrder::getPedido).toList());
                currentLat = RoutingContextService.DEPOT_LAT;
                currentLon = RoutingContextService.DEPOT_LON;
                currentTime = date.atTime(8, 0);
                totalDistKm = 0;
                int position = 0;
                for (Order order : optimized) {
                    double leg = routingContextService.calculateRoadDistanceKm(currentLat, currentLon,
                            order.getGpsLat().doubleValue(), order.getGpsLon().doubleValue());
                    totalDistKm += leg;
                    currentTime = currentTime.plusMinutes(travelMinutes(leg));
                    LocalDateTime start = date.atTime(LocalTime.parse(order.getVentanaInicio()));
                    if (currentTime.isBefore(start)) currentTime = start;
                    RouteOrder stop = route.getPedidos().stream().filter(s -> s.getPedido().getId().equals(order.getId())).findFirst().orElseThrow();
                    stop.setOrden(++position);
                    stop.setHoraEstimada(currentTime.toLocalTime());
                    currentTime = currentTime.plusMinutes(RoutePlanningPolicy.SERVICE_MINUTES);
                    currentLat = order.getGpsLat().doubleValue(); currentLon = order.getGpsLon().doubleValue();
                }
                route.getPedidos().sort(Comparator.comparing(RouteOrder::getOrden));
                totalDistKm += routingContextService.calculateRoadDistanceKm(currentLat, currentLon,
                        RoutingContextService.DEPOT_LAT, RoutingContextService.DEPOT_LON);
                double liters = totalDistKm / vehicle.getConsumoKmL().doubleValue();
                route.setDistanciaKm(BigDecimal.valueOf(totalDistKm).setScale(2, RoundingMode.HALF_UP));
                route.setCombustibleL(BigDecimal.valueOf(liters).setScale(2, RoundingMode.HALF_UP));
                route.setCo2Kg(BigDecimal.valueOf(totalDistKm * vehicle.getFactorEmision().doubleValue())
                        .setScale(2, RoundingMode.HALF_UP));
                generatedRoutes.add(routeRepository.save(route));
            }
        }
        return new GenerateRoutesResponse(
                generatedRoutes.stream().map(DeliveryRouteResponse::fromEntity).toList(),
                remaining.stream().map(Order::getId).toList(), generatedRoutes.size(),
                candidateCount - remaining.size(), BigDecimal.ZERO, BigDecimal.ZERO,
                "Simulated annealing + feasible nearest-neighbor (estimated road distances)",
                System.currentTimeMillis() - startTime);
    }

    private int travelMinutes(double distanceKm) {
        return RoutePlanningPolicy.travelMinutes(distanceKm);
    }

    private boolean canRead(DeliveryRoute route) {
        return !CurrentActor.hasRole("CONDUCTOR") ||
                (route.getConductor().getUsuarioId() != null &&
                 route.getConductor().getUsuarioId().toString().equals(CurrentActor.subject()));
    }

    @Transactional(readOnly = true)
    public RouteGeometryResponse getRouteGeometry(UUID routeId) {
        DeliveryRoute route = routeRepository.findById(routeId)
                .orElseThrow(() -> new ResourceNotFoundException("Ruta no encontrada con ID: " + routeId));

        if (!canRead(route)) throw new AccessDeniedException("La ruta no está asignada al conductor");
        List<double[]> points = new ArrayList<>();
        List<RouteGeometryResponse.WaypointDto> waypoints = new ArrayList<>();
        List<RouteGeometryResponse.ElevationPointDto> elevationProfile = new ArrayList<>();

        // 1. Depósito Inicial
        points.add(new double[]{RoutingContextService.DEPOT_LAT, RoutingContextService.DEPOT_LON});
        waypoints.add(new RouteGeometryResponse.WaypointDto(
                0,
                "DEPOSITO",
                "Almacén Central UGEL Huancayo (Atalaya 1280)",
                BigDecimal.valueOf(RoutingContextService.DEPOT_LAT),
                BigDecimal.valueOf(RoutingContextService.DEPOT_LON),
                "08:00"
        ));
        elevationProfile.add(new RouteGeometryResponse.ElevationPointDto(
                BigDecimal.ZERO,
                RoutingContextService.DEPOT_ELEVATION_M,
                "ASFALTO"
        ));

        double accumulatedKm = 0;
        double lastLat = RoutingContextService.DEPOT_LAT;
        double lastLon = RoutingContextService.DEPOT_LON;

        var anchor = progress.findById(routeId).orElse(null);
        boolean anchorAdded = false;
        List<RouteOrder> sortedOrders = route.getPedidos() != null ? route.getPedidos() : List.of();
        for (RouteOrder ro : sortedOrders) {
            if (anchor != null && !anchorAdded && ro.getOrden() > anchor.lastOrder()) {
                accumulatedKm += appendAnchor(anchor, lastLat, lastLon, points, waypoints);
                lastLat = anchor.lat(); lastLon = anchor.lon(); anchorAdded = true;
            }
            Order order = ro.getPedido();
            if (order != null && order.getGpsLat() != null && order.getGpsLon() != null) {
                double lat = order.getGpsLat().doubleValue();
                double lon = order.getGpsLon().doubleValue();

                // Puntos interpolados para suavizar la polilínea sobre calles
                double midLat = (lastLat + lat) / 2.0;
                double midLon = (lastLon + lon) / 2.0;
                points.add(new double[]{midLat, midLon});
                points.add(new double[]{lat, lon});

                double segmentKm = routingContextService.calculateRoadDistanceKm(lastLat, lastLon, lat, lon);
                accumulatedKm += segmentKm;

                String hora = ro.getHoraEstimada() != null ? ro.getHoraEstimada().format(DateTimeFormatter.ofPattern("HH:mm")) : "09:00";
                waypoints.add(new RouteGeometryResponse.WaypointDto(
                        ro.getOrden(),
                        "ENTREGA",
                        order.getDireccion() != null ? order.getDireccion() : "I.E. Entrega #" + ro.getOrden(),
                        order.getGpsLat(),
                        order.getGpsLon(),
                        hora
                ));

                int elev = (int) Math.round(RoutingContextService.DEPOT_ELEVATION_M + (Math.abs(lat - RoutingContextService.DEPOT_LAT) * 1500));
                String calzada = (lat < -12.09 || lon < -75.24) ? "AFIRMADO" : "ASFALTO";
                elevationProfile.add(new RouteGeometryResponse.ElevationPointDto(
                        BigDecimal.valueOf(accumulatedKm).setScale(2, RoundingMode.HALF_UP),
                        elev,
                        calzada
                ));

                lastLat = lat;
                lastLon = lon;
            }
        }

        // Regreso al depósito
        if (anchor != null && !anchorAdded) {
            accumulatedKm += appendAnchor(anchor, lastLat, lastLon, points, waypoints);
            lastLat = anchor.lat(); lastLon = anchor.lon();
        }
        points.add(new double[]{RoutingContextService.DEPOT_LAT, RoutingContextService.DEPOT_LON});
        accumulatedKm += routingContextService.calculateRoadDistanceKm(lastLat, lastLon, RoutingContextService.DEPOT_LAT, RoutingContextService.DEPOT_LON);
        elevationProfile.add(new RouteGeometryResponse.ElevationPointDto(
                BigDecimal.valueOf(accumulatedKm).setScale(2, RoundingMode.HALF_UP),
                RoutingContextService.DEPOT_ELEVATION_M,
                "ASFALTO"
        ));

        String encoded = routingContextService.encodeCoordinates(points);

        return new RouteGeometryResponse(
                route.getId(),
                encoded,
                waypoints,
                elevationProfile,
                "FLUIDO_CON_CONGESTION_MODERADA_CENTRO",
                route.getDistanciaKm(),
                (int) Math.round((route.getDistanciaKm().doubleValue() / 22.0) * 60) + (sortedOrders.size() * 15)
        );
    }

    private double appendAnchor(com.pathseek.backend.route.entity.RouteProgress anchor, double lat, double lon,
            List<double[]> points, List<RouteGeometryResponse.WaypointDto> waypoints) {
        points.add(new double[]{anchor.lat(), anchor.lon()});
        waypoints.add(new RouteGeometryResponse.WaypointDto(0, "POSICION_ACTUAL", "Última posición proporcionada (sin seguimiento en vivo)",
                BigDecimal.valueOf(anchor.lat()), BigDecimal.valueOf(anchor.lon()), null));
        return routingContextService.calculateRoadDistanceKm(lat, lon, anchor.lat(), anchor.lon());
    }

}
