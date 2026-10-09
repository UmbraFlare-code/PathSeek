package com.pathseek.backend.route.dto;

import io.swagger.v3.oas.annotations.media.Schema;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Schema(description = "Resumen del reporte institucional de sostenibilidad y huella de carbono")
public record SustainabilityReportResponse(
        @Schema(description = "Fecha inicial del periodo consultado", example = "2026-10-01")
        LocalDate fechaInicio,

        @Schema(description = "Fecha final del periodo consultado", example = "2026-10-15")
        LocalDate fechaFin,

        @Schema(description = "Total de rutas ejecutadas", example = "14")
        int totalRutasEjecutadas,

        @Schema(description = "Total de pedidos entregados", example = "84")
        int totalPedidosEntregados,

        @Schema(description = "Distancia total recorrida en km", example = "192.40")
        BigDecimal distanciaTotalKm,

        @Schema(description = "Combustible total consumido en litros", example = "22.60")
        BigDecimal combustibleTotalL,

        @Schema(description = "Emisiones totales de CO2 en kg", example = "53.11")
        BigDecimal emisionesCo2TotalKg,

        @Schema(description = "Litros de combustible ahorrados respecto al ruteo tradicional", example = "48.20")
        BigDecimal combustibleAhorradoL,

        @Schema(description = "Kilogramos de CO2 evitados", example = "113.27")
        BigDecimal co2EvitadoKg,

        @Schema(description = "Ahorro económico proyectado en Soles (S/.)", example = "843.50")
        BigDecimal ahorroEconomicoSoles,

        @Schema(description = "Porcentaje de cumplimiento de ventanas horarias de entrega", example = "96.5")
        double porcentajeCumplimientoVentanas,

        @Schema(description = "Desglose de sostenibilidad por vehículo")
        List<VehicleSustainabilityItem> resumenPorVehiculo
) {
    public record VehicleSustainabilityItem(
            String placa,
            String tipo,
            BigDecimal distanciaKm,
            BigDecimal combustibleL,
            BigDecimal co2Kg,
            int entregasRealizadas
    ) {}
}
