package com.pathseek.backend.route.repository;

import com.pathseek.backend.route.entity.DeliveryRoute;
import com.pathseek.backend.route.entity.RouteStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.QueryHints;
import org.springframework.data.domain.Pageable;
import jakarta.persistence.LockModeType;
import jakarta.persistence.QueryHint;
import java.util.Collection;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@Repository
public interface DeliveryRouteRepository extends JpaRepository<DeliveryRoute, UUID> {

    @Query("select r.id from DeliveryRoute r where r.fecha = :date and r.estado in :states order by r.id")
    List<UUID> findActiveIds(LocalDate date, Collection<RouteStatus> states, Pageable page);

    @Query("select distinct r.id from DeliveryRoute r join r.pedidos p where p.pedido.id in :orders and r.estado in :states")
    List<UUID> findActiveIdsForOrders(Collection<UUID> orders, Collection<RouteStatus> states);

    @Query("select r.id from DeliveryRoute r where r.vehiculo.id = :vehicle and r.estado in :states")
    List<UUID> findActiveIdsForVehicle(UUID vehicle, Collection<RouteStatus> states);

    @Query("select distinct r.vehiculo.id from DeliveryRoute r where r.id in :ids")
    List<UUID> findVehicleIds(Collection<UUID> ids);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @QueryHints({@QueryHint(name = "jakarta.persistence.lock.timeout", value = "0"),
            @QueryHint(name = "jakarta.persistence.query.timeout", value = "5000")})
    @Query("select r from DeliveryRoute r where r.id in :ids order by r.id")
    List<DeliveryRoute> lockPlanningRoutes(Collection<UUID> ids);

    @Query("select distinct r from DeliveryRoute r left join fetch r.pedidos p left join fetch p.pedido where r.id in :ids")
    List<DeliveryRoute> fetchPlanningRoutes(Collection<UUID> ids);

    List<DeliveryRoute> findByEstadoIn(List<RouteStatus> estados);

    List<DeliveryRoute> findByFecha(LocalDate fecha);

    @Query("SELECT r FROM DeliveryRoute r WHERE r.conductor.id = :conductorId ORDER BY r.fecha DESC")
    List<DeliveryRoute> findByConductorId(@Param("conductorId") UUID conductorId);

    @Query("SELECT r FROM DeliveryRoute r LEFT JOIN FETCH r.pedidos p LEFT JOIN FETCH p.pedido WHERE r.id = :id")
    DeliveryRoute findWithPedidosById(@Param("id") UUID id);
}
