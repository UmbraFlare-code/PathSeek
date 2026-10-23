package com.pathseek.backend.route.service;

import com.pathseek.backend.order.entity.Order;
import com.pathseek.backend.order.entity.OrderPriority;
import com.pathseek.backend.route.dto.RoadIncidentRequest;
import org.springframework.stereotype.Component;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.*;

/** Event-local distance cache and bounded repair of unserved suffixes; no road-network claims. */
@Component
public class IncrementalRoutePlanner {
    private final RoutingContextService distances;
    public IncrementalRoutePlanner(RoutingContextService distances) { this.distances = distances; }
    public static final Point DEPOT = new Point(RoutingContextService.DEPOT_LAT, RoutingContextService.DEPOT_LON);
    public record Point(double lat, double lon) {}
    public record Arrival(UUID orderId, LocalTime time) {}
    public record Schedule(double distanceKm, List<Arrival> arrivals) {}
    private record Edge(Point from, Point to) {}
    public record Area(Point center, double radiusMetres) {
        public static Area of(RoadIncidentRequest request) {
            return new Area(new Point(request.lat().doubleValue(), request.lon().doubleValue()),
                    request.radioAfectacionMetros() == null ? 250 : request.radioAfectacionMetros());
        }
        public boolean crosses(Point from, Point to) {
            double scaleX = 111320 * Math.cos(Math.toRadians(center.lat));
            double ax = (from.lon - center.lon) * scaleX, ay = (from.lat - center.lat) * 111320;
            double bx = (to.lon - center.lon) * scaleX, by = (to.lat - center.lat) * 111320;
            double dx = bx - ax, dy = by - ay, length = dx * dx + dy * dy;
            double t = length == 0 ? 0 : Math.max(0, Math.min(1, -(ax * dx + ay * dy) / length));
            return Math.hypot(ax + t * dx, ay + t * dy) <= radiusMetres;
        }
    }
    public static final class Plan {
        public final UUID id;
        public final LocalDate date;
        public final Point start;
        public final LocalDateTime departure;
        public final BigDecimal capacityKg, capacityM3;
        public final List<Area> areas;
        public List<Order> orders;
        public Plan(UUID id, LocalDate date, Point start, LocalDateTime departure, BigDecimal kg,
                BigDecimal m3, List<Order> orders, List<Area> areas) {
            this.id = id; this.date = date; this.start = start; this.departure = departure;
            capacityKg = kg; capacityM3 = m3; this.orders = new ArrayList<>(orders); this.areas = areas;
        }
    }
    public final class Session {
        private final Map<Edge, Double> cache = new HashMap<>();
        private final PlanningBudget budget;
        Session(PlanningBudget budget) { this.budget = budget; }
        public double distance(Point from, Point to) {
            budget.check();
            return cache.computeIfAbsent(new Edge(from, to), key -> distances.calculateRoadDistanceKm(
                    from.lat, from.lon, to.lat, to.lon));
        }
        public boolean affected(Plan plan, Area area) {
            Point previous = plan.start;
            for (Order order : plan.orders) {
                Point next = point(order);
                if (area.crosses(previous, next)) return true;
                previous = next;
            }
            return area.crosses(previous, DEPOT);
        }
        public Schedule schedule(Plan plan, List<Order> orders) {
            budget.check();
            BigDecimal kg = BigDecimal.ZERO, m3 = BigDecimal.ZERO;
            Point previous = plan.start;
            LocalDateTime time = plan.departure;
            double total = 0;
            int priority = -1;
            List<Arrival> arrivals = new ArrayList<>(orders.size());
            for (Order order : orders) {
                budget.check();
                kg = kg.add(order.getPeso()); m3 = m3.add(order.getVolumen());
                int rank = rank(order.getPrioridad());
                if (rank < priority || kg.compareTo(plan.capacityKg) > 0 || m3.compareTo(plan.capacityM3) > 0) return null;
                priority = rank;
                Point next = point(order);
                for (Area area : plan.areas) if (area.crosses(previous, next)) return null;
                double leg = distance(previous, next);
                total += leg;
                time = time.plusMinutes(RoutePlanningPolicy.travelMinutes(leg));
                LocalDateTime earliest = plan.date.atTime(LocalTime.parse(order.getVentanaInicio()));
                if (time.isBefore(earliest)) time = earliest;
                if (time.isAfter(plan.date.atTime(LocalTime.parse(order.getVentanaFin())))) return null;
                arrivals.add(new Arrival(order.getId(), time.toLocalTime()));
                time = time.plusMinutes(RoutePlanningPolicy.SERVICE_MINUTES); previous = next;
            }
            final Point last = previous;
            if (plan.areas.stream().anyMatch(area -> area.crosses(last, DEPOT))) return null;
            total += distance(previous, DEPOT);
            return new Schedule(total, List.copyOf(arrivals));
        }
        public List<Order> insert(Plan plan, Order order) {
            List<Order> best = null;
            double score = Double.POSITIVE_INFINITY;
            int priority = rank(order.getPrioridad());
            for (int index = 0; index <= plan.orders.size(); index++) {
                budget.check();
                if (index > 0 && rank(plan.orders.get(index - 1).getPrioridad()) > priority) continue;
                if (index < plan.orders.size() && rank(plan.orders.get(index).getPrioridad()) < priority) continue;
                var candidate = new ArrayList<>(plan.orders); candidate.add(index, order);
                Schedule evaluated = schedule(plan, candidate);
                if (evaluated != null && evaluated.distanceKm < score) { score = evaluated.distanceKm; best = candidate; }
            }
            return best;
        }
        public boolean repair(Plan plan) {
            plan.orders.sort(Comparator.comparingInt(order -> rank(order.getPrioridad())));
            if (schedule(plan, plan.orders) != null) return true;
            // Repair only this suffix: try equal-priority swaps, retaining all assigned deliveries.
            for (int left = 0; left < plan.orders.size(); left++) {
                for (int right = left + 1; right < plan.orders.size(); right++) {
                    budget.check();
                    if (plan.orders.get(left).getPrioridad() != plan.orders.get(right).getPrioridad()) continue;
                    var candidate = new ArrayList<>(plan.orders); Collections.swap(candidate, left, right);
                    if (schedule(plan, candidate) != null) { plan.orders = candidate; return true; }
                }
            }
            return false;
        }
        public void improve(Plan plan, int iterations) {
            Schedule best = schedule(plan, plan.orders);
            if (best == null || plan.orders.size() < 2) return;
            Random random = new Random(plan.id.hashCode());
            for (int iteration = 0; iteration < iterations && budget.canImprove(); iteration++) {
                int left = random.nextInt(plan.orders.size()), right = random.nextInt(plan.orders.size());
                if (plan.orders.get(left).getPrioridad() != plan.orders.get(right).getPrioridad()) continue;
                var candidate = new ArrayList<>(plan.orders); Collections.swap(candidate, left, right);
                Schedule score = schedule(plan, candidate);
                if (score != null && score.distanceKm < best.distanceKm) { plan.orders = candidate; best = score; }
            }
        }
        public int cachedEdges() { return cache.size(); }
    }
    public Session session(PlanningBudget budget) { return new Session(budget); }
    public static Point point(Order order) { return new Point(order.getGpsLat().doubleValue(), order.getGpsLon().doubleValue()); }
    public static int rank(OrderPriority priority) {
        return switch (priority) { case EXPRESS -> 0; case ESTANDAR -> 1; case ECONOMICO -> 2; };
    }
}
