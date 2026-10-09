package com.pathseek.backend.audit.service;

import com.pathseek.backend.audit.dto.AuditLogResponse;
import com.pathseek.backend.audit.entity.AuditLog;
import com.pathseek.backend.audit.repository.AuditLogRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;

@Service
public class AuditService {

    private static final Logger log = LoggerFactory.getLogger(AuditService.class);

    private final AuditLogRepository auditLogRepository;

    public AuditService(AuditLogRepository auditLogRepository) {
        this.auditLogRepository = auditLogRepository;
    }

    @Transactional
    public void registrarEvento(String usuario, String accion, String entidad, String entidadId, String detalles, String ip) {
        try {
            AuditLog auditLog = new AuditLog(usuario, accion, entidad, entidadId, detalles, ip);
            auditLogRepository.save(auditLog);
            log.info("AUDIT: Usuario [{}] ejecutó [{}] sobre [{}] id [{}]", usuario, accion, entidad, entidadId);
        } catch (Exception e) {
            log.error("Error al registrar evento de auditoría: {}", e.getMessage());
        }
    }

    @Transactional(readOnly = true)
    public List<AuditLogResponse> obtenerUltimosEventos() {
        return auditLogRepository.findTop100ByOrderByFechaHoraDesc().stream()
                .map(AuditLogResponse::fromEntity)
                .toList();
    }

    @Transactional(readOnly = true)
    public List<AuditLogResponse> obtenerPorEntidad(String entidad) {
        return auditLogRepository.findByEntidadOrderByFechaHoraDesc(entidad).stream()
                .map(AuditLogResponse::fromEntity)
                .toList();
    }

    @Transactional(readOnly = true)
    public List<AuditLogResponse> obtenerPorRangoFechas(Instant desde, Instant hasta) {
        return auditLogRepository.findByFechaHoraBetweenOrderByFechaHoraDesc(desde, hasta).stream()
                .map(AuditLogResponse::fromEntity)
                .toList();
    }
}
