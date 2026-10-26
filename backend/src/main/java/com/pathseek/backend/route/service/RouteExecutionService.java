package com.pathseek.backend.route.service;

import com.pathseek.backend.exception.BusinessConflictException;
import com.pathseek.backend.exception.ResourceNotFoundException;
import com.pathseek.backend.order.entity.Order;
import com.pathseek.backend.order.entity.OrderStatus;
import com.pathseek.backend.route.dto.DeliveryUpdateResponse;
import com.pathseek.backend.route.dto.PositionUpdateRequest;
import com.pathseek.backend.route.entity.DeliveryRoute;
import com.pathseek.backend.route.entity.RouteOrder;
import com.pathseek.backend.route.entity.RouteProgress;
import com.pathseek.backend.route.entity.RouteStatus;
import com.pathseek.backend.route.repository.DeliveryRouteRepository;
import com.pathseek.backend.route.repository.RouteProgressRepository;
import com.pathseek.backend.security.CurrentActor;
import com.pathseek.backend.vehicle.entity.Vehicle;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalTime;
import java.util.Comparator;
import java.util.List;
import java.util.UUID;

/**
 * Registro de ejecución del conductor (EN-008 / modo offline):
 * posición actual y entregas completadas, idempotentes para la cola de
 * sincronización del frontend. El conductor solo opera su propia ruta.
 */
@Service
public class RouteExecutionService {

    private final DeliveryRouteRepository routes;
    private final RouteProgressRepository progress;
    private final RoutingContextService context;

    public RouteExecutionService(DeliveryRouteRepository routes, RouteProgressRepository progress,
                                 RoutingContextService context) {
        this.routes = routes;
        this.progress = progress;
        this.context = context;
    }

    @Transactional
    public DeliveryUpdateResponse completeDelivery(UUID rutaId, UUID pedidoId) {
        DeliveryRoute route = loadOwn(rutaId);
        if (!active(route)) {
            throw new BusinessConflictException("ROUTE_NOT_ACTIVE", "La ruta no admite registros de ejecución");
        }
        RouteOrder stop = route.getPedidos().stream()
                .filter(s -> s.getPedido().getId().equals(pedidoId))
                .findFirst()
                .orElseThrow(() -> new ResourceNotFoundException("El pedido no pertenece a la ruta indicada"));
        Order order = stop.getPedido();
        if (order.getEstado() == OrderStatus.ENTREGADO) {
            return response(route, stop, true);
        }
        int orden = stop.getOrden();
        boolean prefixOk = route.getPedidos().stream()
                .filter(s -> s.getOrden() < orden)
                .allMatch(s -> s.getPedido().getEstado() == OrderStatus.ENTREGADO);
        if (!prefixOk) {
            throw new BusinessConflictException("ORDER_PREFIX_INCOMPLETE",
                    "Complete las entregas anteriores antes de registrar esta");
        }
        order.setEstado(OrderStatus.ENTREGADO);
        stop.setCumplioVentana(withinWindow(order, stop.getHoraEstimada()));
        if (route.getEstado() == RouteStatus.PLANIFICADA) {
            route.setEstado(RouteStatus.EN_PROGRESO);
        }
        boolean allDelivered = route.getPedidos().stream()
                .allMatch(s -> s.getPedido().getEstado() == OrderStatus.ENTREGADO);
        if (allDelivered) {
            route.setEstado(RouteStatus.COMPLETADA);
        }
        routes.save(route);
        return response(route, stop, false);
    }

    @Transactional
    public DeliveryUpdateResponse reportPosition(UUID rutaId, PositionUpdateRequest request) {
        DeliveryRoute route = loadOwn(rutaId);
        if (!active(route)) {
            throw new BusinessConflictException("ROUTE_NOT_ACTIVE", "La ruta no admite registros de ejecución");
        }
        double lat = request.lat().doubleValue();
        double lon = request.lon().doubleValue();
        int lastOrder = 0;
        double distance = 0;
        double currentLat = RoutingContextService.DEPOT_LAT;
        double currentLon = RoutingContextService.DEPOT_LON;
        List<RouteOrder> delivered = route.getPedidos().stream()
                .filter(s -> s.getPedido().getEstado() == OrderStatus.ENTREGADO)
                .sorted(Comparator.comparingInt(RouteOrder::getOrden))
                .toList();
        for (RouteOrder stop : delivered) {
            distance += context.calculateRoadDistanceKm(currentLat, currentLon,
                    stop.getPedido().getGpsLat().doubleValue(), stop.getPedido().getGpsLon().doubleValue());
            currentLat = stop.getPedido().getGpsLat().doubleValue();
            currentLon = stop.getPedido().getGpsLon().doubleValue();
            lastOrder = Math.max(lastOrder, stop.getOrden());
        }
        distance += context.calculateRoadDistanceKm(currentLat, currentLon, lat, lon);
        Vehicle vehicle = route.getVehiculo();
        double fuel = distance / vehicle.getConsumoKmL().doubleValue();
        double co2 = distance * vehicle.getFactorEmision().doubleValue();
        progress.save(new RouteProgress(rutaId, lat, lon, lastOrder, distance, fuel, co2));
        if (route.getEstado() == RouteStatus.PLANIFICADA) {
            route.setEstado(RouteStatus.EN_PROGRESO);
        }
        routes.save(route);
        return new DeliveryUpdateResponse(rutaId, null, null, route.getEstado(), null, false);
    }

    private DeliveryRoute loadOwn(UUID rutaId) {
        DeliveryRoute route = routes.findById(rutaId)
                .orElseThrow(() -> new ResourceNotFoundException("Ruta no encontrada con ID: " + rutaId));
        if (route.getConductor().getUsuarioId() == null
                || !route.getConductor().getUsuarioId().toString().equals(CurrentActor.subject())) {
            throw new AccessDeniedException("La ruta no está asignada al conductor");
        }
        return route;
    }

    private boolean active(DeliveryRoute route) {
        return route.getEstado() != RouteStatus.COMPLETADA && route.getEstado() != RouteStatus.CANCELADA;
    }

    private boolean withinWindow(Order order, LocalTime hora) {
        if (hora == null) return false;
        return !hora.isBefore(LocalTime.parse(order.getVentanaInicio()))
                && !hora.isAfter(LocalTime.parse(order.getVentanaFin()));
    }

    private DeliveryUpdateResponse response(DeliveryRoute route, RouteOrder stop, boolean already) {
        return new DeliveryUpdateResponse(route.getId(), stop.getPedido().getId(),
                stop.getPedido().getEstado(), route.getEstado(), stop.getCumplioVentana(), already);
    }
}
