package com.pathseek.backend.carbon;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Clock;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.List;

/**
 * Plan de compensación de huella de carbono (US-010 / RF-010).
 * Las emisiones anuales provienen de rutas COMPLETADA registradas en los
 * últimos 12 meses; los árboles equivalentes usan el factor de US-010
 * (1 árbol ≈ 0.02 t CO₂/año → 42 t ≈ 2,100 árboles).
 */
@Service
public class CarbonOffsetService {

    private static final BigDecimal TONS_PER_TREE = new BigDecimal("0.02");

    private final JdbcTemplate jdbc;
    private final CarbonProjectRepository projects;
    private final Clock clock;

    public CarbonOffsetService(JdbcTemplate jdbc, CarbonProjectRepository projects, Clock clock) {
        this.jdbc = jdbc;
        this.projects = projects;
        this.clock = clock;
    }

    @Transactional(readOnly = true)
    public CarbonPlanResponse plan() {
        LocalDate today = LocalDate.now(clock.withZone(ZoneId.of("America/Lima")));
        LocalDate from = today.minusYears(1);
        BigDecimal co2Kg = jdbc.queryForObject(
                "SELECT COALESCE(SUM(co2_kg), 0) FROM rutas WHERE estado = 'COMPLETADA' AND fecha >= ? AND fecha <= ?",
                BigDecimal.class, from, today);
        if (co2Kg == null) co2Kg = BigDecimal.ZERO;
        BigDecimal toneladas = co2Kg.divide(BigDecimal.valueOf(1000), 3, RoundingMode.HALF_UP);
        long trees = (long) Math.ceil(toneladas.divide(TONS_PER_TREE, 6, RoundingMode.HALF_UP).doubleValue());

        List<CarbonPlanResponse.ProjectOption> options = projects.findByActivoTrueOrderByNombreAsc().stream()
                .map(project -> new CarbonPlanResponse.ProjectOption(
                        project.getId(),
                        project.getNombre(),
                        project.getTipo(),
                        project.getCostoTonelada(),
                        project.getCostoTonelada().multiply(toneladas).setScale(2, RoundingMode.HALF_UP),
                        project.getDescripcion()))
                .toList();

        return new CarbonPlanResponse(co2Kg.setScale(2, RoundingMode.HALF_UP), toneladas, trees, from, today, options);
    }
}
