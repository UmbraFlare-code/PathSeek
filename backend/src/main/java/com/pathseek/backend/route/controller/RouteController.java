package com.pathseek.backend.route.controller;

import com.pathseek.backend.route.dto.DeliveryRouteResponse;
import com.pathseek.backend.route.dto.GenerateRoutesResponse;
import com.pathseek.backend.route.dto.ReoptimizeRouteRequest;
import com.pathseek.backend.route.dto.ReoptimizeRouteResponse;
import com.pathseek.backend.route.dto.RoadIncidentRequest;
import com.pathseek.backend.route.dto.RouteGeometryResponse;
import com.pathseek.backend.route.service.RouteOptimizationService;
import com.pathseek.backend.route.service.RoutingContextService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/rutas")
@Tag(name = "Rutas y Optimización", description = "Endpoints para la generación, consulta y contexto vial de rutas optimizadas")
public class RouteController {

    private final RouteOptimizationService optimizationService;
    private final RoutingContextService routingContextService;

    public RouteController(RouteOptimizationService optimizationService, RoutingContextService routingContextService) {
        this.optimizationService = optimizationService;
        this.routingContextService = routingContextService;
    }

    @GetMapping
    @Operation(summary = "Listar rutas optimizadas", description = "Obtiene el catálogo de rutas planificadas para una fecha opcional")
    public ResponseEntity<List<DeliveryRouteResponse>> getRoutes(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate fecha) {
        List<DeliveryRouteResponse> routes = optimizationService.getRoutes(fecha);
        return ResponseEntity.ok(routes);
    }

    @GetMapping("/{id}")
    @Operation(summary = "Obtener detalle de ruta", description = "Retorna una ruta específica con su secuencia ordenada de pedidos y métricas")
    public ResponseEntity<DeliveryRouteResponse> getRouteById(@PathVariable UUID id) {
        DeliveryRouteResponse response = optimizationService.getRouteById(id);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/generar")
    @Operation(summary = "Ejecutar motor de optimización de rutas (VRPTW)", description = "Resuelve el problema de ruteo vehicular con ventanas de tiempo y consideraciones ambientales")
    public ResponseEntity<GenerateRoutesResponse> generateRoutes() {
        GenerateRoutesResponse response = optimizationService.generateRoutes();
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping("/{id}/geometria")
    @Operation(summary = "Obtener geometría y perfil de elevación", description = "Retorna la polilínea codificada, coordenadas de paradas y perfil altimétrico de la ruta")
    public ResponseEntity<RouteGeometryResponse> getRouteGeometry(@PathVariable UUID id) {
        RouteGeometryResponse response = optimizationService.getRouteGeometry(id);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/{id}/incidentes")
    @Operation(summary = "Reportar incidente vial en ruta", description = "Registra un bloqueo u obra en la ruta para habilitar re-optimización dinámica")
    public ResponseEntity<Map<String, String>> reportIncident(
            @PathVariable UUID id,
            @Valid @RequestBody RoadIncidentRequest request) {
        routingContextService.registrarIncidente(id, request);
        return ResponseEntity.ok(Map.of("mensaje", "Incidente vial registrado exitosamente en la ruta"));
    }

    @PostMapping("/{id}/reoptimizar")
    @Operation(summary = "Re-optimizar ruta dinámicamente", description = "Recalcula y reordena las paradas de la ruta en tiempo real esquivando incidentes viales reportados")
    public ResponseEntity<ReoptimizeRouteResponse> reoptimizeRoute(
            @PathVariable UUID id,
            @Valid @RequestBody ReoptimizeRouteRequest request) {
        ReoptimizeRouteResponse response = optimizationService.reoptimizeRoute(id, request);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Eliminar ruta planificada", description = "Elimina una ruta y libera los pedidos asociados")
    public ResponseEntity<Void> deleteRoute(@PathVariable UUID id) {
        optimizationService.deleteRoute(id);
        return ResponseEntity.noContent().build();
    }
}
