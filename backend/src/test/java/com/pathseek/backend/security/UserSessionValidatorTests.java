package com.pathseek.backend.security;

import com.pathseek.backend.user.entity.User;
import com.pathseek.backend.user.entity.UserRole;
import com.pathseek.backend.user.repository.UserRepository;
import org.junit.jupiter.api.Test;
import org.springframework.security.oauth2.jwt.Jwt;

import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.*;

class UserSessionValidatorTests {
    private final UserRepository users = mock(UserRepository.class);
    private final UserSessionValidator validator = new UserSessionValidator(users);

    @Test
    void missingOrInvalidSubjectIsRejectedWithoutLookingUpUsers() {
        assertThat(validator.validate(token().build()).hasErrors()).isTrue();
        assertThat(validator.validate(token().subject(" ").build()).hasErrors()).isTrue();
        assertThat(validator.validate(token().subject("not-a-uuid").build()).hasErrors()).isTrue();
        verifyNoInteractions(users);
    }

    @Test
    void nonnumericVersionIsRejectedAsInvalidToken() {
        UUID id = UUID.randomUUID();
        User user = new User();
        user.setRol(UserRole.ADMIN);
        when(users.findById(id)).thenReturn(Optional.of(user));
        var result = validator.validate(token().subject(id.toString()).claim("ver", "invalid-version").build());
        assertThat(result.hasErrors()).isTrue();
        assertThat(result.getErrors()).allMatch(error -> error.getErrorCode().equals("invalid_token"));
    }

    private Jwt.Builder token() {
        return Jwt.withTokenValue("signed-token-already-decoded").header("alg", "HS256").claim("rol", "ADMIN");
    }
}
