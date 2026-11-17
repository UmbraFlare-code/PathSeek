package com.pathseek.backend.dashboard;

import com.pathseek.backend.route.service.RoutingContextService;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Isolation;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Clock;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

import static com.pathseek.backend.route.service.RoutingContextService.DEPOT_LAT;
import static com.pathseek.backend.route.service.RoutingContextService.DEPOT_LON;

@Service
public class DashboardService {
    private static final ZoneId LIMA = ZoneId.of("America/Lima");
    private final JdbcTemplate jdbc;
    private final RoutingContextService routing;
    private final Clock clock;
    private final BigDecimal fuelPrice;

    public DashboardService(JdbcTemplate jdbc, RoutingContextService routing, Clock clock,
                            @Value("${app.dashboard.fuel-price-pen-per-liter:0}") BigDecimal fuelPrice) {
        this.jdbc = jdbc;
        this.routing = routing;
        this.clock = clock;
        this.fuelPrice = fuelPrice;
    }

    @Transactional(readOnly = true, isolation = Isolation.REPEATABLE_READ)
    public DashboardSummaryResponse getSummary() {
        var comparison = compareToday(LocalDate.now(clock.withZone(LIMA)));
        return jdbc.queryForObject("""
                SELECT
                    (SELECT COUNT(*) FROM vehiculos) AS total_vehiculos,
                    (SELECT COUNT(*) FROM conductores WHERE disponible = TRUE) AS conductores_disponibles,
                    (SELECT COUNT(*) FROM pedidos WHERE estado = 'PENDIENTE') AS pedidos_pendientes,
                    (SELECT COUNT(*) FROM pedidos WHERE estado = 'EN_RUTA') AS pedidos_en_ruta,
                    (SELECT COUNT(*) FROM pedidos WHERE estado = 'ENTREGADO') AS pedidos_entregados,
                    (SELECT COUNT(*) FROM pedidos WHERE estado = 'CANCELADO') AS pedidos_cancelados,
                    COUNT(CASE WHEN estado = 'PLANIFICADA' THEN 1 END) AS rutas_planificadas,
                    COALESCE(SUM(co2_kg), 0) AS co2_total_kg,
                    COALESCE(SUM(combustible_l), 0) AS combustible_total_l,
                    COUNT(CASE WHEN estado = 'COMPLETADA' THEN 1 END) AS rutas_completadas,
                    COALESCE(SUM(CASE WHEN estado = 'COMPLETADA' THEN distancia_km END), 0) AS distancia_ejecutada,
                    COALESCE(SUM(CASE WHEN estado = 'COMPLETADA' THEN co2_kg END), 0) AS co2_ejecutado,
                    COALESCE(SUM(CASE WHEN estado = 'COMPLETADA' THEN combustible_l END), 0) AS combustible_ejecutado,
                    (SELECT COUNT(*) FROM ruta_pedidos rp JOIN rutas r ON r.ruta_id = rp.ruta_id
                        WHERE r.estado = 'COMPLETADA' AND rp.entregado_en IS NOT NULL) AS entregas_con_hora,
                    (SELECT COUNT(*) FROM ruta_pedidos rp JOIN rutas r ON r.ruta_id = rp.ruta_id
                        WHERE r.estado = 'COMPLETADA' AND rp.entregado_en IS NOT NULL
                          AND rp.cumplio_ventana = TRUE) AS entregas_a_tiempo
                FROM rutas
                """, (rs, rowNum) -> {
            long timed = rs.getLong("entregas_con_hora");
            var executed = new DashboardSummaryResponse.ExecutedRoutes(
                    rs.getLong("rutas_completadas"), rs.getBigDecimal("distancia_ejecutada"),
                    rs.getBigDecimal("co2_ejecutado"), rs.getBigDecimal("combustible_ejecutado"), timed,
                    percentage(BigDecimal.valueOf(rs.getLong("entregas_a_tiempo")), BigDecimal.valueOf(timed)),
                    comparison);
            return new DashboardSummaryResponse(
                    rs.getLong("total_vehiculos"), rs.getLong("conductores_disponibles"),
                    rs.getLong("pedidos_pendientes"), rs.getLong("pedidos_en_ruta"),
                    rs.getLong("pedidos_entregados"), rs.getLong("pedidos_cancelados"),
                    rs.getLong("rutas_planificadas"), rs.getBigDecimal("co2_total_kg"),
                    rs.getBigDecimal("combustible_total_l"), executed);
        });
    }

    private DashboardSummaryResponse.DailyComparison compareToday(LocalDate today) {
        var stops = jdbc.query("""
                SELECT r.ruta_id, r.combustible_l, v.consumo_km_l, p.gps_lat, p.gps_lon
                FROM rutas r
                JOIN vehiculos v ON v.vehiculo_id = r.vehiculo_id
                JOIN ruta_pedidos rp ON rp.ruta_id = r.ruta_id
                JOIN pedidos p ON p.pedido_id = rp.pedido_id AND p.estado = 'ENTREGADO'
                WHERE r.estado = 'COMPLETADA'
                  AND r.combustible_l > 0
                  AND ((r.completada_en >= ? AND r.completada_en < ?)
                       OR (r.completada_en IS NULL AND r.fecha = ?))
                ORDER BY r.ruta_id, p.created_at, p.pedido_id
                """, (rs, row) -> new SequentialStop(rs.getObject("ruta_id", UUID.class),
                rs.getBigDecimal("combustible_l"), rs.getDouble("consumo_km_l"),
                rs.getDouble("gps_lat"), rs.getDouble("gps_lon")),
                today.atStartOfDay(LIMA).toOffsetDateTime(), today.plusDays(1).atStartOfDay(LIMA).toOffsetDateTime(), today);
        Map<UUID, List<SequentialStop>> byRoute = stops.stream().collect(Collectors.groupingBy(SequentialStop::routeId));
        double baseline = 0;
        BigDecimal used = BigDecimal.ZERO;
        for (var route : byRoute.values()) {
            var first = route.get(0);
            baseline += sequentialDistance(route) / first.kmPerLiter();
            used = used.add(first.fuelLiters());
        }
        var sequential = rounded(BigDecimal.valueOf(baseline));
        if (sequential.signum() <= 0) return null;
        var savings = sequential.subtract(used);
        return new DashboardSummaryResponse.DailyComparison(sequential, savings, percentage(savings, sequential),
                fuelPrice.signum() > 0 ? rounded(savings.multiply(fuelPrice)) : null);
    }

    private double sequentialDistance(List<SequentialStop> stops) {
        double distance = 0;
        double lat = DEPOT_LAT;
        double lon = DEPOT_LON;
        for (var stop : stops) {
            distance += routing.calculateRoadDistanceKm(lat, lon, stop.lat(), stop.lon());
            lat = stop.lat();
            lon = stop.lon();
        }
        return distance + routing.calculateRoadDistanceKm(lat, lon, DEPOT_LAT, DEPOT_LON);
    }

    private static BigDecimal percentage(BigDecimal value, BigDecimal total) {
        return total.signum() == 0 ? null : value.movePointRight(2).divide(total, 2, RoundingMode.HALF_UP);
    }

    private static BigDecimal rounded(BigDecimal value) {
        return value.setScale(2, RoundingMode.HALF_UP);
    }

    private record SequentialStop(UUID routeId, BigDecimal fuelLiters, double kmPerLiter, double lat, double lon) {}
}
