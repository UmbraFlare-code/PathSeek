package com.pathseek.backend.vehicle.entity;

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
@Table(name = "vehiculos")
public class Vehicle {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "vehiculo_id", nullable = false, updatable = false)
    private UUID id;

    @Column(nullable = false, unique = true, length = 10)
    private String placa;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 30)
    private VehicleType tipo;

    @Column(name = "capacidad_kg", nullable = false, precision = 10, scale = 2)
    private BigDecimal capacidadKg;

    @Column(name = "capacidad_m3", nullable = false, precision = 10, scale = 2)
    private BigDecimal capacidadM3;

    @Column(name = "consumo_km_l", nullable = false, precision = 10, scale = 2)
    private BigDecimal consumoKmL;

    @Column(name = "factor_emision", nullable = false, precision = 10, scale = 4)
    private BigDecimal factorEmision;

    private Integer anio;

    @Column(name = "restriccion_placa_digito")
    private Integer restriccionPlacaDigito;

    @Column(name = "created_at", nullable = false, updatable = false)
    private OffsetDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private OffsetDateTime updatedAt;

    public Vehicle() {
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

    public String getPlaca() {
        return placa;
    }

    public void setPlaca(String placa) {
        this.placa = placa;
    }

    public VehicleType getTipo() {
        return tipo;
    }

    public void setTipo(VehicleType tipo) {
        this.tipo = tipo;
    }

    public BigDecimal getCapacidadKg() {
        return capacidadKg;
    }

    public void setCapacidadKg(BigDecimal capacidadKg) {
        this.capacidadKg = capacidadKg;
    }

    public BigDecimal getCapacidadM3() {
        return capacidadM3;
    }

    public void setCapacidadM3(BigDecimal capacidadM3) {
        this.capacidadM3 = capacidadM3;
    }

    public BigDecimal getConsumoKmL() {
        return consumoKmL;
    }

    public void setConsumoKmL(BigDecimal consumoKmL) {
        this.consumoKmL = consumoKmL;
    }

    public BigDecimal getFactorEmision() {
        return factorEmision;
    }

    public void setFactorEmision(BigDecimal factorEmision) {
        this.factorEmision = factorEmision;
    }

    public Integer getAnio() {
        return anio;
    }

    public void setAnio(Integer anio) {
        this.anio = anio;
    }

    public Integer getRestriccionPlacaDigito() {
        return restriccionPlacaDigito;
    }

    public void setRestriccionPlacaDigito(Integer restriccionPlacaDigito) {
        this.restriccionPlacaDigito = restriccionPlacaDigito;
    }
}
