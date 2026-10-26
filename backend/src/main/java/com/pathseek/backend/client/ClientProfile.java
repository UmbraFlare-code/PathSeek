package com.pathseek.backend.client;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;

import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.UUID;

@Entity
@Table(name = "clientes")
public class ClientProfile {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "cliente_id", nullable = false, updatable = false)
    private UUID id;

    @Column(name = "usuario_id", nullable = false)
    private UUID usuarioId;

    @Column(nullable = false, length = 120)
    private String nombre;

    @Column(length = 4000)
    private String direccion;

    @Column(name = "punto_referencia", length = 4000)
    private String puntoReferencia;

    @Column(length = 15)
    private String telefono;

    @Column(name = "horario_atencion_inicio", length = 5)
    private String horarioAtencionInicio;

    @Column(name = "horario_atencion_fin", length = 5)
    private String horarioAtencionFin;

    @Column(name = "restricciones_acceso", length = 4000)
    private String restriccionesAcceso;

    @Column(name = "created_at", nullable = false, updatable = false)
    private OffsetDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private OffsetDateTime updatedAt;

    public ClientProfile() {
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

    public UUID getUsuarioId() {
        return usuarioId;
    }

    public void setUsuarioId(UUID usuarioId) {
        this.usuarioId = usuarioId;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getDireccion() {
        return direccion;
    }

    public void setDireccion(String direccion) {
        this.direccion = direccion;
    }

    public String getPuntoReferencia() {
        return puntoReferencia;
    }

    public void setPuntoReferencia(String puntoReferencia) {
        this.puntoReferencia = puntoReferencia;
    }

    public String getTelefono() {
        return telefono;
    }

    public void setTelefono(String telefono) {
        this.telefono = telefono;
    }

    public String getHorarioAtencionInicio() {
        return horarioAtencionInicio;
    }

    public void setHorarioAtencionInicio(String horarioAtencionInicio) {
        this.horarioAtencionInicio = horarioAtencionInicio;
    }

    public String getHorarioAtencionFin() {
        return horarioAtencionFin;
    }

    public void setHorarioAtencionFin(String horarioAtencionFin) {
        this.horarioAtencionFin = horarioAtencionFin;
    }

    public String getRestriccionesAcceso() {
        return restriccionesAcceso;
    }

    public void setRestriccionesAcceso(String restriccionesAcceso) {
        this.restriccionesAcceso = restriccionesAcceso;
    }

    public OffsetDateTime getCreatedAt() {
        return createdAt;
    }

    public OffsetDateTime getUpdatedAt() {
        return updatedAt;
    }
}
