package com.pathseek.backend.user.service;

import com.pathseek.backend.auth.repository.RefreshTokenRepository;
import com.pathseek.backend.auth.service.AuthService;
import com.pathseek.backend.driver.repository.DriverRepository;
import com.pathseek.backend.exception.BusinessConflictException;
import com.pathseek.backend.exception.BusinessRuleException;
import com.pathseek.backend.exception.ResourceNotFoundException;
import com.pathseek.backend.security.CurrentActor;
import com.pathseek.backend.user.dto.*;
import com.pathseek.backend.user.entity.User;
import com.pathseek.backend.user.entity.UserRole;
import com.pathseek.backend.user.repository.UserRepository;
import jakarta.persistence.criteria.Predicate;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.nio.charset.StandardCharsets;
import java.time.Clock;
import java.time.OffsetDateTime;
import java.util.ArrayList;
import java.util.UUID;

@Service
public class UserAdministrationService {
    private final UserRepository users;
    private final RefreshTokenRepository refreshTokens;
    private final DriverRepository drivers;
    private final PasswordEncoder passwords;
    private final Clock clock;
    @jakarta.persistence.PersistenceContext
    private jakarta.persistence.EntityManager entityManager;

    public UserAdministrationService(UserRepository users, RefreshTokenRepository refreshTokens,
            DriverRepository drivers, PasswordEncoder passwords, Clock clock) {
        this.users = users;
        this.refreshTokens = refreshTokens;
        this.drivers = drivers;
        this.passwords = passwords;
        this.clock = clock;
    }

    @Transactional(readOnly = true)
    public UserPageResponse list(int pagina, int tamano, String buscar, UserRole rol, Boolean activo) {
        if (pagina < 0 || tamano < 1 || tamano > 100 || (buscar != null && buscar.length() > 254)) {
            throw new BusinessRuleException("INVALID_USER_FILTER", "La página, el tamaño o la búsqueda no son válidos");
        }
        var page = users.findAll((root, query, cb) -> {
            var clauses = new ArrayList<Predicate>();
            if (buscar != null && !buscar.isBlank()) {
                String term = buscar.trim().toLowerCase(java.util.Locale.ROOT)
                        .replace("\\", "\\\\").replace("%", "\\%").replace("_", "\\_");
                clauses.add(cb.or(cb.like(cb.lower(root.get("nombre")), "%" + term + "%", '\\'),
                        cb.like(cb.lower(root.get("email")), "%" + term + "%", '\\')));
            }
            if (rol != null) clauses.add(cb.equal(root.get("rol"), rol));
            if (activo != null) clauses.add(cb.equal(root.get("activo"), activo));
            return cb.and(clauses.toArray(Predicate[]::new));
        }, PageRequest.of(pagina, tamano, Sort.by("nombre", "id")));
        return new UserPageResponse(page.getContent().stream().map(this::response).toList(),
                page.getNumber(), page.getTotalPages(), page.getTotalElements());
    }

    @Transactional
    public UserResponse create(CreateUserRequest request) {
        lockAdministration();
        String email = AuthService.normalizeEmail(request.email());
        if (users.existsByEmailIgnoreCase(email)) throw duplicateEmail();
        if (request.password().getBytes(StandardCharsets.UTF_8).length > 72) {
            throw new BusinessRuleException("PASSWORD_TOO_LONG", "La contraseña supera el límite de 72 bytes de bcrypt");
        }
        User user = new User();
        user.setNombre(request.nombre().trim());
        user.setEmail(email);
        user.setRol(request.rol());
        assignDni(user, request.dni());
        user.setPasswordHash(passwords.encode(request.password()));
        user.setActivo(true);
        users.saveAndFlush(user);
        linkDriver(user);
        return response(user);
    }

