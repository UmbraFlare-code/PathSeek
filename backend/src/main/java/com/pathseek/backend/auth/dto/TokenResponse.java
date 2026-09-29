package com.pathseek.backend.auth.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

public record TokenResponse(
        String token,
        @JsonProperty("refreshToken") String refreshToken
) {
}
