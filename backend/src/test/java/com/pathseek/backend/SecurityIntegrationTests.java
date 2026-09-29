package com.pathseek.backend;

import com.jayway.jsonpath.JsonPath;
import com.pathseek.backend.auth.entity.RefreshToken;
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
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.oauth2.jose.jws.MacAlgorithm;
import org.springframework.security.oauth2.jwt.JwsHeader;
import org.springframework.security.oauth2.jwt.JwtClaimsSet;
import org.springframework.security.oauth2.jwt.JwtEncoder;
import org.springframework.security.oauth2.jwt.JwtEncoderParameters;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

import java.time.Instant;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.time.temporal.ChronoUnit;
import java.util.UUID;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;
import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class SecurityIntegrationTests {

    private static final String PASSWORD = "Password123!";
    private static final String VEHICLE = """
            {
              "placa": "SEC-101",
              "tipo": "FURGON",
              "capacidad_kg": 800,
              "capacidad_m3": 6.5,
              "consumo_km_l": 10.5,
              "factor_emision": 0.20,
              "anio": 2025,
              "restriccion_placa_digito": 1
            }
            """;

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private RefreshTokenRepository refreshTokenRepository;

    @Autowired
    private VehicleRepository vehicleRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private JwtEncoder jwtEncoder;

    @BeforeEach
    void cleanDatabase() {
        refreshTokenRepository.deleteAll();
        vehicleRepository.deleteAll();
        userRepository.deleteAll();
    }

    @Test
    void healthRemainsPublic() throws Exception {
        mockMvc.perform(get("/api/v1/health"))
                .andExpect(status().isOk());
    }

    @Test
    void validLoginReturnsTokensAndSafeUser() throws Exception {
        createUser("operator@pathseek.test", UserRole.OPERADOR, true);

        mockMvc.perform(loginRequest(" OPERATOR@pathseek.test ", PASSWORD))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.token").isNotEmpty())
                .andExpect(jsonPath("$.refreshToken").isNotEmpty())
                .andExpect(jsonPath("$.usuario.usuario_id").isNotEmpty())
                .andExpect(jsonPath("$.usuario.email").value("operator@pathseek.test"))
                .andExpect(jsonPath("$.usuario.rol").value("OPERADOR"))
                .andExpect(jsonPath("$.usuario.password_hash").doesNotExist())
                .andExpect(jsonPath("$.usuario.passwordHash").doesNotExist());
    }

    @Test
    void invalidCredentialsReturnUnauthorized() throws Exception {
        createUser("user@pathseek.test", UserRole.CLIENTE, true);

        mockMvc.perform(loginRequest("user@pathseek.test", "incorrecta"))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value("INVALID_CREDENTIALS"))
                .andExpect(jsonPath("$.message").value("Credenciales inválidas"));
    }

    @Test
    void threeFailedAttemptsLockAccount() throws Exception {
        createUser("locked@pathseek.test", UserRole.OPERADOR, true);

        mockMvc.perform(loginRequest("locked@pathseek.test", "incorrecta"))
                .andExpect(status().isUnauthorized());
        mockMvc.perform(loginRequest("locked@pathseek.test", "incorrecta"))
                .andExpect(status().isUnauthorized());
        mockMvc.perform(loginRequest("locked@pathseek.test", "incorrecta"))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value("ACCOUNT_LOCKED"));

        User user = userRepository.findByEmail("locked@pathseek.test").orElseThrow();
        org.assertj.core.api.Assertions.assertThat(user.getIntentosFallidos()).isEqualTo(3);
        org.assertj.core.api.Assertions.assertThat(user.getBloqueadoHasta()).isAfter(OffsetDateTime.now(ZoneOffset.UTC));
    }

    @Test
    void lockedAccountCannotLoginWithCorrectPassword() throws Exception {
        createUser("blocked@pathseek.test", UserRole.OPERADOR, true);
        for (int attempt = 0; attempt < 3; attempt++) {
            mockMvc.perform(loginRequest("blocked@pathseek.test", "incorrecta"));
        }

        mockMvc.perform(loginRequest("blocked@pathseek.test", PASSWORD))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value("ACCOUNT_LOCKED"));
    }

    @Test
    void inactiveUserDoesNotReceiveTokens() throws Exception {
        createUser("inactive@pathseek.test", UserRole.OPERADOR, false);

        mockMvc.perform(loginRequest("inactive@pathseek.test", PASSWORD))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.code").value("ACCOUNT_INACTIVE"))
                .andExpect(jsonPath("$.token").doesNotExist());
    }

    @Test
    void validRefreshRotatesBothTokens() throws Exception {
        createUser("refresh@pathseek.test", UserRole.ADMIN, true);
        String loginBody = login("refresh@pathseek.test");
        String oldAccessToken = JsonPath.read(loginBody, "$.token");
        String oldRefreshToken = JsonPath.read(loginBody, "$.refreshToken");

        mockMvc.perform(refreshRequest(oldRefreshToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.token").isNotEmpty())
                .andExpect(jsonPath("$.token").value(org.hamcrest.Matchers.not(oldAccessToken)))
                .andExpect(jsonPath("$.refreshToken").isNotEmpty())
                .andExpect(jsonPath("$.refreshToken").value(org.hamcrest.Matchers.not(oldRefreshToken)));
    }

    @Test
    void credentialsAndRefreshTokensAreStoredOnlyAsHashes() throws Exception {
        User user = createUser("hashes@pathseek.test", UserRole.ADMIN, true);
        String refreshTokenValue = JsonPath.read(login("hashes@pathseek.test"), "$.refreshToken");
        RefreshToken stored = refreshTokenRepository.findAll().get(0);

        assertThat(user.getPasswordHash()).startsWith("$2").isNotEqualTo(PASSWORD);
        assertThat(stored.getTokenHash()).hasSize(64).isNotEqualTo(refreshTokenValue);
    }

    @Test
    void rotatedRefreshTokenCannotBeReused() throws Exception {
        createUser("rotation@pathseek.test", UserRole.ADMIN, true);
        String oldRefreshToken = JsonPath.read(login("rotation@pathseek.test"), "$.refreshToken");

        mockMvc.perform(refreshRequest(oldRefreshToken)).andExpect(status().isOk());
        mockMvc.perform(refreshRequest(oldRefreshToken))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value("INVALID_REFRESH_TOKEN"));
    }

    @Test
    void revokedRefreshTokenIsRejected() throws Exception {
        createUser("logout@pathseek.test", UserRole.ADMIN, true);
        String refreshToken = JsonPath.read(login("logout@pathseek.test"), "$.refreshToken");

        mockMvc.perform(post("/api/v1/auth/logout")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(refreshBody(refreshToken)))
                .andExpect(status().isNoContent());
        mockMvc.perform(refreshRequest(refreshToken))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value("INVALID_REFRESH_TOKEN"));
    }

    @Test
    void expiredRefreshTokenIsRejected() throws Exception {
        createUser("expired-refresh@pathseek.test", UserRole.ADMIN, true);
        String refreshTokenValue = JsonPath.read(login("expired-refresh@pathseek.test"), "$.refreshToken");
        RefreshToken stored = refreshTokenRepository.findAll().get(0);
        stored.setExpiresAt(OffsetDateTime.now(ZoneOffset.UTC).minusMinutes(1));
        refreshTokenRepository.saveAndFlush(stored);

        mockMvc.perform(refreshRequest(refreshTokenValue))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value("INVALID_REFRESH_TOKEN"));
    }

    @Test
    void inactiveSessionCannotBeRefreshed() throws Exception {
        createUser("idle@pathseek.test", UserRole.ADMIN, true);
        String refreshTokenValue = JsonPath.read(login("idle@pathseek.test"), "$.refreshToken");
        RefreshToken stored = refreshTokenRepository.findAll().get(0);
        stored.setLastUsedAt(OffsetDateTime.now(ZoneOffset.UTC).minusMinutes(31));
        refreshTokenRepository.saveAndFlush(stored);

        mockMvc.perform(refreshRequest(refreshTokenValue))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value("SESSION_INACTIVE"));
    }

    @Test
    void vehiclesRequireAuthentication() throws Exception {
        mockMvc.perform(get("/api/v1/vehiculos"))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value("UNAUTHORIZED"));
    }

    @Test
    void adminCanCreateVehicle() throws Exception {
        createUser("admin@pathseek.test", UserRole.ADMIN, true);
        String accessToken = JsonPath.read(login("admin@pathseek.test"), "$.token");

        mockMvc.perform(createVehicleRequest(accessToken))
                .andExpect(status().isCreated());
    }

    @Test
    void operatorCanCreateVehicle() throws Exception {
        createUser("operator@pathseek.test", UserRole.OPERADOR, true);
        String accessToken = JsonPath.read(login("operator@pathseek.test"), "$.token");

        mockMvc.perform(createVehicleRequest(accessToken))
                .andExpect(status().isCreated());
    }

    @Test
    void auditorCanReadButCannotMutateVehicles() throws Exception {
        createUser("auditor@pathseek.test", UserRole.AUDITOR, true);
        String accessToken = JsonPath.read(login("auditor@pathseek.test"), "$.token");

        mockMvc.perform(get("/api/v1/vehiculos").headers(bearer(accessToken)))
                .andExpect(status().isOk());
        mockMvc.perform(createVehicleRequest(accessToken))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.code").value("FORBIDDEN"));
        mockMvc.perform(put("/api/v1/vehiculos/{id}", UUID.randomUUID())
                        .headers(bearer(accessToken))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(VEHICLE))
                .andExpect(status().isForbidden());
        mockMvc.perform(delete("/api/v1/vehiculos/{id}", UUID.randomUUID())
                        .headers(bearer(accessToken)))
                .andExpect(status().isForbidden());
    }

    @Test
    void clientCannotAccessVehicleManagement() throws Exception {
        createUser("client@pathseek.test", UserRole.CLIENTE, true);
        String accessToken = JsonPath.read(login("client@pathseek.test"), "$.token");

        mockMvc.perform(get("/api/v1/vehiculos").headers(bearer(accessToken)))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.code").value("FORBIDDEN"));
    }

    @Test
    void driverCannotAccessVehicleManagement() throws Exception {
        createUser("driver@pathseek.test", UserRole.CONDUCTOR, true);
        String accessToken = JsonPath.read(login("driver@pathseek.test"), "$.token");

        mockMvc.perform(get("/api/v1/vehiculos").headers(bearer(accessToken)))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.code").value("FORBIDDEN"));
    }

    @Test
    void invalidJwtIsRejected() throws Exception {
        mockMvc.perform(get("/api/v1/vehiculos")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer invalid.jwt.value"))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value("UNAUTHORIZED"));
    }

    @Test
    void expiredJwtIsRejected() throws Exception {
        String expiredToken = expiredToken();

        mockMvc.perform(get("/api/v1/vehiculos").headers(bearer(expiredToken)))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value("UNAUTHORIZED"));
    }

    private User createUser(String email, UserRole role, boolean active) {
        User user = new User();
        user.setNombre("Usuario de prueba");
        user.setEmail(email);
        user.setPasswordHash(passwordEncoder.encode(PASSWORD));
        user.setRol(role);
        user.setActivo(active);
        return userRepository.saveAndFlush(user);
    }

    private String login(String email) throws Exception {
        MvcResult result = mockMvc.perform(loginRequest(email, PASSWORD))
                .andExpect(status().isOk())
                .andReturn();
        return result.getResponse().getContentAsString();
    }

    private org.springframework.test.web.servlet.request.MockHttpServletRequestBuilder loginRequest(
            String email,
            String password) {
        return post("/api/v1/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"email\":\"" + email + "\",\"password\":\"" + password + "\"}");
    }

    private org.springframework.test.web.servlet.request.MockHttpServletRequestBuilder refreshRequest(String token) {
        return post("/api/v1/auth/refresh")
                .contentType(MediaType.APPLICATION_JSON)
                .content(refreshBody(token));
    }

    private String refreshBody(String token) {
        return "{\"refreshToken\":\"" + token + "\"}";
    }

    private org.springframework.test.web.servlet.request.MockHttpServletRequestBuilder createVehicleRequest(
            String accessToken) {
        return post("/api/v1/vehiculos")
                .headers(bearer(accessToken))
                .contentType(MediaType.APPLICATION_JSON)
                .content(VEHICLE);
    }

    private HttpHeaders bearer(String token) {
        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth(token);
        return headers;
    }

    private String expiredToken() {
        Instant now = Instant.now();
        JwtClaimsSet claims = JwtClaimsSet.builder()
                .subject(UUID.randomUUID().toString())
                .claim("rol", "ADMIN")
                .claim("email", "expired@pathseek.test")
                .issuedAt(now.minus(2, ChronoUnit.HOURS))
                .expiresAt(now.minus(1, ChronoUnit.HOURS))
                .build();
        JwsHeader header = JwsHeader.with(MacAlgorithm.HS256).build();
        return jwtEncoder.encode(JwtEncoderParameters.from(header, claims)).getTokenValue();
    }
}
