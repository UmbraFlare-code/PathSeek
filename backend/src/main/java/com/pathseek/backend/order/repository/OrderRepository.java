package com.pathseek.backend.order.repository;

import com.pathseek.backend.order.entity.Order;
import com.pathseek.backend.order.entity.OrderStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface OrderRepository extends JpaRepository<Order, UUID> {

    boolean existsByClienteIdAndDireccionAndVentanaInicioAndVentanaFinAndEstadoNotAndIdNot(
            String clienteId,
            String direccion,
            String ventanaInicio,
            String ventanaFin,
            OrderStatus estado,
            UUID id);
}
