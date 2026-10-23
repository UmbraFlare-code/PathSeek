package com.pathseek.backend.route.entity;
import jakarta.persistence.*;
import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "vehiculo_averias")
public class VehicleBreakdown {
    @Id @Column(name = "vehiculo_id") private UUID id;
    @Column(nullable = false) private boolean activa;
    @Column(name = "updated_at", nullable = false) private OffsetDateTime updatedAt;
    protected VehicleBreakdown() {}
    public VehicleBreakdown(UUID id, OffsetDateTime now) { this.id = id; activa = true; updatedAt = now; }
    public void resolve(OffsetDateTime now) { activa = false; updatedAt = now; }
    public UUID getId() { return id; }
}
