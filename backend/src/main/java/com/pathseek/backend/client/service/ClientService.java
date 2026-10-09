package com.pathseek.backend.client.service;

import com.pathseek.backend.client.dto.ClientRequest;
import com.pathseek.backend.client.dto.ClientResponse;
import com.pathseek.backend.client.entity.Client;
import com.pathseek.backend.client.repository.ClientRepository;
import com.pathseek.backend.exception.BusinessConflictException;
import com.pathseek.backend.exception.ResourceNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
public class ClientService {

    private final ClientRepository clientRepository;

    public ClientService(ClientRepository clientRepository) {
        this.clientRepository = clientRepository;
    }

    @Transactional(readOnly = true)
    public List<ClientResponse> findAll() {
        return clientRepository.findAll().stream()
                .map(ClientResponse::fromEntity)
                .toList();
    }

    @Transactional(readOnly = true)
    public ClientResponse findById(UUID id) {
        Client client = clientRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Cliente no encontrado con id " + id));
        return ClientResponse.fromEntity(client);
    }

    @Transactional
    public ClientResponse create(ClientRequest request) {
        clientRepository.findByNombreIgnoreCase(request.nombre().trim())
                .ifPresent(c -> {
                    throw new BusinessConflictException("CLIENTE_DUPLICADO", "Ya existe un cliente registrado con el nombre " + request.nombre());
                });

        Client client = new Client();
        mapToEntity(request, client);
        return ClientResponse.fromEntity(clientRepository.save(client));
    }

    @Transactional
    public ClientResponse update(UUID id, ClientRequest request) {
        Client client = clientRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Cliente no encontrado con id " + id));

        clientRepository.findByNombreIgnoreCase(request.nombre().trim())
                .filter(existing -> !existing.getId().equals(id))
                .ifPresent(existing -> {
                    throw new BusinessConflictException("CLIENTE_DUPLICADO", "Ya existe otro cliente con el nombre " + request.nombre());
                });

        mapToEntity(request, client);
        return ClientResponse.fromEntity(clientRepository.save(client));
    }

    @Transactional
    public void delete(UUID id) {
        if (!clientRepository.existsById(id)) {
            throw new ResourceNotFoundException("Cliente no encontrado con id " + id);
        }
        clientRepository.deleteById(id);
    }

    private void mapToEntity(ClientRequest request, Client client) {
        client.setNombre(request.nombre().trim());
        client.setDireccion(request.direccion().trim());
        client.setPuntoReferencia(request.puntoReferencia() != null ? request.puntoReferencia().trim() : null);
        client.setTelefono(request.telefono() != null ? request.telefono().trim() : null);
        client.setContacto(request.contacto() != null ? request.contacto().trim() : null);
        client.setGpsLat(request.gpsLat());
        client.setGpsLon(request.gpsLon());
        client.setVentanaInicioPreferida(request.ventanaInicioPreferida());
        client.setVentanaFinPreferida(request.ventanaFinPreferida());
        if (request.activo() != null) {
            client.setActivo(request.activo());
        }
    }
}
