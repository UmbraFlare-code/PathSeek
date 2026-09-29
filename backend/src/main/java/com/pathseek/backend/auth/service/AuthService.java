package com.pathseek.backend.auth.service;

import com.pathseek.backend.auth.dto.AuthenticatedUserResponse;
import com.pathseek.backend.auth.dto.LoginRequest;
import com.pathseek.backend.auth.dto.LoginResponse;
import com.pathseek.backend.auth.dto.TokenResponse;
import com.pathseek.backend.exception.ApiAuthenticationException;
import com.pathseek.backend.security.JwtService;
import com.pathseek.backend.user.entity.User;
import com.pathseek.backend.user.repository.UserRepository;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Clock;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.Locale;
import java.util.UUID;

@Service
public class AuthService {

    private static final int MAX_FAILED_ATTEMPTS = 3;
    private static final int LOCK_MINUTES = 15;

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final RefreshTokenService refreshTokenService;
    private final Clock clock;
    private final String dummyPasswordHash;

    public AuthService(
            UserRepository userRepository,
            PasswordEncoder passwordEncoder,
            JwtService jwtService,
            RefreshTokenService refreshTokenService,
            Clock clock) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
        this.refreshTokenService = refreshTokenService;
        this.clock = clock;
        this.dummyPasswordHash = passwordEncoder.encode(UUID.randomUUID().toString());
    }

    @Transactional(noRollbackFor = ApiAuthenticationException.class)
    public LoginResponse login(LoginRequest request) {
        String email = normalizeEmail(request.email());
        User user = userRepository.findByEmailForUpdate(email).orElse(null);

        if (user == null) {
            passwordEncoder.matches(request.password(), dummyPasswordHash);
            throw invalidCredentials();
        }
        if (!user.isActivo()) {
            throw new ApiAuthenticationException(
                    "ACCOUNT_INACTIVE",
                    "La cuenta está inactiva",
                    HttpStatus.FORBIDDEN);
        }

        OffsetDateTime now = now();
        if (user.getBloqueadoHasta() != null && user.getBloqueadoHasta().isAfter(now)) {
            throw accountLocked();
        }
        if (user.getBloqueadoHasta() != null) {
            user.setIntentosFallidos(0);
            user.setBloqueadoHasta(null);
        }

        if (!passwordEncoder.matches(request.password(), user.getPasswordHash())) {
            registerFailedAttempt(user, now);
            throw user.getBloqueadoHasta() == null ? invalidCredentials() : accountLocked();
        }

        user.setIntentosFallidos(0);
        user.setBloqueadoHasta(null);
        user.setUltimoLogin(now);
        userRepository.save(user);

        IssuedRefreshToken refreshToken = refreshTokenService.create(user);
        return new LoginResponse(
                jwtService.generateAccessToken(user),
                refreshToken.value(),
                toResponse(user));
    }

    @Transactional(noRollbackFor = ApiAuthenticationException.class)
    public TokenResponse refresh(String refreshTokenValue) {
        IssuedRefreshToken refreshToken = refreshTokenService.rotate(refreshTokenValue);
        return new TokenResponse(
                jwtService.generateAccessToken(refreshToken.user()),
                refreshToken.value());
    }

    public void logout(String refreshTokenValue) {
        refreshTokenService.revoke(refreshTokenValue);
    }

    public static String normalizeEmail(String email) {
        return email.trim().toLowerCase(Locale.ROOT);
    }

    private void registerFailedAttempt(User user, OffsetDateTime now) {
        int attempts = user.getIntentosFallidos() + 1;
        user.setIntentosFallidos(attempts);
        if (attempts >= MAX_FAILED_ATTEMPTS) {
            user.setBloqueadoHasta(now.plusMinutes(LOCK_MINUTES));
        }
        userRepository.saveAndFlush(user);
    }

    private AuthenticatedUserResponse toResponse(User user) {
        return new AuthenticatedUserResponse(
                user.getId(),
                user.getNombre(),
                user.getEmail(),
                user.getRol());
    }

    private OffsetDateTime now() {
        return OffsetDateTime.now(clock).withOffsetSameInstant(ZoneOffset.UTC);
    }

    private ApiAuthenticationException invalidCredentials() {
        return new ApiAuthenticationException(
                "INVALID_CREDENTIALS",
                "Credenciales inválidas",
                HttpStatus.UNAUTHORIZED);
    }

    private ApiAuthenticationException accountLocked() {
        return new ApiAuthenticationException(
                "ACCOUNT_LOCKED",
                "La cuenta está bloqueada temporalmente",
                HttpStatus.UNAUTHORIZED);
    }
}
