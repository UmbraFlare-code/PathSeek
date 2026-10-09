package com.pathseek.backend.dashboard.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;

import java.math.BigDecimal;

@Schema(description = "Resumen de indicadores para el dashboard institucional")
public record DashboardSummaryDto(
        @JsonProperty("total_vehiculos")
        int totalVehiculos,

        @JsonProperty("conductores_disponibles")
        int conductoresDisponibles,

        @JsonProperty("pedidos_pendientes")
        int pedidosPendientes,

        @JsonProperty("pedidos_en_ruta")
        int pedidosEnRuta,

        @JsonProperty("pedidos_entregados")
        int pedidosEntregados,

        @JsonProperty("pedidos_cancelados")
        int pedidosCancelados,

        @JsonProperty("rutas_planificadas")
        int rutasPlanificadas,

        @JsonProperty("co2_total_kg")
        BigDecimal co2TotalKg,

        @JsonProperty("combustible_total_l")
        BigDecimal combustibleTotalL
) {
}
