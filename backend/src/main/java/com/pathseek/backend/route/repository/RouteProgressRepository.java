package com.pathseek.backend.route.repository;
import com.pathseek.backend.route.entity.RouteProgress;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.UUID;
public interface RouteProgressRepository extends JpaRepository<RouteProgress, UUID> {}
