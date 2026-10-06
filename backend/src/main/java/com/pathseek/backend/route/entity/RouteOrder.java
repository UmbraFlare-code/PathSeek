package com.pathseek.backend.route.entity;

import com.pathseek.backend.order.entity.Order;
import jakarta.persistence.Column;
import jakarta.persistence.EmbeddedId;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.MapsId;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;

import java.time.LocalTime;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;

@Entity
@Table(name = "ruta_pedidos")
public class RouteOrder {

    @EmbeddedId
    private RouteOrderId id = new RouteOrderId();

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("rutaId")
    @JoinColumn(name = "ruta_id", nullable = false)
    private DeliveryRoute ruta;

    @ManyToOne(fetch = FetchType.EAGER)
    @MapsId("pedidoId")
    @JoinColumn(name = "pedido_id", nullable = false)
    private Order pedido;

    @Column(nullable = false)
    private Integer orden;

    @Column(name = "hora_estimada")
    private LocalTime horaEstimada;

    @Column(name = "cumplio_ventana")
    private Boolean cumplioVentana;

    @Column(name = "created_at", nullable = false, updatable = false)
    private OffsetDateTime createdAt;

    public RouteOrder() {
    }

    public RouteOrder(DeliveryRoute ruta, Order pedido, Integer orden, LocalTime horaEstimada, Boolean cumplioVentana) {
        this.ruta = ruta;
        this.pedido = pedido;
        this.orden = orden;
        this.horaEstimada = horaEstimada;
        this.cumplioVentana = cumplioVentana;
        if (ruta != null && ruta.getId() != null && pedido != null && pedido.getId() != null) {
            this.id = new RouteOrderId(ruta.getId(), pedido.getId());
        }
    }

    @PrePersist
    void prePersist() {
        if (createdAt == null) {
            createdAt = OffsetDateTime.now(ZoneOffset.UTC);
        }
    }

    public RouteOrderId getId() {
        return id;
    }

    public void setId(RouteOrderId id) {
        this.id = id;
    }

    public DeliveryRoute getRuta() {
        return ruta;
    }

    public void setRuta(DeliveryRoute ruta) {
        this.ruta = ruta;
    }

    public Order getPedido() {
        return pedido;
    }

    public void setPedido(Order pedido) {
        this.pedido = pedido;
    }

    public Integer getOrden() {
        return orden;
    }

    public void setOrden(Integer orden) {
        this.orden = orden;
    }

    public LocalTime getHoraEstimada() {
        return horaEstimada;
    }

    public void setHoraEstimada(LocalTime horaEstimada) {
        this.horaEstimada = horaEstimada;
    }

    public Boolean getCumplioVentana() {
        return cumplioVentana;
    }

    public void setCumplioVentana(Boolean cumplioVentana) {
        this.cumplioVentana = cumplioVentana;
    }

    public OffsetDateTime getCreatedAt() {
        return createdAt;
    }
}
