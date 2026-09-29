package com.pathseek.backend.order.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.pathseek.backend.order.entity.OrderPriority;
import com.pathseek.backend.order.entity.OrderStatus;
import com.pathseek.backend.order.entity.ProductType;

import java.math.BigDecimal;
import java.util.UUID;

public record OrderResponse(
        @JsonProperty("pedido_id") UUID id,
        @JsonProperty("cliente_id") String clienteId,
        String direccion,
        @JsonProperty("gps_lat") BigDecimal gpsLat,
        @JsonProperty("gps_lon") BigDecimal gpsLon,
        BigDecimal peso,
        BigDecimal volumen,
        @JsonProperty("ventana_inicio") String ventanaInicio,
        @JsonProperty("ventana_fin") String ventanaFin,
        OrderPriority prioridad,
        @JsonProperty("tipo_producto") ProductType tipoProducto,
        OrderStatus estado
) {
}
