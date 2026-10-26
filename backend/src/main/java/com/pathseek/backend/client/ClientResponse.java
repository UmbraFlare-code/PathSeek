package com.pathseek.backend.client;

import com.fasterxml.jackson.annotation.JsonProperty;

import java.time.OffsetDateTime;
import java.util.UUID;

public record ClientResponse(
        @JsonProperty("cliente_id") UUID clienteId,
        @JsonProperty("usuario_id") UUID usuarioId,
        @JsonProperty("nombre") String nombre,
        @JsonProperty("direccion") String direccion,
        @JsonProperty("punto_referencia") String puntoReferencia,
        @JsonProperty("telefono") String telefono,
        @JsonProperty("horario_atencion_inicio") String horarioAtencionInicio,
        @JsonProperty("horario_atencion_fin") String horarioAtencionFin,
        @JsonProperty("restricciones_acceso") String restriccionesAcceso,
        @JsonProperty("created_at") OffsetDateTime createdAt,
        @JsonProperty("updated_at") OffsetDateTime updatedAt) {

    public static ClientResponse from(ClientProfile profile) {
        return new ClientResponse(
                profile.getId(),
                profile.getUsuarioId(),
                profile.getNombre(),
                profile.getDireccion(),
                profile.getPuntoReferencia(),
                profile.getTelefono(),
                profile.getHorarioAtencionInicio(),
                profile.getHorarioAtencionFin(),
                profile.getRestriccionesAcceso(),
                profile.getCreatedAt(),
                profile.getUpdatedAt());
    }
}
