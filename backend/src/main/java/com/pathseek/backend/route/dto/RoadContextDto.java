package com.pathseek.backend.route.dto;

import java.math.BigDecimal;
import java.util.List;

public record RoadContextDto(
        String tipoSuperficie, // ASFALTO, AFIRMADO, TROCHA
        BigDecimal factorCalzada,
        Integer elevacionMetros,
        BigDecimal pendienteMediaPorcentaje,
        String nivelCongestion, // FLUIDO, MODERADO, CONGESTIONADO
        List<String> restriccionesViales,
        List<String> incidentesActivos
) {
    public static RoadContextDto defaultForHuancayo(BigDecimal lat, BigDecimal lon) {
        // Contexto aproximado según coordenadas en Huancayo y valles circundantes
        double latitude = lat != null ? lat.doubleValue() : -12.0683;
        double longitude = lon != null ? lon.doubleValue() : -75.2100;

        String superficie = "ASFALTO";
        BigDecimal factor = BigDecimal.valueOf(1.0);
        int elevacion = 3260;
        BigDecimal pendiente = BigDecimal.valueOf(2.5);
        String congestion = "FLUIDO";

        // Zonas altas periurbanas / rurales
        if (latitude < -12.09 || latitude > -12.04 || longitude < -75.24) {
            superficie = "AFIRMADO";
            factor = BigDecimal.valueOf(1.25);
            elevacion = 3450;
            pendiente = BigDecimal.valueOf(6.8);
        }

        return new RoadContextDto(
                superficie,
                factor,
                elevacion,
                pendiente,
                congestion,
                List.of("DS N.° 033-2012-MTC Restricción Placa"),
                List.of()
        );
    }
}
