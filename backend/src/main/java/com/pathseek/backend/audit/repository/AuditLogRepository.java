package com.pathseek.backend.audit.repository;

import com.pathseek.backend.audit.entity.AuditLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Repository
public interface AuditLogRepository extends JpaRepository<AuditLog, UUID> {
    List<AuditLog> findTop100ByOrderByFechaHoraDesc();
    List<AuditLog> findByEntidadOrderByFechaHoraDesc(String entidad);
    List<AuditLog> findByFechaHoraBetweenOrderByFechaHoraDesc(Instant desde, Instant hasta);
}
