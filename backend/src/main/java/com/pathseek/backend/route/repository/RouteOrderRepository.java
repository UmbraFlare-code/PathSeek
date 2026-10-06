package com.pathseek.backend.route.repository;

import com.pathseek.backend.route.entity.RouteOrder;
import com.pathseek.backend.route.entity.RouteOrderId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface RouteOrderRepository extends JpaRepository<RouteOrder, RouteOrderId> {

    List<RouteOrder> findByRuta_IdOrderByOrdenAsc(UUID rutaId);
}
