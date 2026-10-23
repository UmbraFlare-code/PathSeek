package com.pathseek.backend.route.service;

import com.pathseek.backend.exception.BusinessConflictException;
import com.pathseek.backend.exception.BusinessRuleException;
import com.pathseek.backend.exception.ResourceNotFoundException;
import com.pathseek.backend.order.entity.Order;
import com.pathseek.backend.order.entity.OrderStatus;
import com.pathseek.backend.order.repository.OrderRepository;
import com.pathseek.backend.route.dto.*;
import com.pathseek.backend.route.entity.*;
import com.pathseek.backend.route.repository.*;
import com.pathseek.backend.vehicle.entity.Vehicle;
import com.pathseek.backend.vehicle.repository.VehicleRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import tools.jackson.databind.ObjectMapper;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.time.*;
import java.util.*;
import java.util.function.Function;
import java.util.stream.Collectors;
import static com.pathseek.backend.route.service.IncrementalRoutePlanner.*;

@Service
public class RouteReoptimizationService {
    private static final Logger LOG = LoggerFactory.getLogger(RouteReoptimizationService.class);
    private static final List<RouteStatus> ACTIVE = List.of(RouteStatus.PLANIFICADA, RouteStatus.EN_PROGRESO);
    private final DeliveryRouteRepository routes;
    private final RouteOrderRepository assignments;
    private final OrderRepository orders;
    private final VehicleRepository vehicles;
    private final RoadIncidentRepository incidents;
    private final VehicleBreakdownRepository breakdowns;
    private final RouteNotificationRepository notifications;
    private final ReoptimizationEventRepository events;
    private final RouteProgressRepository progress;
    private final IncrementalRoutePlanner planner;
    private final ReoptimizationProperties properties;
    private final ObjectMapper json;
    private final Clock clock;

    public RouteReoptimizationService(DeliveryRouteRepository routes, RouteOrderRepository assignments,
            OrderRepository orders, VehicleRepository vehicles, RoadIncidentRepository incidents,
            VehicleBreakdownRepository breakdowns, RouteNotificationRepository notifications,
            ReoptimizationEventRepository events, RouteProgressRepository progress, IncrementalRoutePlanner planner,
            ReoptimizationProperties properties, ObjectMapper json, Clock clock) {
        this.routes = routes; this.assignments = assignments; this.orders = orders; this.vehicles = vehicles;
        this.incidents = incidents; this.breakdowns = breakdowns; this.notifications = notifications;
        this.events = events; this.planner = planner; this.properties = properties; this.json = json; this.clock = clock;
        this.progress = progress;
    }

