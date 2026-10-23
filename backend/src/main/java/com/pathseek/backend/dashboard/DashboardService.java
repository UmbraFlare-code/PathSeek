package com.pathseek.backend.dashboard;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class DashboardService {
    private final JdbcTemplate jdbc;

    public DashboardService(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    @Transactional(readOnly = true)
    public DashboardSummaryResponse getSummary() {
        // Same metrics as sp_obtener_resumen_dashboard, also usable on H2 tests.
        return jdbc.queryForObject("""
                SELECT
                    (SELECT COUNT(*) FROM vehiculos) AS total_vehiculos,
                    (SELECT COUNT(*) FROM conductores WHERE disponible = TRUE) AS conductores_disponibles,
                    (SELECT COUNT(*) FROM pedidos WHERE estado = 'PENDIENTE') AS pedidos_pendientes,
                    (SELECT COUNT(*) FROM pedidos WHERE estado = 'EN_RUTA') AS pedidos_en_ruta,
                    (SELECT COUNT(*) FROM pedidos WHERE estado = 'ENTREGADO') AS pedidos_entregados,
                    (SELECT COUNT(*) FROM pedidos WHERE estado = 'CANCELADO') AS pedidos_cancelados,
                    (SELECT COUNT(*) FROM rutas WHERE estado = 'PLANIFICADA') AS rutas_planificadas,
                    COALESCE((SELECT SUM(co2_kg) FROM rutas), 0) AS co2_total_kg,
                    COALESCE((SELECT SUM(combustible_l) FROM rutas), 0) AS combustible_total_l
                """, (rs, rowNum) -> new DashboardSummaryResponse(
                rs.getLong("total_vehiculos"), rs.getLong("conductores_disponibles"),
                rs.getLong("pedidos_pendientes"), rs.getLong("pedidos_en_ruta"),
                rs.getLong("pedidos_entregados"), rs.getLong("pedidos_cancelados"),
                rs.getLong("rutas_planificadas"), rs.getBigDecimal("co2_total_kg"),
                rs.getBigDecimal("combustible_total_l")));
    }
}
