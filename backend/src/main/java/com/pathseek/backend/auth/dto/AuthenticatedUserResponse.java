package com.pathseek.backend.auth.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.pathseek.backend.user.entity.UserRole;

import java.util.UUID;

public record AuthenticatedUserResponse(
        @JsonProperty("usuario_id") UUID id,
        String nombre,
        String email,
        UserRole rol
) {
}