    /** One event is atomic: plans, order status, notification inbox and idempotency result commit together. */
    @Transactional(timeout = 28)
    public ReoptimizationResponse reoptimize(ReoptimizationRequest request) {
        PlanningBudget budget = new PlanningBudget(properties.getBudgetMs());
        validate(request);
        String fingerprint = fingerprint(request);
        var previous = events.findById(request.eventoId());
        if (previous.isPresent()) return replay(previous.get(), fingerprint);
        ZonedDateTime now = ZonedDateTime.now(clock.withZone(ZoneId.of("America/Lima")));
        LocalDate date = request.fecha() == null ? now.toLocalDate() : request.fecha();
        List<UUID> scope = scope(request, date);
        if (scope.size() > properties.getMaxRoutes()) throw invalid("REOPTIMIZATION_SCOPE_TOO_LARGE", "Seleccione como máximo " + properties.getMaxRoutes() + " rutas por evento.");
        Set<UUID> vehicleIds = new HashSet<>(scope.isEmpty() ? List.of() : routes.findVehicleIds(scope));
        if (request.vehiculoId() != null) vehicleIds.add(request.vehiculoId());
        if (request.vehiculoSustitutoId() != null) vehicleIds.add(request.vehiculoSustitutoId());
        // Vehicle -> route -> order, deterministic and compatible with generation/deletion vehicle locks.
        Map<UUID, Vehicle> lockedVehicles = vehicleIds.isEmpty() ? Map.of() : vehicles.lockPlanningSubset(vehicleIds).stream()
                .collect(Collectors.toMap(Vehicle::getId, Function.identity()));
        if (lockedVehicles.size() != vehicleIds.size()) throw missing("Vehículo no encontrado");
        List<DeliveryRoute> selected = scope.isEmpty() ? List.of() : routes.lockPlanningRoutes(scope);
        if (selected.size() != scope.size()) throw missing("Una de las rutas no existe");
        for (DeliveryRoute route : selected) {
            if (!ACTIVE.contains(route.getEstado()) || !route.getFecha().equals(date)) {
                throw conflict("ROUTE_NOT_ACTIVE", "El ámbito debe contener rutas activas de la fecha indicada.");
            }
            if (!lockedVehicles.containsKey(route.getVehiculo().getId())) {
                throw conflict("PLANNING_CHANGED", "Cambió el vehículo de una ruta; consulte y reintente.");
            }
        }
        Set<UUID> orderIds = new HashSet<>(request.pedidosIds());
        if (!scope.isEmpty()) orderIds.addAll(assignments.findOrderIds(scope, PageRequest.of(0, properties.getMaxOrders() + 1)));
        if (orderIds.size() > properties.getMaxOrders()) throw invalid("REOPTIMIZATION_SCOPE_TOO_LARGE", "Demasiadas entregas para un recálculo incremental.");
        Map<UUID, Order> lockedOrders = orderIds.isEmpty() ? Map.of() : orders.lockPlanningOrders(orderIds).stream()
                .collect(Collectors.toMap(Order::getId, Function.identity()));
        if (lockedOrders.size() != orderIds.size()) throw missing("Uno de los pedidos no existe");
        if (!scope.isEmpty()) routes.fetchPlanningRoutes(scope);
        budget.check();
        // A waiter/retry must never execute a committed event a second time.
        previous = events.findById(request.eventoId());
        if (previous.isPresent()) return replay(previous.get(), fingerprint);

        Map<UUID, ReoptimizationRequest.Posicion> positions = request.posiciones().stream()
                .collect(Collectors.toMap(ReoptimizationRequest.Posicion::rutaId, Function.identity()));
        if (!new HashSet<>(scope).containsAll(positions.keySet())) throw invalid("INVALID_POSITION_SCOPE", "La posición debe pertenecer al ámbito solicitado.");
        Map<UUID, List<Area>> areas = new HashMap<>();
        List<RoadIncident> recorded = scope.isEmpty() ? List.of() : incidents.findByRuta_IdInAndActivaTrue(scope);
        if (recorded.size() > 1000) throw invalid("INCIDENT_SCOPE_TOO_LARGE", "Resuelva los incidentes obsoletos antes de replanificar.");
        for (RoadIncident incident : recorded) areas.computeIfAbsent(incident.getRouteId(), id -> new ArrayList<>()).add(Area.of(incident.toRequest()));
        var session = planner.session(budget);
        List<Frame> frames = new ArrayList<>();
        Map<UUID, RouteProgress> savedProgress = progress.findAllById(scope).stream().collect(Collectors.toMap(RouteProgress::getId, Function.identity()));
        for (DeliveryRoute route : selected) {
            if (request.tipo() == ReoptimizationRequest.Tipo.NUEVOS_PEDIDOS && route.getEstado() != RouteStatus.PLANIFICADA) continue;
            frames.add(frame(route, positions.get(route.getId()), areas.getOrDefault(route.getId(), List.of()), savedProgress.get(route.getId()), now, session));
        }
        Set<UUID> changed = new HashSet<>();
        Set<UUID> unavailable = new HashSet<>(breakdowns.findActiveVehicleIds());

        if (request.tipo() == ReoptimizationRequest.Tipo.AVERIA) {
            if (!new HashSet<>(scope).containsAll(routes.findActiveIdsForVehicle(request.vehiculoId(), ACTIVE))) {
                throw conflict("INCOMPLETE_ROUTE_SCOPE", "La avería afecta a otra ruta fuera del ámbito.");
            }
            if (unavailable.contains(request.vehiculoSustitutoId()) || !routes.findActiveIdsForVehicle(request.vehiculoSustitutoId(), ACTIVE).isEmpty()) {
                throw conflict("REPLACEMENT_UNAVAILABLE", "El vehículo sustituto está ocupado o averiado.");
            }
            Vehicle replacement = lockedVehicles.get(request.vehiculoSustitutoId());
            for (Frame frame : frames) {
                if (!frame.route.getVehiculo().getId().equals(request.vehiculoId())) continue;
                frame.vehicle = replacement;
                frame.plan = new Plan(frame.plan.id, date, frame.plan.start, frame.plan.departure,
                        replacement.getCapacidadKg(), replacement.getCapacidadM3(), frame.plan.orders, frame.plan.areas);
                changed.add(frame.route.getId());
            }
            breakdowns.save(new VehicleBreakdown(request.vehiculoId(), now.toOffsetDateTime()));
        }
        if (request.tipo() == ReoptimizationRequest.Tipo.CANCELACION) {
            var assignedRoutes = routes.findActiveIdsForOrders(request.pedidosIds(), ACTIVE);
            if (!new HashSet<>(scope).containsAll(assignedRoutes)) throw conflict("INCOMPLETE_ROUTE_SCOPE", "La cancelación afecta a otra ruta fuera del ámbito.");
            for (UUID id : request.pedidosIds()) {
                Order order = lockedOrders.get(id);
                if (order.getEstado() == OrderStatus.ENTREGADO) throw conflict("ORDER_ALREADY_DELIVERED", "No se puede cancelar una entrega realizada.");
                order.setEstado(OrderStatus.CANCELADO);
            }
            for (Frame frame : frames) {
                if (frame.route.getPedidos().stream().anyMatch(stop -> request.pedidosIds().contains(stop.getPedido().getId()))) changed.add(frame.route.getId());
                frame.plan.orders.removeIf(order -> request.pedidosIds().contains(order.getId()));
            }
        }
        if (request.tipo() == ReoptimizationRequest.Tipo.INCIDENTE) {
            if (request.incidente() == null && recorded.isEmpty()) throw invalid("INCIDENT_REQUIRED", "Reporte un incidente o incluya un incidente existente en el ámbito.");
            for (Frame frame : frames) {
                if (request.incidente() != null) {
                    Area area = Area.of(request.incidente());
                    if (session.affected(frame.plan, area)) changed.add(frame.route.getId());
                    frame.plan.areas.add(area);
                    incidents.save(new RoadIncident(frame.route, request.incidente()));
                } else if (frame.plan.areas.stream().anyMatch(area -> session.affected(frame.plan, area))) changed.add(frame.route.getId());
            }
        }
        List<UUID> unassigned = new ArrayList<>();
        if (request.tipo() == ReoptimizationRequest.Tipo.NUEVOS_PEDIDOS) {
            if (assignments.countActiveAssignments(request.pedidosIds(), ACTIVE) > 0) throw conflict("ORDER_ALREADY_ASSIGNED", "Uno de los pedidos ya tiene una ruta activa.");
            List<Order> incoming = request.pedidosIds().stream().map(lockedOrders::get).sorted(
                    Comparator.comparingInt((Order order) -> rank(order.getPrioridad())).thenComparing(Order::getVentanaFin).thenComparing(Order::getId)).toList();
            for (Order order : incoming) {
                if (order.getEstado() != OrderStatus.PENDIENTE) throw conflict("ORDER_NOT_PENDING", "Los pedidos nuevos deben estar pendientes.");
                Frame best = null; List<Order> bestOrders = null; double bestDelta = Double.POSITIVE_INFINITY;
                for (Frame frame : frames) {
                    budget.check();
                    // No pickup/load-transfer model exists: do not invent cargo in an executing vehicle.
                    if (frame.route.getEstado() != RouteStatus.PLANIFICADA || unavailable.contains(frame.vehicle.getId())) continue;
                    var before = session.schedule(frame.plan, frame.plan.orders);
                    if (before == null) continue;
                    var candidate = session.insert(frame.plan, order);
                    if (candidate == null) continue;
                    double delta = session.schedule(frame.plan, candidate).distanceKm() - before.distanceKm();
                    if (delta < bestDelta) { best = frame; bestOrders = candidate; bestDelta = delta; }
                }
                if (best == null) unassigned.add(order.getId());
                else { best.plan.orders = bestOrders; changed.add(best.route.getId()); order.setEstado(OrderStatus.EN_RUTA); }
            }
        }
        List<DeliveryRouteResponse> updated = new ArrayList<>();
        int notificationCount = 0, unlinked = 0;
        for (Frame frame : frames) {
            if (!changed.contains(frame.route.getId())) continue;
            if (!session.repair(frame.plan)) throw conflict("REOPTIMIZATION_INFEASIBLE", "No se encontró una secuencia factible para la ruta " + frame.route.getId() + "; no se aplicó el evento.");
            session.improve(frame.plan, properties.getIterations());
            apply(frame, session.schedule(frame.plan, frame.plan.orders));
            notifications.save(new RouteNotification(request.eventoId(), frame.route,
                    "Ruta actualizada por " + request.tipo() + ". Consulte la nueva secuencia y sus horarios estimados.", now.toOffsetDateTime()));
            if (frame.route.getConductor().getUsuarioId() == null) unlinked++; else notificationCount++;
            updated.add(DeliveryRouteResponse.fromEntity(frame.route));
        }
        budget.check();
        ReoptimizationResponse result = new ReoptimizationResponse(request.eventoId(), request.tipo(), List.copyOf(updated),
                scope.stream().filter(id -> !changed.contains(id)).toList(), List.copyOf(unassigned), notificationCount, unlinked,
                budget.elapsedMs(), peak(now.toLocalTime()), "ESTIMADO_SIN_RED_VIAL");
        events.saveAndFlush(new ReoptimizationEvent(request.eventoId(), fingerprint, json.writeValueAsString(result), now.toOffsetDateTime()));
        budget.check();
        LOG.info("reoptimization event={} type={} routes={} unchanged={} pending={} elapsed_ms={} peak={}", request.eventoId(), request.tipo(),
                updated.size(), result.rutasSinCambios().size(), unassigned.size(), budget.elapsedMs(), result.horarioPunta());
        return result;
    }

