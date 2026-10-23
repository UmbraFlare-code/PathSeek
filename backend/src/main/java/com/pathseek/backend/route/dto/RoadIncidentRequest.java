package com.pathseek.backend.route.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

import java.math.BigDecimal;

public record RoadIncidentRequest(
        @NotBlank(message = "El tipo de incidente es obligatorio")
        @Pattern(regexp = "BLOQUEO|OBRAS|ACCIDENTE|HUAICO|CONGESTION_SEVERA", message = "Tipo de incidente inválido")
        String tipo, // BLOQUEO, OBRAS, ACCIDENTE, HUAICO, CONGESTION_SEVERA

        @NotBlank(message = "La descripción es obligatoria")
        @Size(max = 1000, message = "La descripción no puede superar 1000 caracteres")
        String descripcion,

        @NotNull(message = "La latitud es obligatoria")
        @DecimalMin("-90") @DecimalMax("90")
        BigDecimal lat,

        @NotNull(message = "La longitud es obligatoria")
        @DecimalMin("-180") @DecimalMax("180")
        BigDecimal lon,

        @Min(value = 1, message = "El radio debe ser positivo")
        @Max(value = 5000, message = "El radio no puede superar 5000 metros") Integer radioAfectacionMetros
) {
}
