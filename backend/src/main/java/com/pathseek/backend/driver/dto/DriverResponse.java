package com.pathseek.backend.driver.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.pathseek.backend.driver.entity.DriverCategory;

import java.util.UUID;

public record DriverResponse(
        @JsonProperty("conductor_id") UUID id,
        @JsonProperty("usuario_id") UUID usuarioId,
        String dni,
        String nombre,
        String licencia,
        DriverCategory categoria,
        Integer experiencia,
        Boolean disponible,
        String contacto
) {
}
