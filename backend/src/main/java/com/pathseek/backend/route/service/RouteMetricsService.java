package com.pathseek.backend.route.service;

import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * Métricas en memoria para la historia 2 de rendimiento (P95 &lt; 45 s).
 * MVP: sin persistencia; reinicia con cada despliegue. Suficiente para
 * medir varias ejecuciones seguidas durante la operación.
 */
@Service
public class RouteMetricsService {

    private static final long SLA_MS = 45_000L;
    private static final int MAX_SAMPLES = 500;

    private final List<Long> samples = Collections.synchronizedList(new ArrayList<>());

    public void record(long durationMs) {
        synchronized (samples) {
            if (samples.size() >= MAX_SAMPLES) {
                samples.remove(0);
            }
            samples.add(durationMs);
        }
    }

    public MetricsSnapshot snapshot() {
        List<Long> copy;
        synchronized (samples) {
            copy = new ArrayList<>(samples);
        }
        Collections.sort(copy);
        int n = copy.size();
        if (n == 0) {
            return new MetricsSnapshot(0, 0, 0, 0, 0, 0, true);
        }
        long min = copy.get(0);
        long max = copy.get(n - 1);
        double mean = copy.stream().mapToLong(Long::longValue).average().orElse(0);
        long p50 = percentile(copy, 50);
        long p95 = percentile(copy, 95);
        long last = copy.get(n - 1);
        return new MetricsSnapshot(n, p50, p95, mean, min, max, last, p95 < SLA_MS);
    }

    private long percentile(List<Long> sorted, int p) {
        int n = sorted.size();
        int index = (int) Math.ceil(p / 100.0 * n) - 1;
        if (index < 0) {
            index = 0;
        }
        if (index >= n) {
            index = n - 1;
        }
        return sorted.get(index);
    }

    public record MetricsSnapshot(
            long totalSolicitudes,
            long p50Ms,
            long p95Ms,
            double mediaMs,
            long minMs,
            long maxMs,
            long ultimaMs,
            boolean slaCumplido) {
        MetricsSnapshot(long total, long p50, long p95, double mean, long min, long max, boolean sla) {
            this(total, p50, p95, mean, min, max, max, sla);
        }
    }
}
