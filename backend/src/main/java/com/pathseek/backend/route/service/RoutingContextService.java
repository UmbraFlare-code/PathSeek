package com.pathseek.backend.route.service;

import com.pathseek.backend.route.dto.RoadIncidentRequest;
import com.pathseek.backend.route.repository.RoadIncidentRepository;
import com.pathseek.backend.route.repository.DeliveryRouteRepository;
import com.pathseek.backend.route.entity.RoadIncident;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;

@Service
public class RoutingContextService {

    public static final double DEPOT_LAT = -12.068300;
    public static final double DEPOT_LON = -75.210000;
    public static final int DEPOT_ELEVATION_M = 3260;

    private RoadIncidentRepository incidents;
    private DeliveryRouteRepository routes;
    private com.pathseek.backend.vehicle.repository.VehicleRepository vehicles;

    /** Geometry-only construction remains available to existing algorithm tests. */
    public RoutingContextService() {}
    @Autowired
    public RoutingContextService(RoadIncidentRepository incidents, DeliveryRouteRepository routes,
            com.pathseek.backend.vehicle.repository.VehicleRepository vehicles) {
        this.incidents = incidents; this.routes = routes;
        this.vehicles = vehicles;
    }

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

    @Transactional
    public void registrarIncidente(UUID rutaId, RoadIncidentRequest incidente) {
        if (incidents == null) throw new IllegalStateException("El almacenamiento de incidentes no está configurado");
        var lockedVehicles = vehicles.lockPlanningSubset(routes.findVehicleIds(List.of(rutaId)));
        var selected = routes.lockPlanningRoutes(List.of(rutaId));
        if (selected.isEmpty()) throw new com.pathseek.backend.exception.ResourceNotFoundException("Ruta no encontrada");
        if (lockedVehicles.stream().noneMatch(vehicle -> vehicle.getId().equals(selected.get(0).getVehiculo().getId()))) {
            throw new com.pathseek.backend.exception.BusinessConflictException("PLANNING_CHANGED", "La ruta cambió; reintente.");
        }
        incidents.save(new RoadIncident(selected.get(0), incidente));
    }

    @Transactional(readOnly = true)
    public List<RoadIncidentRequest> getIncidentes(UUID rutaId) {
        if (incidents == null) throw new IllegalStateException("El almacenamiento de incidentes no está configurado");
        return incidents.findByRuta_IdAndActivaTrue(rutaId).stream().map(RoadIncident::toRequest).toList();
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
