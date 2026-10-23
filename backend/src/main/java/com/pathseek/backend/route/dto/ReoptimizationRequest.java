package com.pathseek.backend.route.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.Valid;
import jakarta.validation.constraints.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

public record ReoptimizationRequest(
        @NotNull @JsonProperty("evento_id") UUID eventoId,
        @NotNull Tipo tipo,
        LocalDate fecha,
        @Size(max = 15) @JsonProperty("rutas_ids") List<@NotNull UUID> rutasIds,
        @Size(max = 150) @JsonProperty("pedidos_ids") List<@NotNull UUID> pedidosIds,
        @JsonProperty("vehiculo_id") UUID vehiculoId,
        @JsonProperty("vehiculo_sustituto_id") UUID vehiculoSustitutoId,
        @Valid RoadIncidentRequest incidente,
        @Size(max = 15) List<@NotNull @Valid Posicion> posiciones) {
    public enum Tipo { NUEVOS_PEDIDOS, CANCELACION, INCIDENTE, AVERIA }
    public record Posicion(@NotNull @JsonProperty("ruta_id") UUID rutaId,
            @NotNull @DecimalMin("-90") @DecimalMax("90") BigDecimal lat,
            @NotNull @DecimalMin("-180") @DecimalMax("180") BigDecimal lon) {}
    public ReoptimizationRequest {
        rutasIds = rutasIds == null ? List.of() : List.copyOf(rutasIds);
        pedidosIds = pedidosIds == null ? List.of() : List.copyOf(pedidosIds);
        posiciones = posiciones == null ? List.of() : List.copyOf(posiciones);
    }
}
