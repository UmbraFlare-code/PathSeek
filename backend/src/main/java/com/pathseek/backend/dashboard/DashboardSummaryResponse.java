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
        @JsonProperty("combustible_total_l") BigDecimal combustibleTotalL,
        @JsonProperty("rutas_ejecutadas") ExecutedRoutes executedRoutes
) {
    public record ExecutedRoutes(
            @JsonProperty("rutas_completadas") long completedRoutes,
            @JsonProperty("distancia_km") BigDecimal distanceKm,
            @JsonProperty("co2_kg") BigDecimal co2Kg,
            @JsonProperty("combustible_l") BigDecimal fuelLiters,
            @JsonProperty("entregas_con_hora") long timedDeliveries,
            @JsonProperty("cumplimiento_ventanas_pct") BigDecimal onTimePercent,
            @JsonProperty("comparacion_hoy") DailyComparison dailyComparison
    ) {}

    public record DailyComparison(
            @JsonProperty("combustible_secuencial_l") BigDecimal sequentialLiters,
            @JsonProperty("ahorro_l") BigDecimal savedLiters,
            @JsonProperty("ahorro_pct") BigDecimal savedPercent,
            @JsonProperty("ahorro_pen") BigDecimal savedSoles
    ) {}
}
