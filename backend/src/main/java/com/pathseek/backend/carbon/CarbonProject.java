package com.pathseek.backend.carbon;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.UUID;

@Entity
@Table(name = "proyectos_compensacion")
public class CarbonProject {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "proyecto_id", nullable = false, updatable = false)
    private UUID id;

    @Column(nullable = false, unique = true, length = 160)
    private String nombre;

    @Column(length = 4000)
    private String descripcion;

    @Column(nullable = false, length = 40)
    private String tipo;

    @Column(name = "costo_tonelada", nullable = false, precision = 12, scale = 2)
    private BigDecimal costoTonelada;

    @Column(nullable = false)
    private Boolean activo = Boolean.TRUE;

    @Column(name = "created_at", nullable = false, updatable = false)
    private OffsetDateTime createdAt;

    public CarbonProject() {
    }

    @PrePersist
    void prePersist() {
        createdAt = OffsetDateTime.now(ZoneOffset.UTC);
    }

    public UUID getId() {
        return id;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getNombre() {
        return nombre;
    }

    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }

    public String getDescripcion() {
        return descripcion;
    }

    public void setTipo(String tipo) {
        this.tipo = tipo;
    }

    public String getTipo() {
        return tipo;
    }

    public void setCostoTonelada(BigDecimal costoTonelada) {
        this.costoTonelada = costoTonelada;
    }

    public BigDecimal getCostoTonelada() {
        return costoTonelada;
    }

    public Boolean getActivo() {
        return activo;
    }

    public OffsetDateTime getCreatedAt() {
        return createdAt;
    }
}
