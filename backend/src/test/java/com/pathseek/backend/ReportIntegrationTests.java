package com.pathseek.backend;

import com.jayway.jsonpath.JsonPath;
import com.pathseek.backend.auth.repository.RefreshTokenRepository;
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

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class ReportIntegrationTests {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private RefreshTokenRepository refreshTokenRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    private String adminToken;

    @BeforeEach
    void setUp() throws Exception {
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
    void getSustainabilityReportJsonAndPdf() throws Exception {
        // 1. JSON
        mockMvc.perform(get("/api/v1/reportes/sostenibilidad?fechaInicio=2026-10-01&fechaFin=2026-10-31")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + adminToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.distanciaTotalKm").isNumber())
                .andExpect(jsonPath("$.emisionesCo2TotalKg").isNumber())
                .andExpect(jsonPath("$.co2EvitadoKg").isNumber());

        // 2. PDF Download
        mockMvc.perform(get("/api/v1/reportes/sostenibilidad/pdf?fechaInicio=2026-10-01&fechaFin=2026-10-31")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + adminToken))
                .andExpect(status().isOk())
                .andExpect(header().string(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_PDF_VALUE));
    }

    @Test
    void getCarbonCompensationPlan() throws Exception {
        mockMvc.perform(get("/api/v1/reportes/compensacion")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + adminToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.emisionesAnualesToneladas").isNumber())
                .andExpect(jsonPath("$.arbolesEquivalentesRequeridos").isNumber())
                .andExpect(jsonPath("$.proyectosSugeridos").isArray());
    }
}
