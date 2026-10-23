package com.pathseek.backend;

import com.pathseek.backend.auth.repository.RefreshTokenRepository;
import com.pathseek.backend.driver.entity.*;
import com.pathseek.backend.driver.repository.DriverRepository;
import com.pathseek.backend.exception.BusinessConflictException;
import com.pathseek.backend.order.entity.*;
import com.pathseek.backend.order.repository.OrderRepository;
import com.pathseek.backend.route.dto.*;
import com.pathseek.backend.route.entity.*;
import com.pathseek.backend.route.repository.*;
import com.pathseek.backend.route.service.*;
import com.pathseek.backend.user.entity.*;
import com.pathseek.backend.user.repository.UserRepository;
import com.pathseek.backend.vehicle.entity.*;
import com.pathseek.backend.vehicle.repository.VehicleRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.AfterEach;
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
import org.springframework.security.oauth2.jwt.*;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.support.TransactionTemplate;
import org.springframework.transaction.PlatformTransactionManager;
import tools.jackson.databind.ObjectMapper;
import com.jayway.jsonpath.JsonPath;
import java.math.BigDecimal;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.*;
import java.util.*;
import java.util.concurrent.*;
import static org.junit.jupiter.api.Assertions.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@Import(ReoptimizationIntegrationTests.TimeConfig.class)
class ReoptimizationIntegrationTests {
    static final LocalDate DATE = LocalDate.of(2026,10,22);
    static class MutableClock extends Clock {
        Instant instant = DATE.atTime(7,30).atZone(ZoneId.of("America/Lima")).toInstant();
        @Override public ZoneId getZone() { return ZoneOffset.UTC; }
        @Override public Clock withZone(ZoneId zone) { return Clock.fixed(instant, zone); }
        @Override public Instant instant() { return instant; }
    }
    @TestConfiguration static class TimeConfig { @Bean @Primary MutableClock planningClock() { return new MutableClock(); } }
    @Autowired MutableClock clock;
    @Autowired MockMvc api;
    @Autowired ObjectMapper json;
    @Autowired JwtEncoder jwt;
    @Autowired RouteReoptimizationService service;
    @Autowired RouteOptimizationService generation;
    @Autowired RoutingContextService context;
    @Autowired ReoptimizationProperties properties;
    @Autowired DeliveryRouteRepository routes;
    @Autowired RouteOrderRepository assignments;
    @Autowired OrderRepository orders;
    @Autowired VehicleRepository vehicles;
    @Autowired DriverRepository drivers;
    @Autowired ReoptimizationEventRepository events;
    @Autowired RoadIncidentRepository incidents;
    @Autowired VehicleBreakdownRepository breakdowns;
    @Autowired RouteNotificationRepository notifications;
    @Autowired RouteProgressRepository progress;
    @Autowired RefreshTokenRepository refreshTokens;
    @Autowired UserRepository users;
    @Autowired PlatformTransactionManager transactions;
    int sequence;

