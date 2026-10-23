package com.pathseek.backend.route.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.util.List;
import java.util.UUID;

public record ReoptimizationResponse(
        @JsonProperty("evento_id") UUID eventoId,
        ReoptimizationRequest.Tipo tipo,
        @JsonProperty("rutas_reoptimizadas") List<DeliveryRouteResponse> rutasReoptimizadas,
        @JsonProperty("rutas_sin_cambios") List<UUID> rutasSinCambios,
        @JsonProperty("pedidos_no_asignados") List<UUID> pedidosNoAsignados,
        @JsonProperty("notificaciones_generadas") int notificacionesGeneradas,
        @JsonProperty("conductores_sin_usuario") int conductoresSinUsuario,
        @JsonProperty("tiempo_calculo_ms") long tiempoCalculoMs,
        @JsonProperty("horario_punta") boolean horarioPunta,
        @JsonProperty("modelo_distancia") String modeloDistancia) {}