    @Transactional
    public UserResponse update(UUID id, UpdateUserRequest request) {
        UUID actorId = lockAdministration();
        User user = users.findByIdForUpdate(id)
                .orElseThrow(() -> new ResourceNotFoundException("No se encontró el usuario solicitado"));
        entityManager.refresh(user);
        boolean losingAdmin = user.getRol() == UserRole.ADMIN && user.isActivo()
                && (request.rol() != UserRole.ADMIN || !request.activo());
        if (losingAdmin && users.countByRolAndActivo(UserRole.ADMIN, true) <= 1) {
            throw new BusinessConflictException("LAST_ACTIVE_ADMIN", "Debe conservarse al menos un administrador activo");
        }
        if (id.equals(actorId) && (request.rol() != UserRole.ADMIN || !request.activo())) {
            throw new BusinessConflictException("SELF_ACCESS_CHANGE", "No puedes desactivar tu cuenta ni cambiar tu propio rol");
        }
        if (user.getRol() != request.rol() && drivers.existsByUsuarioId(id)) {
            throw new BusinessConflictException("DRIVER_ACCOUNT_LINKED", "La cuenta está vinculada a un conductor; conserva su rol para mantener el acceso a sus rutas");
        }
        String email = AuthService.normalizeEmail(request.email());
        if (users.existsByEmailIgnoreCaseAndIdNot(email, id)) throw duplicateEmail();
        String previousDni = user.getDni();        if (request.rol() == UserRole.CONDUCTOR && user.getRol() != UserRole.CONDUCTOR                && previousDni == null && request.dni() == null)            throw new BusinessRuleException("DRIVER_DNI_REQUIRED", "Indique el DNI para asignar el rol de conductor");
        assignDni(user, request.dni() == null ? previousDni : request.dni());
        if (!java.util.Objects.equals(previousDni, user.getDni()) && drivers.existsByUsuarioId(id)) {
            throw new BusinessConflictException("DRIVER_DNI_LINKED", "No se puede cambiar el DNI de una cuenta ya vinculada");
        }
        boolean accessChanged = !java.util.Objects.equals(previousDni, user.getDni()) || user.getRol() != request.rol() || user.isActivo() != request.activo()
                || !email.equals(user.getEmail());
        user.setNombre(request.nombre().trim());
        user.setEmail(email);
        user.setRol(request.rol());
        user.setActivo(request.activo());
        if (accessChanged) {
            user.invalidateSessions();
            refreshTokens.revokeAllForUser(id, OffsetDateTime.now(clock));
        }
        users.saveAndFlush(user);
        linkDriver(user);
        return response(user);
    }

    private void assignDni(User user, String dni) {
        if (user.getRol() == UserRole.CONDUCTOR && dni == null && user.getId() == null)
            throw new BusinessRuleException("DRIVER_DNI_REQUIRED", "Indique el DNI de la cuenta de conductor");
        if (dni != null && !dni.matches("[0-9]{8}"))
            throw new BusinessRuleException("INVALID_DNI", "El DNI debe tener 8 dígitos");
        if (dni != null && users.findByDni(dni).filter(other -> !other.getId().equals(user.getId())).isPresent())
            throw new BusinessConflictException("USER_DNI_CONFLICT", "Ya existe una cuenta con ese DNI");
        user.setDni(dni);
    }

    private void linkDriver(User user) {
        if (user.getDni() == null || user.getRol() != UserRole.CONDUCTOR || !user.isActivo()) return;
        drivers.findByDni(user.getDni()).ifPresent(driver -> {
            if (driver.getUsuarioId() != null && !driver.getUsuarioId().equals(user.getId()))
                throw new BusinessConflictException("DRIVER_USER_CONFLICT", "El DNI pertenece a un conductor vinculado a otra cuenta");
            driver.setUsuarioId(user.getId());
            drivers.save(driver);
        });
    }

    private UUID lockAdministration() {
        users.lockAdministrators();
        UUID actorId = UUID.fromString(CurrentActor.subject());
        User actor = users.findByIdForUpdate(actorId).orElseThrow(() -> new AccessDeniedException("Cuenta no disponible"));
        entityManager.refresh(actor);
        // Recheck after locks: a request authenticated before another administrator's change is stale.
        if (!actor.isActivo() || actor.getRol() != UserRole.ADMIN) throw new AccessDeniedException("Se requiere una cuenta administradora activa");
        return actorId;
    }

    private UserResponse response(User user) {
        return new UserResponse(user.getId(), user.getDni(), user.getNombre(), user.getEmail(), user.getRol(),
                user.isActivo(), user.getBloqueadoHasta(), user.getUltimoLogin());
    }

    private BusinessConflictException duplicateEmail() {
        return new BusinessConflictException("USER_EMAIL_CONFLICT", "Ya existe una cuenta con ese correo electrónico");
    }
}
