package com.pathseek.backend.route.service;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;
import org.springframework.validation.annotation.Validated;

@Component
@Validated
@ConfigurationProperties(prefix = "app.reoptimization")
public class ReoptimizationProperties {
    @Min(100) @Max(27000) private int budgetMs = 25000;
    @Min(1) @Max(15) private int maxRoutes = 15;
    @Min(1) @Max(500) private int maxOrders = 300;
    @Min(1) @Max(600) private int iterations = 200;
    public int getBudgetMs() { return budgetMs; }
    public void setBudgetMs(int value) { budgetMs = value; }
    public int getMaxRoutes() { return maxRoutes; }
    public void setMaxRoutes(int value) { maxRoutes = value; }
    public int getMaxOrders() { return maxOrders; }
    public void setMaxOrders(int value) { maxOrders = value; }
    public int getIterations() { return iterations; }
    public void setIterations(int value) { iterations = value; }
}
