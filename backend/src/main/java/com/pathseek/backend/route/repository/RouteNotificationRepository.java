package com.pathseek.backend.route.repository;
import com.pathseek.backend.route.entity.RouteNotification;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.UUID;
public interface RouteNotificationRepository extends JpaRepository<RouteNotification, UUID> {
    List<RouteNotification> findAllByOrderByCreatedAtDesc(Pageable page);
    List<RouteNotification> findByUserIdOrderByCreatedAtDesc(UUID userId, Pageable page);
}
