package com.pathseek.backend.route.repository;

import com.pathseek.backend.route.entity.DeliveryRoute;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@Repository
public interface DeliveryRouteRepository extends JpaRepository<DeliveryRoute, UUID> {

    List<DeliveryRoute> findByFecha(LocalDate fecha);

    @Query("SELECT r FROM DeliveryRoute r WHERE r.conductor.id = :conductorId ORDER BY r.fecha DESC")
    List<DeliveryRoute> findByConductorId(@Param("conductorId") UUID conductorId);

    @Query("SELECT r FROM DeliveryRoute r LEFT JOIN FETCH r.pedidos p LEFT JOIN FETCH p.pedido WHERE r.id = :id")
    DeliveryRoute findWithPedidosById(@Param("id") UUID id);
}
