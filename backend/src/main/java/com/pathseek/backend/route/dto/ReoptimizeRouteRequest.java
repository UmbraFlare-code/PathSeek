package com.pathseek.backend.route.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

@Schema(description = "Solicitud de re-optimización dinámica de ruta ante incidentes o pedidos prioritarios")
public record ReoptimizeRouteRequest(
        @NotBlank(message = "El motivo de re-optimización es obligatorio")
        @Size(max = 100, message = "El motivo no puede exceder 100 caracteres")
        @Schema(description = "Motivo de la re-optimización", example = "ACCIDENTE")
        String motivo,

        @Size(max = 255, message = "La descripción no puede exceder 255 caracteres")
        @Schema(description = "Detalle del incidente vial o cambio", example = "Bloqueo por obras en Jr. Real y Av. Huancavelica")
        String descripcion,

        @NotNull(message = "La latitud del incidente es obligatoria")
        @DecimalMin(value = "-90.0", message = "La latitud mínima es -90")
        @DecimalMax(value = "90.0", message = "La latitud máxima es 90")
        @Schema(description = "Latitud GPS del incidente", example = "-12.0685")
        BigDecimal latitudIncidente,

        @NotNull(message = "La longitud del incidente es obligatoria")
        @DecimalMin(value = "-180.0", message = "La longitud mínima es -180")
        @DecimalMax(value = "180.0", message = "La longitud máxima es 180")
        @Schema(description = "Longitud GPS del incidente", example = "-75.2103")
        BigDecimal longitudIncidente,

        @Schema(description = "Radio estimado de afectación en metros", example = "350")
        Integer radioBloqueoMetros,

        @Schema(description = "Lista de IDs de pedidos cancelados o reasignados")
        List<UUID> pedidosCancelados
) {
    public ReoptimizeRouteRequest {
        if (radioBloqueoMetros == null || radioBloqueoMetros <= 0) {
            radioBloqueoMetros = 250;
        }
        if (pedidosCancelados == null) {
            pedidosCancelados = List.of();
        }
    }
}
