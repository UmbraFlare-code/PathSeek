package com.pathseek.backend.audit.controller;

import com.pathseek.backend.audit.dto.AuditLogResponse;
import com.pathseek.backend.audit.service.AuditService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;
import java.time.ZoneOffset;
import java.util.List;

@RestController
@RequestMapping("/api/v1/auditoria")
@Tag(name = "Auditoría", description = "Endpoints para la consulta de pistas de auditoría y trazabilidad del sistema")
public class AuditController {

    private final AuditService auditService;

    public AuditController(AuditService auditService) {
        this.auditService = auditService;
    }

    @GetMapping
    @Operation(summary = "Consultar registros de auditoría", description = "Retorna los últimos 100 eventos o filtrados por entidad y rango de fechas")
    public ResponseEntity<List<AuditLogResponse>> getAuditLogs(
            @RequestParam(required = false) String entidad,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate fechaInicio,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate fechaFin) {

        if (entidad != null && !entidad.isBlank()) {
            return ResponseEntity.ok(auditService.obtenerPorEntidad(entidad.trim()));
        }

        if (fechaInicio != null && fechaFin != null) {
            return ResponseEntity.ok(auditService.obtenerPorRangoFechas(
                    fechaInicio.atStartOfDay().toInstant(ZoneOffset.UTC),
                    fechaFin.plusDays(1).atStartOfDay().toInstant(ZoneOffset.UTC)
            ));
        }

        return ResponseEntity.ok(auditService.obtenerUltimosEventos());
    }
}
