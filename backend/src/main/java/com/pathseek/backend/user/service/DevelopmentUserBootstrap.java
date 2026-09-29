package com.pathseek.backend.user.service;

import com.pathseek.backend.auth.service.AuthService;
import com.pathseek.backend.user.entity.User;
import com.pathseek.backend.user.entity.UserRole;
import com.pathseek.backend.user.repository.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

@Component
public class DevelopmentUserBootstrap implements ApplicationRunner {

    private static final Logger LOGGER = LoggerFactory.getLogger(DevelopmentUserBootstrap.class);

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final boolean enabled;
    private final String name;
    private final String email;
    private final String password;
    private final UserRole role;

    public DevelopmentUserBootstrap(
            UserRepository userRepository,
            PasswordEncoder passwordEncoder,
            @Value("${app.bootstrap-user.enabled:false}") boolean enabled,
            @Value("${app.bootstrap-user.name:}") String name,
            @Value("${app.bootstrap-user.email:}") String email,
            @Value("${app.bootstrap-user.password:}") String password,
            @Value("${app.bootstrap-user.role:ADMIN}") UserRole role) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.enabled = enabled;
        this.name = name;
        this.email = email;
        this.password = password;
        this.role = role;
    }

    @Override
    @Transactional
    public void run(ApplicationArguments arguments) {
        if (!enabled) {
            return;
        }
        validateConfiguration();

        String normalizedEmail = AuthService.normalizeEmail(email);
        if (userRepository.existsByEmail(normalizedEmail)) {
            return;
        }

        User user = new User();
        user.setNombre(name.trim());
        user.setEmail(normalizedEmail);
        user.setPasswordHash(passwordEncoder.encode(password));
        user.setRol(role);
        user.setActivo(true);
        userRepository.save(user);
        LOGGER.info("Usuario local de desarrollo creado");
    }

    private void validateConfiguration() {
        if (name == null || name.isBlank()
                || email == null || email.isBlank()
                || password == null || password.length() < 8) {
            throw new IllegalStateException(
                    "El bootstrap local requiere nombre, email y una contraseña de al menos 8 caracteres");
        }
    }
}
