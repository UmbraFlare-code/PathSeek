package com.pathseek.backend.route.dto;

import io.swagger.v3.oas.annotations.media.Schema;

import java.math.BigDecimal;
import java.util.List;

@Schema(description = "Plan de compensación de huella de carbono y proyectos de reforestación")
public record CarbonCompensationResponse(
        @Schema(description = "Emisiones de CO2 anuales estimadas en toneladas", example = "42.0")
        BigDecimal emisionesAnualesToneladas,

        @Schema(description = "Emisiones acumuladas registradas en kilogramos", example = "3500.80")
        BigDecimal emisionesAcumuladasKg,

        @Schema(description = "Cantidad estimada de árboles nativos a plantar para compensación", example = "2100")
        int arbolesEquivalentesRequeridos,

        @Schema(description = "Años proyectados para alcanzar la neutralidad de carbono", example = "3")
        int horizonteAniosNeutralidad,

        @Schema(description = "Proyectos locales de reforestación sugeridos en la región Junín")
        List<ReforestationProjectDto> proyectosSugeridos
) {
    public record ReforestationProjectDto(
            String id,
            String nombre,
            String ubicacion,
            String especieArbol,
            int capacidadArboles,
            String entidadGestora,
            String estado
    ) {}
}
