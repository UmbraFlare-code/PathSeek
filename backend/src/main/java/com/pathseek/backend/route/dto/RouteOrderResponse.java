package com.pathseek.backend.route.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.pathseek.backend.order.entity.OrderStatus;
import com.pathseek.backend.route.entity.RouteOrder;

import java.math.BigDecimal;
import java.time.format.DateTimeFormatter;
import java.util.UUID;

public record RouteOrderResponse(
        @JsonProperty("pedido_id") UUID pedidoId,
        Integer orden,
        @JsonProperty("hora_estimada") String horaEstimada,
        String direccion,
        @JsonProperty("gps_lat") BigDecimal gpsLat,
        @JsonProperty("gps_lon") BigDecimal gpsLon,
        BigDecimal peso,
        @JsonProperty("ventana_inicio") String ventanaInicio,
        @JsonProperty("ventana_fin") String ventanaFin,
        @JsonProperty("cumplio_ventana") Boolean cumplioVentana,
        @JsonProperty("contexto_vial") RoadContextDto contextoVial,
        @JsonProperty("cliente_id") String clienteId,
        @JsonProperty("pedido_estado") OrderStatus pedidoEstado
) {
    public static RouteOrderResponse fromEntity(RouteOrder routeOrder) {
        var pedido = routeOrder.getPedido();
        String hora = routeOrder.getHoraEstimada() != null
                ? routeOrder.getHoraEstimada().format(DateTimeFormatter.ofPattern("HH:mm"))
                : null;

        RoadContextDto contexto = RoadContextDto.defaultForHuancayo(
                pedido != null ? pedido.getGpsLat() : null,
                pedido != null ? pedido.getGpsLon() : null
        );

        return new RouteOrderResponse(
                pedido != null ? pedido.getId() : null,
                routeOrder.getOrden(),
                hora,
                pedido != null ? pedido.getDireccion() : null,
                pedido != null ? pedido.getGpsLat() : null,
                pedido != null ? pedido.getGpsLon() : null,
                pedido != null ? pedido.getPeso() : null,
                pedido != null ? pedido.getVentanaInicio() : null,
                pedido != null ? pedido.getVentanaFin() : null,
                routeOrder.getCumplioVentana(),
                contexto,
                pedido != null ? pedido.getClienteId() : null,
                pedido != null ? pedido.getEstado() : null
        );
    }
}
