package com.pathseek.backend.route.entity;

import com.pathseek.backend.route.dto.RoadIncidentRequest;
import jakarta.persistence.*;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;
import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.UUID;

@Entity
@Table(name = "ruta_incidentes", indexes = @Index(name = "idx_ruta_incidentes_activos", columnList = "ruta_id,activa"))
public class RoadIncident {
    @Id @GeneratedValue(strategy = GenerationType.UUID) @Column(name = "incidente_id") private UUID id;
    @ManyToOne(fetch = FetchType.LAZY, optional = false) @JoinColumn(name = "ruta_id", nullable = false)
    @OnDelete(action = OnDeleteAction.CASCADE) private DeliveryRoute ruta;
    @Column(nullable = false, length = 30) private String tipo;
    @Column(nullable = false, length = 1000) private String descripcion;
    @Column(nullable = false, precision = 9, scale = 6) private BigDecimal lat;
    @Column(nullable = false, precision = 9, scale = 6) private BigDecimal lon;
    @Column(name = "radio_metros", nullable = false) private int radius;
    @Column(nullable = false) private boolean activa = true;
    @Column(name = "created_at", nullable = false) private OffsetDateTime createdAt;
    protected RoadIncident() {}
    public RoadIncident(DeliveryRoute route, RoadIncidentRequest request) {
        ruta = route; tipo = request.tipo(); descripcion = request.descripcion(); lat = request.lat(); lon = request.lon();
        radius = request.radioAfectacionMetros() == null ? 250 : request.radioAfectacionMetros();
        createdAt = OffsetDateTime.now(ZoneOffset.UTC);
    }
    public UUID getId() { return id; }
    public UUID getRouteId() { return ruta.getId(); }
    public void resolve() { activa = false; }
    public RoadIncidentRequest toRequest() { return new RoadIncidentRequest(tipo, descripcion, lat, lon, radius); }
}
