package com.pathseek.backend;

import com.jayway.jsonpath.JsonPath;
import com.pathseek.backend.auth.repository.RefreshTokenRepository;
import com.pathseek.backend.driver.entity.Driver;
import com.pathseek.backend.driver.entity.DriverCategory;
import com.pathseek.backend.driver.repository.DriverRepository;
import com.pathseek.backend.route.repository.DeliveryRouteRepository;
import com.pathseek.backend.security.JwtService;
import com.pathseek.backend.user.entity.User;
import com.pathseek.backend.user.entity.UserRole;
import com.pathseek.backend.user.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.http.MediaType;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import java.util.List;
import java.util.concurrent.*;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class UserAdministrationIntegrationTests {
    @Autowired MockMvc mvc;
    @Autowired UserRepository users;
    @Autowired RefreshTokenRepository refreshTokens;
    @Autowired DriverRepository drivers;
    @Autowired DeliveryRouteRepository routes;
    @Autowired PasswordEncoder passwords;
    @Autowired JwtService jwt;

    User admin;
    String adminToken;
    static final String PASSWORD = "Password123!";

    @BeforeEach
    void setup() {
        refreshTokens.deleteAll();
        routes.deleteAll();
        drivers.deleteAll();
        users.deleteAll();
        admin = user("admin@pathseek.test", UserRole.ADMIN);
        adminToken = jwt.generateAccessToken(admin);
    }

    @Test
    void adminCreatesSafeAccountWithNormalizedEmailAndBcryptPassword() throws Exception {
        String body = mvc.perform(post("/api/v1/usuarios").header("Authorization", bearer(adminToken))
                        .contentType(MediaType.APPLICATION_JSON).content(create("NUEVO@PathSeek.test", PASSWORD, "OPERADOR")))
                .andExpect(status().isCreated()).andExpect(jsonPath("$.activo").value(true))
                .andExpect(jsonPath("$.usuario_id").isNotEmpty()).andExpect(jsonPath("$.email").value("nuevo@pathseek.test"))
                .andExpect(jsonPath("$.password").doesNotExist()).andExpect(jsonPath("$.password_hash").doesNotExist())
                .andExpect(jsonPath("$.passwordHash").doesNotExist()).andExpect(jsonPath("$.token_version").doesNotExist())
                .andReturn().getResponse().getContentAsString();
        assertThat(JsonPath.<String>read(body, "$.rol")).isEqualTo("OPERADOR");
        var saved = users.findByEmail("nuevo@pathseek.test").orElseThrow();
        assertThat(saved.getPasswordHash()).startsWith("$2").isNotEqualTo(PASSWORD);
        assertThat(passwords.matches(PASSWORD, saved.getPasswordHash())).isTrue();
        mvc.perform(post("/api/v1/auth/login").contentType(MediaType.APPLICATION_JSON)
                        .content("{\"email\":\"nuevo@pathseek.test\",\"password\":\"" + PASSWORD + "\"}"))
                .andExpect(status().isOk());
    }

    @Test
    void duplicatesAndInvalidFieldsAreRejected() throws Exception {
        user("existing@pathseek.test", UserRole.CLIENTE);
        mvc.perform(post("/api/v1/usuarios").header("Authorization", bearer(adminToken)).contentType(MediaType.APPLICATION_JSON)
                        .content(create("EXISTING@pathseek.test", PASSWORD, "CLIENTE")))
                .andExpect(status().isConflict()).andExpect(jsonPath("$.code").value("USER_EMAIL_CONFLICT"));
        for (String password : List.of("12345678", "password123", "PASSWORD123", "Password", "Aa1")) {
            mvc.perform(post("/api/v1/usuarios").header("Authorization", bearer(adminToken)).contentType(MediaType.APPLICATION_JSON)
                            .content(create("other@pathseek.test", password, "CLIENTE")))
                    .andExpect(status().isBadRequest());
        }
        mvc.perform(post("/api/v1/usuarios").header("Authorization", bearer(adminToken)).contentType(MediaType.APPLICATION_JSON)
                        .content(create("invalid", PASSWORD, "ADMIN")))
                .andExpect(status().isBadRequest());
        mvc.perform(post("/api/v1/usuarios").header("Authorization", bearer(adminToken)).contentType(MediaType.APPLICATION_JSON)
                        .content(create("other@pathseek.test", PASSWORD, "ROOT")))
                .andExpect(status().isBadRequest());
    }

    @Test
    void catalogReadableOnlyByAdministrativeRolesAndUserDataOnlyByAdmin() throws Exception {
        mvc.perform(get("/api/v1/usuarios")).andExpect(status().isUnauthorized());
        for (var role : UserRole.values()) {
            User actor = user("actor-" + role.name().toLowerCase() + "@pathseek.test", role);
            String token = jwt.generateAccessToken(actor);
            mvc.perform(get("/api/v1/usuarios").header("Authorization", bearer(token)))
                    .andExpect(role == UserRole.ADMIN ? status().isOk() : status().isForbidden());
            mvc.perform(get("/api/v1/configuracion/roles").header("Authorization", bearer(token)))
                    .andExpect(role == UserRole.ADMIN || role == UserRole.OPERADOR || role == UserRole.AUDITOR
                            ? status().isOk() : status().isForbidden());
            mvc.perform(post("/api/v1/usuarios").header("Authorization", bearer(token)).contentType(MediaType.APPLICATION_JSON)
                            .content(create("created-" + role.name().toLowerCase() + "@pathseek.test", PASSWORD, "CLIENTE")))
                    .andExpect(role == UserRole.ADMIN ? status().isCreated() : status().isForbidden());
            mvc.perform(put("/api/v1/usuarios/" + actor.getId()).header("Authorization", bearer(token))
                            .contentType(MediaType.APPLICATION_JSON).content(update(actor, role, true)))
                    .andExpect(role == UserRole.ADMIN ? status().isOk() : status().isForbidden());
        }
        mvc.perform(get("/api/v1/configuracion/roles").header("Authorization", bearer(adminToken)))
                .andExpect(status().isOk()).andExpect(jsonPath("$.length()").value(5))
                .andExpect(jsonPath("$[0].rol").value("ADMIN")).andExpect(jsonPath("$[0].permisos").isArray());
    }

    @Test
    void listingSupportsPaginationAndFiltersWithoutLeakingSecrets() throws Exception {
        user("first@pathseek.test", UserRole.OPERADOR);
        User second = user("second@pathseek.test", UserRole.OPERADOR);
        second.setActivo(false);
        users.saveAndFlush(second);
        mvc.perform(get("/api/v1/usuarios").param("rol", "OPERADOR").param("activo", "false").param("buscar", "SECOND")
                        .param("tamano", "1").header("Authorization", bearer(adminToken)))
                .andExpect(status().isOk()).andExpect(jsonPath("$.total_elementos").value(1))
                .andExpect(jsonPath("$.total_paginas").value(1)).andExpect(jsonPath("$.pagina").value(0))
                .andExpect(jsonPath("$.contenido[0].email").value(second.getEmail()))
                .andExpect(jsonPath("$.contenido[0].passwordHash").doesNotExist());
        mvc.perform(get("/api/v1/usuarios").param("pagina", "-1").header("Authorization", bearer(adminToken)))
                .andExpect(status().isUnprocessableContent());
        mvc.perform(get("/api/v1/usuarios").param("tamano", "101").header("Authorization", bearer(adminToken)))
                .andExpect(status().isUnprocessableContent());
    }

    @Test
    void changingRoleImmediatelyRevokesAccessAndRefreshEvenAfterRoleIsRestored() throws Exception {
        User target = user("operator@pathseek.test", UserRole.OPERADOR);
        String login = login(target);
        String oldAccess = JsonPath.read(login, "$.token");
        String oldRefresh = JsonPath.read(login, "$.refreshToken");
        change(target, UserRole.CLIENTE, true, adminToken).andExpect(status().isOk());
        mvc.perform(get("/api/v1/vehiculos").header("Authorization", bearer(oldAccess))).andExpect(status().isUnauthorized());
        refresh(oldRefresh).andExpect(status().isUnauthorized());
        change(target, UserRole.OPERADOR, true, adminToken).andExpect(status().isOk());
        mvc.perform(get("/api/v1/vehiculos").header("Authorization", bearer(oldAccess))).andExpect(status().isUnauthorized());
        String newAccess = JsonPath.read(login(target), "$.token");
        mvc.perform(get("/api/v1/vehiculos").header("Authorization", bearer(newAccess))).andExpect(status().isOk());
    }

    @Test
    void deactivationRevokesSessionsAndReactivationDoesNotRestoreOldTokens() throws Exception {
        User target = user("inactive@pathseek.test", UserRole.AUDITOR);
        String login = login(target);
        String access = JsonPath.read(login, "$.token");
        String refresh = JsonPath.read(login, "$.refreshToken");
        change(target, UserRole.AUDITOR, false, adminToken).andExpect(status().isOk());
        mvc.perform(get("/api/v1/vehiculos").header("Authorization", bearer(access))).andExpect(status().isUnauthorized());
        refresh(refresh).andExpect(status().isUnauthorized());
        change(target, UserRole.AUDITOR, true, adminToken).andExpect(status().isOk());
        mvc.perform(get("/api/v1/vehiculos").header("Authorization", bearer(access))).andExpect(status().isUnauthorized());
        refresh(refresh).andExpect(status().isUnauthorized());
    }

    @Test
    void lastAdminAndOwnAccessAreProtectedButOwnNameCanBeEdited() throws Exception {
        change(admin, UserRole.OPERADOR, true, adminToken).andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("LAST_ACTIVE_ADMIN"));
        change(admin, UserRole.ADMIN, false, adminToken).andExpect(status().isConflict());
        user("otheradmin@pathseek.test", UserRole.ADMIN);
        change(admin, UserRole.OPERADOR, true, adminToken).andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("SELF_ACCESS_CHANGE"));
        change(admin, UserRole.ADMIN, true, adminToken).andExpect(status().isOk());
        assertThat(users.countByRolAndActivo(UserRole.ADMIN, true)).isEqualTo(2);
    }

    @Test
    void linkedDriverRoleCannotBeChangedAndAccountIsNeverDeleted() throws Exception {
        User target = user("driver@pathseek.test", UserRole.CONDUCTOR);
        Driver driver = new Driver();
        driver.setDni("44556677"); driver.setNombre("Conductor"); driver.setLicencia("DRIVER123");
        driver.setCategoria(DriverCategory.AII); driver.setExperiencia(2); driver.setDisponible(true); driver.setUsuarioId(target.getId());
        drivers.saveAndFlush(driver);
        change(target, UserRole.OPERADOR, true, adminToken).andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("DRIVER_ACCOUNT_LINKED"));
        change(target, UserRole.CONDUCTOR, false, adminToken).andExpect(status().isOk());
        assertThat(drivers.findById(driver.getId()).orElseThrow().getUsuarioId()).isEqualTo(target.getId());
        mvc.perform(delete("/api/v1/usuarios/" + target.getId()).header("Authorization", bearer(adminToken)))
                .andExpect(status().isMethodNotAllowed());
        assertThat(users.existsById(target.getId())).isTrue();
    }

    @Test
    void concurrentAdministratorsCannotRemoveEachOthersLastAccess() throws Exception {
        User second = user("secondadmin@pathseek.test", UserRole.ADMIN);
        String secondToken = jwt.generateAccessToken(second);
        var executor = Executors.newFixedThreadPool(2);
        var start = new CountDownLatch(1);
        try {
            var first = executor.submit(() -> { start.await(); return change(second, UserRole.OPERADOR, true, adminToken)
                    .andReturn().getResponse().getStatus(); });
            var other = executor.submit(() -> { start.await(); return change(admin, UserRole.OPERADOR, true, secondToken)
                    .andReturn().getResponse().getStatus(); });
            start.countDown();
            var codes = List.of(first.get(15, TimeUnit.SECONDS), other.get(15, TimeUnit.SECONDS));
            assertThat(codes).contains(200);
            assertThat(codes.stream().filter(code -> code == 200).count()).isEqualTo(1);
            assertThat(codes).allMatch(code -> code == 200 || code == 401 || code == 403 || code == 409);
            assertThat(users.countByRolAndActivo(UserRole.ADMIN, true)).isEqualTo(1);
        } finally { executor.shutdownNow(); }
    }

    @Test
    void refreshRacingWithDeactivationCannotKeepAnActiveSession() throws Exception {
        User target = user("race@pathseek.test", UserRole.OPERADOR);
        String oldRefresh = JsonPath.read(login(target), "$.refreshToken");
        var executor = Executors.newFixedThreadPool(2);
        var start = new CountDownLatch(1);
        try {
            var rotation = executor.submit(() -> { start.await(); return refresh(oldRefresh).andReturn(); });
            var deactivate = executor.submit(() -> { start.await(); return change(target, UserRole.OPERADOR, false, adminToken).andReturn(); });
            start.countDown();
            var rotated = rotation.get(15, TimeUnit.SECONDS);
            assertThat(deactivate.get(15, TimeUnit.SECONDS).getResponse().getStatus()).isEqualTo(200);
            assertThat(rotated.getResponse().getStatus()).isIn(200, 401);
            if (rotated.getResponse().getStatus() == 200) {
                String access = JsonPath.read(rotated.getResponse().getContentAsString(), "$.token");
                String nextRefresh = JsonPath.read(rotated.getResponse().getContentAsString(), "$.refreshToken");
                mvc.perform(get("/api/v1/vehiculos").header("Authorization", bearer(access))).andExpect(status().isUnauthorized());
                refresh(nextRefresh).andExpect(status().isUnauthorized());
            }
            assertThat(refreshTokens.findAll().stream().filter(token -> token.getRevokedAt() == null).count()).isZero();
        } finally { executor.shutdownNow(); }
    }

    @Test
    void linksByDniInEitherCreationOrderAndRejectsDuplicates() throws Exception {
        for (int variant = 1; variant <= 2; variant++) {
            String dni = "8811223" + variant;
            String profile = "{\"dni\":\"" + dni + "\",\"nombre\":\"Conductor DNI\",\"licencia\":\"Q1234567" + variant
                    + "\",\"categoria\":\"AIII\",\"experiencia\":2,\"disponible\":true}";
            String account = create("dni" + variant + "@pathseek.test", PASSWORD, "CONDUCTOR");
            account = account.substring(0, account.length()-1) + ",\"dni\":\"" + dni + "\"}";
            if (variant == 1) mvc.perform(post("/api/v1/conductores").header("Authorization", bearer(adminToken))
                    .contentType(MediaType.APPLICATION_JSON).content(profile)).andExpect(status().isCreated());
            mvc.perform(post("/api/v1/usuarios").header("Authorization", bearer(adminToken))
                    .contentType(MediaType.APPLICATION_JSON).content(account)).andExpect(status().isCreated());
            if (variant == 2) mvc.perform(post("/api/v1/conductores").header("Authorization", bearer(adminToken))
                    .contentType(MediaType.APPLICATION_JSON).content(profile)).andExpect(status().isCreated());
            assertThat(drivers.findByDni(dni).orElseThrow().getUsuarioId()).isEqualTo(users.findByDni(dni).orElseThrow().getId());
            mvc.perform(post("/api/v1/usuarios").header("Authorization", bearer(adminToken))
                    .contentType(MediaType.APPLICATION_JSON).content(account.replace("dni"+variant+"@", "duplicate"+variant+"@")))
                    .andExpect(status().isConflict());
        }
        mvc.perform(post("/api/v1/usuarios").header("Authorization", bearer(adminToken))
                .contentType(MediaType.APPLICATION_JSON).content(create("nodni@pathseek.test", PASSWORD, "CONDUCTOR")))
                .andExpect(status().isUnprocessableEntity());
    }

    private User user(String email, UserRole role) {
        User user = new User(); user.setNombre("Usuario " + email); user.setEmail(email);
        user.setPasswordHash(passwords.encode(PASSWORD)); user.setRol(role); return users.saveAndFlush(user);
    }
    private String login(User user) throws Exception {
        return mvc.perform(post("/api/v1/auth/login").contentType(MediaType.APPLICATION_JSON)
                        .content("{\"email\":\"" + user.getEmail() + "\",\"password\":\"" + PASSWORD + "\"}"))
                .andExpect(status().isOk()).andReturn().getResponse().getContentAsString();
    }
    private org.springframework.test.web.servlet.ResultActions refresh(String value) throws Exception {
        return mvc.perform(post("/api/v1/auth/refresh").contentType(MediaType.APPLICATION_JSON)
                .content("{\"refreshToken\":\"" + value + "\"}"));
    }
    private org.springframework.test.web.servlet.ResultActions change(User user, UserRole role, boolean active, String token) throws Exception {
        return mvc.perform(put("/api/v1/usuarios/" + user.getId()).header("Authorization", bearer(token))
                .contentType(MediaType.APPLICATION_JSON).content(update(user, role, active)));
    }
    private String bearer(String value) { return "Bearer " + value; }
    private String create(String email, String password, String role) {
        return "{\"nombre\":\"Nueva cuenta\",\"email\":\"" + email + "\",\"password\":\"" + password + "\",\"rol\":\"" + role + "\"}";
    }
    private String update(User user, UserRole role, boolean active) {
        return "{\"nombre\":\"Nombre actualizado\",\"email\":\"" + user.getEmail() + "\",\"rol\":\"" + role.name() + "\",\"activo\":" + active + "}";
    }
}
