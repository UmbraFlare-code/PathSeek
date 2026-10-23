package com.pathseek.backend.user.dto;

import com.pathseek.backend.user.entity.UserRole;
import jakarta.validation.constraints.*;

public record CreateUserRequest(
        @Pattern(regexp = "[0-9]{8}", message = "El DNI debe tener 8 dígitos") String dni,
        @NotBlank @Size(max = 120) String nombre,
        @NotBlank @Email @Size(max = 254) String email,
        @NotBlank @Size(min = 8, max = 72)
        @Pattern(regexp = "(?s)(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9]).*",
                message = "Debe incluir mayúscula, minúscula y número") String password,
        @NotNull UserRole rol) {}
