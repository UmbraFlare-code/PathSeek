package com.pathseek.backend.route.dto;

import com.pathseek.backend.route.entity.RouteOrder;

import java.math.BigDecimal;
import java.time.format.DateTimeFormatter;
import java.util.UUID;

public record RouteOrderResponse(
        UUID pedidoId,
        Integer orden,
        String horaEstimada,
        String direccion,
        BigDecimal gpsLat,
        BigDecimal gpsLon,
        BigDecimal peso,
        String ventanaInicio,
        String ventanaFin,
        Boolean cumplioVentana,
        RoadContextDto contextoVial
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
                contexto
        );
    }
}
