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

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class ReoptimizeRouteIntegrationTests {

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
    void reoptimizeRouteWithIncidentEvasion() throws Exception {
        Vehicle vehicle = new Vehicle();
        vehicle.setPlaca("EGB-202");
        vehicle.setTipo(VehicleType.CAMIONETA);
        vehicle.setCapacidadKg(BigDecimal.valueOf(1500));
        vehicle.setCapacidadM3(BigDecimal.valueOf(8.0));
        vehicle.setConsumoKmL(BigDecimal.valueOf(10.0));
        vehicle.setFactorEmision(BigDecimal.valueOf(2.35));
        vehicleRepository.save(vehicle);

        Driver driver = new Driver();
        driver.setDni("45678901");
        driver.setNombre("Pedro Castillo Huamán");
        driver.setLicencia("Q45678901");
        driver.setCategoria(DriverCategory.AII);
        driver.setExperiencia(6);
        driver.setDisponible(true);
        driverRepository.save(driver);

        for (int i = 1; i <= 3; i++) {
            Order order = new Order();
            order.setClienteId("IE-00" + i);
            order.setDireccion("Jr. Ancash " + (100 * i));
            order.setGpsLat(BigDecimal.valueOf(-12.0650 - (i * 0.003)));
            order.setGpsLon(BigDecimal.valueOf(-75.2050 - (i * 0.003)));
            order.setPeso(BigDecimal.valueOf(40.0));
            order.setVolumen(BigDecimal.valueOf(0.5));
            order.setVentanaInicio("08:00");
            order.setVentanaFin("13:00");
            order.setPrioridad(OrderPriority.ESTANDAR);
            order.setTipoProducto(ProductType.NO_PERECEDERO);
            order.setEstado(OrderStatus.PENDIENTE);
            orderRepository.save(order);
        }

        // Generar rutas iniciales
        String genRes = mockMvc.perform(post("/api/v1/rutas/generar")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + adminToken))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.totalRutasGeneradas").value(1))
                .andReturn()
                .getResponse()
                .getContentAsString();

        String routeId = JsonPath.read(genRes, "$.rutas[0].id");

        // Re-optimizar ante incidente
        String reoptBody = """
                {
                  "motivo": "BLOQUEO_VIAL",
                  "descripcion": "Obras en Jr. Ancash y Av. Real",
                  "latitudIncidente": -12.0680,
                  "longitudIncidente": -75.2080,
                  "radioBloqueoMetros": 300,
                  "pedidosCancelados": []
                }
                """;

        mockMvc.perform(post("/api/v1/rutas/" + routeId + "/reoptimizar")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(reoptBody))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.rutaId").value(routeId))
                .andExpect(jsonPath("$.estado").value("REOPTIMIZADA"))
                .andExpect(jsonPath("$.pedidosReordenados").value(3))
                .andExpect(jsonPath("$.distanciaKm").isNumber())
                .andExpect(jsonPath("$.co2Kg").isNumber());
    }
}
