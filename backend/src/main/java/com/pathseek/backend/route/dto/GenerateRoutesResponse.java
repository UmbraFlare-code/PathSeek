package com.pathseek.backend.route.dto;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

public record GenerateRoutesResponse(
        List<DeliveryRouteResponse> rutas,
        List<UUID> pedidosNoAsignados,
        Integer totalRutasGeneradas,
        Integer totalPedidosPlanificados,
        BigDecimal ahorroCombustibleEstimadoL,
        BigDecimal reduccionCo2EstimadaKg,
        String metaheuristicaAplicada,
        Long tiempoCalculoMs
) {
}
