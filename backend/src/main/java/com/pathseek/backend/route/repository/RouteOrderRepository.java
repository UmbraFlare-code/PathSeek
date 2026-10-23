package com.pathseek.backend.route.repository;

import com.pathseek.backend.route.entity.RouteOrder;
import com.pathseek.backend.route.entity.RouteOrderId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.domain.Pageable;
import com.pathseek.backend.route.entity.RouteStatus;
import java.util.Collection;

import java.util.List;
import java.util.UUID;

@Repository
public interface RouteOrderRepository extends JpaRepository<RouteOrder, RouteOrderId> {

    @Query("select distinct p.pedido.id from RouteOrder p where p.ruta.id in :routes order by p.pedido.id")
    List<UUID> findOrderIds(Collection<UUID> routes, Pageable page);

    @Query("select count(p) from RouteOrder p where p.pedido.id in :orders and p.ruta.estado in :states")
    long countActiveAssignments(Collection<UUID> orders, Collection<RouteStatus> states);

    List<RouteOrder> findByRuta_IdOrderByOrdenAsc(UUID rutaId);
}
