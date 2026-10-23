package com.pathseek.backend.user.dto;

import com.pathseek.backend.user.entity.UserRole;
import jakarta.validation.constraints.*;

public record UpdateUserRequest(
        @Pattern(regexp = "[0-9]{8}", message = "El DNI debe tener 8 dígitos") String dni,
        @NotBlank @Size(max = 120) String nombre,
        @NotBlank @Email @Size(max = 254) String email,
        @NotNull UserRole rol,
        @NotNull Boolean activo) {}
