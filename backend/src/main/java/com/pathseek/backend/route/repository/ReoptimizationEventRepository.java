package com.pathseek.backend.route.repository;
import com.pathseek.backend.route.entity.ReoptimizationEvent;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.UUID;
public interface ReoptimizationEventRepository extends JpaRepository<ReoptimizationEvent, UUID> {}
