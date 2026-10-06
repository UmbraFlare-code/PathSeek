package com.pathseek.backend.route.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;

public record RoadIncidentRequest(
        @NotBlank(message = "El tipo de incidente es obligatorio")
        String tipo, // BLOQUEO, OBRAS, ACCIDENTE, HUAICO, CONGESTION_SEVERA

        @NotBlank(message = "La descripción es obligatoria")
        String descripcion,

        @NotNull(message = "La latitud es obligatoria")
        BigDecimal lat,

        @NotNull(message = "La longitud es obligatoria")
        BigDecimal lon,

        Integer radioAfectacionMetros
) {
}
