package com.pathseek.backend.auth.service;

import com.pathseek.backend.auth.entity.RefreshToken;
import com.pathseek.backend.auth.repository.RefreshTokenRepository;
import com.pathseek.backend.exception.ApiAuthenticationException;
import com.pathseek.backend.security.SecurityProperties;
import com.pathseek.backend.user.entity.User;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.time.Clock;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.Base64;
import java.util.HexFormat;

@Service
public class RefreshTokenService {

    private static final int TOKEN_BYTES = 32;

    private final RefreshTokenRepository repository;
    private final SecurityProperties properties;
    private final Clock clock;
    private final SecureRandom secureRandom = new SecureRandom();

    public RefreshTokenService(
            RefreshTokenRepository repository,
            SecurityProperties properties,
            Clock clock) {
        this.repository = repository;
        this.properties = properties;
        this.clock = clock;
    }

    @Transactional
    public IssuedRefreshToken create(User user) {
        OffsetDateTime now = now();
        String value = generateValue();

        RefreshToken token = new RefreshToken();
        token.setUser(user);
        token.setTokenHash(hash(value));
        token.setExpiresAt(now.plusDays(properties.refreshExpirationDays()));
        token.setLastUsedAt(now);
        repository.save(token);

        return new IssuedRefreshToken(value, user);
    }

    @Transactional(noRollbackFor = ApiAuthenticationException.class)
    public IssuedRefreshToken rotate(String value) {
        OffsetDateTime now = now();
        RefreshToken current = repository.findByTokenHashForUpdate(hash(value))
                .orElseThrow(this::invalidRefreshToken);

        if (current.getRevokedAt() != null) {
            throw invalidRefreshToken();
        }
        if (!current.getUser().isActivo()) {
            revoke(current, now);
            throw new ApiAuthenticationException(
                    "ACCOUNT_INACTIVE",
                    "La cuenta está inactiva",
                    HttpStatus.FORBIDDEN);
        }
        if (!current.getExpiresAt().isAfter(now)) {
            revoke(current, now);
            throw invalidRefreshToken();
        }
        OffsetDateTime inactivityLimit = current.getLastUsedAt()
                .plusMinutes(properties.sessionInactivityMinutes());
        if (inactivityLimit.isBefore(now)) {
            revoke(current, now);
            throw new ApiAuthenticationException(
                    "SESSION_INACTIVE",
                    "La sesión expiró por inactividad",
                    HttpStatus.UNAUTHORIZED);
        }

        current.setLastUsedAt(now);
        revoke(current, now);
        return create(current.getUser());
    }

    @Transactional
    public void revoke(String value) {
        repository.findByTokenHashForUpdate(hash(value)).ifPresent(token -> {
            if (token.getRevokedAt() == null) {
                revoke(token, now());
            }
        });
    }

    private void revoke(RefreshToken token, OffsetDateTime revokedAt) {
        token.setRevokedAt(revokedAt);
        repository.save(token);
    }

    private String generateValue() {
        byte[] bytes = new byte[TOKEN_BYTES];
        secureRandom.nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }

    private String hash(String value) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            return HexFormat.of().formatHex(digest.digest(value.getBytes(StandardCharsets.UTF_8)));
        } catch (NoSuchAlgorithmException exception) {
            throw new IllegalStateException("SHA-256 no está disponible", exception);
        }
    }

    private OffsetDateTime now() {
        return OffsetDateTime.now(clock).withOffsetSameInstant(ZoneOffset.UTC);
    }

    private ApiAuthenticationException invalidRefreshToken() {
        return new ApiAuthenticationException(
                "INVALID_REFRESH_TOKEN",
                "El refresh token no es válido",
                HttpStatus.UNAUTHORIZED);
    }
}
