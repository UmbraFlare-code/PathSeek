package com.pathseek.backend.route.service;

import java.util.concurrent.TimeUnit;
import java.util.function.LongSupplier;
import com.pathseek.backend.exception.BusinessConflictException;

/** Monotonic, cooperative budget. Optional improvement stops before the hard deadline. */
public final class PlanningBudget {
    private final LongSupplier ticker;
    private final long started, duration;
    public PlanningBudget(long milliseconds) { this(milliseconds, System::nanoTime); }
    PlanningBudget(long milliseconds, LongSupplier ticker) {
        this.ticker = ticker;
        this.started = ticker.getAsLong();
        this.duration = TimeUnit.MILLISECONDS.toNanos(milliseconds);
    }
    public void check() {
        if (Thread.currentThread().isInterrupted() || ticker.getAsLong() - started >= duration) {
            throw new BusinessConflictException("REOPTIMIZATION_TIMEOUT",
                    "Se agotó el presupuesto de recálculo. La planificación no se modificó; reintente con un ámbito menor.");
        }
    }
    public boolean canImprove() { return ticker.getAsLong() - started < duration * 9 / 10; }
    public long elapsedMs() { return TimeUnit.NANOSECONDS.toMillis(ticker.getAsLong() - started); }
}
