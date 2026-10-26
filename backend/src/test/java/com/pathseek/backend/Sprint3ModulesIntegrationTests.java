package com.pathseek.backend;

import com.pathseek.backend.auth.repository.RefreshTokenRepository;
import com.pathseek.backend.carbon.CarbonProjectRepository;
import com.pathseek.backend.client.ClientProfileRepository;
import com.pathseek.backend.driver.entity.Driver;
import com.pathseek.backend.driver.entity.DriverCategory;
import com.pathseek.backend.driver.repository.DriverRepository;
import com.pathseek.backend.order.entity.Order;
import com.pathseek.backend.order.entity.OrderPriority;
import com.pathseek.backend.order.entity.OrderStatus;
import com.pathseek.backend.order.entity.ProductType;
import com.pathseek.backend.order.repository.OrderRepository;
import com.pathseek.backend.route.entity.DeliveryRoute;
import com.pathseek.backend.route.entity.RouteOrder;
import com.pathseek.backend.route.entity.RouteProgress;
import com.pathseek.backend.route.entity.RouteStatus;
import com.pathseek.backend.route.repository.DeliveryRouteRepository;
import com.pathseek.backend.route.repository.RouteProgressRepository;
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
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Import;
import org.springframework.context.annotation.Primary;
import org.springframework.http.MediaType;
import org.springframework.security.oauth2.jose.jws.MacAlgorithm;
import org.springframework.security.oauth2.jwt.JwsHeader;
import org.springframework.security.oauth2.jwt.JwtClaimsSet;
import org.springframework.security.oauth2.jwt.JwtEncoder;
import org.springframework.security.oauth2.jwt.JwtEncoderParameters;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

import java.math.BigDecimal;
import java.time.Clock;
import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.ZoneId;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.within;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@Import(Sprint3ModulesIntegrationTests.TimeConfig.class)
class Sprint3ModulesIntegrationTests {

    static final LocalDate DAY = LocalDate.of(2026, 10, 25);

    @TestConfiguration
    static class TimeConfig {
        @Bean
        @Primary
        Clock planningClock() {
            return Clock.fixed(
                    DAY.atTime(12, 0).atZone(ZoneId.of("America/Lima")).toInstant(),
                    ZoneId.of("America/Lima"));
        }
    }

    @Autowired MockMvc api;
    @Autowired JwtEncoder jwt;
    @Autowired UserRepository users;
    @Autowired RefreshTokenRepository refreshTokens;
    @Autowired VehicleRepository vehicles;
    @Autowired DriverRepository drivers;
    @Autowired OrderRepository orders;
    @Autowired DeliveryRouteRepository routes;
    @Autowired RouteProgressRepository progress;
    @Autowired ClientProfileRepository clients;
    @Autowired CarbonProjectRepository projects;
    int sequence;

    @BeforeEach
    void reset() {
        progress.deleteAll();
        routes.deleteAll();
        orders.deleteAll();
        clients.deleteAll();
        vehicles.deleteAll();
        drivers.deleteAll();
        refreshTokens.deleteAll();
        users.deleteAll();
        sequence = 0;
    }

    // ---------------------------------------------------------------- US-009

    @Test void sustainabilityReportReturnsPdfForOperativeRoles() throws Exception {
        User admin = user(UserRole.ADMIN);
        String auth = token(admin);
        MvcResult result = api.perform(get("/api/v1/reportes/sostenibilidad")
                        .header("Authorization", "Bearer " + auth))
                .andExpect(status().isOk())
                .andExpect(content().contentType(MediaType.APPLICATION_PDF))
                .andReturn();
        byte[] pdf = result.getResponse().getContentAsByteArray();
        assertThat(pdf.length).isGreaterThan(500);
        assertThat(new String(pdf, 0, 4, java.nio.charset.StandardCharsets.US_ASCII)).isEqualTo("%PDF");
    }

    @Test void sustainabilityReportRendersDetailTableWhenRoutesExist() throws Exception {
        completedRoute("25.00", "4.00", "8.00");
        String auth = token(user(UserRole.ADMIN));
        MvcResult result = api.perform(get("/api/v1/reportes/sostenibilidad")
                        .header("Authorization", "Bearer " + auth)
                        .param("desde", DAY.toString())
                        .param("hasta", DAY.toString()))
                .andExpect(status().isOk())
                .andExpect(content().contentType(MediaType.APPLICATION_PDF))
                .andReturn();
        byte[] pdf = result.getResponse().getContentAsByteArray();
        assertThat(pdf.length).isGreaterThan(500);
        assertThat(new String(pdf, 0, 4, java.nio.charset.StandardCharsets.US_ASCII)).isEqualTo("%PDF");
    }

