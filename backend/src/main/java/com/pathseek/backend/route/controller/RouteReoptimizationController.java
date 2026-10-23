package com.pathseek.backend.route.controller;

import com.pathseek.backend.route.dto.*;
import com.pathseek.backend.route.entity.RouteNotification;
import com.pathseek.backend.route.service.*;
import com.pathseek.backend.route.repository.RoadIncidentRepository;
import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.Operation;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/rutas")
public class RouteReoptimizationController {
    private final RouteReoptimizationService service;
    private final RouteEventInboxService inbox;
    private final RouteOptimizationService routes;
    private final RoadIncidentRepository incidents;
    public RouteReoptimizationController(RouteReoptimizationService service, RouteEventInboxService inbox,
            RouteOptimizationService routes, RoadIncidentRepository incidents) {
        this.service = service; this.inbox = inbox; this.routes = routes; this.incidents = incidents;
    }
    @PostMapping("/reoptimizar")
    @Operation(summary = "Reoptimizar incrementalmente las rutas afectadas", description = "Evento idempotente; preserva entregas realizadas. Distancias y exclusión geométrica estimadas, sin red vial.")
    public ReoptimizationResponse reoptimize(@Valid @RequestBody ReoptimizationRequest request) { return service.reoptimize(request); }
    @GetMapping("/notificaciones")
    public List<RouteNotification.View> notifications(@RequestParam(defaultValue = "0") int pagina) { return inbox.notifications(pagina); }
    @PostMapping("/notificaciones/{id}/leida")
    public ResponseEntity<Void> read(@PathVariable UUID id) { inbox.markRead(id); return ResponseEntity.noContent().build(); }
    @GetMapping("/{id}/incidentes")
    public List<IncidentView> incidents(@PathVariable UUID id) {
        routes.getRouteById(id);
        return incidents.findByRuta_IdAndActivaTrue(id).stream().map(incident -> new IncidentView(incident.getId(), incident.toRequest())).toList();
    }
    @PostMapping("/{id}/incidentes/{incidentId}/resolver")
    public ResponseEntity<Void> resolveIncident(@PathVariable UUID id, @PathVariable UUID incidentId) {
        inbox.resolveIncident(id, incidentId); return ResponseEntity.noContent().build();
    }
    @PostMapping("/averias/{vehicleId}/resolver")
    public ResponseEntity<Void> resolveBreakdown(@PathVariable UUID vehicleId) {
        inbox.resolveBreakdown(vehicleId); return ResponseEntity.noContent().build();
    }
    @PostMapping("/averias/{vehicleId}")
    public ResponseEntity<Void> reportBreakdown(@PathVariable UUID vehicleId) {
        inbox.reportBreakdown(vehicleId); return ResponseEntity.noContent().build();
    }
    public record IncidentView(@JsonProperty("incidente_id") UUID id, RoadIncidentRequest detalle) {}
}
