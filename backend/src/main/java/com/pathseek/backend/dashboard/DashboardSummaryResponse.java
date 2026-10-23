package com.pathseek.backend.dashboard;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.math.BigDecimal;

public record DashboardSummaryResponse(
        @JsonProperty("total_vehiculos") long totalVehiculos,
        @JsonProperty("conductores_disponibles") long conductoresDisponibles,
        @JsonProperty("pedidos_pendientes") long pedidosPendientes,
        @JsonProperty("pedidos_en_ruta") long pedidosEnRuta,
        @JsonProperty("pedidos_entregados") long pedidosEntregados,
        @JsonProperty("pedidos_cancelados") long pedidosCancelados,
        @JsonProperty("rutas_planificadas") long rutasPlanificadas,
        @JsonProperty("co2_total_kg") BigDecimal co2TotalKg,
        @JsonProperty("combustible_total_l") BigDecimal combustibleTotalL
) {}
