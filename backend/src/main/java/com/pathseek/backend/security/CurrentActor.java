package com.pathseek.backend.security;

import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.jwt.Jwt;

/** Identity comes exclusively from the JWT validated by Spring Security. */
public final class CurrentActor {
    private CurrentActor() {}
    public static boolean hasRole(String role) {
        var auth = SecurityContextHolder.getContext().getAuthentication();
        return auth != null && auth.getAuthorities().stream()
                .anyMatch(authority -> authority.getAuthority().equals("ROLE_" + role));
    }
    public static String subject() {
        var auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth != null && auth.getPrincipal() instanceof Jwt jwt) return jwt.getSubject();
        throw new org.springframework.security.access.AccessDeniedException("Identidad no disponible");
    }
}
