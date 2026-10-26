package com.pathseek.backend.carbon;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/compensacion")
@Tag(name = "Compensación de Carbono", description = "Plan de compensación de huella de carbono (US-010 / RF-010)")
public class CarbonOffsetController {

    private final CarbonOffsetService service;

    public CarbonOffsetController(CarbonOffsetService service) {
        this.service = service;
    }

    @GetMapping("/plan")
    @Operation(summary = "Genera el plan de compensación de carbono",
            description = "Calcula las emisiones anuales de las rutas completadas, los árboles equivalentes y sugiere proyectos locales de compensación")
    public ResponseEntity<CarbonPlanResponse> plan() {
        return ResponseEntity.ok(service.plan());
    }
}
