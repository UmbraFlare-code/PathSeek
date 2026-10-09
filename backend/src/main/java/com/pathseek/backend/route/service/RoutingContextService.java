package com.pathseek.backend.route.service;

import com.pathseek.backend.route.dto.RoadIncidentRequest;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
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

    private final OsmRoutingService osmRoutingService;
    private final Map<UUID, List<RoadIncidentRequest>> incidentesPorRuta = new ConcurrentHashMap<>();

    public RoutingContextService(OsmRoutingService osmRoutingService) {
        this.osmRoutingService = osmRoutingService;
    }

    /**
     * Calcula la distancia vial estimada en kilómetros considerando la red vial de OpenStreetMap y orografía andina.
     */
    public double calculateRoadDistanceKm(double lat1, double lon1, double lat2, double lon2) {
        OsmRoutingService.RouteSegmentResult segment = osmRoutingService.calculateSegment(lat1, lon1, lat2, lon2);
        return segment.distanceKm();
    }

    /**
     * Traza la trayectoria completa entre paradas siguiendo estrictamente las carreteras permitidas de OpenStreetMap.
     */
    public List<double[]> getDetailedRoadPath(List<double[]> stops) {
        if (stops == null || stops.isEmpty()) return List.of();
        OsmRoutingService.RouteSegmentResult result = osmRoutingService.calculateMultiPointRoute(stops);
        return result.coordinates();
    }

    /**
     * Evalúa el multiplicador de tráfico / incidencias estilo Waze para un tramo vial.
     */
    public double getTrafficPenaltyFactor(double lat1, double lon1, double lat2, double lon2, UUID rutaId) {
        List<RoadIncidentRequest> incidentes = getIncidentes(rutaId);
        double penalty = 1.0;

        for (RoadIncidentRequest inc : incidentes) {
            if (inc.lat() != null && inc.lon() != null) {
                double incLat = inc.lat().doubleValue();
                double incLon = inc.lon().doubleValue();
                double radiusKm = (inc.radioAfectacionMetros() != null ? inc.radioAfectacionMetros() : 250) / 1000.0;

                // Verificar si cualquiera de los puntos o el punto medio cae dentro del radio del incidente
                double d1 = osmRoutingService.haversineDistanceKm(lat1, lon1, incLat, incLon);
                double d2 = osmRoutingService.haversineDistanceKm(lat2, lon2, incLat, incLon);
                double dMid = osmRoutingService.haversineDistanceKm((lat1 + lat2) / 2.0, (lon1 + lon2) / 2.0, incLat, incLon);

                if (d1 <= radiusKm || d2 <= radiusKm || dMid <= radiusKm) {
                    String tipo = inc.tipo() != null ? inc.tipo().toUpperCase() : "CONGESTION";
                    if (tipo.contains("BLOQUEO") || tipo.contains("HUAICO") || tipo.contains("CERRADA")) {
                        return 10.0; // Penalización máxima para forzar desvío
                    } else if (tipo.contains("ACCIDENTE") || tipo.contains("SEVERA")) {
                        penalty = Math.max(penalty, 2.5);
                    } else if (tipo.contains("OBRAS")) {
                        penalty = Math.max(penalty, 1.8);
                    } else {
                        penalty = Math.max(penalty, 1.4);
                    }
                }
            }
        }
        return penalty;
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

    public void limpiarIncidentes(UUID rutaId) {
        incidentesPorRuta.remove(rutaId);
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
