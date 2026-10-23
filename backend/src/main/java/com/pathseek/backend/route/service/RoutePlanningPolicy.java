package com.pathseek.backend.route.service;

/** Shared estimates used by initial and incremental planners. */
final class RoutePlanningPolicy {
    static final int SERVICE_MINUTES = 15;
    private RoutePlanningPolicy() {}
    static int travelMinutes(double distanceKm) { return Math.max(5, (int) Math.round(distanceKm / 25.0 * 60.0)); }
}
