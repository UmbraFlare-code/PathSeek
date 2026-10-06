package com.pathseek.backend.route.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.Valid;
import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

public record RouteGenerateRequest(
        @JsonProperty("fecha_operacion")
        @NotNull(message = "La fecha de operación es obligatoria")
        LocalDate fechaOperacion,

        @NotNull(message = "El depósito es obligatorio")
        @Valid
        DepotDto deposito,

        @JsonProperty("velocidad_kmh")
        @NotNull(message = "La velocidad promedio es obligatoria")
        @DecimalMin(value = "1", message = "La velocidad debe ser mayor que cero")
        @DecimalMax(value = "120", message = "La velocidad máxima es 120 km/h")
        BigDecimal velocidadKmh,

        @JsonProperty("tiempo_servicio_min")
        @Min(value = 1, message = "El tiempo de servicio mínimo es 1 minuto")
        @Max(value = 120, message = "El tiempo de servicio máximo es 120 minutos")
        Integer tiempoServicioMin,

        @JsonProperty("vehiculo_ids")
        List<UUID> vehiculoIds,

        @JsonProperty("pedido_ids")
        List<UUID> pedidoIds
) {
    public record DepotDto(
            @NotNull(message = "La latitud del depósito es obligatoria")
            @DecimalMin(value = "-90", message = "Latitud del depósito fuera de rango")
            @DecimalMax(value = "90", message = "Latitud del depósito fuera de rango")
            BigDecimal latitud,

            @NotNull(message = "La longitud del depósito es obligatoria")
            @DecimalMin(value = "-180", message = "Longitud del depósito fuera de rango")
            @DecimalMax(value = "180", message = "Longitud del depósito fuera de rango")
            BigDecimal longitud
    ) {
    }

    public int tiempoServicioOrDefault() {
        return tiempoServicioMin == null ? 15 : tiempoServicioMin;
    }

    public double velocidadOrDefault() {
        return velocidadKmh == null ? 40.0 : velocidadKmh.doubleValue();
    }
}
