package com.pathseek.backend.client;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

import java.util.UUID;

public record ClientRequest(
        @JsonProperty("usuario_id") UUID usuarioId,
        @NotBlank(message = "El nombre del cliente es obligatorio") @Size(max = 120) String nombre,
        @Size(max = 255) String direccion,
        @JsonProperty("punto_referencia") @Size(max = 255) String puntoReferencia,
        @Size(max = 15) String telefono,
        @JsonProperty("horario_atencion_inicio")
        @Pattern(regexp = "^([01]\\d|2[0-3]):[0-5]\\d$", message = "El horario de inicio debe tener formato HH:mm")
        String horarioAtencionInicio,
        @JsonProperty("horario_atencion_fin")
        @Pattern(regexp = "^([01]\\d|2[0-3]):[0-5]\\d$", message = "El horario de fin debe tener formato HH:mm")
        String horarioAtencionFin,
        @JsonProperty("restricciones_acceso") @Size(max = 500) String restriccionesAcceso) {
}
