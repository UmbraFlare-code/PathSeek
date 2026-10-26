package com.pathseek.backend.report;

import com.pathseek.backend.exception.BusinessRuleException;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;

@RestController
@RequestMapping("/api/v1/reportes")
@Tag(name = "Reportes de Sostenibilidad", description = "Generación de reportes PDF de sostenibilidad (US-009 / RF-006)")
public class ReportController {

    private final SustainabilityReportService service;

    public ReportController(SustainabilityReportService service) {
        this.service = service;
    }

    @GetMapping("/sostenibilidad")
    @Operation(summary = "Descarga el reporte PDF de sostenibilidad",
            description = "Genera un PDF con métricas por ruta (distancia, CO₂, combustible y cumplimiento de ventanas) filtrado por rango de fechas opcional")
    public ResponseEntity<byte[]> sustainabilityReport(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate desde,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate hasta) {
        if (desde != null && hasta != null && desde.isAfter(hasta)) {
            throw new BusinessRuleException("INVALID_REPORT_RANGE", "La fecha 'desde' no puede ser posterior a 'hasta'.");
        }
        byte[] pdf = service.generate(desde, hasta);
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"reporte_sostenibilidad.pdf\"")
                .contentType(MediaType.APPLICATION_PDF)
                .body(pdf);
    }
}
