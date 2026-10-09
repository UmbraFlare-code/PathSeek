package com.pathseek.backend.audit.dto;

import com.pathseek.backend.audit.entity.AuditLog;
import io.swagger.v3.oas.annotations.media.Schema;

import java.time.Instant;
import java.util.UUID;

@Schema(description = "Registro de evento de auditoría y trazabilidad")
public record AuditLogResponse(
        UUID id,
        String usuario,
        String accion,
        String entidad,
        String entidadId,
        String detalles,
        String ipOrigen,
        Instant fechaHora
) {
    public static AuditLogResponse fromEntity(AuditLog log) {
        return new AuditLogResponse(
                log.getId(),
                log.getUsuario(),
                log.getAccion(),
                log.getEntidad(),
                log.getEntidadId(),
                log.getDetalles(),
                log.getIpOrigen(),
                log.getFechaHora()
        );
    }
}
