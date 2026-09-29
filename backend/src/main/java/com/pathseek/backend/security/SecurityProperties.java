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
        if (jwtSecret == null || jwtSecret.isBlank()
                || jwtSecret.getBytes(StandardCharsets.UTF_8).length < 32) {
            throw new IllegalArgumentException("""
                    JWT_SECRET debe contener al menos 32 bytes.

                    Spring Boot NO lee archivos .env de forma nativa, por lo que la variable
                    debe existir en el entorno. Opciones:

                      1) En PowerShell, desde backend/:
                         .\\run-local.ps1
                         (crea/le usa backend/.env, que esta en .gitignore)

                      2) Definiendola en la terminal actual:
                         $env:JWT_SECRET = (un valor aleatorio de 32+ caracteres)

                    Copia .env.example a .env como base. NUNCA commitear el secreto.""");
        }
        if (accessExpirationMinutes <= 0 || refreshExpirationDays <= 0 || sessionInactivityMinutes <= 0) {
            throw new IllegalArgumentException("Las duraciones de seguridad deben ser mayores que cero");
        }
    }
}