    @Test void sustainabilityReportRejectsInvertedRangeAndUnauthorizedRoles() throws Exception {
        String admin = token(user(UserRole.ADMIN));
        api.perform(get("/api/v1/reportes/sostenibilidad")
                        .header("Authorization", "Bearer " + admin)
                        .param("desde", "2026-12-01")
                        .param("hasta", "2026-01-01"))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code").value("INVALID_REPORT_RANGE"));
        api.perform(get("/api/v1/reportes/sostenibilidad")).andExpect(status().isUnauthorized());
        String conductor = token(user(UserRole.CONDUCTOR));
        api.perform(get("/api/v1/reportes/sostenibilidad").header("Authorization", "Bearer " + conductor))
                .andExpect(status().isForbidden());
    }

    // ---------------------------------------------------------------- US-010

    @Test void carbonPlanAggregatesCompletedRoutesAndSuggestsProjects() throws Exception {
        completedRoute("25.00", "4.00", "8.00");
        completedRoute("10.00", "1.50", "3.20");
        String auth = token(user(UserRole.ADMIN));
        api.perform(get("/api/v1/compensacion/plan").header("Authorization", "Bearer " + auth))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.emisiones_anuales_kg").value(5.50))
                .andExpect(jsonPath("$.emisiones_anuales_t").value(0.006))
                .andExpect(jsonPath("$.arboles_equivalentes").value(1))
                .andExpect(jsonPath("$.proyectos.length()").value(3))
                .andExpect(jsonPath("$.proyectos[0].coste_compensacion_estimado").exists());
    }

    @Test void carbonPlanWithZeroEmissionsSuggestsZeroTrees() throws Exception {
        String auth = token(user(UserRole.AUDITOR));
        api.perform(get("/api/v1/compensacion/plan").header("Authorization", "Bearer " + auth))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.emisiones_anuales_kg").value(0))
                .andExpect(jsonPath("$.arboles_equivalentes").value(0));
    }

    // ---------------------------------------------------------------- US-004

    @Test void adminCreatesClientProfileLinkedToClientAccount() throws Exception {
        User clientUser = user(UserRole.CLIENTE);
        String auth = token(user(UserRole.ADMIN));
        String body = """
                {
                  "usuario_id": "%s",
                  "nombre": "Bodega El Ahorro",
                  "direccion": "Jr. Real 450, Huancayo",
                  "punto_referencia": "Frente a la plazuela",
                  "telefono": "964123456",
                  "horario_atencion_inicio": "06:00",
                  "horario_atencion_fin": "21:00",
                  "restricciones_acceso": "Sin acceso de camiones después de las 14:00"
                }
                """.formatted(clientUser.getId());
        api.perform(post("/api/v1/clientes").header("Authorization", "Bearer " + auth)
                        .contentType(MediaType.APPLICATION_JSON).content(body))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.cliente_id").isNotEmpty())
                .andExpect(jsonPath("$.usuario_id").value(clientUser.getId().toString()))
                .andExpect(jsonPath("$.nombre").value("Bodega El Ahorro"));
        assertThat(clients.count()).isEqualTo(1);
    }

