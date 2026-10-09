package com.pathseek.backend.report.controller;

import com.pathseek.backend.report.service.ReportService;
import com.pathseek.backend.route.dto.CarbonCompensationResponse;
import com.pathseek.backend.route.dto.SustainabilityReportResponse;
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
@Tag(name = "Reportes y Sostenibilidad", description = "Endpoints para la generación de métricas de sostenibilidad y compensación de carbono")
public class ReportController {

    private final ReportService reportService;

    public ReportController(ReportService reportService) {
        this.reportService = reportService;
    }

    @GetMapping("/sostenibilidad")
    @Operation(summary = "Obtener reporte de sostenibilidad en formato JSON", description = "Retorna métricas agregadas de emisiones, ahorro de combustible y cumplimiento de ventanas")
    public ResponseEntity<SustainabilityReportResponse> getSustainabilityReport(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate fechaInicio,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate fechaFin) {
        SustainabilityReportResponse response = reportService.getSustainabilityReport(fechaInicio, fechaFin);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/sostenibilidad/pdf")
    @Operation(summary = "Descargar reporte de sostenibilidad en formato PDF", description = "Genera un documento PDF descargable con el resumen institucional de emisiones")
    public ResponseEntity<byte[]> downloadSustainabilityPdf(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate fechaInicio,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate fechaFin) {
        byte[] pdfBytes = reportService.generatePdfReport(fechaInicio, fechaFin);
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"reporte_sostenibilidad_pathseek.pdf\"")
                .contentType(MediaType.APPLICATION_PDF)
                .body(pdfBytes);
    }

    @GetMapping("/compensacion")
    @Operation(summary = "Obtener plan de compensación de huella de carbono", description = "Retorna el cálculo de árboles equivalentes y catálogo de proyectos de reforestación regional")
    public ResponseEntity<CarbonCompensationResponse> getCarbonCompensation() {
        CarbonCompensationResponse response = reportService.getCarbonCompensation();
        return ResponseEntity.ok(response);
    }
}
