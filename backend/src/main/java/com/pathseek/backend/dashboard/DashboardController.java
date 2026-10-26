package com.pathseek.backend.dashboard;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/dashboard")
@Tag(name = "Dashboard", description = "Indicadores operativos y de sostenibilidad (US-008 / RF-005)")
public class DashboardController {
    private final DashboardService service;

    public DashboardController(DashboardService service) {
        this.service = service;
    }

    @GetMapping("/resumen")
    @Operation(summary = "Obtiene el resumen de indicadores del dashboard")
    public DashboardSummaryResponse getSummary() {
        return service.getSummary();
    }
}
