package com.pathseek.backend.route.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.util.List;
import java.util.UUID;

public record RouteConfirmRequest(
        @JsonProperty("pedido_ids")
        @NotNull(message = "Debe enviar los pedidos a confirmar")
        @Size(min = 1, message = "Debe enviar al menos un pedido")
        List<UUID> pedidoIds
) {
}
