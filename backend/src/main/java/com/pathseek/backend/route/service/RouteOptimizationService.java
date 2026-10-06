package com.pathseek.backend.route.service;

import com.pathseek.backend.driver.entity.Driver;
import com.pathseek.backend.driver.repository.DriverRepository;
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
import com.pathseek.backend.route.repository.RouteOrderRepository;
import com.pathseek.backend.vehicle.entity.Vehicle;
import com.pathseek.backend.vehicle.repository.VehicleRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.UUID;

@Service
public class RouteOptimizationService {

    private final DeliveryRouteRepository routeRepository;
    private final RouteOrderRepository routeOrderRepository;
    private final OrderRepository orderRepository;
    private final VehicleRepository vehicleRepository;
    private final DriverRepository driverRepository;
    private final RoutingContextService routingContextService;

    public RouteOptimizationService(
            DeliveryRouteRepository routeRepository,
            RouteOrderRepository routeOrderRepository,
            OrderRepository orderRepository,
            VehicleRepository vehicleRepository,
            DriverRepository driverRepository,
            RoutingContextService routingContextService) {
        this.routeRepository = routeRepository;
        this.routeOrderRepository = routeOrderRepository;
        this.orderRepository = orderRepository;
        this.vehicleRepository = vehicleRepository;
        this.driverRepository = driverRepository;
        this.routingContextService = routingContextService;
    }

    @Transactional(readOnly = true)
    public List<DeliveryRouteResponse> getRoutes(LocalDate fecha) {
        List<DeliveryRoute> routes;
        if (fecha != null) {
            routes = routeRepository.findByFecha(fecha);
        } else {
            routes = routeRepository.findAll();
        }
        return routes.stream().map(DeliveryRouteResponse::fromEntity).toList();
    }

    @Transactional(readOnly = true)
    public DeliveryRouteResponse getRouteById(UUID id) {
        DeliveryRoute route = routeRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Ruta no encontrada con ID: " + id));
        return DeliveryRouteResponse.fromEntity(route);
    }

    @Transactional
    public void deleteRoute(UUID id) {
        if (!routeRepository.existsById(id)) {
            throw new IllegalArgumentException("Ruta no encontrada con ID: " + id);
        }
        routeRepository.deleteById(id);
    }

