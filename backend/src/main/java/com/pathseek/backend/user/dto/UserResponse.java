package com.pathseek.backend.user.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.pathseek.backend.user.entity.UserRole;
import java.time.OffsetDateTime;
import java.util.UUID;

public record UserResponse(@JsonProperty("usuario_id") UUID usuarioId,
        String dni, String nombre, String email, UserRole rol, boolean activo,
        @JsonProperty("bloqueado_hasta") OffsetDateTime bloqueadoHasta,
        @JsonProperty("ultimo_login") OffsetDateTime ultimoLogin) {}
