package com.pathseek.backend.route.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.pathseek.backend.order.entity.MotivoNoAsignado;
import com.pathseek.backend.order.entity.OrderPriority;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

public record RouteGenerateResponse(
        @JsonProperty("ruta_id") UUID rutaId,
        @JsonProperty("fecha_operacion") LocalDate fechaOperacion,
        @JsonProperty("duracion_ms") long duracionMs,
        DepositoDto deposito,
        @JsonProperty("metricas") MetricsDto metricas,
        List<VehicleRouteDto> rutas,
        @JsonProperty("no_asignados") List<UnassignedDto> noAsignados
) {
    public record DepositoDto(
            BigDecimal latitud,
            BigDecimal longitud
    ) {
    }
    public record MetricsDto(
            @JsonProperty("distancia_km") BigDecimal distanciaKm,
            @JsonProperty("combustible_l") BigDecimal combustibleL,
            @JsonProperty("co2_kg") BigDecimal co2Kg,
            @JsonProperty("cumplimiento_pct") BigDecimal cumplimientoPct,
            @JsonProperty("total_asignados") int totalAsignados,
            @JsonProperty("total_no_asignados") int totalNoAsignados,
            BigDecimal penalizacion
    ) {
    }

    public record VehicleRouteDto(
            @JsonProperty("vehiculo_id") UUID vehiculoId,
            String placa,
            @JsonProperty("distancia_km") BigDecimal distanciaKm,
            @JsonProperty("combustible_l") BigDecimal combustibleL,
            @JsonProperty("co2_kg") BigDecimal co2Kg,
            List<StopDto> paradas
    ) {
    }

    public record StopDto(
            @JsonProperty("pedido_id") UUID pedidoId,
            int orden,
            @JsonProperty("llegada_estimada") String llegadaEstimada,
            @JsonProperty("distancia_tramo_km") BigDecimal distanciaTramoKm,
            @JsonProperty("gps_lat") BigDecimal gpsLat,
            @JsonProperty("gps_lon") BigDecimal gpsLon,
            @JsonProperty("cliente_id") String clienteId,
            String direccion,
            @JsonProperty("ventana_inicio") String ventanaInicio,
            @JsonProperty("ventana_fin") String ventanaFin,
            BigDecimal peso,
            OrderPriority prioridad
    ) {
    }

    public record UnassignedDto(
            @JsonProperty("pedido_id") UUID pedidoId,
            MotivoNoAsignado motivo,
            @JsonProperty("cliente_id") String clienteId,
            String direccion,
            @JsonProperty("ventana_inicio") String ventanaInicio,
            @JsonProperty("ventana_fin") String ventanaFin,
            String sugerencia
    ) {
    }
}
