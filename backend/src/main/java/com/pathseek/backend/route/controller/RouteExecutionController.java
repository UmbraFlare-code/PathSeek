package com.pathseek.backend.route.controller;

import com.pathseek.backend.route.dto.DeliveryUpdateResponse;
import com.pathseek.backend.route.dto.PositionUpdateRequest;
import com.pathseek.backend.route.service.RouteExecutionService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/rutas")
@Tag(name = "Ejecución de Rutas", description = "Registro de posición y entregas del conductor (EN-008 / modo offline)")
public class RouteExecutionController {

    private final RouteExecutionService service;

    public RouteExecutionController(RouteExecutionService service) {
        this.service = service;
    }

    @PostMapping("/{id}/posicion")
    @Operation(summary = "Registra la posición actual del conductor",
            description = "Actualiza el progreso estimado de la ruta; idempotente por ruta")
    public ResponseEntity<DeliveryUpdateResponse> reportPosition(
            @PathVariable UUID id,
            @Valid @RequestBody PositionUpdateRequest request) {
        return ResponseEntity.ok(service.reportPosition(id, request));
    }

    @PostMapping("/{id}/entregas/{pedidoId}/completar")
    @Operation(summary = "Marca una entrega como completada",
            description = "Valida el prefijo de entregas; repetir la misma entrega no la duplica")
    public ResponseEntity<DeliveryUpdateResponse> completeDelivery(
            @PathVariable UUID id,
            @PathVariable UUID pedidoId) {
        return ResponseEntity.ok(service.completeDelivery(id, pedidoId));
    }
}
