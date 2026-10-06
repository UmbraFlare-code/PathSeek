package com.pathseek.backend.route.entity;

import com.pathseek.backend.driver.entity.Driver;
import com.pathseek.backend.vehicle.entity.Vehicle;
import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.OrderBy;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "rutas")
public class DeliveryRoute {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "ruta_id", nullable = false, updatable = false)
    private UUID id;

    @Column(nullable = false)
    private LocalDate fecha;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "conductor_id", nullable = false)
    private Driver conductor;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "vehiculo_id", nullable = false)
    private Vehicle vehiculo;

    @Column(name = "distancia_km", nullable = false, precision = 10, scale = 2)
    private BigDecimal distanciaKm = BigDecimal.ZERO;

    @Column(name = "co2_kg", nullable = false, precision = 10, scale = 2)
    private BigDecimal co2Kg = BigDecimal.ZERO;

    @Column(name = "combustible_l", nullable = false, precision = 10, scale = 2)
    private BigDecimal combustibleL = BigDecimal.ZERO;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private RouteStatus estado = RouteStatus.PLANIFICADA;

    @OneToMany(mappedBy = "ruta", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.LAZY)
    @OrderBy("orden ASC")
    private List<RouteOrder> pedidos = new ArrayList<>();

    @Column(name = "created_at", nullable = false, updatable = false)
    private OffsetDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private OffsetDateTime updatedAt;

    public DeliveryRoute() {
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

    public void setId(UUID id) {
        this.id = id;
    }

    public LocalDate getFecha() {
        return fecha;
    }

    public void setFecha(LocalDate fecha) {
        this.fecha = fecha;
    }

    public Driver getConductor() {
        return conductor;
    }

    public void setConductor(Driver conductor) {
        this.conductor = conductor;
    }

    public Vehicle getVehiculo() {
        return vehiculo;
    }

    public void setVehiculo(Vehicle vehiculo) {
        this.vehiculo = vehiculo;
    }

    public BigDecimal getDistanciaKm() {
        return distanciaKm;
    }

    public void setDistanciaKm(BigDecimal distanciaKm) {
        this.distanciaKm = distanciaKm;
    }

    public BigDecimal getCo2Kg() {
        return co2Kg;
    }

    public void setCo2Kg(BigDecimal co2Kg) {
        this.co2Kg = co2Kg;
    }

    public BigDecimal getCombustibleL() {
        return combustibleL;
    }

    public void setCombustibleL(BigDecimal combustibleL) {
        this.combustibleL = combustibleL;
    }

    public RouteStatus getEstado() {
        return estado;
    }

    public void setEstado(RouteStatus estado) {
        this.estado = estado;
    }

    public List<RouteOrder> getPedidos() {
        return pedidos;
    }

    public void setPedidos(List<RouteOrder> pedidos) {
        this.pedidos = pedidos;
    }

    public void addPedido(RouteOrder routeOrder) {
        pedidos.add(routeOrder);
        routeOrder.setRuta(this);
    }
}
