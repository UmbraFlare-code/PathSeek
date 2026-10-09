package com.pathseek.backend;

import com.jayway.jsonpath.JsonPath;
import com.pathseek.backend.auth.repository.RefreshTokenRepository;
import com.pathseek.backend.client.repository.ClientRepository;
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

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class ClientIntegrationTests {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ClientRepository clientRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private RefreshTokenRepository refreshTokenRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    private String adminToken;

    @BeforeEach
    void setUp() throws Exception {
        clientRepository.deleteAll();
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
    void crudClientLifecycle() throws Exception {
        String createJson = """
                {
                  "nombre": "I.E. Mariscal Castilla",
                  "direccion": "Av. Mariscal Castilla 890, El Tambo",
                  "puntoReferencia": "Frente al estadio Castilla",
                  "telefono": "064-245678",
                  "contacto": "Lic. Roberto Gómez",
                  "gpsLat": -12.0612,
                  "gpsLon": -75.2155,
                  "ventanaInicioPreferida": "08:30",
                  "ventanaFinPreferida": "12:30",
                  "activo": true
                }
                """;

        // 1. Crear
        String res = mockMvc.perform(post("/api/v1/clientes")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(createJson))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.nombre").value("I.E. Mariscal Castilla"))
                .andReturn()
                .getResponse()
                .getContentAsString();

        String clientId = JsonPath.read(res, "$.id");

        // 2. Listar
        mockMvc.perform(get("/api/v1/clientes")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + adminToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$.length()").value(1));

        // 3. Detalle
        mockMvc.perform(get("/api/v1/clientes/" + clientId)
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + adminToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.contacto").value("Lic. Roberto Gómez"));

        // 4. Actualizar
        String updateJson = """
                {
                  "nombre": "I.E. Mariscal Castilla (Sede Secundaria)",
                  "direccion": "Av. Mariscal Castilla 890, El Tambo",
                  "puntoReferencia": "Frente al estadio Castilla",
                  "telefono": "064-245678",
                  "contacto": "Lic. Roberto Gómez",
                  "gpsLat": -12.0612,
                  "gpsLon": -75.2155,
                  "ventanaInicioPreferida": "08:00",
                  "ventanaFinPreferida": "13:00",
                  "activo": true
                }
                """;

        mockMvc.perform(put("/api/v1/clientes/" + clientId)
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(updateJson))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.nombre").value("I.E. Mariscal Castilla (Sede Secundaria)"));

        // 5. Eliminar
        mockMvc.perform(delete("/api/v1/clientes/" + clientId)
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + adminToken))
                .andExpect(status().isNoContent());
    }
}
