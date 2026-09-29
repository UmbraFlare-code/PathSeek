package com.pathseek.backend.order.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.pathseek.backend.order.entity.OrderPriority;
import com.pathseek.backend.order.entity.OrderStatus;
import com.pathseek.backend.order.entity.ProductType;
import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Digits;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

import java.math.BigDecimal;

public record OrderRequest(
        @JsonProperty("cliente_id")
        @NotBlank(message = "El cliente es obligatorio")
        @Size(max = 120, message = "El identificador del cliente debe tener como máximo 120 caracteres")
        String clienteId,

        @NotBlank(message = "La dirección es obligatoria")
        @Size(max = 255, message = "La dirección debe tener como máximo 255 caracteres")
        String direccion,

        @JsonProperty("gps_lat")
        @NotNull(message = "La latitud es obligatoria")
        @DecimalMin(value = "-90", message = "La latitud debe estar entre -90 y 90")
        @DecimalMax(value = "90", message = "La latitud debe estar entre -90 y 90")
        @Digits(integer = 3, fraction = 6, message = "La latitud excede el formato permitido")
        BigDecimal gpsLat,

        @JsonProperty("gps_lon")
        @NotNull(message = "La longitud es obligatoria")
        @DecimalMin(value = "-180", message = "La longitud debe estar entre -180 y 180")
        @DecimalMax(value = "180", message = "La longitud debe estar entre -180 y 180")
        @Digits(integer = 3, fraction = 6, message = "La longitud excede el formato permitido")
        BigDecimal gpsLon,

        @NotNull(message = "El peso es obligatorio")
        @DecimalMin(value = "0", inclusive = false, message = "El peso debe ser mayor que cero")
        @Digits(integer = 8, fraction = 2, message = "El peso excede el formato permitido")
        BigDecimal peso,

        @NotNull(message = "El volumen es obligatorio")
        @DecimalMin(value = "0", inclusive = false, message = "El volumen debe ser mayor que cero")
        @Digits(integer = 8, fraction = 2, message = "El volumen excede el formato permitido")
        BigDecimal volumen,

        @JsonProperty("ventana_inicio")
        @NotBlank(message = "La hora de inicio es obligatoria")
        @Pattern(regexp = "^([01][0-9]|2[0-3]):[0-5][0-9]$", message = "Formato de hora inválido (HH:mm)")
        String ventanaInicio,

        @JsonProperty("ventana_fin")
        @NotBlank(message = "La hora de fin es obligatoria")
        @Pattern(regexp = "^([01][0-9]|2[0-3]):[0-5][0-9]$", message = "Formato de hora inválido (HH:mm)")
        String ventanaFin,

        @NotNull(message = "La prioridad es obligatoria")
        OrderPriority prioridad,

        @JsonProperty("tipo_producto")
        @NotNull(message = "El tipo de producto es obligatorio")
        ProductType tipoProducto,

        OrderStatus estado
) {
}
