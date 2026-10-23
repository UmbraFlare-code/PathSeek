package com.pathseek.backend.route.entity;

import jakarta.persistence.*;
import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "reoptimizacion_eventos")
public class ReoptimizationEvent {
    @Id @Column(name = "evento_id") private UUID id;
    @Column(name = "solicitud_hash", nullable = false, length = 64) private String fingerprint;
    @Column(name = "respuesta_json", nullable = false, columnDefinition = "text") private String response;
    @Column(name = "created_at", nullable = false) private OffsetDateTime createdAt;
    protected ReoptimizationEvent() {}
    public ReoptimizationEvent(UUID id, String fingerprint, String response, OffsetDateTime createdAt) {
        this.id = id; this.fingerprint = fingerprint; this.response = response; this.createdAt = createdAt;
    }
    public UUID getId() { return id; }
    public String getFingerprint() { return fingerprint; }
    public String getResponse() { return response; }
}
