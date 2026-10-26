package com.pathseek.backend.route.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.pathseek.backend.order.entity.OrderStatus;
import com.pathseek.backend.route.entity.RouteStatus;

import java.util.UUID;

public record DeliveryUpdateResponse(
        @JsonProperty("ruta_id") UUID rutaId,
        @JsonProperty("pedido_id") UUID pedidoId,
        @JsonProperty("pedido_estado") OrderStatus pedidoEstado,
        @JsonProperty("ruta_estado") RouteStatus rutaEstado,
        @JsonProperty("cumplio_ventana") Boolean cumplioVentana,
        @JsonProperty("ya_registrado") boolean yaRegistrado) {
}
