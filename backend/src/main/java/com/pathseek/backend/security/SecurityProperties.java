package com.pathseek.backend.security;

import org.springframework.boot.context.properties.ConfigurationProperties;

import java.nio.charset.StandardCharsets;

@ConfigurationProperties(prefix = "app.security")
public record SecurityProperties(
        String jwtSecret,
        long accessExpirationMinutes,
        long refreshExpirationDays,
        long sessionInactivityMinutes,
        String corsAllowedOrigins
) {

    public SecurityProperties {
        if (jwtSecret == null || jwtSecret.getBytes(StandardCharsets.UTF_8).length < 32) {
            throw new IllegalArgumentException("JWT_SECRET debe contener al menos 32 bytes");
        }
        if (accessExpirationMinutes <= 0 || refreshExpirationDays <= 0 || sessionInactivityMinutes <= 0) {
            throw new IllegalArgumentException("Las duraciones de seguridad deben ser mayores que cero");
        }
    }
}
