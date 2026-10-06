package com.pathseek.backend.route.dto;

import com.pathseek.backend.route.entity.DeliveryRoute;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

public record DeliveryRouteResponse(
        UUID id,
        LocalDate fecha,
        UUID conductorId,
        String conductorNombre,
        UUID vehiculoId,
        String placa,
        BigDecimal distanciaKm,
        BigDecimal co2Kg,
        BigDecimal combustibleL,
        String estado,
        List<RouteOrderResponse> pedidos,
        Integer totalEntregas
) {
    public static DeliveryRouteResponse fromEntity(DeliveryRoute route) {
        var orderResponses = route.getPedidos() != null
                ? route.getPedidos().stream().map(RouteOrderResponse::fromEntity).toList()
                : List.<RouteOrderResponse>of();

        return new DeliveryRouteResponse(
                route.getId(),
                route.getFecha(),
                route.getConductor() != null ? route.getConductor().getId() : null,
                route.getConductor() != null ? route.getConductor().getNombre() : null,
                route.getVehiculo() != null ? route.getVehiculo().getId() : null,
                route.getVehiculo() != null ? route.getVehiculo().getPlaca() : null,
                route.getDistanciaKm(),
                route.getCo2Kg(),
                route.getCombustibleL(),
                route.getEstado().name(),
                orderResponses,
                orderResponses.size()
        );
    }
}
