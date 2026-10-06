package com.pathseek.backend;

import com.jayway.jsonpath.JsonPath;
import com.pathseek.backend.auth.repository.RefreshTokenRepository;
import com.pathseek.backend.user.entity.User;
import com.pathseek.backend.user.entity.UserRole;
import com.pathseek.backend.user.repository.UserRepository;
import com.pathseek.backend.vehicle.repository.VehicleRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.http.MediaType;
import org.springframework.http.HttpHeaders;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import java.util.UUID;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class ApiIntegrationTests {

    private static final String VALID_VEHICLE = """
            {
              "placa": "ABC-123",
              "tipo": "CAMIONETA",
              "capacidad_kg": 1000,
              "capacidad_m3": 8.5,
              "consumo_km_l": 11.3,
              "factor_emision": 0.24,
              "anio": 2024,
              "restriccion_placa_digito": 3
            }
            """;

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private VehicleRepository vehicleRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private RefreshTokenRepository refreshTokenRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    private String adminToken;

    @Autowired
    private com.pathseek.backend.route.repository.DeliveryRouteRepository routeRepository;

    @BeforeEach
    void cleanDatabase() throws Exception {
        refreshTokenRepository.deleteAll();
        routeRepository.deleteAll();
        vehicleRepository.deleteAll();
        userRepository.deleteAll();

        User admin = new User();
        admin.setNombre("Admin de pruebas");
        admin.setEmail("admin-api@pathseek.test");
        admin.setPasswordHash(passwordEncoder.encode("Admin123!"));
        admin.setRol(UserRole.ADMIN);
        admin.setActivo(true);
        userRepository.saveAndFlush(admin);

        String response = mockMvc.perform(post("/api/v1/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {"email":"admin-api@pathseek.test","password":"Admin123!"}
                                """))
                .andReturn().getResponse().getContentAsString();
        adminToken = JsonPath.read(response, "$.token");
    }

    @Test
    void healthReturnsServiceStatus() throws Exception {
        mockMvc.perform(get("/api/v1/health"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("UP"))
                .andExpect(jsonPath("$.service").value("PathSeek API"));
    }

    @Test
    void openApiDocumentationIsAvailable() throws Exception {
        mockMvc.perform(get("/v3/api-docs"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.info.title").value("PathSeek API"))
                .andExpect(jsonPath("$.paths['/api/v1/health']").exists())
                .andExpect(jsonPath("$.paths['/api/v1/vehiculos']").exists());
    }

    @Test
    void createsValidVehicle() throws Exception {
        mockMvc.perform(post("/api/v1/vehiculos")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(VALID_VEHICLE))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.vehiculo_id").isNotEmpty())
                .andExpect(jsonPath("$.placa").value("ABC-123"))
                .andExpect(jsonPath("$.tipo").value("CAMIONETA"))
                .andExpect(jsonPath("$.capacidad_kg").value(1000));
    }

    @Test
    void rejectsInvalidVehicle() throws Exception {
        String invalidVehicle = """
                {
                  "placa": " ",
                  "tipo": "MOTO",
                  "capacidad_kg": 0,
                  "capacidad_m3": 1,
                  "consumo_km_l": 20,
                  "factor_emision": 0
                }
                """;

        mockMvc.perform(post("/api/v1/vehiculos")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(invalidVehicle))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("VALIDATION_ERROR"))
                .andExpect(jsonPath("$.message").value("Los datos enviados no son válidos"))
                .andExpect(jsonPath("$.errors").isArray());
    }

    @Test
    void rejectsDuplicatedPlate() throws Exception {
        mockMvc.perform(post("/api/v1/vehiculos")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(VALID_VEHICLE))
                .andExpect(status().isCreated());

        mockMvc.perform(post("/api/v1/vehiculos")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(VALID_VEHICLE.replace("ABC-123", "abc-123")))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("VEHICLE_PLATE_CONFLICT"))
                .andExpect(jsonPath("$.message")
                        .value("Ya existe un vehículo registrado con esa placa"));
    }

    @Test
    void rejectsVehicleWithUnreasonableYear() throws Exception {
        mockMvc.perform(post("/api/v1/vehiculos")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(VALID_VEHICLE.replace("2024", "2100")))
                .andExpect(status().isUnprocessableContent())
                .andExpect(jsonPath("$.code").value("INVALID_VEHICLE_YEAR"))
                .andExpect(jsonPath("$.message").isNotEmpty());
    }

    @Test
    void returnsNotFoundForUnknownVehicle() throws Exception {
        mockMvc.perform(get("/api/v1/vehiculos/{id}", UUID.randomUUID())
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + adminToken))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.code").value("RESOURCE_NOT_FOUND"))
                .andExpect(jsonPath("$.message").value("No se encontró el vehículo solicitado"));
    }
}