    @BeforeEach void reset() {
        progress.deleteAll(); notifications.deleteAll(); events.deleteAll(); incidents.deleteAll(); breakdowns.deleteAll();
        routes.deleteAll(); orders.deleteAll(); vehicles.deleteAll(); drivers.deleteAll(); refreshTokens.deleteAll(); users.deleteAll();
        sequence = 0; properties.setBudgetMs(25000);
        clock.instant = DATE.atTime(7,30).atZone(ZoneId.of("America/Lima")).toInstant();
    }
    @AfterEach void cleanup() {
        progress.deleteAll(); notifications.deleteAll(); events.deleteAll(); incidents.deleteAll(); breakdowns.deleteAll();
        routes.deleteAll(); orders.deleteAll(); vehicles.deleteAll(); drivers.deleteAll(); refreshTokens.deleteAll(); users.deleteAll();
    }
    @Test void newOrdersChangeOnlyTheReceivingRouteAndRetryReplaysTheOriginalSnapshot() {
        var first = route(2); var unaffected = route(2);
        Order incoming = order(-12.061,-75.204,10);
        var request = request(ReoptimizationRequest.Tipo.NUEVOS_PEDIDOS, List.of(first.getId(),unaffected.getId()), List.of(incoming.getId()), null,null,null,List.of());
        var result = service.reoptimize(request);
        assertEquals(1,result.rutasReoptimizadas().size()); assertEquals(1,result.rutasSinCambios().size());
        UUID untouched = result.rutasSinCambios().get(0);
        assertEquals(new BigDecimal("50.00"), routes.findById(untouched).orElseThrow().getDistanciaKm());
        assertEquals(OrderStatus.EN_RUTA, orders.findById(incoming.getId()).orElseThrow().getEstado());
        long notices = notifications.count();
        assertEquals(result, service.reoptimize(request)); assertEquals(notices, notifications.count());
        assertEquals(1, events.count()); assertEquals(2,routes.count());
        var reused = new ReoptimizationRequest(request.eventoId(), ReoptimizationRequest.Tipo.CANCELACION, DATE,
                request.rutasIds(), request.pedidosIds(),null,null,null,List.of());
        assertEquals("EVENT_ID_REUSED", assertThrows(BusinessConflictException.class, () -> service.reoptimize(reused)).getCode());
    }
    @Test void simultaneousRequestsCannotAssignTheSameOrderTwice() throws Exception {
        var route = route(2); var incoming = order(-12.061,-75.204,10);
        var executor = Executors.newFixedThreadPool(2); var start = new CountDownLatch(1);
        try {
            List<Future<Boolean>> attempts = new ArrayList<>();
            for (int i=0;i<2;i++) attempts.add(executor.submit(() -> {
                start.await();
                try { service.reoptimize(request(ReoptimizationRequest.Tipo.NUEVOS_PEDIDOS,List.of(route.getId()),List.of(incoming.getId()),null,null,null,List.of())); return true; }
                catch (BusinessConflictException | org.springframework.dao.PessimisticLockingFailureException expected) { return false; }
            }));
            start.countDown(); int successes=0;
            for (var attempt : attempts) if (attempt.get(10,TimeUnit.SECONDS)) successes++;
            assertEquals(1,successes);
            assertEquals(1,assignments.countActiveAssignments(List.of(incoming.getId()),List.of(RouteStatus.PLANIFICADA,RouteStatus.EN_PROGRESO)));
            assertEquals(1,events.count()); assertEquals(1,notifications.count());
        } finally { executor.shutdownNow(); }
    }
    @Test void capacityFailureLeavesNewOrdersPendingWithoutChangingExistingRoutes() {
        var route = route(1); Order oversized = order(-12.061,-75.204,50000);
        var result = service.reoptimize(request(ReoptimizationRequest.Tipo.NUEVOS_PEDIDOS,List.of(route.getId()),List.of(oversized.getId()),null,null,null,List.of()));
        assertEquals(List.of(oversized.getId()),result.pedidosNoAsignados());
        assertTrue(result.rutasReoptimizadas().isEmpty()); assertEquals(0,notifications.count());
        assertEquals(OrderStatus.PENDIENTE,orders.findById(oversized.getId()).orElseThrow().getEstado());
        assertEquals(new BigDecimal("50.00"),routes.findById(route.getId()).orElseThrow().getDistanciaKm());
    }
    @Test void cancellingTheOnlyDeliveryPreservesTheRouteAsCancelledHistory() {
        var route = route(1); UUID orderId = orderIds(route.getId()).get(0);
        service.reoptimize(request(ReoptimizationRequest.Tipo.CANCELACION,List.of(),List.of(orderId),null,null,null,List.of()));
        assertEquals(RouteStatus.CANCELADA,routes.findById(route.getId()).orElseThrow().getEstado());
        assertEquals(OrderStatus.CANCELADO,orders.findById(orderId).orElseThrow().getEstado());
        assertEquals(0,assignments.findByRuta_IdOrderByOrdenAsc(route.getId()).size());
        assertEquals(1,routes.count()); assertEquals(1,notifications.count());
    }
    @Test void incidentReordersOnlyAffectedRouteAndPersistsExclusion() {
        var route = route(List.of(new double[]{-12.0583,-75.20},new double[]{-12.0583,-75.21},new double[]{-12.0683,-75.20}));
        var unaffected = route(1);
        var incident = new RoadIncidentRequest("BLOQUEO","Cierre de tramo",BigDecimal.valueOf(-12.0633),BigDecimal.valueOf(-75.205),25);
        var result = service.reoptimize(request(ReoptimizationRequest.Tipo.INCIDENTE,List.of(route.getId(),unaffected.getId()),List.of(),null,null,incident,List.of()));
        assertEquals(1,result.rutasReoptimizadas().size()); assertEquals(List.of(unaffected.getId()),result.rutasSinCambios());
        assertEquals(1,context.getIncidentes(route.getId()).size());
        assertEquals(3,orderIds(route.getId()).size());
        var area = IncrementalRoutePlanner.Area.of(incident); var last = IncrementalRoutePlanner.DEPOT;
        for (var stop : result.rutasReoptimizadas().get(0).pedidos()) {
            var point = new IncrementalRoutePlanner.Point(stop.gpsLat().doubleValue(),stop.gpsLon().doubleValue());
            assertFalse(area.crosses(last,point)); last=point;
        }
        assertFalse(area.crosses(last,IncrementalRoutePlanner.DEPOT));
        assertEquals("ESTIMADO_SIN_RED_VIAL",result.modeloDistancia());
    }
    @Test void infeasibleEventRollsBackCancellationAssignmentsAndNotifications() {
        var route = route(2); var ids=orderIds(route.getId());
        Order blocked=orders.findById(ids.get(1)).orElseThrow();
        context.registrarIncidente(route.getId(),new RoadIncidentRequest("BLOQUEO","Destino inaccesible",blocked.getGpsLat(),blocked.getGpsLon(),100));
        var error=assertThrows(BusinessConflictException.class,()->service.reoptimize(request(ReoptimizationRequest.Tipo.CANCELACION,
                List.of(route.getId()),List.of(ids.get(0)),null,null,null,List.of())));
        assertEquals("REOPTIMIZATION_INFEASIBLE",error.getCode());
        assertEquals(OrderStatus.EN_RUTA,orders.findById(ids.get(0)).orElseThrow().getEstado());
        assertEquals(2,orderIds(route.getId()).size()); assertEquals(0,events.count()); assertEquals(0,notifications.count());
    }
    @Test void executingRouteRequiresCurrentPositionAndNeverCancelsDeliveredOrders() throws Exception {
        var route=route(3); var ids=orderIds(route.getId());
        markExecuting(route.getId(),ids.get(0));
        String token=token(user(UserRole.ADMIN));
        api.perform(post("/api/v1/rutas/reoptimizar").header("Authorization","Bearer "+token).contentType(MediaType.APPLICATION_JSON)
            .content(json.writeValueAsString(request(ReoptimizationRequest.Tipo.CANCELACION,List.of(route.getId()),List.of(ids.get(2)),null,null,null,List.of()))))
            .andExpect(status().isUnprocessableEntity()).andExpect(jsonPath("$.code").value("CURRENT_POSITION_REQUIRED"));
        var error=assertThrows(BusinessConflictException.class,()->service.reoptimize(request(ReoptimizationRequest.Tipo.CANCELACION,
            List.of(route.getId()),List.of(ids.get(0)),null,null,null,List.of(position(route.getId())))));
        assertEquals("ORDER_ALREADY_DELIVERED",error.getCode());
        assertEquals(OrderStatus.ENTREGADO,orders.findById(ids.get(0)).orElseThrow().getEstado());
    }
    @Test void breakdownPreservesCompletedPrefixAndItsMetricsAcrossSubsequentEvents() {
        var route=route(4); var ids=orderIds(route.getId()); markExecuting(route.getId(),ids.get(0));
        var oldVehicle=route.getVehiculo(); var replacement=vehicle(); replacement.setFactorEmision(BigDecimal.valueOf(.8)); vehicles.save(replacement);
        var before=assignments.findByRuta_IdOrderByOrdenAsc(route.getId()).get(0).getHoraEstimada();
        service.reoptimize(request(ReoptimizationRequest.Tipo.AVERIA,List.of(route.getId()),List.of(),oldVehicle.getId(),replacement.getId(),null,List.of(position(route.getId()))));
        assertEquals(replacement.getId(),routes.findById(route.getId()).orElseThrow().getVehiculo().getId());
        assertTrue(generation.getRouteGeometry(route.getId()).waypoints().stream().anyMatch(point -> point.tipo().equals("POSICION_ACTUAL")));
        assertTrue(breakdowns.findActiveVehicleIds().contains(oldVehicle.getId()));
        double frozenCo2=progress.findById(route.getId()).orElseThrow().co2();
        assertTrue(frozenCo2>0);
        service.reoptimize(request(ReoptimizationRequest.Tipo.CANCELACION,List.of(route.getId()),List.of(ids.get(2)),null,null,null,List.of(position(route.getId()))));
        assertEquals(frozenCo2,progress.findById(route.getId()).orElseThrow().co2(),.000001);
        var completed=assignments.findByRuta_IdOrderByOrdenAsc(route.getId()).get(0);
        assertEquals(ids.get(0),completed.getPedido().getId()); assertEquals(1,completed.getOrden()); assertEquals(before,completed.getHoraEstimada());
        assertEquals(OrderStatus.ENTREGADO,orders.findById(ids.get(0)).orElseThrow().getEstado());
        order(-12.061,-75.204,10); assertTrue(generation.generateRoutes().rutas().isEmpty());
    }
    @Test void unavailableReplacementRollsBackEventWithoutDestroyingOriginalRoute() {
        var first=route(2); var busy=route(1);
        var error=assertThrows(BusinessConflictException.class,()->service.reoptimize(request(ReoptimizationRequest.Tipo.AVERIA,
            List.of(first.getId()),List.of(),first.getVehiculo().getId(),busy.getVehiculo().getId(),null,List.of())));
        assertEquals("REPLACEMENT_UNAVAILABLE",error.getCode());
        assertEquals(first.getVehiculo().getId(),routes.findById(first.getId()).orElseThrow().getVehiculo().getId());
        assertEquals(0,events.count()); assertEquals(0,breakdowns.count());
    }
    @Test void reportedBreakdownCannotBeReusedUntilExplicitlyResolved() throws Exception {
        var available=vehicle(); driver(); Order pending=order(-12.061,-75.204,10);
        String auth=token(user(UserRole.ADMIN));
        api.perform(post("/api/v1/rutas/averias/"+available.getId()).header("Authorization","Bearer "+auth)).andExpect(status().isNoContent());
        assertEquals(List.of(pending.getId()),generation.generateRoutes().pedidosNoAsignados());
        api.perform(post("/api/v1/rutas/averias/"+available.getId()+"/resolver").header("Authorization","Bearer "+auth)).andExpect(status().isNoContent());
        assertEquals(1,generation.generateRoutes().rutas().size());
    }
    @Test void expiredBudgetCannotCommitAnyPlanningChange() {
        var route=route(2); var incoming=order(-12.061,-75.204,10); properties.setBudgetMs(0);
        try {
            var error=assertThrows(BusinessConflictException.class,()->service.reoptimize(request(ReoptimizationRequest.Tipo.NUEVOS_PEDIDOS,
                List.of(route.getId()),List.of(incoming.getId()),null,null,null,List.of())));
            assertEquals("REOPTIMIZATION_TIMEOUT",error.getCode());
            assertEquals(OrderStatus.PENDIENTE,orders.findById(incoming.getId()).orElseThrow().getEstado());
            assertEquals(0,events.count()); assertEquals(0,notifications.count());
        } finally { properties.setBudgetMs(25000); }
    }
    @Test void notificationInboxIsPersistentScopedAndOnlyItsRecipientCanAcknowledge() throws Exception {
        User recipient=user(UserRole.CONDUCTOR), other=user(UserRole.CONDUCTOR);
        var route=route(1); Driver driver=route.getConductor(); driver.setUsuarioId(recipient.getId()); drivers.save(driver);
        var ids=orderIds(route.getId());
        var result=service.reoptimize(request(ReoptimizationRequest.Tipo.CANCELACION,List.of(route.getId()),ids,null,null,null,List.of()));
        assertEquals(1,result.notificacionesGeneradas()); assertEquals(0,result.conductoresSinUsuario());
        String own=token(recipient), otherToken=token(other);
        String response=api.perform(get("/api/v1/rutas/notificaciones").header("Authorization","Bearer "+own))
            .andExpect(status().isOk()).andExpect(jsonPath("$.length()").value(1)).andReturn().getResponse().getContentAsString();
        String id=JsonPath.read(response,"$[0].notificacion_id");
        api.perform(get("/api/v1/rutas/notificaciones").header("Authorization","Bearer "+otherToken)).andExpect(jsonPath("$.length()").value(0));
        api.perform(post("/api/v1/rutas/notificaciones/"+id+"/leida").header("Authorization","Bearer "+otherToken)).andExpect(status().isForbidden());
        api.perform(post("/api/v1/rutas/notificaciones/"+id+"/leida").header("Authorization","Bearer "+own)).andExpect(status().isNoContent());
        api.perform(get("/api/v1/rutas/notificaciones").header("Authorization","Bearer "+own)).andExpect(jsonPath("$[0].leida").value(true));
    }
    @Test void reoptimizationPreservesExistingAuthorizationAndValidatesPayload() throws Exception {
        var route=route(1); var incoming=order(-12.061,-75.204,10);
        var payload=json.writeValueAsString(request(ReoptimizationRequest.Tipo.NUEVOS_PEDIDOS,List.of(route.getId()),List.of(incoming.getId()),null,null,null,List.of()));
        api.perform(post("/api/v1/rutas/reoptimizar").contentType(MediaType.APPLICATION_JSON).content(payload)).andExpect(status().isUnauthorized());
        for (var role:List.of(UserRole.AUDITOR,UserRole.CONDUCTOR,UserRole.CLIENTE)) api.perform(post("/api/v1/rutas/reoptimizar")
            .header("Authorization","Bearer "+token(user(role))).contentType(MediaType.APPLICATION_JSON).content(payload)).andExpect(status().isForbidden());
        api.perform(post("/api/v1/rutas/reoptimizar").header("Authorization","Bearer "+token(user(UserRole.ADMIN)))
            .contentType(MediaType.APPLICATION_JSON).content("{\"tipo\":\"NUEVOS_PEDIDOS\"}")).andExpect(status().isBadRequest());
        api.perform(post("/api/v1/rutas/reoptimizar").header("Authorization","Bearer "+token(user(UserRole.OPERADOR)))
            .contentType(MediaType.APPLICATION_JSON).content(payload)).andExpect(status().isOk());
    }
    @Test void existingIncidentEndpointPersistsAndResolutionRemovesExclusion() throws Exception {
        var route=route(1); String auth=token(user(UserRole.ADMIN));
        api.perform(post("/api/v1/rutas/"+route.getId()+"/incidentes").header("Authorization","Bearer "+auth).contentType(MediaType.APPLICATION_JSON)
            .content("{\"tipo\":\"OBRAS\",\"descripcion\":\"Obras\",\"lat\":-12.06,\"lon\":-75.20,\"radioAfectacionMetros\":100}"))
            .andExpect(status().isOk()).andExpect(jsonPath("$.mensaje").exists());
        String response=api.perform(get("/api/v1/rutas/"+route.getId()+"/incidentes").header("Authorization","Bearer "+auth))
            .andExpect(status().isOk()).andExpect(jsonPath("$.length()").value(1)).andReturn().getResponse().getContentAsString();
        String id=JsonPath.read(response,"$[0].incidente_id");
        api.perform(post("/api/v1/rutas/"+route.getId()+"/incidentes/"+id+"/resolver").header("Authorization","Bearer "+auth)).andExpect(status().isNoContent());
        assertTrue(context.getIncidentes(route.getId()).isEmpty());
    }
    @Test void peakMorningReference150Orders15VehiclesCompletesBelow30Seconds() throws Exception { benchmark(7,30,"morning"); }
    @Test void peakEveningReference150Orders15VehiclesCompletesBelow30Seconds() throws Exception { benchmark(17,30,"evening"); }
    private void benchmark(int hour,int minute,String label) throws Exception {
        clock.instant=DATE.atTime(hour,minute).atZone(ZoneId.of("America/Lima")).toInstant();
        List<UUID> scope=new ArrayList<>();
        for(int routeIndex=0;routeIndex<15;routeIndex++) {
            List<double[]> points=new ArrayList<>();
            for(int stop=0;stop<10;stop++) points.add(new double[]{-12.06-routeIndex*.001,-75.20-stop*.0002});
            scope.add(route(points).getId());
        }
        var incoming=new ArrayList<UUID>(); for(int i=0;i<5;i++) incoming.add(order(-12.061-i*.0001,-75.204,10).getId());
        String payload=json.writeValueAsString(request(ReoptimizationRequest.Tipo.NUEVOS_PEDIDOS,scope,incoming,null,null,null,List.of()));
        String auth=token(user(UserRole.OPERADOR)); long started=System.nanoTime();
        String response=assertTimeout(Duration.ofSeconds(30),()->api.perform(post("/api/v1/rutas/reoptimizar")
            .header("Authorization","Bearer "+auth).contentType(MediaType.APPLICATION_JSON).content(payload))
            .andExpect(status().isOk()).andExpect(jsonPath("$.horario_punta").value(true)).andReturn().getResponse().getContentAsString());
        double elapsed=(System.nanoTime()-started)/1_000_000.0;
        assertTrue(elapsed<30000,"SLA de reoptimización excedido: "+elapsed+" ms");
        assertEquals(15,routes.count()); assertEquals(155,assignments.count());
        var metrics=Map.of("scenario",label,"existing_orders",150,"vehicles",15,"new_orders",5,
            "http_local_elapsed_ms",elapsed,"server_calculation_ms",JsonPath.read(response,"$.tiempo_calculo_ms"),"sla_ms",30000);
        Files.createDirectories(Path.of("target"));
        Files.writeString(Path.of("target/reoptimization-benchmark-"+label+".json"),json.writeValueAsString(metrics));
        System.out.println("REOPTIMIZATION_BENCHMARK "+json.writeValueAsString(metrics));
    }
    private ReoptimizationRequest request(ReoptimizationRequest.Tipo type,List<UUID> routes,List<UUID> orders,UUID vehicle,UUID replacement,RoadIncidentRequest incident,List<ReoptimizationRequest.Posicion> positions) {
        return new ReoptimizationRequest(UUID.randomUUID(),type,DATE,routes,orders,vehicle,replacement,incident,positions);
    }
    private ReoptimizationRequest.Posicion position(UUID route) { return new ReoptimizationRequest.Posicion(route,BigDecimal.valueOf(-12.061),BigDecimal.valueOf(-75.204)); }
    private List<UUID> orderIds(UUID route) { return assignments.findByRuta_IdOrderByOrdenAsc(route).stream().map(stop->stop.getPedido().getId()).toList(); }
    private void markExecuting(UUID routeId,UUID delivered) {
        var tx=new TransactionTemplate(transactions); tx.executeWithoutResult(status->{
            var route=routes.findById(routeId).orElseThrow(); route.setEstado(RouteStatus.EN_PROGRESO);
            for(var stop:route.getPedidos()) if(stop.getPedido().getId().equals(delivered)) { stop.getPedido().setEstado(OrderStatus.ENTREGADO); stop.setHoraEstimada(LocalTime.of(7,15)); }
        });
    }
    private DeliveryRoute route(int count) {
        List<double[]> points=new ArrayList<>(); for(int i=0;i<count;i++) points.add(new double[]{-12.06-i*.0001,-75.20});
        return route(points);
    }
    private DeliveryRoute route(List<double[]> points) {
        var route=new DeliveryRoute(); route.setFecha(DATE); route.setConductor(driver()); route.setVehiculo(vehicle());
        route.setDistanciaKm(new BigDecimal("50.00")); routes.saveAndFlush(route);
        int index=0; for(var point:points) {
            Order order=order(point[0],point[1],10); order.setEstado(OrderStatus.EN_RUTA); orders.save(order);
            route.addPedido(new RouteOrder(route,order,++index,LocalTime.of(8,0).plusMinutes(index*20L),true));
        }
        return routes.saveAndFlush(route);
    }
    private Vehicle vehicle() {
        var vehicle=new Vehicle(); vehicle.setPlaca("TST-"+String.format("%03d",++sequence)); vehicle.setTipo(VehicleType.CAMIONETA);
        vehicle.setCapacidadKg(BigDecimal.valueOf(1000)); vehicle.setCapacidadM3(BigDecimal.valueOf(100)); vehicle.setConsumoKmL(BigDecimal.TEN);
        vehicle.setFactorEmision(BigDecimal.valueOf(.2)); vehicle.setAnio(2024); return vehicles.save(vehicle);
    }
    private Driver driver() {
        var driver=new Driver(); driver.setNombre("Conductor de prueba"); driver.setDni(String.format("%08d",++sequence));
        driver.setLicencia("Q"+driver.getDni()); driver.setCategoria(DriverCategory.AII); driver.setExperiencia(5); driver.setDisponible(true); return drivers.save(driver);
    }
    private Order order(double lat,double lon,int weight) {
        var order=new Order(); order.setClienteId(UUID.randomUUID().toString()); order.setDireccion("Entrega de prueba");
        order.setGpsLat(BigDecimal.valueOf(lat)); order.setGpsLon(BigDecimal.valueOf(lon)); order.setPeso(BigDecimal.valueOf(weight)); order.setVolumen(BigDecimal.ONE);
        order.setVentanaInicio("07:00"); order.setVentanaFin("23:00"); order.setPrioridad(OrderPriority.ESTANDAR); order.setTipoProducto(ProductType.NO_PERECEDERO);
        order.setEstado(OrderStatus.PENDIENTE); return orders.save(order);
    }
    private User user(UserRole role) {
        var user=new User(); user.setNombre("Prueba "+role); user.setEmail(UUID.randomUUID()+"@local.test"); user.setRol(role); user.setActivo(true);
        user.setPasswordHash("unused-test-password-hash"); return users.save(user);
    }
    private String token(User user) {
        Instant now=Instant.now();
        var claims=JwtClaimsSet.builder().subject(user.getId().toString()).issuedAt(now).expiresAt(now.plusSeconds(3600))
            .claim("rol",user.getRol().name()).claim("jti",UUID.randomUUID().toString()).build();
        return jwt.encode(JwtEncoderParameters.from(JwsHeader.with(MacAlgorithm.HS256).build(),claims)).getTokenValue();
    }
}
