package com.pathseek.backend.driver.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.pathseek.backend.driver.entity.DriverCategory;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public record DriverRequest(
        @JsonProperty("usuario_id")
        String usuarioId,

        @NotBlank(message = "El DNI es obligatorio")
        @Pattern(regexp = "^[0-9]{8}$", message = "El DNI debe tener 8 dígitos")
        String dni,

        @NotBlank(message = "El nombre es obligatorio")
        @Size(max = 120, message = "El nombre debe tener como máximo 120 caracteres")
        String nombre,

        @NotBlank(message = "La licencia es obligatoria")
        @Pattern(regexp = "^[A-Za-z][0-9]{7,9}$", message = "Formato de licencia inválido (ej. Q12345678)")
        @Size(max = 20, message = "La licencia debe tener como máximo 20 caracteres")
        String licencia,

        @NotNull(message = "La categoría es obligatoria")
        DriverCategory categoria,

        @NotNull(message = "La experiencia es obligatoria")
        @Min(value = 0, message = "La experiencia no puede ser negativa")
        Integer experiencia,

        Boolean disponible,

        @Size(max = 140, message = "El contacto debe tener como máximo 140 caracteres")
        String contacto
) {
}