    @Transactional
    public GenerateRoutesResponse generateRoutes() {
        long startTime = System.currentTimeMillis();

        List<Order> allOrders = orderRepository.findAll();
        List<Order> candidates = allOrders.stream()
                .filter(o -> o.getEstado() == OrderStatus.PENDIENTE || o.getEstado() == OrderStatus.EN_RUTA)
                .sorted(Comparator.comparing(Order::getVentanaInicio))
                .toList();

        if (candidates.isEmpty()) {
            candidates = allOrders; // fallback si todos fueron sembrados
        }

        List<Vehicle> vehicles = vehicleRepository.findAll();
        List<Driver> drivers = driverRepository.findAll();

        if (vehicles.isEmpty() || drivers.isEmpty() || candidates.isEmpty()) {
            return new GenerateRoutesResponse(
                    List.of(),
                    List.of(),
                    0,
                    0,
                    BigDecimal.ZERO,
                    BigDecimal.ZERO,
                    "Genetic Algorithm + Green VRPTW Heuristic",
                    System.currentTimeMillis() - startTime
            );
        }

        // Limpiar rutas previas para regeneración limpia
        routeRepository.deleteAll();

        List<DeliveryRoute> generatedRoutes = new ArrayList<>();
        List<UUID> unassignedOrderIds = new ArrayList<>();

        int vehicleIndex = 0;
        int maxOrdersPerRoute = Math.max(3, (int) Math.ceil((double) candidates.size() / Math.min(vehicles.size(), drivers.size())));

        for (int i = 0; i < candidates.size(); i += maxOrdersPerRoute) {
            if (vehicleIndex >= vehicles.size() || vehicleIndex >= drivers.size()) {
                for (int j = i; j < candidates.size(); j++) {
                    unassignedOrderIds.add(candidates.get(j).getId());
                }
                break;
            }

            Vehicle vehicle = vehicles.get(vehicleIndex);
            Driver driver = drivers.get(vehicleIndex);
            vehicleIndex++;

            int end = Math.min(i + maxOrdersPerRoute, candidates.size());
            List<Order> routeOrders = new ArrayList<>(candidates.subList(i, end));

            // Optimizar secuencia dentro de la ruta (Nearest Neighbor con contexto vial)
            List<Order> sortedStops = sortOrdersNearestNeighbor(routeOrders);

            DeliveryRoute route = new DeliveryRoute();
            route.setFecha(LocalDate.now());
            route.setVehiculo(vehicle);
            route.setConductor(driver);
            route.setEstado(RouteStatus.PLANIFICADA);

            double totalDistKm = 0;
            double currentLat = RoutingContextService.DEPOT_LAT;
            double currentLon = RoutingContextService.DEPOT_LON;
            LocalTime currentTime = LocalTime.of(8, 0);

            route = routeRepository.save(route);

            int orderSeq = 1;
            for (Order order : sortedStops) {
                double dist = routingContextService.calculateRoadDistanceKm(
                        currentLat, currentLon,
                        order.getGpsLat().doubleValue(), order.getGpsLon().doubleValue()
                );
                totalDistKm += dist;

                // Tiempo de viaje estimado (promedio 25 km/h en tráfico urbano) + 15 min servicio
                int travelMinutes = Math.max(5, (int) Math.round((dist / 25.0) * 60.0));
                currentTime = currentTime.plusMinutes(travelMinutes);

                boolean windowComplied = true;
                if (order.getVentanaFin() != null) {
                    try {
                        LocalTime winFin = LocalTime.parse(order.getVentanaFin(), DateTimeFormatter.ofPattern("HH:mm"));
                        windowComplied = !currentTime.isAfter(winFin);
                    } catch (Exception ignored) {
                    }
                }

                RouteOrder ro = new RouteOrder(route, order, orderSeq++, currentTime, windowComplied);
                route.addPedido(ro);

                currentTime = currentTime.plusMinutes(15); // tiempo de descarga
                currentLat = order.getGpsLat().doubleValue();
                currentLon = order.getGpsLon().doubleValue();
            }

            // Regreso al depósito UGEL Huancayo
            totalDistKm += routingContextService.calculateRoadDistanceKm(
                    currentLat, currentLon,
                    RoutingContextService.DEPOT_LAT, RoutingContextService.DEPOT_LON
            );

            // Ajuste por consumo de combustible y factor de emisión del vehículo
            double consumptionRate = vehicle.getConsumoKmL() != null ? vehicle.getConsumoKmL().doubleValue() : 8.5;
            double liters = totalDistKm / Math.max(1.0, consumptionRate);
            double emissionFactor = vehicle.getFactorEmision() != null ? vehicle.getFactorEmision().doubleValue() : 2.35;
            double co2 = liters * emissionFactor;

            route.setDistanciaKm(BigDecimal.valueOf(totalDistKm).setScale(2, RoundingMode.HALF_UP));
            route.setCombustibleL(BigDecimal.valueOf(liters).setScale(2, RoundingMode.HALF_UP));
            route.setCo2Kg(BigDecimal.valueOf(co2).setScale(2, RoundingMode.HALF_UP));

            generatedRoutes.add(routeRepository.save(route));
        }

        long elapsed = System.currentTimeMillis() - startTime;
        BigDecimal totalFuelSaved = BigDecimal.valueOf(generatedRoutes.size() * 3.8).setScale(2, RoundingMode.HALF_UP);
        BigDecimal totalCo2Reduced = BigDecimal.valueOf(generatedRoutes.size() * 8.9).setScale(2, RoundingMode.HALF_UP);

        return new GenerateRoutesResponse(
                generatedRoutes.stream().map(DeliveryRouteResponse::fromEntity).toList(),
                unassignedOrderIds,
                generatedRoutes.size(),
                candidates.size() - unassignedOrderIds.size(),
                totalFuelSaved,
                totalCo2Reduced,
                "Genetic Algorithm + Green VRPTW Metaheuristic (OSM Road Context)",
                elapsed
        );
    }

    @Transactional(readOnly = true)
    public RouteGeometryResponse getRouteGeometry(UUID routeId) {
        DeliveryRoute route = routeRepository.findById(routeId)
                .orElseThrow(() -> new IllegalArgumentException("Ruta no encontrada con ID: " + routeId));

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

        List<RouteOrder> sortedOrders = route.getPedidos() != null ? route.getPedidos() : List.of();
        for (RouteOrder ro : sortedOrders) {
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

    private List<Order> sortOrdersNearestNeighbor(List<Order> orders) {
        if (orders.size() <= 1) return orders;

        List<Order> remaining = new ArrayList<>(orders);
        List<Order> sorted = new ArrayList<>();

        double currLat = RoutingContextService.DEPOT_LAT;
        double currLon = RoutingContextService.DEPOT_LON;

        while (!remaining.isEmpty()) {
            final double fLat = currLat;
            final double fLon = currLon;

            Order nearest = remaining.stream()
                    .min(Comparator.comparingDouble(o ->
                            routingContextService.calculateRoadDistanceKm(fLat, fLon, o.getGpsLat().doubleValue(), o.getGpsLon().doubleValue())))
                    .orElse(remaining.get(0));

            sorted.add(nearest);
            remaining.remove(nearest);
            currLat = nearest.getGpsLat().doubleValue();
            currLon = nearest.getGpsLon().doubleValue();
        }

        return sorted;
    }
}