    @Test void clientRulesRejectDuplicateLinkInvalidAccountAndIncompleteSchedule() throws Exception {
        User clientUser = user(UserRole.CLIENTE);
        String auth = token(user(UserRole.ADMIN));
        String valid = clientBody(clientUser.getId(), "Bodega Uno", "\"06:00\"", "\"21:00\"");
        api.perform(post("/api/v1/clientes").header("Authorization", "Bearer " + auth)
                .contentType(MediaType.APPLICATION_JSON).content(valid)).andExpect(status().isCreated());
        api.perform(post("/api/v1/clientes").header("Authorization", "Bearer " + auth)
                        .contentType(MediaType.APPLICATION_JSON).content(valid))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("CLIENT_ALREADY_LINKED"));
        api.perform(post("/api/v1/clientes").header("Authorization", "Bearer " + auth)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(clientBody(user(UserRole.OPERADOR).getId(), "Bodega Dos", "\"06:00\"", "\"21:00\"")))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code").value("CLIENT_USER_INVALID"));
        api.perform(post("/api/v1/clientes").header("Authorization", "Bearer " + auth)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(clientBody(user(UserRole.CLIENTE).getId(), "Bodega Tres", "\"06:00\"", "null")))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code").value("CLIENT_SCHEDULE_INCOMPLETE"));
    }

    @Test void clientOwnsOnlyItsProfileAndCannotMutateOthers() throws Exception {
        User owner = user(UserRole.CLIENTE);
        User other = user(UserRole.CLIENTE);
        String admin = token(user(UserRole.ADMIN));
        api.perform(post("/api/v1/clientes").header("Authorization", "Bearer " + admin)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(clientBody(owner.getId(), "Bodega Propia", "\"06:00\"", "\"21:00\"")))
                .andExpect(status().isCreated());
        api.perform(post("/api/v1/clientes").header("Authorization", "Bearer " + admin)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(clientBody(other.getId(), "Bodega Ajena", "\"08:00\"", "\"18:00\"")))
                .andExpect(status().isCreated());

        String ownerToken = token(owner);
        MvcResult own = api.perform(get("/api/v1/clientes").header("Authorization", "Bearer " + ownerToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(1))
                .andExpect(jsonPath("$[0].nombre").value("Bodega Propia"))
                .andReturn();
        String ownId = com.jayway.jsonpath.JsonPath.read(own.getResponse().getContentAsString(), "$[0].cliente_id");
        UUID otherProfileId = clients.findByUsuarioId(other.getId()).orElseThrow().getId();
        api.perform(get("/api/v1/clientes/" + otherProfileId).header("Authorization", "Bearer " + ownerToken))
                .andExpect(status().isForbidden());
        api.perform(put("/api/v1/clientes/" + ownId).header("Authorization", "Bearer " + ownerToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(clientBody(other.getId(), "Intento de suplantación", "\"06:00\"", "\"21:00\"")))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("CLIENT_USER_LOCKED"));
        api.perform(get("/api/v1/clientes").header("Authorization", "Bearer " + token(user(UserRole.CONDUCTOR))))
                .andExpect(status().isForbidden());
    }

    @Test void clientCreatesOwnProfileWithoutChoosingAccount() throws Exception {
        User owner = user(UserRole.CLIENTE);
        String ownerToken = token(owner);
        String body = """
                {
                  "nombre": "Mi Bodega",
                  "direccion": "Av. Ferrocarril 900",
                  "horario_atencion_inicio": "07:30",
                  "horario_atencion_fin": "20:00"
                }
                """;
        api.perform(post("/api/v1/clientes").header("Authorization", "Bearer " + ownerToken)
                        .contentType(MediaType.APPLICATION_JSON).content(body))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.usuario_id").value(owner.getId().toString()));
        api.perform(post("/api/v1/clientes").header("Authorization", "Bearer " + ownerToken)
                        .contentType(MediaType.APPLICATION_JSON).content(body))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("CLIENT_ALREADY_LINKED"));
        assertThat(clients.findByUsuarioId(owner.getId())).isPresent();
    }

    // ------------------------------------------------- EN-008 (ejecución)

    @Test void conductorCompletesDeliveriesInOrderAndReplaysAreIdempotent() throws Exception {
        User conductor = user(UserRole.CONDUCTOR);
        DeliveryRoute route = routeWithStops(conductor, 2);
        String auth = token(conductor);
        UUID first = route.getPedidos().get(0).getPedido().getId();
        UUID second = route.getPedidos().get(1).getPedido().getId();

        api.perform(post("/api/v1/rutas/" + route.getId() + "/entregas/" + second + "/completar")
                        .header("Authorization", "Bearer " + auth))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("ORDER_PREFIX_INCOMPLETE"));
        api.perform(post("/api/v1/rutas/" + route.getId() + "/entregas/" + first + "/completar")
                        .header("Authorization", "Bearer " + auth))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.pedido_estado").value("ENTREGADO"))
                .andExpect(jsonPath("$.ruta_estado").value("EN_PROGRESO"))
                .andExpect(jsonPath("$.ya_registrado").value(false));
        api.perform(post("/api/v1/rutas/" + route.getId() + "/entregas/" + first + "/completar")
                        .header("Authorization", "Bearer " + auth))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.ya_registrado").value(true));
        api.perform(post("/api/v1/rutas/" + route.getId() + "/entregas/" + second + "/completar")
                        .header("Authorization", "Bearer " + auth))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.ruta_estado").value("COMPLETADA"));
    }

    @Test void conductorReportsPositionAndCannotTouchOtherRoutes() throws Exception {
        User owner = user(UserRole.CONDUCTOR);
        User intruder = user(UserRole.CONDUCTOR);
        DeliveryRoute route = routeWithStops(owner, 1);
        String ownerToken = token(owner);
        String intruderToken = token(intruder);
        String position = "{\"lat\": -12.0651, \"lon\": -75.2045}";

        api.perform(post("/api/v1/rutas/" + route.getId() + "/posicion")
                        .header("Authorization", "Bearer " + ownerToken)
                        .contentType(MediaType.APPLICATION_JSON).content(position))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.ruta_estado").value("EN_PROGRESO"));
        RouteProgress saved = progress.findById(route.getId()).orElseThrow();
        assertThat(saved.lastOrder()).isZero();
        assertThat(saved.distance()).isGreaterThan(0);
        assertThat(saved.fuel()).isEqualTo(saved.distance() / 10.0, within(1e-5));
        assertThat(saved.co2()).isEqualTo(saved.distance() * 0.2, within(1e-5));

        api.perform(post("/api/v1/rutas/" + route.getId() + "/posicion")
                        .header("Authorization", "Bearer " + intruderToken)
                        .contentType(MediaType.APPLICATION_JSON).content(position))
                .andExpect(status().isForbidden());
        api.perform(post("/api/v1/rutas/" + route.getId() + "/posicion")
                        .contentType(MediaType.APPLICATION_JSON).content(position))
                .andExpect(status().isUnauthorized());
        api.perform(post("/api/v1/rutas/" + route.getId() + "/posicion")
                        .header("Authorization", "Bearer " + ownerToken)
                        .contentType(MediaType.APPLICATION_JSON).content("{\"lat\": 91.0, \"lon\": -75.2}"))
                .andExpect(status().isBadRequest());
    }

    // ------------------------------------------------------------ helpers

    private DeliveryRoute routeWithStops(User conductorUser, int stops) {
        Vehicle vehicle = new Vehicle();
        vehicle.setPlaca("EJEC-" + String.format("%03d", ++sequence));
        vehicle.setTipo(VehicleType.CAMIONETA);
        vehicle.setCapacidadKg(BigDecimal.valueOf(1000));
        vehicle.setCapacidadM3(BigDecimal.valueOf(100));
        vehicle.setConsumoKmL(BigDecimal.TEN);
        vehicle.setFactorEmision(BigDecimal.valueOf(0.2));
        vehicle.setAnio(2024);
        vehicles.save(vehicle);

        Driver driver = new Driver();
        driver.setNombre("Conductor ejecución");
        driver.setDni(String.format("%08d", ++sequence));
        driver.setLicencia("Q" + driver.getDni());
        driver.setCategoria(DriverCategory.AII);
        driver.setExperiencia(3);
        driver.setDisponible(true);
        driver.setUsuarioId(conductorUser.getId());
        drivers.save(driver);

        DeliveryRoute route = new DeliveryRoute();
        route.setFecha(DAY);
        route.setConductor(driver);
        route.setVehiculo(vehicle);
        route.setDistanciaKm(new BigDecimal("12.00"));
        routes.saveAndFlush(route);
        for (int i = 0; i < stops; i++) {
            Order order = new Order();
            order.setClienteId(UUID.randomUUID().toString());
            order.setDireccion("Entrega ejecución " + i);
            order.setGpsLat(BigDecimal.valueOf(-12.06 - i * 0.001));
            order.setGpsLon(BigDecimal.valueOf(-75.20));
            order.setPeso(BigDecimal.TEN);
            order.setVolumen(BigDecimal.ONE);
            order.setVentanaInicio("07:00");
            order.setVentanaFin("23:00");
            order.setPrioridad(OrderPriority.ESTANDAR);
            order.setTipoProducto(ProductType.NO_PERECEDERO);
            order.setEstado(OrderStatus.EN_RUTA);
            orders.save(order);
            route.addPedido(new RouteOrder(route, order, i + 1, LocalTime.of(8, 0).plusMinutes((i + 1) * 20L), true));
        }
        return routes.saveAndFlush(route);
    }

    private DeliveryRoute completedRoute(String distance, String co2, String fuel) {
        DeliveryRoute route = routeWithStops(user(UserRole.CONDUCTOR), 1);
        route.setEstado(RouteStatus.COMPLETADA);
        route.setDistanciaKm(new BigDecimal(distance));
        route.setCo2Kg(new BigDecimal(co2));
        route.setCombustibleL(new BigDecimal(fuel));
        return routes.save(route);
    }

    private String clientBody(UUID usuarioId, String nombre, String inicio, String fin) {
        return """
                {
                  "usuario_id": "%s",
                  "nombre": "%s",
                  "direccion": "Dirección de prueba",
                  "horario_atencion_inicio": %s,
                  "horario_atencion_fin": %s
                }
                """.formatted(usuarioId, nombre, inicio, fin);
    }

    private User user(UserRole role) {
        User user = new User();
        user.setNombre("Prueba " + role);
        user.setEmail(UUID.randomUUID() + "@local.test");
        user.setRol(role);
        user.setActivo(true);
        user.setPasswordHash("unused-test-password-hash");
        return users.save(user);
    }

    private String token(User user) {
        Instant now = Instant.now();
        JwtClaimsSet claims = JwtClaimsSet.builder()
                .subject(user.getId().toString())
                .issuedAt(now)
                .expiresAt(now.plusSeconds(3600))
                .claim("rol", user.getRol().name())
                .claim("email", user.getEmail())
                .build();
        JwsHeader header = JwsHeader.with(MacAlgorithm.HS256).build();
        return jwt.encode(JwtEncoderParameters.from(header, claims)).getTokenValue();
    }
}
