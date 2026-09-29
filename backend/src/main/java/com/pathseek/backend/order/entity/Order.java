package com.pathseek.backend.order.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.UUID;

@Entity
@Table(name = "pedidos")
public class Order {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "pedido_id", nullable = false, updatable = false)
    private UUID id;

    @Column(name = "cliente_id", nullable = false, length = 120)
    private String clienteId;

    @Column(nullable = false, length = 255)
    private String direccion;

    @Column(name = "gps_lat", nullable = false, precision = 9, scale = 6)
    private BigDecimal gpsLat;

    @Column(name = "gps_lon", nullable = false, precision = 9, scale = 6)
    private BigDecimal gpsLon;

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal peso;

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal volumen;

    @Column(name = "ventana_inicio", nullable = false, length = 5)
    private String ventanaInicio;

    @Column(name = "ventana_fin", nullable = false, length = 5)
    private String ventanaFin;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private OrderPriority prioridad;

    @Enumerated(EnumType.STRING)
    @Column(name = "tipo_producto", nullable = false, length = 20)
    private ProductType tipoProducto;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private OrderStatus estado;

    @Column(name = "created_at", nullable = false, updatable = false)
    private OffsetDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private OffsetDateTime updatedAt;

    public Order() {
    }

    @PrePersist
    void prePersist() {
        OffsetDateTime now = OffsetDateTime.now(ZoneOffset.UTC);
        createdAt = now;
        updatedAt = now;
    }

    @PreUpdate
    void preUpdate() {
        updatedAt = OffsetDateTime.now(ZoneOffset.UTC);
    }

    public UUID getId() {
        return id;
    }

    public String getClienteId() {
        return clienteId;
    }

    public void setClienteId(String clienteId) {
        this.clienteId = clienteId;
    }

    public String getDireccion() {
        return direccion;
    }

    public void setDireccion(String direccion) {
        this.direccion = direccion;
    }

    public BigDecimal getGpsLat() {
        return gpsLat;
    }

    public void setGpsLat(BigDecimal gpsLat) {
        this.gpsLat = gpsLat;
    }

    public BigDecimal getGpsLon() {
        return gpsLon;
    }

    public void setGpsLon(BigDecimal gpsLon) {
        this.gpsLon = gpsLon;
    }

    public BigDecimal getPeso() {
        return peso;
    }

    public void setPeso(BigDecimal peso) {
        this.peso = peso;
    }

    public BigDecimal getVolumen() {
        return volumen;
    }

    public void setVolumen(BigDecimal volumen) {
        this.volumen = volumen;
    }

    public String getVentanaInicio() {
        return ventanaInicio;
    }

    public void setVentanaInicio(String ventanaInicio) {
        this.ventanaInicio = ventanaInicio;
    }

    public String getVentanaFin() {
        return ventanaFin;
    }

    public void setVentanaFin(String ventanaFin) {
        this.ventanaFin = ventanaFin;
    }

    public OrderPriority getPrioridad() {
        return prioridad;
    }

    public void setPrioridad(OrderPriority prioridad) {
        this.prioridad = prioridad;
    }

    public ProductType getTipoProducto() {
        return tipoProducto;
    }

    public void setTipoProducto(ProductType tipoProducto) {
        this.tipoProducto = tipoProducto;
    }

    public OrderStatus getEstado() {
        return estado;
    }

    public void setEstado(OrderStatus estado) {
        this.estado = estado;
    }
}
