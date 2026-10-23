package com.pathseek.backend;

import com.jayway.jsonpath.JsonPath;
import com.pathseek.backend.auth.repository.RefreshTokenRepository;
import com.pathseek.backend.driver.entity.Driver;
import com.pathseek.backend.driver.entity.DriverCategory;
import com.pathseek.backend.driver.repository.DriverRepository;
import com.pathseek.backend.order.entity.Order;
import com.pathseek.backend.order.entity.OrderPriority;
import com.pathseek.backend.order.entity.OrderStatus;
import com.pathseek.backend.order.entity.ProductType;
import com.pathseek.backend.order.repository.OrderRepository;
import com.pathseek.backend.route.repository.DeliveryRouteRepository;
import com.pathseek.backend.route.entity.DeliveryRoute;
import com.pathseek.backend.route.entity.RouteStatus;
import com.pathseek.backend.route.service.RouteOptimizationService;
import com.pathseek.backend.user.entity.User;
import com.pathseek.backend.user.entity.UserRole;
import com.pathseek.backend.security.JwtService;
import com.pathseek.backend.user.repository.UserRepository;
import com.pathseek.backend.vehicle.entity.Vehicle;
import com.pathseek.backend.vehicle.entity.VehicleType;
import com.pathseek.backend.vehicle.repository.VehicleRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import java.math.BigDecimal;
import java.util.UUID;
import java.time.LocalDate;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class RouteIntegrationTests {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private DeliveryRouteRepository routeRepository;

    @Autowired
    private VehicleRepository vehicleRepository;

    @Autowired
    private DriverRepository driverRepository;

    @Autowired
    private OrderRepository orderRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private RefreshTokenRepository refreshTokenRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private JwtService jwtService;

    @Autowired
    private RouteOptimizationService optimizationService;

    private String adminToken;

    @BeforeEach
    void setUp() throws Exception {
        routeRepository.deleteAll();
        orderRepository.deleteAll();
        vehicleRepository.deleteAll();
        driverRepository.deleteAll();
        refreshTokenRepository.deleteAll();
        userRepository.deleteAll();

        User admin = new User();
        admin.setNombre("Admin General");
        admin.setEmail("admin@pathseek.pe");
        admin.setPasswordHash(passwordEncoder.encode("Secret123!"));
        admin.setRol(UserRole.ADMIN);
        admin.setActivo(true);
        userRepository.save(admin);

        String loginBody = """
                {
                  "email": "admin@pathseek.pe",
                  "password": "Secret123!"
                }
                """;

        String response = mockMvc.perform(post("/api/v1/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(loginBody))
                .andExpect(status().isOk())
                .andReturn()
                .getResponse()
                .getContentAsString();

        adminToken = JsonPath.read(response, "$.token");
    }

    @Test
    void getRoutesEmptyInitially() throws Exception {
        mockMvc.perform(get("/api/v1/rutas")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + adminToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray());
    }

    @Test
    void dashboardReturnsFrontendContractWithZeroTotals() throws Exception {
        mockMvc.perform(get("/api/v1/dashboard/resumen")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + adminToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.total_vehiculos").value(0))
                .andExpect(jsonPath("$.conductores_disponibles").value(0))
                .andExpect(jsonPath("$.pedidos_pendientes").value(0))
                .andExpect(jsonPath("$.pedidos_en_ruta").value(0))
                .andExpect(jsonPath("$.pedidos_entregados").value(0))
                .andExpect(jsonPath("$.pedidos_cancelados").value(0))
                .andExpect(jsonPath("$.rutas_planificadas").value(0))
                .andExpect(jsonPath("$.co2_total_kg").value(0))
                .andExpect(jsonPath("$.combustible_total_l").value(0));
    }

    @Test
    void dashboardEnforcesFrontendRolePermissions() throws Exception {
        mockMvc.perform(get("/api/v1/dashboard/resumen")).andExpect(status().isUnauthorized());
        for (UserRole role : UserRole.values()) {
            User user = new User();
            user.setNombre("Role test");
            user.setEmail(role.name().toLowerCase() + "@pathseek.local");
            user.setPasswordHash(passwordEncoder.encode("Secret123!"));
            user.setRol(role);
            userRepository.save(user);
            mockMvc.perform(get("/api/v1/dashboard/resumen")
                            .header(HttpHeaders.AUTHORIZATION, "Bearer " + jwtService.generateAccessToken(user)))
                    .andExpect(role == UserRole.CLIENTE ? status().isForbidden() : status().isOk());
        }
    }

    @Test
    void missingRouteReturns404ForDetailGeometryAndDelete() throws Exception {
        String path = "/api/v1/rutas/" + UUID.randomUUID();
        mockMvc.perform(get(path).header(HttpHeaders.AUTHORIZATION, "Bearer " + adminToken))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.code").value("RESOURCE_NOT_FOUND"));
        mockMvc.perform(get(path + "/geometria").header(HttpHeaders.AUTHORIZATION, "Bearer " + adminToken))
                .andExpect(status().isNotFound());
        mockMvc.perform(delete(path).header(HttpHeaders.AUTHORIZATION, "Bearer " + adminToken))
                .andExpect(status().isNotFound());
        mockMvc.perform(post(path + "/incidentes")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {"tipo":"BLOQUEO","descripcion":"Obras","lat":-12.06,"lon":-75.21}
                                """))
                .andExpect(status().isNotFound());
    }

    @Test
    void rejectsInvalidIncidentCoordinatesAndType() throws Exception {
        mockMvc.perform(post("/api/v1/rutas/" + UUID.randomUUID() + "/incidentes")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {"tipo":"DESCONOCIDO","descripcion":"Obras","lat":91,"lon":181,"radioAfectacionMetros":0}
                                """))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("VALIDATION_ERROR"));
    }

    @Test
    void generationWithoutVehiclesReturnsUnassignedOrderIds() throws Exception {
        String created = mockMvc.perform(post("/api/v1/pedidos")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {"cliente_id":"IE-001","direccion":"Av. Real 123",
                                 "gps_lat":-12.06,"gps_lon":-75.21,"peso":20,"volumen":1,
                                 "ventana_inicio":"08:00","ventana_fin":"12:00",
                                 "prioridad":"ESTANDAR","tipo_producto":"NO_PERECEDERO"}
                                """))
                .andExpect(status().isCreated()).andReturn().getResponse().getContentAsString();
        String orderId = JsonPath.read(created, "$.pedido_id");
        mockMvc.perform(post("/api/v1/rutas/generar")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + adminToken))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.rutas").isEmpty())
                .andExpect(jsonPath("$.pedidos_no_asignados[0]").value(orderId));
    }

    @Test
    void generateRoutesAndRetrieveGeometryWithContext() throws Exception {
        // 1. Crear vehículo
        Vehicle vehicle = new Vehicle();
        vehicle.setPlaca("EGB-101");
        vehicle.setTipo(VehicleType.CAMIONETA);
        vehicle.setCapacidadKg(BigDecimal.valueOf(1500));
        vehicle.setCapacidadM3(BigDecimal.valueOf(10));
        vehicle.setConsumoKmL(BigDecimal.valueOf(10));
        vehicle.setFactorEmision(BigDecimal.valueOf(2.35));
        vehicleRepository.save(vehicle);

        // 2. Crear conductor
        Driver driver = new Driver();
        driver.setDni("47890123");
        driver.setNombre("Juan Perez");
        driver.setLicencia("Q47890123");
        driver.setCategoria(DriverCategory.AII);
        driver.setExperiencia(5);
        driver.setDisponible(true);
        driverRepository.save(driver);

        // 3. Crear 2 pedidos
        Order o1 = new Order();
        o1.setClienteId("IE-001");
        o1.setDireccion("I.E. Santa Isabel - Huancayo");
        o1.setGpsLat(BigDecimal.valueOf(-12.062000));
        o1.setGpsLon(BigDecimal.valueOf(-75.205000));
        o1.setPeso(BigDecimal.valueOf(120));
        o1.setVolumen(BigDecimal.valueOf(1.5));
        o1.setVentanaInicio("08:00");
        o1.setVentanaFin("11:00");
        o1.setPrioridad(OrderPriority.ESTANDAR);
        o1.setTipoProducto(ProductType.NO_PERECEDERO);
        o1.setEstado(OrderStatus.PENDIENTE);
        orderRepository.save(o1);

        Order o2 = new Order();
        o2.setClienteId("IE-002");
        o2.setDireccion("I.E. Enma Luzmila - El Tambo");
        o2.setGpsLat(BigDecimal.valueOf(-12.055000));
        o2.setGpsLon(BigDecimal.valueOf(-75.215000));
        o2.setPeso(BigDecimal.valueOf(80));
        o2.setVolumen(BigDecimal.valueOf(1.0));
        o2.setVentanaInicio("09:00");
        o2.setVentanaFin("12:00");
        o2.setPrioridad(OrderPriority.ESTANDAR);
        o2.setTipoProducto(ProductType.NO_PERECEDERO);
        o2.setEstado(OrderStatus.PENDIENTE);
        orderRepository.save(o2);

        // 4. Ejecutar optimización
        String generateRes = mockMvc.perform(post("/api/v1/rutas/generar")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + adminToken))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.totalRutasGeneradas").value(1))
                .andExpect(jsonPath("$.totalPedidosPlanificados").value(2))
                .andExpect(jsonPath("$.pedidos_no_asignados").isEmpty())
                .andExpect(jsonPath("$.rutas[0].pedidos[0].pedido_id").isNotEmpty())
                .andExpect(jsonPath("$.rutas[0].pedidos[0].hora_estimada").isNotEmpty())
                .andExpect(jsonPath("$.rutas[0].pedidos[0].gps_lat").isNumber())
                .andReturn()
                .getResponse()
                .getContentAsString();

        String routeId = JsonPath.read(generateRes, "$.rutas[0].ruta_id");

        mockMvc.perform(get("/api/v1/dashboard/resumen")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + adminToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.total_vehiculos").value(1))
                .andExpect(jsonPath("$.conductores_disponibles").value(1))
                .andExpect(jsonPath("$.pedidos_pendientes").value(0))
                .andExpect(jsonPath("$.pedidos_en_ruta").value(2))
                .andExpect(jsonPath("$.rutas_planificadas").value(1))
                .andExpect(jsonPath("$.co2_total_kg").value(JsonPath.<Number>read(generateRes, "$.rutas[0].co2_kg")))
                .andExpect(jsonPath("$.combustible_total_l").value(JsonPath.<Number>read(generateRes, "$.rutas[0].combustible_l")));

        // 5. Consultar detalle de ruta
        mockMvc.perform(get("/api/v1/rutas/" + routeId)
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + adminToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.ruta_id").value(routeId))
                .andExpect(jsonPath("$.placa").value("EGB-101"))
                .andExpect(jsonPath("$.conductor_nombre").value("Juan Perez"))
                .andExpect(jsonPath("$.pedidos").isArray());

        // 6. Consultar geometría y contexto vial
        mockMvc.perform(get("/api/v1/rutas/" + routeId + "/geometria")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + adminToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.rutaId").value(routeId))
                .andExpect(jsonPath("$.encodedPolyline").doesNotExist())
                .andExpect(jsonPath("$.geometrySource").value("SCHEMATIC"))
                .andExpect(jsonPath("$.waypoints").isArray())
                .andExpect(jsonPath("$.perfilElevacion").isArray());

        // 7. Reportar incidente en ruta
        String incidentJson = """
                {
                  "tipo": "BLOQUEO",
                  "descripcion": "Obras en Av. Ferrocarril",
                  "lat": -12.060000,
                  "lon": -75.210000,
                  "radioAfectacionMetros": 200
                }
                """;

        mockMvc.perform(post("/api/v1/rutas/" + routeId + "/incidentes")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(incidentJson))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.mensaje").isNotEmpty());
    }

    @Test
    void repeatedGenerationPreservesHistoryAndDoesNotDuplicateAssignments() {
        Vehicle vehicle = planningVehicle(1000, 10);
        Driver driver = planningDriver(true);
        Order pending = planningOrder(OrderStatus.PENDIENTE, 20, 1, "10:00", "12:00");
        planningOrder(OrderStatus.ENTREGADO, 20, 1, "08:00", "12:00");
        planningOrder(OrderStatus.CANCELADO, 20, 1, "08:00", "12:00");
        planningOrder(OrderStatus.EN_RUTA, 20, 1, "08:00", "12:00");
        DeliveryRoute history = new DeliveryRoute();
        history.setFecha(LocalDate.of(2025, 1, 1));
        history.setVehiculo(vehicle);
        history.setConductor(driver);
        history.setEstado(RouteStatus.COMPLETADA);
        routeRepository.save(history);

        var first = optimizationService.generateRoutes();
        org.junit.jupiter.api.Assertions.assertEquals(1, first.totalPedidosPlanificados());
        org.junit.jupiter.api.Assertions.assertEquals("10:00", first.rutas().get(0).pedidos().get(0).horaEstimada());
        org.junit.jupiter.api.Assertions.assertEquals(OrderStatus.EN_RUTA, orderRepository.findById(pending.getId()).orElseThrow().getEstado());
        var second = optimizationService.generateRoutes();
        org.junit.jupiter.api.Assertions.assertEquals(0, second.totalRutasGeneradas());
        org.junit.jupiter.api.Assertions.assertEquals(2, routeRepository.count());
        org.junit.jupiter.api.Assertions.assertTrue(routeRepository.existsById(history.getId()));
    }

    @Test
    void unavailableDriverLeavesOrdersUnassigned() {
        planningVehicle(1000, 10);
        planningDriver(false);
        Order order = planningOrder(OrderStatus.PENDIENTE, 20, 1, "08:00", "12:00");
        var result = optimizationService.generateRoutes();
        org.junit.jupiter.api.Assertions.assertEquals(java.util.List.of(order.getId()), result.pedidosNoAsignados());
        org.junit.jupiter.api.Assertions.assertEquals(0, routeRepository.count());
    }

    @Test
    void plannerEnforcesWeightVolumeAndTimeWindow() {
        planningVehicle(100, 2);
        planningDriver(true);
        planningOrder(OrderStatus.PENDIENTE, 60, 1, "08:00", "12:00");
        planningOrder(OrderStatus.PENDIENTE, 60, 1, "08:00", "12:00");
        planningOrder(OrderStatus.PENDIENTE, 10, 3, "08:00", "12:00");
        planningOrder(OrderStatus.PENDIENTE, 10, 1, "06:00", "07:00");
        var result = optimizationService.generateRoutes();
        org.junit.jupiter.api.Assertions.assertEquals(1, result.totalPedidosPlanificados());
        org.junit.jupiter.api.Assertions.assertEquals(3, result.pedidosNoAsignados().size());
        org.junit.jupiter.api.Assertions.assertEquals(1, result.rutas().get(0).pedidos().size());
    }

    @Test
    void deletingPlannedRouteReleasesOrdersAndPreservesCompletedHistory() throws Exception {
        planningVehicle(1000, 10);
        planningDriver(true);
        Order order = planningOrder(OrderStatus.PENDIENTE, 20, 1, "08:00", "12:00");
        UUID routeId = optimizationService.generateRoutes().rutas().get(0).id();
        optimizationService.deleteRoute(routeId);
        org.junit.jupiter.api.Assertions.assertEquals(OrderStatus.PENDIENTE, orderRepository.findById(order.getId()).orElseThrow().getEstado());
        UUID newId = optimizationService.generateRoutes().rutas().get(0).id();
        DeliveryRoute completed = routeRepository.findById(newId).orElseThrow();
        completed.setEstado(RouteStatus.COMPLETADA);
        routeRepository.save(completed);
        mockMvc.perform(delete("/api/v1/rutas/" + newId).header(HttpHeaders.AUTHORIZATION, "Bearer " + adminToken))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("ROUTE_NOT_DELETABLE"));
    }

    @Test
    void concurrentGenerationAssignsEachOrderOnlyOnce() throws Exception {
        planningVehicle(1000, 10);
        planningDriver(true);
        planningOrder(OrderStatus.PENDIENTE, 20, 1, "08:00", "12:00");
        var pool = Executors.newFixedThreadPool(2);
        try {
            var first = pool.submit(() -> optimizationService.generateRoutes().totalPedidosPlanificados());
            var second = pool.submit(() -> optimizationService.generateRoutes().totalPedidosPlanificados());
            org.junit.jupiter.api.Assertions.assertEquals(1, first.get(10, TimeUnit.SECONDS) + second.get(10, TimeUnit.SECONDS));
            org.junit.jupiter.api.Assertions.assertEquals(1, routeRepository.count());
        } finally {
            pool.shutdownNow();
        }
    }

    private Vehicle planningVehicle(int capacityKg, int capacityM3) {
        Vehicle vehicle = new Vehicle();
        vehicle.setPlaca("TST-" + vehicleRepository.count());
        vehicle.setTipo(VehicleType.CAMIONETA);
        vehicle.setCapacidadKg(BigDecimal.valueOf(capacityKg));
        vehicle.setCapacidadM3(BigDecimal.valueOf(capacityM3));
        vehicle.setConsumoKmL(BigDecimal.valueOf(10));
        vehicle.setFactorEmision(BigDecimal.valueOf(2.35));
        return vehicleRepository.save(vehicle);
    }

    @Test
    void referenceLoad150Orders15VehiclesProducesFeasibleRoutesWithin45Seconds() {
        for (int i = 0; i < 15; i++) { planningVehicle(100, 10); planningDriver(true); }
        for (int i = 0; i < 150; i++) planningOrder(OrderStatus.PENDIENTE, 1, 1, "08:00", "23:00");
        var result = org.junit.jupiter.api.Assertions.assertTimeout(java.time.Duration.ofSeconds(45),
                () -> optimizationService.generateRoutes());
        org.junit.jupiter.api.Assertions.assertEquals(150, result.totalPedidosPlanificados());
        org.junit.jupiter.api.Assertions.assertEquals(15, result.totalRutasGeneradas());
        org.junit.jupiter.api.Assertions.assertTrue(result.metaheuristicaAplicada().contains("Simulated annealing"));
    }

    @Test
    void driverCanReadOnlyAssignedRoutesAndCannotGenerate() throws Exception {
        User user = new User(); user.setNombre("Driver"); user.setEmail("driver-scope@test.pe");
        user.setRol(UserRole.CONDUCTOR); user.setPasswordHash(passwordEncoder.encode("Secret123!"));
        userRepository.save(user);
        planningVehicle(1000, 10);
        Driver driver = planningDriver(true); driver.setUsuarioId(user.getId()); driverRepository.save(driver);
        planningOrder(OrderStatus.PENDIENTE, 20, 1, "08:00", "12:00");
        UUID route = optimizationService.generateRoutes().rutas().get(0).id();
        String token = jwtService.generateAccessToken(user);
        mockMvc.perform(get("/api/v1/rutas").header(HttpHeaders.AUTHORIZATION, "Bearer " + token))
                .andExpect(status().isOk()).andExpect(jsonPath("$.length()").value(1));
        mockMvc.perform(get("/api/v1/rutas/" + route + "/geometria").header(HttpHeaders.AUTHORIZATION, "Bearer " + token))
                .andExpect(status().isOk());
        mockMvc.perform(post("/api/v1/rutas/generar").header(HttpHeaders.AUTHORIZATION, "Bearer " + token))
                .andExpect(status().isForbidden());
        driver.setUsuarioId(UUID.randomUUID()); driverRepository.save(driver);
        mockMvc.perform(get("/api/v1/rutas").header(HttpHeaders.AUTHORIZATION, "Bearer " + token))
                .andExpect(status().isOk()).andExpect(jsonPath("$.length()").value(0));
        mockMvc.perform(get("/api/v1/rutas/" + route).header(HttpHeaders.AUTHORIZATION, "Bearer " + token))
                .andExpect(status().isForbidden());
        mockMvc.perform(get("/api/v1/rutas/" + route + "/geometria").header(HttpHeaders.AUTHORIZATION, "Bearer " + token))
                .andExpect(status().isForbidden());
    }

    @Test
    void annealingPreservesFeasibilityAndNeverWorsensInitialSequence() {
        var orders = java.util.List.of(
                planningOrder(OrderStatus.PENDIENTE, 1, 1, "08:00", "23:00"),
                planningOrder(OrderStatus.PENDIENTE, 1, 1, "08:00", "23:00"),
                planningOrder(OrderStatus.PENDIENTE, 1, 1, "08:00", "23:00"));
        orders.get(0).setGpsLat(BigDecimal.valueOf(-12.10));
        orders.get(1).setGpsLat(BigDecimal.valueOf(-12.04));
        var optimizer = new com.pathseek.backend.route.service.RouteSequenceOptimizer(
                new com.pathseek.backend.route.service.RoutingContextService());
        var result = optimizer.improve(orders);
        org.junit.jupiter.api.Assertions.assertEquals(new java.util.HashSet<>(orders), new java.util.HashSet<>(result));
        org.junit.jupiter.api.Assertions.assertTrue(optimizer.score(result) <= optimizer.score(orders));
    }

    private Driver planningDriver(boolean available) {
        Driver driver = new Driver();
        driver.setDni(String.format("%08d", driverRepository.count() + 1));
        driver.setNombre("Conductor de prueba");
        driver.setLicencia("Q" + driver.getDni());
        driver.setCategoria(DriverCategory.AII);
        driver.setExperiencia(5);
        driver.setDisponible(available);
        return driverRepository.save(driver);
    }

    private Order planningOrder(OrderStatus state, int weight, int volume, String start, String end) {
        Order order = new Order();
        order.setClienteId(UUID.randomUUID().toString());
        order.setDireccion("Entrega de prueba");
        order.setGpsLat(BigDecimal.valueOf(-12.062));
        order.setGpsLon(BigDecimal.valueOf(-75.205));
        order.setPeso(BigDecimal.valueOf(weight));
        order.setVolumen(BigDecimal.valueOf(volume));
        order.setVentanaInicio(start);
        order.setVentanaFin(end);
        order.setPrioridad(OrderPriority.ESTANDAR);
        order.setTipoProducto(ProductType.NO_PERECEDERO);
        order.setEstado(state);
        return orderRepository.save(order);
    }
}
