package com.pathseek.backend.route.service;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;
import java.util.concurrent.TimeUnit;

/** Includes transaction completion/serialization; external client measurements also include network latency. */
@Configuration
public class ReoptimizationHttpTiming implements WebMvcConfigurer {
    private static final Logger LOG = LoggerFactory.getLogger(ReoptimizationHttpTiming.class);
    @Override public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(new HandlerInterceptor() {
            @Override public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) {
                request.setAttribute("reoptimizationStartedNanos", System.nanoTime()); return true;
            }
            @Override public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception error) {
                Object started = request.getAttribute("reoptimizationStartedNanos");
                if (started instanceof Long value) LOG.info("reoptimization_http status={} elapsed_ms={}", response.getStatus(),
                        TimeUnit.NANOSECONDS.toMillis(System.nanoTime() - value));
            }
        }).addPathPatterns("/api/v1/rutas/reoptimizar");
    }
}
