package com.pathseek.backend;

import com.pathseek.backend.driver.entity.Driver;
import com.pathseek.backend.driver.entity.DriverCategory;
import com.pathseek.backend.driver.repository.DriverRepository;
import com.pathseek.backend.order.entity.Order;
import com.pathseek.backend.order.entity.OrderPriority;
import com.pathseek.backend.order.entity.OrderStatus;
import com.pathseek.backend.order.entity.ProductType;
import com.pathseek.backend.order.repository.OrderRepository;
import com.pathseek.backend.route.dto.GenerateRoutesResponse;
import com.pathseek.backend.route.repository.DeliveryRouteRepository;
import com.pathseek.backend.route.service.RouteOptimizationService;
import com.pathseek.backend.vehicle.entity.Vehicle;
import com.pathseek.backend.vehicle.entity.VehicleType;
import com.pathseek.backend.vehicle.repository.VehicleRepository;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.condition.EnabledIfEnvironmentVariable;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import tools.jackson.databind.ObjectMapper;

import java.math.BigDecimal;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.Duration;
import java.time.LocalDate;
import java.util.Map;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertTimeout;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.junit.jupiter.api.Assertions.assertEquals;

/**
 * EN-001: generación de rutas válidas en ≤ 45 s para 150 pedidos y 15 vehículos.
 * EN-005: prueba de volumen con 1,000 pedidos y 50 vehículos (opt-in, sin SLA rígido).
 * Los artefactos JSON quedan en {@code target/} como evidencia reproducible.
 */
@SpringBootTest
@ActiveProfiles("test")
class GenerationPerformanceTests {

    private static final Duration SLA = Duration.ofSeconds(45);

    @Autowired RouteOptimizationService generation;
    @Autowired DeliveryRouteRepository routes;
    @Autowired OrderRepository orders;
    @Autowired VehicleRepository vehicles;
    @Autowired DriverRepository drivers;
    @Autowired ObjectMapper json;
    int sequence;

    @AfterEach
    void cleanup() {
        routes.deleteAll();
        orders.deleteAll();
        vehicles.deleteAll();
        drivers.deleteAll();
    }

    @Test
    void referenceLoad150Orders15VehiclesCompletesBelow45Seconds() throws Exception {
        seed(150, 15);
        long started = System.nanoTime();
        GenerateRoutesResponse result = assertTimeout(SLA, () -> generation.generateRoutes());
        double elapsedMs = (System.nanoTime() - started) / 1_000_000.0;
        assertTrue(result.rutas().size() > 0, "Se esperaban rutas generadas");
        assertEquals(0, result.pedidosNoAsignados().size(), "Todos los pedidos debían asignarse");
        assertTrue(elapsedMs < 45_000, "SLA de generación excedido: " + elapsedMs + " ms");
        writeArtifact("generation-benchmark-150x15.json", Map.of(
                "scenario", "150_pedidos_15_vehiculos",
                "pedidos", 150, "vehiculos", 15,
                "rutas_generadas", result.rutas().size(),
                "local_elapsed_ms", elapsedMs, "sla_ms", 45000));
    }

    @Test
    @EnabledIfEnvironmentVariable(named = "PATHSEEK_LOAD_TEST", matches = "true")
    void projectedLoad1000Orders50VehiclesRemainsStable() throws Exception {
        seed(1000, 50);
        long started = System.nanoTime();
        GenerateRoutesResponse result = assertTimeout(Duration.ofSeconds(300), () -> generation.generateRoutes());
        double elapsedMs = (System.nanoTime() - started) / 1_000_000.0;
        assertTrue(result.rutas().size() > 0);
        writeArtifact("generation-benchmark-1000x50.json", Map.of(
                "scenario", "1000_pedidos_50_vehiculos",
                "pedidos", 1000, "vehiculos", 50,
                "rutas_generadas", result.rutas().size(),
                "pedidos_no_asignados", result.pedidosNoAsignados().size(),
                "local_elapsed_ms", elapsedMs));
    }

    private void seed(int orderCount, int vehicleCount) {
        for (int i = 0; i < vehicleCount; i++) {
            Vehicle vehicle = new Vehicle();
            vehicle.setPlaca("PERF-" + String.format("%03d", ++sequence));
            vehicle.setTipo(VehicleType.CAMIONETA);
            vehicle.setCapacidadKg(BigDecimal.valueOf(1000));
            vehicle.setCapacidadM3(BigDecimal.valueOf(100));
            vehicle.setConsumoKmL(BigDecimal.TEN);
            vehicle.setFactorEmision(BigDecimal.valueOf(0.2));
            vehicle.setAnio(2024);
            vehicles.save(vehicle);

            Driver driver = new Driver();
            driver.setNombre("Conductor perf " + i);
            driver.setDni(String.format("%08d", ++sequence));
            driver.setLicencia("P" + driver.getDni());
            driver.setCategoria(DriverCategory.AII);
            driver.setExperiencia(4);
            driver.setDisponible(true);
            drivers.save(driver);
        }
        for (int i = 0; i < orderCount; i++) {
            Order order = new Order();
            order.setClienteId(UUID.randomUUID().toString());
            order.setDireccion("Carga sintética " + i);
            order.setGpsLat(BigDecimal.valueOf(-12.06 - (i % 40) * 0.0009));
            order.setGpsLon(BigDecimal.valueOf(-75.20 - (i % 30) * 0.0006));
            order.setPeso(BigDecimal.TEN);
            order.setVolumen(BigDecimal.ONE);
            order.setVentanaInicio("07:00");
            order.setVentanaFin("23:00");
            order.setPrioridad(i % 5 == 0 ? OrderPriority.EXPRESS : OrderPriority.ESTANDAR);
            order.setTipoProducto(ProductType.NO_PERECEDERO);
            order.setEstado(OrderStatus.PENDIENTE);
            orders.save(order);
        }
        System.out.println("Seeded " + orderCount + " pedidos y " + vehicleCount + " vehículos (fecha " + LocalDate.now() + ")");
    }

    private void writeArtifact(String fileName, Map<String, ?> metrics) throws Exception {
        Files.createDirectories(Path.of("target"));
        Files.writeString(Path.of("target/" + fileName), json.writeValueAsString(metrics));
        System.out.println("GENERATION_BENCHMARK " + json.writeValueAsString(metrics));
    }
}
