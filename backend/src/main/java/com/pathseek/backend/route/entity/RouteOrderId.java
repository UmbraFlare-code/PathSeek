package com.pathseek.backend.route.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;

import java.io.Serializable;
import java.util.Objects;
import java.util.UUID;

@Embeddable
public class RouteOrderId implements Serializable {

    @Column(name = "ruta_id", nullable = false)
    private UUID rutaId;

    @Column(name = "pedido_id", nullable = false)
    private UUID pedidoId;

    public RouteOrderId() {
    }

    public RouteOrderId(UUID rutaId, UUID pedidoId) {
        this.rutaId = rutaId;
        this.pedidoId = pedidoId;
    }

    public UUID getRutaId() {
        return rutaId;
    }

    public void setRutaId(UUID rutaId) {
        this.rutaId = rutaId;
    }

    public UUID getPedidoId() {
        return pedidoId;
    }

    public void setPedidoId(UUID pedidoId) {
        this.pedidoId = pedidoId;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        RouteOrderId that = (RouteOrderId) o;
        return Objects.equals(rutaId, that.rutaId) && Objects.equals(pedidoId, that.pedidoId);
    }

    @Override
    public int hashCode() {
        return Objects.hash(rutaId, pedidoId);
    }
}
