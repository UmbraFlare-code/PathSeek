package com.pathseek.backend.route.service;

import com.pathseek.backend.order.entity.Order;
import com.pathseek.backend.order.entity.OrderPriority;
import com.pathseek.backend.order.entity.OrderStatus;
import com.pathseek.backend.order.entity.ProductType;
import com.pathseek.backend.order.repository.OrderRepository;
import com.pathseek.backend.vehicle.entity.Vehicle;
import com.pathseek.backend.vehicle.entity.VehicleType;
import com.pathseek.backend.vehicle.repository.VehicleRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.UUID;

/**
 * Carga automática de datos semilla de ciudad (Huancayo) para despliegue
 * simple: sin este paso las tablas Flyway quedan vacías y el generador no
 * tiene con qué trabajar. Idempotente (no duplica). Desactivar con
 * {@code APP_SEED_CITY_DATA_ENABLED=false}.
 */
@Component
public class CitySeedRunner implements ApplicationRunner {

    private static final Logger LOGGER = LoggerFactory.getLogger(CitySeedRunner.class);

    private final VehicleRepository vehicleRepository;
    private final OrderRepository orderRepository;
    private final boolean enabled;

    public CitySeedRunner(
            VehicleRepository vehicleRepository,
            OrderRepository orderRepository,
            @Value("${app.seed.city-data-enabled:true}") boolean enabled) {
        this.vehicleRepository = vehicleRepository;
        this.orderRepository = orderRepository;
        this.enabled = enabled;
    }

    @Override
    @Transactional
    public void run(ApplicationArguments arguments) {
        if (!enabled) {
            return;
        }
        seedVehicle("W1A-100", VehicleType.FURGON, "2500.00", "15.00", "8.50", "0.2650", 2022, 0);
        seedVehicle("W2B-200", VehicleType.CAMIONETA, "1000.00", "6.00", "11.20", "0.1980", 2021, 2);
        seedVehicle("W3C-300", VehicleType.MOTO, "150.00", "0.80", "35.00", "0.0620", 2023, null);

        seedOrder("IE-SAN-CARLOS", "Av. Ferrocarril 450, Huancayo",
                "-12.065400", "-75.204800", "350.00", "2.50",
                "08:00", "11:00", OrderPriority.EXPRESS, ProductType.NO_PERECEDERO);
        seedOrder("IE-MARISCAL-CASTILLA", "Jr. Real 1250, El Tambo",
                "-12.052100", "-75.213200", "180.00", "1.20",
                "09:00", "13:00", OrderPriority.ESTANDAR, ProductType.PERECEDERO);
        seedOrder("IE-ENRIQUE-GUZMAN", "Av. Giraldez 310, Huancayo",
                "-12.068900", "-75.208900", "75.00", "0.50",
                "14:00", "17:00", OrderPriority.ECONOMICO, ProductType.NO_PERECEDERO);
    }

    private void seedVehicle(
            String placa, VehicleType tipo, String kg, String m3,
            String consumo, String factor, int anio, Integer restriccion) {
        if (vehicleRepository.existsByPlaca(placa)) {
            return;
        }
        Vehicle vehicle = new Vehicle();
        vehicle.setPlaca(placa);
        vehicle.setTipo(tipo);
        vehicle.setCapacidadKg(new BigDecimal(kg));
        vehicle.setCapacidadM3(new BigDecimal(m3));
        vehicle.setConsumoKmL(new BigDecimal(consumo));
        vehicle.setFactorEmision(new BigDecimal(factor));
        vehicle.setAnio(anio);
        vehicle.setRestriccionPlacaDigito(restriccion);
        vehicleRepository.save(vehicle);
        LOGGER.info("Vehículo semilla creado: {}", placa);
    }

    private void seedOrder(
            String clienteId, String direccion, String lat, String lon,
            String peso, String volumen, String inicio, String fin,
            OrderPriority prioridad, ProductType tipoProducto) {
        boolean exists = orderRepository
                .existsByClienteIdAndDireccionAndVentanaInicioAndVentanaFinAndEstadoNotAndIdNot(
                        clienteId, direccion, inicio, fin, OrderStatus.CANCELADO, UUID.randomUUID());
        if (exists) {
            return;
        }
        Order order = new Order();
        order.setClienteId(clienteId);
        order.setDireccion(direccion);
        order.setGpsLat(new BigDecimal(lat));
        order.setGpsLon(new BigDecimal(lon));
        order.setPeso(new BigDecimal(peso));
        order.setVolumen(new BigDecimal(volumen));
        order.setVentanaInicio(inicio);
        order.setVentanaFin(fin);
        order.setPrioridad(prioridad);
        order.setTipoProducto(tipoProducto);
        order.setEstado(OrderStatus.PENDIENTE);
        orderRepository.save(order);
        LOGGER.info("Pedido semilla creado: {}", clienteId);
    }
}
