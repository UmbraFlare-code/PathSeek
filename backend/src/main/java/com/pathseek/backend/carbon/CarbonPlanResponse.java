package com.pathseek.backend.carbon;

import com.fasterxml.jackson.annotation.JsonProperty;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

public record CarbonPlanResponse(
        @JsonProperty("emisiones_anuales_kg") BigDecimal emisionesAnualesKg,
        @JsonProperty("emisiones_anuales_t") BigDecimal emisionesAnualesT,
        @JsonProperty("arboles_equivalentes") long arbolesEquivalentes,
        @JsonProperty("periodo_desde") LocalDate periodoDesde,
        @JsonProperty("periodo_hasta") LocalDate periodoHasta,
        @JsonProperty("proyectos") List<ProjectOption> proyectos) {

    public record ProjectOption(
            @JsonProperty("proyecto_id") UUID proyectoId,
            @JsonProperty("nombre") String nombre,
            @JsonProperty("tipo") String tipo,
            @JsonProperty("costo_tonelada") BigDecimal costoTonelada,
            @JsonProperty("coste_compensacion_estimado") BigDecimal costeCompensacionEstimado,
            @JsonProperty("descripcion") String descripcion) {
    }
}
