package com.pathseek.backend.client.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

import java.math.BigDecimal;

@Schema(description = "Datos para crear o actualizar un cliente")
public record ClientRequest(
        @NotBlank(message = "El nombre del cliente o institución es obligatorio")
        @Size(max = 150, message = "El nombre no puede exceder 150 caracteres")
        @Schema(description = "Nombre de la institución educativa o cliente", example = "I.E. Santa Isabel")
        String nombre,

        @NotBlank(message = "La dirección es obligatoria")
        @Size(max = 200, message = "La dirección no puede exceder 200 caracteres")
        @Schema(description = "Dirección en Huancayo", example = "Av. Jacinto Ibarra 450")
        String direccion,

        @Size(max = 200, message = "El punto de referencia no puede exceder 200 caracteres")
        @Schema(description = "Punto de referencia", example = "Frente al parque Túpac Amaru")
        String puntoReferencia,

        @Size(max = 20, message = "El teléfono no puede exceder 20 caracteres")
        @Schema(description = "Teléfono de contacto", example = "064-234567")
        String telefono,

        @Size(max = 100, message = "El contacto no puede exceder 100 caracteres")
        @Schema(description = "Nombre de la persona de contacto", example = "Prof. Carmen Morales")
        String contacto,

        @NotNull(message = "La latitud GPS es obligatoria")
        @DecimalMin(value = "-90.0", message = "La latitud mínima es -90")
        @DecimalMax(value = "90.0", message = "La latitud máxima es 90")
        @Schema(description = "Latitud GPS", example = "-12.0722")
        BigDecimal gpsLat,

        @NotNull(message = "La longitud GPS es obligatoria")
        @DecimalMin(value = "-180.0", message = "La longitud mínima es -180")
        @DecimalMax(value = "180.0", message = "La longitud máxima es 180")
        @Schema(description = "Longitud GPS", example = "-75.2089")
        BigDecimal gpsLon,

        @Pattern(regexp = "^([01]?[0-9]|2[0-3]):[0-5][0-9]$", message = "La hora de inicio debe tener formato HH:mm")
        @Schema(description = "Hora preferida de inicio de recepción", example = "08:00")
        String ventanaInicioPreferida,

        @Pattern(regexp = "^([01]?[0-9]|2[0-3]):[0-5][0-9]$", message = "La hora de fin debe tener formato HH:mm")
        @Schema(description = "Hora preferida de fin de recepción", example = "12:00")
        String ventanaFinPreferida,

        @Schema(description = "Estado de actividad del cliente", example = "true")
        Boolean activo
) {
    public ClientRequest {
        if (activo == null) {
            activo = true;
        }
    }
}
