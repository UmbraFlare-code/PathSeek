package com.pathseek.backend.order.repository;

import com.pathseek.backend.order.entity.Order;
import com.pathseek.backend.order.entity.OrderStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.jpa.repository.QueryHints;
import jakarta.persistence.QueryHint;
import java.util.Collection;
import jakarta.persistence.LockModeType;
import java.util.List;

import java.util.UUID;

public interface OrderRepository extends JpaRepository<Order, UUID> {

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @QueryHints(@QueryHint(name = "jakarta.persistence.lock.timeout", value = "0"))
    @Query("select o from Order o where o.id = :id")
    java.util.Optional<Order> lockForUpdate(UUID id);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @QueryHints({@QueryHint(name = "jakarta.persistence.lock.timeout", value = "0"),
            @QueryHint(name = "jakarta.persistence.query.timeout", value = "5000")})
    @Query("select o from Order o where o.id in :ids order by o.id")
    List<Order> lockPlanningOrders(Collection<UUID> ids);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select o from Order o where o.estado = :estado order by o.ventanaInicio, o.id")
    List<Order> lockByEstado(OrderStatus estado);

    boolean existsByClienteIdAndDireccionAndVentanaInicioAndVentanaFinAndEstadoInAndIdNot(
            String clienteId,
            String direccion,
            String ventanaInicio,
            String ventanaFin,
            List<OrderStatus> estados,
            UUID id);
}
