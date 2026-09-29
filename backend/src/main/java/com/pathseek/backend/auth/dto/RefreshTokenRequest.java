package com.pathseek.backend.auth.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record RefreshTokenRequest(
        @JsonProperty("refreshToken")
        @NotBlank(message = "El refresh token es obligatorio")
        @Size(max = 200, message = "El refresh token es demasiado largo")
        String refreshToken
) {
}