    private Frame frame(DeliveryRoute route, ReoptimizationRequest.Posicion position, List<Area> areas, RouteProgress previous,
            ZonedDateTime now, IncrementalRoutePlanner.Session session) {
        List<RouteOrder> completed = new ArrayList<>(); List<Order> remaining = new ArrayList<>();
        boolean unserved = false;
        Point last = previous == null ? DEPOT : new Point(previous.lat(), previous.lon());
        double prefixDistance = previous == null ? 0 : previous.distance();
        double prefixFuel = previous == null ? 0 : previous.fuel();
        double prefixCo2 = previous == null ? 0 : previous.co2();
        double newPrefixDistance = 0;
        for (RouteOrder stop : route.getPedidos()) {
            if (stop.getPedido().getEstado() == OrderStatus.ENTREGADO) {
                if (unserved) throw conflict("AMBIGUOUS_ROUTE_PROGRESS", "Las entregas completadas deben formar un prefijo de la ruta.");
                completed.add(stop);
                if (previous == null || stop.getOrden() > previous.lastOrder()) {
                    Point point = point(stop.getPedido()); newPrefixDistance += session.distance(last, point); last = point;
                }
            } else if (stop.getPedido().getEstado() != OrderStatus.CANCELADO) {
                unserved = true; remaining.add(stop.getPedido());
            }
        }
        Point start = DEPOT;
        LocalDateTime departure = route.getFecha().atTime(8, 0);
        if (route.getFecha().isBefore(now.toLocalDate())) throw conflict("ROUTE_DATE_EXPIRED", "Se requiere regularizar la fecha de la ruta activa.");
        if (route.getFecha().equals(now.toLocalDate()) && now.toLocalDateTime().isAfter(departure)) departure = now.toLocalDateTime();
        if (route.getEstado() == RouteStatus.EN_PROGRESO) {
            if (position == null || !route.getFecha().equals(now.toLocalDate())) throw invalid("CURRENT_POSITION_REQUIRED", "Indique la posición actual de cada ruta en progreso de hoy.");
            start = new Point(position.lat().doubleValue(), position.lon().doubleValue());
            newPrefixDistance += session.distance(last, start);
            departure = now.toLocalDateTime();
        } else if (!completed.isEmpty()) throw conflict("INVALID_ROUTE_PROGRESS", "Una ruta planificada no puede tener entregas completadas.");
        Vehicle vehicle = route.getVehiculo();
        if (previous != null && completed.stream().mapToInt(RouteOrder::getOrden).max().orElse(0) < previous.lastOrder()) {
            throw conflict("INVALID_ROUTE_PROGRESS", "No se puede revertir el progreso ya confirmado.");
        }
        prefixDistance += newPrefixDistance;
        prefixFuel += newPrefixDistance / vehicle.getConsumoKmL().doubleValue();
        prefixCo2 += newPrefixDistance * vehicle.getFactorEmision().doubleValue();
        return new Frame(route, vehicle, completed, prefixDistance, prefixFuel, prefixCo2,
                new Plan(route.getId(), route.getFecha(), start, departure, vehicle.getCapacidadKg(), vehicle.getCapacidadM3(), remaining, new ArrayList<>(areas)));
    }

