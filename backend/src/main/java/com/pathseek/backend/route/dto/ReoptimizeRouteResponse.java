package com.pathseek.backend.route.dto;

import com.pathseek.backend.route.entity.RouteStatus;
import io.swagger.v3.oas.annotations.media.Schema;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

@Schema(description = "Respuesta del proceso de re-optimización dinámica de ruta")
public record ReoptimizeRouteResponse(
        @Schema(description = "Identificador único de la ruta", example = "3fa85f64-5717-4562-b3fc-2c963f66afa6")
        UUID rutaId,

        @Schema(description = "Estado de la ruta tras el recálculo", example = "REOPTIMIZADA")
        RouteStatus estado,

        @Schema(description = "Distancia total recalculada en kilómetros", example = "14.85")
        BigDecimal distanciaKm,

        @Schema(description = "Consumo estimado de combustible en litros", example = "1.75")
        BigDecimal combustibleL,

        @Schema(description = "Emisiones estimadas de CO2 en kilogramos", example = "4.11")
        BigDecimal co2Kg,

        @Schema(description = "Tiempo de ejecución del algoritmo en milisegundos", example = "142")
        long tiempoRecalculoMs,

        @Schema(description = "Mensaje descriptivo del resultado")
        String mensaje,

        @Schema(description = "Cantidad de entregas reordenadas en la ruta", example = "5")
        int pedidosReordenados,

        @Schema(description = "Lista ordenada de pedidos tras la re-optimización")
        List<RouteOrderResponse> pedidos,

        @Schema(description = "Polilínea codificada trazada sobre carreteras de OpenStreetMap")
        String encodedPolyline
) {
}
