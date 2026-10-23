package com.pathseek.backend.route.service;

import com.pathseek.backend.exception.ResourceNotFoundException;
import com.pathseek.backend.route.entity.RouteNotification;
import com.pathseek.backend.route.repository.*;
import com.pathseek.backend.security.CurrentActor;
import com.pathseek.backend.vehicle.repository.VehicleRepository;
import org.springframework.data.domain.PageRequest;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.Clock;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

@Service
public class RouteEventInboxService {
    private final RouteNotificationRepository notifications;
    private final RoadIncidentRepository incidents;
    private final VehicleBreakdownRepository breakdowns;
    private final VehicleRepository vehicles;
    private final DeliveryRouteRepository routes;
    private final Clock clock;
    public RouteEventInboxService(RouteNotificationRepository notifications, RoadIncidentRepository incidents,
            VehicleBreakdownRepository breakdowns, VehicleRepository vehicles, DeliveryRouteRepository routes, Clock clock) {
        this.notifications = notifications; this.incidents = incidents; this.breakdowns = breakdowns; this.vehicles = vehicles; this.clock = clock;
        this.routes = routes;
    }
    @Transactional(readOnly = true)
    public List<RouteNotification.View> notifications(int page) {
        if (page < 0) throw new com.pathseek.backend.exception.BusinessRuleException("INVALID_PAGE", "La página no puede ser negativa.");
        var pagination = PageRequest.of(page, 100);
        var items = CurrentActor.hasRole("CONDUCTOR")
                ? notifications.findByUserIdOrderByCreatedAtDesc(UUID.fromString(CurrentActor.subject()), pagination)
                : notifications.findAllByOrderByCreatedAtDesc(pagination);
        return items.stream().map(RouteNotification::toView).toList();
    }
    @Transactional
    public void markRead(UUID id) {
        var notification = notifications.findById(id).orElseThrow(() -> new ResourceNotFoundException("Notificación no encontrada"));
        if (notification.recipient() == null || !notification.recipient().toString().equals(CurrentActor.subject())) throw new AccessDeniedException("La notificación pertenece a otro conductor");
        notification.markRead();
    }
    @Transactional
    public void resolveIncident(UUID routeId, UUID incidentId) {
        var locked = vehicles.lockPlanningSubset(routes.findVehicleIds(List.of(routeId)));
        var selected = routes.lockPlanningRoutes(List.of(routeId));
        if (selected.isEmpty()) throw new ResourceNotFoundException("Ruta no encontrada");
        if (locked.stream().noneMatch(vehicle -> vehicle.getId().equals(selected.get(0).getVehiculo().getId()))) {
            throw new com.pathseek.backend.exception.BusinessConflictException("PLANNING_CHANGED", "La ruta cambió; reintente.");
        }
        var incident = incidents.findById(incidentId).orElseThrow(() -> new ResourceNotFoundException("Incidente no encontrado"));
        if (!incident.getRouteId().equals(routeId)) throw new ResourceNotFoundException("Incidente no encontrado en la ruta");
        incident.resolve();
    }
    @Transactional
    public void reportBreakdown(UUID vehicleId) {
        if (vehicles.lockPlanningSubset(List.of(vehicleId)).isEmpty()) throw new ResourceNotFoundException("Vehículo no encontrado");
        breakdowns.save(new com.pathseek.backend.route.entity.VehicleBreakdown(vehicleId, OffsetDateTime.now(clock)));
    }
    @Transactional
    public void resolveBreakdown(UUID vehicleId) {
        if (vehicles.lockPlanningSubset(List.of(vehicleId)).isEmpty()) throw new ResourceNotFoundException("Vehículo no encontrado");
        breakdowns.findById(vehicleId).ifPresent(breakdown -> breakdown.resolve(OffsetDateTime.now(clock)));
    }
}