    private void apply(Frame frame, Schedule schedule) {
        DeliveryRoute route = frame.route;
        Set<UUID> kept = frame.completed.stream().map(stop -> stop.getPedido().getId()).collect(Collectors.toSet());
        frame.plan.orders.forEach(order -> kept.add(order.getId()));
        route.getPedidos().removeIf(stop -> !kept.contains(stop.getPedido().getId()));
        Map<UUID, RouteOrder> existing = route.getPedidos().stream().collect(Collectors.toMap(stop -> stop.getPedido().getId(), Function.identity()));
        int orderNumber = frame.completed.stream().mapToInt(RouteOrder::getOrden).max().orElse(0);
        for (int index = 0; index < frame.plan.orders.size(); index++) {
            Order order = frame.plan.orders.get(index);
            RouteOrder stop = existing.get(order.getId());
            if (stop == null) { stop = new RouteOrder(route, order, 0, null, true); route.addPedido(stop); }
            stop.setOrden(++orderNumber); stop.setHoraEstimada(schedule.arrivals().get(index).time()); stop.setCumplioVentana(true);
            order.setEstado(OrderStatus.EN_RUTA);
        }
        route.getPedidos().sort(Comparator.comparing(RouteOrder::getOrden));
        route.setVehiculo(frame.vehicle);
        double distance = frame.prefixDistance + schedule.distanceKm();
        route.setDistanciaKm(money(distance));
        route.setCombustibleL(money(frame.prefixFuel + schedule.distanceKm() / frame.vehicle.getConsumoKmL().doubleValue()));
        route.setCo2Kg(money(frame.prefixCo2 + schedule.distanceKm() * frame.vehicle.getFactorEmision().doubleValue()));
        if (route.getEstado() == RouteStatus.EN_PROGRESO) progress.save(new RouteProgress(route.getId(), frame.plan.start.lat(), frame.plan.start.lon(),
                frame.completed.stream().mapToInt(RouteOrder::getOrden).max().orElse(0), frame.prefixDistance, frame.prefixFuel, frame.prefixCo2));
        if (frame.plan.orders.isEmpty()) route.setEstado(frame.completed.isEmpty() ? RouteStatus.CANCELADA : RouteStatus.COMPLETADA);
        routes.save(route);
    }
    private List<UUID> scope(ReoptimizationRequest request, LocalDate date) {
        if (!request.rutasIds().isEmpty()) return request.rutasIds().stream().sorted().toList();
        List<UUID> ids = switch (request.tipo()) {
            case CANCELACION -> routes.findActiveIdsForOrders(request.pedidosIds(), ACTIVE);
            case AVERIA -> routes.findActiveIdsForVehicle(request.vehiculoId(), ACTIVE);
            case NUEVOS_PEDIDOS -> routes.findActiveIds(date, List.of(RouteStatus.PLANIFICADA), PageRequest.of(0, properties.getMaxRoutes() + 1));
            default -> routes.findActiveIds(date, ACTIVE, PageRequest.of(0, properties.getMaxRoutes() + 1));
        };
        return ids.stream().distinct().sorted().toList();
    }
    private void validate(ReoptimizationRequest request) {
        if (request.eventoId() == null || request.tipo() == null) throw invalid("INVALID_EVENT", "Evento y tipo son obligatorios.");
        if (new HashSet<>(request.rutasIds()).size() != request.rutasIds().size()
                || new HashSet<>(request.pedidosIds()).size() != request.pedidosIds().size()
                || request.posiciones().stream().map(ReoptimizationRequest.Posicion::rutaId).distinct().count() != request.posiciones().size()) {
            throw invalid("DUPLICATE_EVENT_ITEMS", "El evento no puede repetir rutas, pedidos o posiciones.");
        }
        boolean orderEvent = request.tipo() == ReoptimizationRequest.Tipo.NUEVOS_PEDIDOS || request.tipo() == ReoptimizationRequest.Tipo.CANCELACION;
        if (orderEvent != !request.pedidosIds().isEmpty()) throw invalid("INVALID_EVENT_PAYLOAD", "Solo nuevos pedidos/cancelación requieren pedidos_ids.");
        if (request.tipo() == ReoptimizationRequest.Tipo.AVERIA) {
            if (request.vehiculoId() == null || request.vehiculoSustitutoId() == null || request.vehiculoId().equals(request.vehiculoSustitutoId())) {
                throw invalid("REPLACEMENT_REQUIRED", "Indique el vehículo averiado y un sustituto distinto, con relevo operativo confirmado.");
            }
        } else if (request.vehiculoId() != null || request.vehiculoSustitutoId() != null) throw invalid("INVALID_EVENT_PAYLOAD", "Los vehículos corresponden a un evento AVERIA.");
        if (request.tipo() != ReoptimizationRequest.Tipo.INCIDENTE && request.incidente() != null) throw invalid("INVALID_EVENT_PAYLOAD", "El incidente corresponde a un evento INCIDENTE.");
    }
    private String fingerprint(ReoptimizationRequest request) {
        try { return HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256").digest(json.writeValueAsString(request).getBytes(StandardCharsets.UTF_8))); }
        catch (java.security.NoSuchAlgorithmException impossible) { throw new IllegalStateException(impossible); }
    }
    private ReoptimizationResponse replay(ReoptimizationEvent event, String fingerprint) {
        if (!event.getFingerprint().equals(fingerprint)) throw conflict("EVENT_ID_REUSED", "El evento_id ya se usó con otro contenido.");
        return json.readValue(event.getResponse(), ReoptimizationResponse.class);
    }
    static boolean peak(LocalTime time) {
        return (!time.isBefore(LocalTime.of(7, 0)) && time.isBefore(LocalTime.of(9, 0)))
                || (!time.isBefore(LocalTime.of(17, 0)) && time.isBefore(LocalTime.of(20, 0)));
    }
    private static BigDecimal money(double value) { return BigDecimal.valueOf(value).setScale(2, RoundingMode.HALF_UP); }
    private static BusinessConflictException conflict(String code, String message) { return new BusinessConflictException(code, message); }
    private static BusinessRuleException invalid(String code, String message) { return new BusinessRuleException(code, message); }
    private static ResourceNotFoundException missing(String message) { return new ResourceNotFoundException(message); }
    private static final class Frame {
        final DeliveryRoute route; Vehicle vehicle; final List<RouteOrder> completed; final double prefixDistance, prefixFuel, prefixCo2; Plan plan;
        Frame(DeliveryRoute route, Vehicle vehicle, List<RouteOrder> completed, double prefixDistance, double prefixFuel, double prefixCo2, Plan plan) {
            this.route = route; this.vehicle = vehicle; this.completed = completed; this.prefixDistance = prefixDistance;
            this.prefixFuel = prefixFuel; this.prefixCo2 = prefixCo2; this.plan = plan;
        }
    }
}
