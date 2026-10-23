package com.pathseek.backend.route.service;

import com.pathseek.backend.exception.BusinessConflictException;
import com.pathseek.backend.order.entity.*;
import org.junit.jupiter.api.Test;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.*;
import java.util.concurrent.atomic.AtomicLong;
import static com.pathseek.backend.route.service.IncrementalRoutePlanner.*;
import static org.junit.jupiter.api.Assertions.*;

class IncrementalPlannerTests {
    private final IncrementalRoutePlanner planner = new IncrementalRoutePlanner(new RoutingContextService());
    private final LocalDate date = LocalDate.of(2026,10,22);
    @Test void deadlineUsesMonotonicElapsedTimeAndStopsOptionalWorkBeforeExpiry() {
        AtomicLong ticks = new AtomicLong();
        PlanningBudget budget = new PlanningBudget(100, ticks::get);
        ticks.set(91_000_000); assertFalse(budget.canImprove()); budget.check();
        ticks.set(100_000_000);
        assertEquals("REOPTIMIZATION_TIMEOUT", assertThrows(BusinessConflictException.class, budget::check).getCode());
    }
    @Test void peakWindowsUseLimaLocalTimeAndHalfOpenBoundaries() {
        assertTrue(RouteReoptimizationService.peak(LocalTime.of(7,0)));
        assertTrue(RouteReoptimizationService.peak(LocalTime.of(8,59)));
        assertFalse(RouteReoptimizationService.peak(LocalTime.of(9,0)));
        assertTrue(RouteReoptimizationService.peak(LocalTime.of(17,0)));
        assertTrue(RouteReoptimizationService.peak(LocalTime.of(19,59)));
        assertFalse(RouteReoptimizationService.peak(LocalTime.of(20,0)));
    }
    @Test void incidentRepairAvoidsCrossingEveryExcludedSegment() {
        Order a = order(-12.0583,-75.20), b = order(-12.0583,-75.21), c = order(-12.0683,-75.20);
        Area blocked = new Area(new Point(-12.0633,-75.205),25);
        Plan plan = plan(List.of(a,b,c), List.of(blocked));
        var session = planner.session(new PlanningBudget(25000));
        assertNull(session.schedule(plan, plan.orders)); assertTrue(session.repair(plan));
        assertNotNull(session.schedule(plan, plan.orders));
        Point previous = DEPOT;
        for (Order order : plan.orders) { assertFalse(blocked.crosses(previous, point(order))); previous = point(order); }
        assertFalse(blocked.crosses(previous, DEPOT));
    }
    @Test void blockedDestinationNeverProducesAnInventedDetourOrDropsAssignedDeliveries() {
        Order order = order(-12.06,-75.20);
        Plan plan = plan(List.of(order), List.of(new Area(point(order),100)));
        assertFalse(planner.session(new PlanningBudget(25000)).repair(plan));
        assertEquals(List.of(order), plan.orders);
    }
    @Test void insertionEnforcesBothCapacitiesWindowsAndPriorityWithoutMutatingCandidatePlan() {
        Order standard = order(-12.06,-75.20), express = order(-12.064,-75.20); express.setPrioridad(OrderPriority.EXPRESS);
        Plan plan = plan(List.of(standard), List.of()); var session = planner.session(new PlanningBudget(25000));
        var candidate = session.insert(plan, express);
        assertEquals(express, candidate.get(0)); assertEquals(List.of(standard), plan.orders);
        express.setPeso(BigDecimal.valueOf(5000)); assertNull(session.insert(plan, express));
        express.setPeso(BigDecimal.ONE); express.setVolumen(BigDecimal.valueOf(5000)); assertNull(session.insert(plan, express));
        express.setVolumen(BigDecimal.ONE); express.setVentanaFin("07:30"); assertNull(session.insert(plan, express));
    }
    @Test void optionalImprovementPreservesAllIdsAndCannotWorsenTheFeasibleSuffix() {
        Plan plan = plan(List.of(order(-12.06,-75.20), order(-12.08,-75.23), order(-12.05,-75.19)), List.of());
        var session = planner.session(new PlanningBudget(25000));
        var ids = new HashSet<>(plan.orders.stream().map(Order::getId).toList());
        double before = session.schedule(plan, plan.orders).distanceKm();
        session.improve(plan, 200);
        assertTrue(session.schedule(plan, plan.orders).distanceKm() <= before);
        assertEquals(ids, new HashSet<>(plan.orders.stream().map(Order::getId).toList()));
        int count = session.cachedEdges(); session.schedule(plan, plan.orders); assertEquals(count, session.cachedEdges());
    }
    private Plan plan(List<Order> orders, List<Area> areas) {
        return new Plan(UUID.randomUUID(), date, DEPOT, date.atTime(8,0), BigDecimal.valueOf(100), BigDecimal.TEN, orders, new ArrayList<>(areas));
    }
    private Order order(double lat, double lon) {
        Order order = new Order();
        // Domain entity ids are database generated; assign a test-only id without changing production setters.
        try { var field = Order.class.getDeclaredField("id"); field.setAccessible(true); field.set(order, UUID.randomUUID()); }
        catch (ReflectiveOperationException error) { throw new AssertionError(error); }
        order.setGpsLat(BigDecimal.valueOf(lat)); order.setGpsLon(BigDecimal.valueOf(lon));
        order.setPeso(BigDecimal.ONE); order.setVolumen(BigDecimal.ONE); order.setPrioridad(OrderPriority.ESTANDAR);
        order.setVentanaInicio("07:00"); order.setVentanaFin("23:00");
        return order;
    }
}
