package com.pathseek.backend;

import com.jayway.jsonpath.JsonPath;
import com.pathseek.backend.auth.repository.RefreshTokenRepository;
import com.pathseek.backend.driver.repository.DriverRepository;
import com.pathseek.backend.order.repository.OrderRepository;
import com.pathseek.backend.user.entity.User;
import com.pathseek.backend.user.entity.UserRole;
import com.pathseek.backend.user.repository.UserRepository;
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
import org.springframework.test.web.servlet.MvcResult;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class RouteIntegrationTests {

    private static final String PASSWORD = "Password123!";

    // 2026-10-05 es lunes: dígitos restringidos {1,2} según PlateRestrictionService.
    private static final String GENERATE_MONDAY = """
            {
              "fecha_operacion": "2026-10-05",
              "deposito": { "latitud": -12.065, "longitud": -75.204 },
              "velocidad_kmh": 40,
              "tiempo_servicio_min": 15
            }
            """;

    private static final String VEHICLE_ALLOWED = """
            {
              "placa": "XYZ-999",
              "tipo": "CAMIONETA",
              "capacidad_kg": 1000,
              "capacidad_m3": 10,
              "consumo_km_l": 10,
              "factor_emision": 2.3,
              "anio": 2020
            }
            """;

    private static final String VEHICLE_RESTRICTED_MONDAY = """
            {
              "placa": "ABC-001",
              "tipo": "CAMIONETA",
              "capacidad_kg": 1000,
              "capacidad_m3": 10,
              "consumo_km_l": 10,
              "factor_emision": 2.3,
              "anio": 2020
            }
            """;

    private static final String ORDER = """
            {
              "cliente_id": "CLI-RUTA",
              "direccion": "Av. Ferrocarril 100, Huancayo",
              "gps_lat": -12.068,
              "gps_lon": -75.21,
              "peso": 10,
              "volumen": 0.5,
              "ventana_inicio": "08:00",
              "ventana_fin": "12:00",
              "prioridad": "ESTANDAR",
              "tipo_producto": "NO_PERECEDERO"
            }
            """;

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private VehicleRepository vehicleRepository;

    @Autowired
    private OrderRepository orderRepository;

    @Autowired
    private DriverRepository driverRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private RefreshTokenRepository refreshTokenRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    private String adminToken;

    @BeforeEach
    void cleanDatabase() throws Exception {
        refreshTokenRepository.deleteAll();
        driverRepository.deleteAll();
        orderRepository.deleteAll();
        vehicleRepository.deleteAll();
        userRepository.deleteAll();

        createUser("admin-rutas@pathseek.test", UserRole.ADMIN, true);
        adminToken = login("admin-rutas@pathseek.test");
    }

    @Test
    void generatesRoutesRespectingPlateRestriction() throws Exception {
        createVehicle(VEHICLE_ALLOWED);
        createVehicle(VEHICLE_RESTRICTED_MONDAY);
        createOrder(ORDER);

        mockMvc.perform(post("/api/v1/rutas/generar")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(GENERATE_MONDAY))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.ruta_id").isNotEmpty())
                .andExpect(jsonPath("$.metricas.total_asignados").value(1))
                .andExpect(jsonPath("$.rutas[0].placa").value("XYZ-999"))
                .andExpect(jsonPath("$.rutas[0].paradas[0].direccion").isNotEmpty())
                .andExpect(jsonPath("$.rutas[0].paradas[0].prioridad").value("ESTANDAR"))
                .andExpect(jsonPath("$.metricas.co2_kg").isNumber());

        mockMvc.perform(get("/api/v1/rutas/metricas-rendimiento")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + adminToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.total_solicitudes").isNumber())
                .andExpect(jsonPath("$.p95_ms").isNumber());

        mockMvc.perform(get("/api/v1/rutas/lock")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + adminToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.en_ejecucion").value(false));
    }

    @Test
    void generateWithoutPendingOrdersReturns422() throws Exception {
        mockMvc.perform(post("/api/v1/rutas/generar")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(GENERATE_MONDAY))
                .andExpect(status().isUnprocessableContent())
                .andExpect(jsonPath("$.code").value("NO_PENDING_ORDERS"));
    }

    @Test
    void confirmMovesAssignedOrdersToEnRoute() throws Exception {
        createVehicle(VEHICLE_ALLOWED);
        createOrder(ORDER);

        MvcResult generated = mockMvc.perform(post("/api/v1/rutas/generar")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(GENERATE_MONDAY))
                .andExpect(status().isOk())
                .andReturn();
        String pedidoId = JsonPath.read(
                generated.getResponse().getContentAsString(), "$.rutas[0].paradas[0].pedido_id");

        mockMvc.perform(post("/api/v1/rutas/confirmar")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"pedido_ids\":[\"" + pedidoId + "\"]}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.confirmados").value(1));

        mockMvc.perform(post("/api/v1/rutas/generar")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(GENERATE_MONDAY))
                .andExpect(status().isUnprocessableContent())
                .andExpect(jsonPath("$.code").value("NO_PENDING_ORDERS"));
    }

    @Test
    void rejectsGenerateWithoutDate() throws Exception {        mockMvc.perform(post("/api/v1/rutas/generar")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "deposito": { "latitud": -12.065, "longitud": -75.204 },
                                  "velocidad_kmh": 40
                                }
                                """))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("VALIDATION_ERROR"));
    }

    @Test
    void routesRequireAuthentication() throws Exception {
        mockMvc.perform(post("/api/v1/rutas/generar")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(GENERATE_MONDAY))
                .andExpect(status().isUnauthorized());
    }

    private void createVehicle(String body) throws Exception {
        mockMvc.perform(post("/api/v1/vehiculos")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isCreated());
    }

    private void createOrder(String body) throws Exception {
        mockMvc.perform(post("/api/v1/pedidos")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isCreated());
    }

    private void createUser(String email, UserRole role, boolean active) {
        User user = new User();
        user.setNombre("Usuario de prueba");
        user.setEmail(email);
        user.setPasswordHash(passwordEncoder.encode(PASSWORD));
        user.setRol(role);
        user.setActivo(active);
        userRepository.saveAndFlush(user);
    }

    private String login(String email) throws Exception {
        MvcResult result = mockMvc.perform(post("/api/v1/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"email\":\"" + email + "\",\"password\":\"" + PASSWORD + "\"}"))
                .andExpect(status().isOk())
                .andReturn();
        return JsonPath.read(result.getResponse().getContentAsString(), "$.token");
    }
}
