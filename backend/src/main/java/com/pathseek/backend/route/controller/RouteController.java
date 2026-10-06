package com.pathseek.backend.route.controller;

import com.pathseek.backend.route.dto.RouteGenerateRequest;
import com.pathseek.backend.route.dto.RouteGenerateResponse;
import com.pathseek.backend.route.dto.RouteConfirmRequest;
import com.pathseek.backend.route.service.RouteMetricsService;
import com.pathseek.backend.route.service.RouteService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/api/v1/rutas")
@Tag(name = "Rutas", description = "Generación de rutas optimizadas (Sprint 2)")
public class RouteController {

    private final RouteService routeService;
    private final RouteMetricsService metricsService;

    public RouteController(RouteService routeService, RouteMetricsService metricsService) {
        this.routeService = routeService;
        this.metricsService = metricsService;
    }

    @PostMapping("/generar")
    @Operation(summary = "Genera rutas optimizadas respetando capacidad, ventanas y placa")
    public ResponseEntity<RouteGenerateResponse> generate(
            @Valid @RequestBody RouteGenerateRequest request) {
        return ResponseEntity.ok(routeService.generate(request));
    }

    @PostMapping("/confirmar")
    @Operation(summary = "Confirma un plan: los pedidos asignados PENDIENTE pasan a EN_RUTA")
    public ResponseEntity<Map<String, Object>> confirm(
            @Valid @RequestBody RouteConfirmRequest request) {
        return ResponseEntity.ok(routeService.confirm(request.pedidoIds()));
    }

    @GetMapping("/metricas-rendimiento")
    @Operation(summary = "Métricas de latencia de generación (P50/P95/media para SLA 45 s)")
    public ResponseEntity<Map<String, Object>> metrics() {
        RouteMetricsService.MetricsSnapshot snapshot = metricsService.snapshot();
        return ResponseEntity.ok(Map.of(
                "total_solicitudes", snapshot.totalSolicitudes(),
                "p50_ms", snapshot.p50Ms(),
                "p95_ms", snapshot.p95Ms(),
                "media_ms", Math.round(snapshot.mediaMs() * 100.0) / 100.0,
                "min_ms", snapshot.minMs(),
                "max_ms", snapshot.maxMs(),
                "ultima_ms", snapshot.ultimaMs(),
                "sla_45s_cumplido", snapshot.slaCumplido()));
    }

    @GetMapping("/lock")
    @Operation(summary = "Indica si existe una generación de rutas en curso")
    public ResponseEntity<Map<String, Object>> lock() {
        return ResponseEntity.ok(Map.of("en_ejecucion", routeService.isRunning()));
    }
}
