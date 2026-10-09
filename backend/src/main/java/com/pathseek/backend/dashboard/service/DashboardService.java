package com.pathseek.backend.dashboard.service;

import com.pathseek.backend.dashboard.dto.DashboardSummaryDto;
import com.pathseek.backend.driver.repository.DriverRepository;
import com.pathseek.backend.order.entity.OrderStatus;
import com.pathseek.backend.order.repository.OrderRepository;
import com.pathseek.backend.route.entity.DeliveryRoute;
import com.pathseek.backend.route.repository.DeliveryRouteRepository;
import com.pathseek.backend.vehicle.repository.VehicleRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;

@Service
public class DashboardService {

    private final VehicleRepository vehicleRepository;
    private final DriverRepository driverRepository;
    private final OrderRepository orderRepository;
    private final DeliveryRouteRepository routeRepository;

    public DashboardService(
            VehicleRepository vehicleRepository,
            DriverRepository driverRepository,
            OrderRepository orderRepository,
            DeliveryRouteRepository routeRepository) {
        this.vehicleRepository = vehicleRepository;
        this.driverRepository = driverRepository;
        this.orderRepository = orderRepository;
        this.routeRepository = routeRepository;
    }

    @Transactional(readOnly = true)
    public DashboardSummaryDto getSummary() {
        int totalVehiculos = (int) vehicleRepository.count();
        int conductoresDisponibles = (int) driverRepository.findByDisponibleTrue().size();

        int pendientes = (int) orderRepository.findAll().stream().filter(o -> o.getEstado() == OrderStatus.PENDIENTE).count();
        int enRuta = (int) orderRepository.findAll().stream().filter(o -> o.getEstado() == OrderStatus.EN_RUTA).count();
        int entregados = (int) orderRepository.findAll().stream().filter(o -> o.getEstado() == OrderStatus.ENTREGADO).count();
        int cancelados = (int) orderRepository.findAll().stream().filter(o -> o.getEstado() == OrderStatus.CANCELADO).count();

        List<DeliveryRoute> routes = routeRepository.findAll();
        int rutasPlanificadas = routes.size();

        double totalCo2 = routes.stream()
                .mapToDouble(r -> r.getCo2Kg() != null ? r.getCo2Kg().doubleValue() : 0.0)
                .sum();
        double totalFuel = routes.stream()
                .mapToDouble(r -> r.getCombustibleL() != null ? r.getCombustibleL().doubleValue() : 0.0)
                .sum();

        return new DashboardSummaryDto(
                totalVehiculos,
                conductoresDisponibles,
                pendientes,
                enRuta,
                entregados,
                cancelados,
                rutasPlanificadas,
                BigDecimal.valueOf(totalCo2).setScale(2, RoundingMode.HALF_UP),
                BigDecimal.valueOf(totalFuel).setScale(2, RoundingMode.HALF_UP)
        );
    }
}
