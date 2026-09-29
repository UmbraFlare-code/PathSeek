package com.pathseek.backend.vehicle.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.pathseek.backend.vehicle.entity.VehicleType;

import java.math.BigDecimal;
import java.util.UUID;

public record VehicleResponse(
        @JsonProperty("vehiculo_id") UUID id,
        String placa,
        VehicleType tipo,
        @JsonProperty("capacidad_kg") BigDecimal capacidadKg,
        @JsonProperty("capacidad_m3") BigDecimal capacidadM3,
        @JsonProperty("consumo_km_l") BigDecimal consumoKmL,
        @JsonProperty("factor_emision") BigDecimal factorEmision,
        Integer anio,
        @JsonProperty("restriccion_placa_digito") Integer restriccionPlacaDigito
) {
}
