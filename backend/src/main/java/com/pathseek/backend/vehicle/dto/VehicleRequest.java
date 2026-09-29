package com.pathseek.backend.vehicle.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.pathseek.backend.vehicle.entity.VehicleType;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Digits;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.math.BigDecimal;

public record VehicleRequest(
        @NotBlank(message = "La placa es obligatoria")
        @Size(max = 10, message = "La placa debe tener como máximo 10 caracteres")
        String placa,

        @NotNull(message = "El tipo es obligatorio")
        VehicleType tipo,

        @JsonProperty("capacidad_kg")
        @NotNull(message = "La capacidad en kg es obligatoria")
        @DecimalMin(value = "0", inclusive = false, message = "La capacidad en kg debe ser mayor que cero")
        @Digits(integer = 8, fraction = 2, message = "La capacidad en kg excede el formato permitido")
        BigDecimal capacidadKg,

        @JsonProperty("capacidad_m3")
        @NotNull(message = "La capacidad en m3 es obligatoria")
        @DecimalMin(value = "0", inclusive = false, message = "La capacidad en m3 debe ser mayor que cero")
        @Digits(integer = 8, fraction = 2, message = "La capacidad en m3 excede el formato permitido")
        BigDecimal capacidadM3,

        @JsonProperty("consumo_km_l")
        @NotNull(message = "El consumo es obligatorio")
        @DecimalMin(value = "0", inclusive = false, message = "El consumo debe ser mayor que cero")
        @Digits(integer = 8, fraction = 2, message = "El consumo excede el formato permitido")
        BigDecimal consumoKmL,

        @JsonProperty("factor_emision")
        @NotNull(message = "El factor de emisión es obligatorio")
        @DecimalMin(value = "0", message = "El factor de emisión no puede ser negativo")
        @Digits(integer = 6, fraction = 4, message = "El factor de emisión excede el formato permitido")
        BigDecimal factorEmision,

        @Min(value = 1900, message = "El año debe ser igual o posterior a 1900")
        Integer anio,

        @JsonProperty("restriccion_placa_digito")
        @Min(value = 0, message = "El dígito de restricción debe estar entre 0 y 9")
        @Max(value = 9, message = "El dígito de restricción debe estar entre 0 y 9")
        Integer restriccionPlacaDigito
) {
}
