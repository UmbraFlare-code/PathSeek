package com.pathseek.backend.route.dto;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

public record RouteGeometryResponse(
        UUID rutaId,
        String encodedPolyline,
        List<WaypointDto> waypoints,
        List<ElevationPointDto> perfilElevacion,
        String nivelTraficoGeneral,
        BigDecimal distanciaTotalKm,
        Integer duracionEstimadaMinutos
) {
    public record WaypointDto(
            Integer orden,
            String tipo, // DEPOSITO, ENTREGA
            String etiqueta,
            BigDecimal lat,
            BigDecimal lon,
            String horaEstimada
    ) {}

    public record ElevationPointDto(
            BigDecimal distanciaAcumuladaKm,
            Integer elevacionMetros,
            String tipoCalzada
    ) {}
}
