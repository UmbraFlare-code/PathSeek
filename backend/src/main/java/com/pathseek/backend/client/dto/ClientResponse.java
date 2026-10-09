package com.pathseek.backend.client.dto;

import com.pathseek.backend.client.entity.Client;
import io.swagger.v3.oas.annotations.media.Schema;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

@Schema(description = "Respuesta con datos del cliente")
public record ClientResponse(
        UUID id,
        String nombre,
        String direccion,
        String puntoReferencia,
        String telefono,
        String contacto,
        BigDecimal gpsLat,
        BigDecimal gpsLon,
        String ventanaInicioPreferida,
        String ventanaFinPreferida,
        Boolean activo,
        Instant creadoEn
) {
    public static ClientResponse fromEntity(Client client) {
        return new ClientResponse(
                client.getId(),
                client.getNombre(),
                client.getDireccion(),
                client.getPuntoReferencia(),
                client.getTelefono(),
                client.getContacto(),
                client.getGpsLat(),
                client.getGpsLon(),
                client.getVentanaInicioPreferida(),
                client.getVentanaFinPreferida(),
                client.getActivo(),
                client.getCreadoEn()
        );
    }
}
