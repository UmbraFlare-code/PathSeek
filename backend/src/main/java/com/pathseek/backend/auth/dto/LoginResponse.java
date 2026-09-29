package com.pathseek.backend.auth.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

public record LoginResponse(
        String token,
        @JsonProperty("refreshToken") String refreshToken,
        AuthenticatedUserResponse usuario
) {
}
