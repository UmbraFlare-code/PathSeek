package com.pathseek.backend.route.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import tools.jackson.databind.ObjectMapper;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.List;
import java.util.stream.Collectors;

/** Visualization only: Route service preserves the supplied operational stop order. */
@Service
public class StreetGeometryService {
    private final boolean enabled;
    private final String baseUrl;
    private final ObjectMapper json;
    private final HttpClient client = HttpClient.newBuilder().version(HttpClient.Version.HTTP_1_1)
            .connectTimeout(Duration.ofSeconds(3)).build();
    private final java.util.concurrent.atomic.AtomicLong nextRequest = new java.util.concurrent.atomic.AtomicLong();
    private final java.util.concurrent.ConcurrentMap<String, Cached> cache = new java.util.concurrent.ConcurrentHashMap<>();
    private record Cached(Geometry geometry, long expiresAt) {}

    public StreetGeometryService(@Value("${app.routing.enabled:false}") boolean enabled,
            @Value("${app.routing.base-url:https://router.project-osrm.org}") String baseUrl, ObjectMapper json) {
        this.enabled = enabled; this.baseUrl = baseUrl.replaceAll("/+$", ""); this.json = json;
    }

    public record Geometry(String encoded, String source, String status, Double distanceKm, Double durationMinutes) {}

    public Geometry route(List<double[]> stops) {
        if (!enabled) return fallback("DISABLED");
        if (stops.size() < 2 || stops.size() > 100) return fallback("WAYPOINT_LIMIT");
        try {
            String coordinates = stops.stream().map(p -> Double.toString(p[1]) + "," + Double.toString(p[0]))
                    .collect(Collectors.joining(";"));
            long now = System.nanoTime();
            var cached = cache.get(coordinates);
            if (cached != null && now < cached.expiresAt()) return cached.geometry();
            long next = nextRequest.get();
            if (now < next || !nextRequest.compareAndSet(next, now + Duration.ofSeconds(1).toNanos())) return fallback("RATE_LIMITED");
            // Limit snapping: do not silently route to a distant road instead of the requested delivery.
            String radiuses = stops.stream().map(p -> "100").collect(Collectors.joining(";"));
            URI uri = URI.create(baseUrl + "/route/v1/driving/" + coordinates
                    + "?overview=full&geometries=polyline&steps=false&alternatives=false&radiuses=" + radiuses);
            HttpRequest request = HttpRequest.newBuilder(uri).timeout(Duration.ofSeconds(8))
                    .header("User-Agent", "PathSeek/1.0").GET().build();
            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
            if (response.statusCode() != 200) return fallback("PROVIDER_UNAVAILABLE");
            var body = json.readTree(response.body());
            if (!"Ok".equals(body.path("code").asText()) || body.path("routes").size() == 0) return fallback("NO_ROUTE");
            var route = body.path("routes").get(0);
            String encoded = route.path("geometry").asText("");
            double distance = route.path("distance").asDouble(-1), duration = route.path("duration").asDouble(-1);
            if (encoded.isBlank() || !Double.isFinite(distance) || !Double.isFinite(duration) || distance < 0 || duration < 0
                    || body.path("waypoints").size() != stops.size()) return fallback("INVALID_RESPONSE");
            Geometry geometry = new Geometry(encoded, "OSRM", "OK", distance / 1000, duration / 60);
            if (cache.size() >= 128) cache.clear();
            cache.put(coordinates, new Cached(geometry, System.nanoTime() + Duration.ofMinutes(5).toNanos()));
            return geometry;
        } catch (InterruptedException interrupted) {
            Thread.currentThread().interrupt(); return fallback("PROVIDER_UNAVAILABLE");
        } catch (Exception unavailable) {
            return fallback("PROVIDER_UNAVAILABLE");
        }
    }

    public static Geometry fallback(String status) { return new Geometry(null, "SCHEMATIC", status, null, null); }
}
