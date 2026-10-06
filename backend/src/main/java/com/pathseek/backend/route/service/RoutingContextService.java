package com.pathseek.backend.route.service;

import com.pathseek.backend.route.dto.RoadContextDto;
import com.pathseek.backend.route.dto.RoadIncidentRequest;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class RoutingContextService {

    public static final double DEPOT_LAT = -12.068300;
    public static final double DEPOT_LON = -75.210000;
    public static final int DEPOT_ELEVATION_M = 3260;

    private final Map<UUID, List<RoadIncidentRequest>> incidentesPorRuta = new ConcurrentHashMap<>();

    /**
     * Calcula la distancia vial estimada en kilómetros considerando el factor de serpenteo de calles andinas.
     */
    public double calculateRoadDistanceKm(double lat1, double lon1, double lat2, double lon2) {
        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);

        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                   Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2)) *
                   Math.sin(dLon / 2) * Math.sin(dLon / 2);

        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        double haversineKm = 6371.0 * c;

        // Factor de curvatura urbana y orográfica de Huancayo (1.35x sobre la distancia recta)
        return haversineKm * 1.35;
    }

    /**
     * Obtiene el factor de ajuste de consumo según superficie y altitud.
     */
    public double getSurfaceAndSlopeMultiplier(double lat, double lon) {
        // En altitudes periurbanas (>3,400 m) el consumo de combustible aumenta por menor oxigenación y pendiente
        if (lat < -12.09 || lat > -12.04 || lon < -75.24) {
            return 1.25; // 25% extra por vías afirmadas y subida
        }
        return 1.0;
    }

    public void registrarIncidente(UUID rutaId, RoadIncidentRequest incidente) {
        incidentesPorRuta.computeIfAbsent(rutaId, k -> new ArrayList<>()).add(incidente);
    }

    public List<RoadIncidentRequest> getIncidentes(UUID rutaId) {
        return incidentesPorRuta.getOrDefault(rutaId, List.of());
    }

    /**
     * Genera un Polyline codificado estándar para dibujar la ruta en mapas.
     */
    public String encodeCoordinates(List<double[]> points) {
        StringBuilder encoded = new StringBuilder();
        int prevLat = 0;
        int prevLon = 0;

        for (double[] point : points) {
            int lat = (int) Math.round(point[0] * 1e5);
            int lon = (int) Math.round(point[1] * 1e5);

            encodeValue(lat - prevLat, encoded);
            encodeValue(lon - prevLon, encoded);

            prevLat = lat;
            prevLon = lon;
        }

        return encoded.toString();
    }

    private void encodeValue(int val, StringBuilder result) {
        int v = val < 0 ? ~(val << 1) : (val << 1);
        while (v >= 0x20) {
            result.append((char) ((0x20 | (v & 0x1f)) + 63));
            v >>= 5;
        }
        result.append((char) (v + 63));
    }
}
