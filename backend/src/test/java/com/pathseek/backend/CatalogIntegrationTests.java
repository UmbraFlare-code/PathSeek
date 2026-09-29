package com.pathseek.backend;

import com.jayway.jsonpath.JsonPath;
import com.pathseek.backend.auth.repository.RefreshTokenRepository;
import com.pathseek.backend.driver.repository.DriverRepository;
import com.pathseek.backend.order.repository.OrderRepository;
import com.pathseek.backend.user.entity.User;
import com.pathseek.backend.user.entity.UserRole;
import com.pathseek.backend.user.repository.UserRepository;
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

import java.util.UUID;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class CatalogIntegrationTests {

    private static final String PASSWORD = "Password123!";

    private static final String VALID_DRIVER = """
            {
              "dni": "12345678",
              "nombre": "Juan Pérez",
              "licencia": "Q12345678",
              "categoria": "AII",
              "experiencia": 5,
              "disponible": true,
              "contacto": "999888777"
            }
            """;

    private static final String VALID_ORDER = """
            {
              "cliente_id": "CLI-001",
              "direccion": "Av. Ferrocarril 123, Huancayo",
              "gps_lat": -12.0651,
              "gps_lon": -75.2045,
              "peso": 25.5,
              "volumen": 1.2,
              "ventana_inicio": "08:00",
              "ventana_fin": "12:00",
              "prioridad": "ESTANDAR",
              "tipo_producto": "NO_PERECEDERO"
            }
            """;

    @Autowired
    private MockMvc mockMvc;

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
    void cleanDatabase() throws Exception {
        refreshTokenRepository.deleteAll();
        driverRepository.deleteAll();
        orderRepository.deleteAll();
        userRepository.deleteAll();

        createUser("admin-catalog@pathseek.test", UserRole.ADMIN, true);
        adminToken = login("admin-catalog@pathseek.test");
    }

    @Test
    void openApiDocumentsNewPaths() throws Exception {
        mockMvc.perform(get("/v3/api-docs"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.paths['/api/v1/conductores']").exists())
                .andExpect(jsonPath("$.paths['/api/v1/pedidos']").exists());
    }

    @Test
    void createsValidDriver() throws Exception {
        mockMvc.perform(post("/api/v1/conductores")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(VALID_DRIVER))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.conductor_id").isNotEmpty())
                .andExpect(jsonPath("$.dni").value("12345678"))
                .andExpect(jsonPath("$.nombre").value("Juan Pérez"))
                .andExpect(jsonPath("$.licencia").value("Q12345678"))
                .andExpect(jsonPath("$.categoria").value("AII"))
                .andExpect(jsonPath("$.experiencia").value(5))
                .andExpect(jsonPath("$.disponible").value(true));
    }

    @Test
    void driverDefaultsToAvailableWhenOmitted() throws Exception {
        String withoutAvailable = VALID_DRIVER.replace("\"disponible\": true,", "");

        mockMvc.perform(post("/api/v1/conductores")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(withoutAvailable))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.disponible").value(true));
    }

    @Test
    void rejectsInvalidDriver() throws Exception {
        String invalidDriver = """
                {
                  "dni": "123",
                  "nombre": " ",
                  "licencia": "Q12345678",
                  "categoria": "AII",
                  "experiencia": -1
                }
                """;

        mockMvc.perform(post("/api/v1/conductores")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(invalidDriver))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("VALIDATION_ERROR"))
                .andExpect(jsonPath("$.errors").isArray());
    }

    @Test
    void rejectsDuplicatedDni() throws Exception {
        createDriver(VALID_DRIVER);

        mockMvc.perform(post("/api/v1/conductores")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(VALID_DRIVER.replace("Q12345678", "Q87654321")))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("DRIVER_DNI_CONFLICT"));
    }

    @Test
    void rejectsDuplicatedLicense() throws Exception {
        createDriver(VALID_DRIVER);

        String sameLicense = """
                {
                  "dni": "87654321",
                  "nombre": "Juan Pérez",
                  "licencia": "Q12345678",
                  "categoria": "AII",
                  "experiencia": 5,
                  "disponible": true
                }
                """;

        mockMvc.perform(post("/api/v1/conductores")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(sameLicense))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("DRIVER_LICENSE_CONFLICT"));
    }

    @Test
    void rejectsInvalidUsuarioId() throws Exception {
        mockMvc.perform(post("/api/v1/conductores")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(VALID_DRIVER.replace(
                                "\"dni\": \"12345678\"",
                                "\"usuario_id\": \"no-es-uuid\", \"dni\": \"12345678\"")))
                .andExpect(status().isUnprocessableContent())
                .andExpect(jsonPath("$.code").value("INVALID_DRIVER_USER"));
    }

    @Test
    void updatesAndDeletesDriver() throws Exception {
        String driverId = JsonPath.read(createDriver(VALID_DRIVER), "$.conductor_id");

        mockMvc.perform(put("/api/v1/conductores/{id}", driverId)
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(VALID_DRIVER.replace("\"experiencia\": 5", "\"experiencia\": 6")))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.experiencia").value(6));

        mockMvc.perform(delete("/api/v1/conductores/{id}", driverId)
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + adminToken))
                .andExpect(status().isNoContent());

        mockMvc.perform(get("/api/v1/conductores/{id}", driverId)
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + adminToken))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.code").value("RESOURCE_NOT_FOUND"));
    }

    @Test
    void returnsNotFoundForUnknownDriver() throws Exception {
        mockMvc.perform(get("/api/v1/conductores/{id}", UUID.randomUUID())
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + adminToken))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.code").value("RESOURCE_NOT_FOUND"))
                .andExpect(jsonPath("$.message").value("No se encontró el conductor solicitado"));
    }

    @Test
    void createsValidOrderWithDefaultStatus() throws Exception {
        mockMvc.perform(post("/api/v1/pedidos")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(VALID_ORDER))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.pedido_id").isNotEmpty())
                .andExpect(jsonPath("$.cliente_id").value("CLI-001"))
                .andExpect(jsonPath("$.ventana_inicio").value("08:00"))
                .andExpect(jsonPath("$.ventana_fin").value("12:00"))
                .andExpect(jsonPath("$.prioridad").value("ESTANDAR"))
                .andExpect(jsonPath("$.tipo_producto").value("NO_PERECEDERO"))
                .andExpect(jsonPath("$.estado").value("PENDIENTE"));
    }

    @Test
    void rejectsInvalidOrder() throws Exception {
        String invalidOrder = """
                {
                  "cliente_id": "CLI-001",
                  "direccion": "Av. Ferrocarril 123",
                  "gps_lat": -95.0,
                  "gps_lon": -75.2045,
                  "peso": 0,
                  "volumen": 1.2,
                  "ventana_inicio": "08:00",
                  "ventana_fin": "12:00",
                  "prioridad": "ESTANDAR",
                  "tipo_producto": "NO_PERECEDERO"
                }
                """;

        mockMvc.perform(post("/api/v1/pedidos")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(invalidOrder))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("VALIDATION_ERROR"))
                .andExpect(jsonPath("$.errors").isArray());
    }

    @Test
    void rejectsDuplicatedOrder() throws Exception {
        createOrder(VALID_ORDER);

        mockMvc.perform(post("/api/v1/pedidos")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(VALID_ORDER))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("ORDER_DUPLICATE"))
                .andExpect(jsonPath("$.message")
                        .value("Ya existe un pedido activo con el mismo cliente, dirección y ventana de tiempo"));
    }

    @Test
    void cancelledOrderDoesNotBlockIdenticalOrder() throws Exception {
        String orderId = JsonPath.read(createOrder(VALID_ORDER), "$.pedido_id");

        mockMvc.perform(put("/api/v1/pedidos/{id}", orderId)
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(VALID_ORDER.replace(
                                "\"prioridad\": \"ESTANDAR\"",
                                "\"prioridad\": \"ESTANDAR\", \"estado\": \"CANCELADO\"")))
                .andExpect(status().isOk());

        mockMvc.perform(post("/api/v1/pedidos")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(VALID_ORDER))
                .andExpect(status().isCreated());
    }

    @Test
    void rejectsInvertedTimeWindow() throws Exception {
        mockMvc.perform(post("/api/v1/pedidos")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(VALID_ORDER
                                .replace("\"ventana_inicio\": \"08:00\"", "\"ventana_inicio\": \"14:00\"")
                                .replace("\"ventana_fin\": \"12:00\"", "\"ventana_fin\": \"12:00\"")))
                .andExpect(status().isUnprocessableContent())
                .andExpect(jsonPath("$.code").value("INVALID_ORDER_WINDOW"));
    }

    @Test
    void updatesOrderStatus() throws Exception {
        String orderId = JsonPath.read(createOrder(VALID_ORDER), "$.pedido_id");

        mockMvc.perform(put("/api/v1/pedidos/{id}", orderId)
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(VALID_ORDER.replace(
                                "\"prioridad\": \"ESTANDAR\"",
                                "\"prioridad\": \"ESTANDAR\", \"estado\": \"EN_RUTA\"")))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.estado").value("EN_RUTA"));
    }

    @Test
    void returnsNotFoundForUnknownOrder() throws Exception {
        mockMvc.perform(get("/api/v1/pedidos/{id}", UUID.randomUUID())
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + adminToken))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.code").value("RESOURCE_NOT_FOUND"))
                .andExpect(jsonPath("$.message").value("No se encontró el pedido solicitado"));
    }

    @Test
    void catalogRequiresAuthentication() throws Exception {
        mockMvc.perform(get("/api/v1/conductores"))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value("UNAUTHORIZED"));
        mockMvc.perform(get("/api/v1/pedidos"))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value("UNAUTHORIZED"));
    }

    @Test
    void clientCanReadAndCreateButCannotModifyOrders() throws Exception {
        createUser("client-catalog@pathseek.test", UserRole.CLIENTE, true);
        String clientToken = login("client-catalog@pathseek.test");

        mockMvc.perform(get("/api/v1/pedidos")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + clientToken))
                .andExpect(status().isOk());

        String created = mockMvc.perform(post("/api/v1/pedidos")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + clientToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(VALID_ORDER))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.pedido_id").isNotEmpty())
                .andReturn().getResponse().getContentAsString();
        String orderId = JsonPath.read(created, "$.pedido_id");

        mockMvc.perform(put("/api/v1/pedidos/{id}", orderId)
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + clientToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(VALID_ORDER))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.code").value("FORBIDDEN"));
        mockMvc.perform(delete("/api/v1/pedidos/{id}", orderId)
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + clientToken))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.code").value("FORBIDDEN"));
    }

    @Test
    void clientCannotAccessDriverManagement() throws Exception {
        createUser("client-drivers@pathseek.test", UserRole.CLIENTE, true);
        String clientToken = login("client-drivers@pathseek.test");

        mockMvc.perform(get("/api/v1/conductores")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + clientToken))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.code").value("FORBIDDEN"));
    }

    @Test
    void driverRoleCannotAccessOrders() throws Exception {
        createUser("driver-orders@pathseek.test", UserRole.CONDUCTOR, true);
        String driverToken = login("driver-orders@pathseek.test");

        mockMvc.perform(get("/api/v1/pedidos")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + driverToken))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.code").value("FORBIDDEN"));
    }

    @Test
    void auditorCanReadCatalog() throws Exception {
        createUser("auditor-catalog@pathseek.test", UserRole.AUDITOR, true);
        String auditorToken = login("auditor-catalog@pathseek.test");

        mockMvc.perform(get("/api/v1/conductores")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + auditorToken))
                .andExpect(status().isOk());
        mockMvc.perform(get("/api/v1/pedidos")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + auditorToken))
                .andExpect(status().isOk());
        mockMvc.perform(post("/api/v1/conductores")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + auditorToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(VALID_DRIVER))
                .andExpect(status().isForbidden());
    }

    private String createDriver(String body) throws Exception {
        MvcResult result = mockMvc.perform(post("/api/v1/conductores")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isCreated())
                .andReturn();
        return result.getResponse().getContentAsString();
    }

    private String createOrder(String body) throws Exception {
        MvcResult result = mockMvc.perform(post("/api/v1/pedidos")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isCreated())
                .andReturn();
        return result.getResponse().getContentAsString();
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
