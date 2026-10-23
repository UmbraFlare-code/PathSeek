package com.pathseek.backend.route.service;

import com.pathseek.backend.order.entity.Order;
import org.springframework.stereotype.Service;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Random;

/** Bounded simulated annealing (RF-003). Capacity is invariant under permutations. */
@Service
public class RouteSequenceOptimizer {
    private final RoutingContextService context;
    public RouteSequenceOptimizer(RoutingContextService context) { this.context = context; }

    public List<Order> improve(List<Order> original) {
        if (original.size() < 3) return List.copyOf(original);
        var random = new Random(original.stream().map(Order::getId).toList().hashCode());
        var current = new ArrayList<>(original);
        var best = new ArrayList<>(original);
        double currentScore = score(current), bestScore = currentScore;
        double temperature = Math.max(1, currentScore * .1);
        for (int step = 0; step < 600; step++, temperature *= .99) {
            var next = new ArrayList<>(current);
            int a = random.nextInt(next.size()), b = random.nextInt(next.size());
            // Preserve the express/standard/economy ordering selected by the planner.
            if (next.get(a).getPrioridad() != next.get(b).getPrioridad()) continue;
            Collections.swap(next, a, b);
            double nextScore = score(next);
            if (!Double.isFinite(nextScore)) continue;
            if (nextScore < currentScore || random.nextDouble() < Math.exp((currentScore - nextScore) / temperature)) {
                current = next; currentScore = nextScore;
            }
            if (currentScore < bestScore) { best = new ArrayList<>(current); bestScore = currentScore; }
        }
        return List.copyOf(best);
    }

    public double score(List<Order> orders) {
        double lat = RoutingContextService.DEPOT_LAT, lon = RoutingContextService.DEPOT_LON, distance = 0;
        long minute = 8 * 60;
        for (Order order : orders) {
            double leg = context.calculateRoadDistanceKm(lat, lon, order.getGpsLat().doubleValue(), order.getGpsLon().doubleValue());
            distance += leg;
            minute += RoutePlanningPolicy.travelMinutes(leg);
            var start = LocalTime.parse(order.getVentanaInicio());
            var end = LocalTime.parse(order.getVentanaFin());
            minute = Math.max(minute, start.toSecondOfDay() / 60);
            if (minute > end.toSecondOfDay() / 60) return Double.POSITIVE_INFINITY;
            minute += RoutePlanningPolicy.SERVICE_MINUTES;
            lat = order.getGpsLat().doubleValue(); lon = order.getGpsLon().doubleValue();
        }
        return distance + context.calculateRoadDistanceKm(lat, lon, RoutingContextService.DEPOT_LAT, RoutingContextService.DEPOT_LON);
    }
}
