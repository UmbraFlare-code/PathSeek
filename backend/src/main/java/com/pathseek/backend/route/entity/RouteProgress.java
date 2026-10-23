package com.pathseek.backend.route.entity;
import jakarta.persistence.*;
import java.math.BigDecimal;
import java.util.UUID;

/** Frozen estimated prefix at the last accepted position; vehicle changes cannot rewrite it. */
@Entity
@Table(name = "ruta_progreso")
public class RouteProgress {
    @Id @Column(name = "ruta_id") private UUID id;
    @Column(nullable = false, precision = 9, scale = 6) private BigDecimal lat;
    @Column(nullable = false, precision = 9, scale = 6) private BigDecimal lon;
    @Column(name = "ultimo_orden", nullable = false) private int lastOrder;
    @Column(name = "distancia_km", nullable = false, precision = 12, scale = 6) private BigDecimal distance;
    @Column(name = "combustible_l", nullable = false, precision = 12, scale = 6) private BigDecimal fuel;
    @Column(name = "co2_kg", nullable = false, precision = 12, scale = 6) private BigDecimal co2;
    protected RouteProgress() {}
    public RouteProgress(UUID id, double lat, double lon, int lastOrder, double distance, double fuel, double co2) {
        this.id = id; this.lat = BigDecimal.valueOf(lat); this.lon = BigDecimal.valueOf(lon); this.lastOrder = lastOrder;
        this.distance = BigDecimal.valueOf(distance); this.fuel = BigDecimal.valueOf(fuel); this.co2 = BigDecimal.valueOf(co2);
    }
    public UUID getId() { return id; }
    public double lat() { return lat.doubleValue(); }
    public double lon() { return lon.doubleValue(); }
    public int lastOrder() { return lastOrder; }
    public double distance() { return distance.doubleValue(); }
    public double fuel() { return fuel.doubleValue(); }
    public double co2() { return co2.doubleValue(); }
}
