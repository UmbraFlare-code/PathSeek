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
import com.pathseek.backend.user.entity.User;
import com.pathseek.backend.user.entity.UserRole;
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
                .andReturn()
                .getResponse()
                .getContentAsString();

        String routeId = JsonPath.read(generateRes, "$.rutas[0].id");

        // 5. Consultar detalle de ruta
        mockMvc.perform(get("/api/v1/rutas/" + routeId)
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + adminToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(routeId))
                .andExpect(jsonPath("$.placa").value("EGB-101"))
                .andExpect(jsonPath("$.conductorNombre").value("Juan Perez"))
                .andExpect(jsonPath("$.pedidos").isArray());

        // 6. Consultar geometría y contexto vial
        mockMvc.perform(get("/api/v1/rutas/" + routeId + "/geometria")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + adminToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.rutaId").value(routeId))
                .andExpect(jsonPath("$.encodedPolyline").isNotEmpty())
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
}
