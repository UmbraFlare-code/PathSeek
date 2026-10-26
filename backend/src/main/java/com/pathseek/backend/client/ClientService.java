package com.pathseek.backend.client;

import com.pathseek.backend.exception.BusinessConflictException;
import com.pathseek.backend.exception.BusinessRuleException;
import com.pathseek.backend.exception.ResourceNotFoundException;
import com.pathseek.backend.security.CurrentActor;
import com.pathseek.backend.user.entity.User;
import com.pathseek.backend.user.entity.UserRole;
import com.pathseek.backend.user.repository.UserRepository;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

/**
 * Módulo de clientes y preferencias de entrega (US-004 / RF-009).
 * Un perfil se asocia a una cuenta CLIENTE activa; el propio cliente solo
 * gestiona su perfil y los roles operativos gestionan todos.
 */
@Service
public class ClientService {

    private final ClientProfileRepository repository;
    private final UserRepository users;

    public ClientService(ClientProfileRepository repository, UserRepository users) {
        this.repository = repository;
        this.users = users;
    }

    @Transactional(readOnly = true)
    public List<ClientResponse> list() {
        if (CurrentActor.hasRole("CLIENTE")) {
            UUID subject = UUID.fromString(CurrentActor.subject());
            return repository.findByUsuarioId(subject).map(profile -> List.of(ClientResponse.from(profile)))
                    .orElseGet(List::of);
        }
        return repository.findAllByOrderByNombreAsc().stream().map(ClientResponse::from).toList();
    }

    @Transactional(readOnly = true)
    public ClientResponse get(UUID id) {
        ClientProfile profile = find(id);
        assertOwn(profile);
        return ClientResponse.from(profile);
    }

    @Transactional
    public ClientResponse create(ClientRequest request) {
        UUID usuarioId = resolveUsuarioId(request);
        validateAccount(usuarioId);
        if (repository.findByUsuarioId(usuarioId).isPresent()) {
            throw new BusinessConflictException("CLIENT_ALREADY_LINKED",
                    "Esa cuenta ya tiene un perfil de cliente asociado");
        }
        validateSchedule(request);
        ClientProfile profile = new ClientProfile();
        profile.setUsuarioId(usuarioId);
        apply(profile, request);
        return ClientResponse.from(repository.save(profile));
    }

    @Transactional
    public ClientResponse update(UUID id, ClientRequest request) {
        ClientProfile profile = find(id);
        assertOwn(profile);
        if (request.usuarioId() != null && !request.usuarioId().equals(profile.getUsuarioId())) {
            throw new BusinessConflictException("CLIENT_USER_LOCKED",
                    "La cuenta asociada al perfil no puede modificarse");
        }
        validateSchedule(request);
        apply(profile, request);
        return ClientResponse.from(repository.save(profile));
    }

    @Transactional
    public void delete(UUID id) {
        ClientProfile profile = find(id);
        repository.delete(profile);
    }

    private ClientProfile find(UUID id) {
        return repository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Cliente no encontrado con ID: " + id));
    }

    private void assertOwn(ClientProfile profile) {
        if (CurrentActor.hasRole("CLIENTE")
                && !profile.getUsuarioId().toString().equals(CurrentActor.subject())) {
            throw new AccessDeniedException("El perfil pertenece a otro cliente");
        }
    }

    private UUID resolveUsuarioId(ClientRequest request) {
        if (CurrentActor.hasRole("CLIENTE")) {
            return UUID.fromString(CurrentActor.subject());
        }
        if (request.usuarioId() == null) {
            throw new BusinessRuleException("CLIENT_USER_REQUIRED",
                    "Seleccione la cuenta de usuario del cliente");
        }
        return request.usuarioId();
    }

    private void validateAccount(UUID usuarioId) {
        User user = users.findById(usuarioId)
                .orElseThrow(() -> new BusinessRuleException("CLIENT_USER_INVALID",
                        "La cuenta seleccionada no existe"));
        if (!user.isActivo() || user.getRol() != UserRole.CLIENTE) {
            throw new BusinessRuleException("CLIENT_USER_INVALID",
                    "La cuenta debe estar activa y tener el rol CLIENTE");
        }
    }

    private void validateSchedule(ClientRequest request) {
        boolean onlyStart = request.horarioAtencionInicio() != null && request.horarioAtencionFin() == null;
        boolean onlyEnd = request.horarioAtencionInicio() == null && request.horarioAtencionFin() != null;
        if (onlyStart || onlyEnd) {
            throw new BusinessRuleException("CLIENT_SCHEDULE_INCOMPLETE",
                    "El horario de atención requiere inicio y fin");
        }
        if (request.horarioAtencionInicio() != null
                && request.horarioAtencionFin().compareTo(request.horarioAtencionInicio()) <= 0) {
            throw new BusinessRuleException("CLIENT_SCHEDULE_INVALID",
                    "El horario de fin debe ser posterior al de inicio");
        }
    }

    private void apply(ClientProfile profile, ClientRequest request) {
        profile.setNombre(request.nombre().trim());
        profile.setDireccion(trimToNull(request.direccion()));
        profile.setPuntoReferencia(trimToNull(request.puntoReferencia()));
        profile.setTelefono(trimToNull(request.telefono()));
        profile.setHorarioAtencionInicio(trimToNull(request.horarioAtencionInicio()));
        profile.setHorarioAtencionFin(trimToNull(request.horarioAtencionFin()));
        profile.setRestriccionesAcceso(trimToNull(request.restriccionesAcceso()));
    }

    private String trimToNull(String value) {
        if (value == null) return null;
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }
}
