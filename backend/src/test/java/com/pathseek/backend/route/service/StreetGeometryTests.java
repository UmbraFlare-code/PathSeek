package com.pathseek.backend.route.service;

import com.sun.net.httpserver.HttpServer;
import org.junit.jupiter.api.Test;
import tools.jackson.databind.ObjectMapper;
import java.net.InetSocketAddress;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.concurrent.atomic.AtomicReference;
import static org.junit.jupiter.api.Assertions.*;

class StreetGeometryTests {
    private final List<double[]> stops = List.of(new double[]{-12.0683, -75.21}, new double[]{-12.07, -75.207});

    @Test void preservesOrderAndUsesLongitudeLatitudeAndFullPolyline() throws Exception {
        AtomicReference<String> uri = new AtomicReference<>();
        try (var server = server(200, "{\"code\":\"Ok\",\"waypoints\":[{},{}],\"routes\":[{\"geometry\":\"abc123\",\"distance\":1250,\"duration\":180}]}", uri)) {
            var geometry = service(server).route(stops);
            assertEquals("OSRM", geometry.source()); assertEquals("abc123", geometry.encoded());
            assertEquals(1.25, geometry.distanceKm()); assertEquals(3.0, geometry.durationMinutes());
            assertTrue(uri.get().contains("/-75.21,-12.0683;-75.207,-12.07?"));
            assertTrue(uri.get().contains("overview=full&geometries=polyline"));
            assertFalse(uri.get().contains("trip/"));
        }
    }

    @Test void unavailableOrInvalidProviderNeverClaimsStreetGeometry() throws Exception {
        for (String body : List.of("{\"code\":\"NoRoute\"}", "invalid json", "{\"code\":\"Ok\",\"routes\":[{}]}")) {
            try (var server = server(200, body, new AtomicReference<>())) {
                var geometry = service(server).route(stops);
                assertEquals("SCHEMATIC", geometry.source()); assertNull(geometry.encoded());
            }
        }
        try (var server = server(503, "{}", new AtomicReference<>())) {
            assertEquals("PROVIDER_UNAVAILABLE", service(server).route(stops).status());
        }
    }

    @Test void disabledAndOversizedRoutesDoNotCallProvider() {
        assertEquals("DISABLED", new StreetGeometryService(false, "invalid", new ObjectMapper()).route(stops).status());
        assertEquals("WAYPOINT_LIMIT", new StreetGeometryService(true, "invalid", new ObjectMapper())
                .route(java.util.Collections.nCopies(101, stops.get(0))).status());
    }

    private StreetGeometryService service(Server server) {
        return new StreetGeometryService(true, "http://127.0.0.1:" + server.getAddress().getPort(), new ObjectMapper());
    }
    private Server server(int status, String body, AtomicReference<String> uri) throws Exception {
        return new Server(status, body, uri);
    }
    private static class Server implements AutoCloseable {
        final HttpServer server;
        Server(int status, String body, AtomicReference<String> uri) throws Exception {
            server = HttpServer.create(new InetSocketAddress("127.0.0.1", 0), 0);
            server.createContext("/", exchange -> {
                uri.set(exchange.getRequestURI().toString());
                byte[] bytes = body.getBytes(StandardCharsets.UTF_8);
                exchange.sendResponseHeaders(status, bytes.length);
                try (var out = exchange.getResponseBody()) { out.write(bytes); }
            }); server.start();
        }
        InetSocketAddress getAddress() { return server.getAddress(); }
        @Override public void close() { server.stop(0); }
    }
}
