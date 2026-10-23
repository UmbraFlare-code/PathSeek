package com.pathseek.backend.security;

import com.pathseek.backend.user.repository.UserRepository;
import org.springframework.security.oauth2.core.OAuth2Error;
import org.springframework.security.oauth2.core.OAuth2TokenValidator;
import org.springframework.security.oauth2.core.OAuth2TokenValidatorResult;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Component;

import java.util.UUID;

/** Account and version checks also revoke already-issued access tokens after administration. */
@Component
public class UserSessionValidator implements OAuth2TokenValidator<Jwt> {
    private final UserRepository users;
    public UserSessionValidator(UserRepository users) { this.users = users; }

    @Override
    public OAuth2TokenValidatorResult validate(Jwt token) {
        try {
            String subject = token.getSubject();
            if (subject == null || subject.isBlank()) return invalidSession();
            var user = users.findById(UUID.fromString(subject)).orElse(null);
            Object version = token.getClaims().get("ver");
            // Tokens issued before this migration belong to version zero only.
            long issuedVersion = version == null ? 0 : ((Number) version).longValue();
            if (user != null && user.isActivo() && user.getTokenVersion() == issuedVersion
                    && user.getRol().name().equals(token.getClaimAsString("rol"))) {
                return OAuth2TokenValidatorResult.success();
            }
        } catch (IllegalArgumentException | ClassCastException exception) {
            // Malformed subjects/versions are authentication errors, never server errors.
        }
        return invalidSession();
    }

    private OAuth2TokenValidatorResult invalidSession() {
        return OAuth2TokenValidatorResult.failure(new OAuth2Error("invalid_token", "La sesión ya no es válida", null));
    }
}
