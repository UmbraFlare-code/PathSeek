package com.pathseek.backend.route.entity;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.persistence.*;
import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "ruta_notificaciones", indexes = @Index(name = "idx_ruta_notificaciones_usuario", columnList = "usuario_id,created_at"),
        uniqueConstraints = @UniqueConstraint(name = "uq_ruta_notificacion_evento", columnNames = {"evento_id", "ruta_id"}))
public class RouteNotification {
    @Id @GeneratedValue(strategy = GenerationType.UUID) @Column(name = "notificacion_id") private UUID id;
    @Column(name = "evento_id", nullable = false) private UUID eventId;
    @Column(name = "ruta_id", nullable = false) private UUID routeId;
    @Column(name = "conductor_id", nullable = false) private UUID driverId;
    @Column(name = "usuario_id") private UUID userId;
    @Column(nullable = false, length = 500) private String mensaje;
    @Column(nullable = false) private boolean leida;
    @Column(name = "created_at", nullable = false) private OffsetDateTime createdAt;
    protected RouteNotification() {}
    public RouteNotification(UUID eventId, DeliveryRoute route, String message, OffsetDateTime createdAt) {
        this.eventId = eventId; routeId = route.getId(); driverId = route.getConductor().getId();
        userId = route.getConductor().getUsuarioId(); mensaje = message; this.createdAt = createdAt;
    }
    public void markRead() { leida = true; }
    public UUID recipient() { return userId; }
    public View toView() { return new View(id, eventId, routeId, driverId, userId, mensaje, leida, createdAt); }
    public record View(@JsonProperty("notificacion_id") UUID id, @JsonProperty("evento_id") UUID eventId,
            @JsonProperty("ruta_id") UUID routeId, @JsonProperty("conductor_id") UUID driverId,
            @JsonProperty("usuario_id") UUID userId, String mensaje, boolean leida, @JsonProperty("created_at") OffsetDateTime createdAt) {}
}
