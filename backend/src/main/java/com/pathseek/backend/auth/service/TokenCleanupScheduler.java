package com.pathseek.backend.auth.service;

import com.pathseek.backend.auth.repository.RefreshTokenRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.OffsetDateTime;
import java.time.ZoneOffset;

@Component
public class TokenCleanupScheduler {

    private static final Logger log = LoggerFactory.getLogger(TokenCleanupScheduler.class);

    private final RefreshTokenRepository refreshTokenRepository;

    public TokenCleanupScheduler(RefreshTokenRepository refreshTokenRepository) {
        this.refreshTokenRepository = refreshTokenRepository;
    }

    // Limpieza diaria a las 03:00 AM UTC
    @Scheduled(cron = "0 0 3 * * ?")
    @Transactional
    public void cleanupExpiredTokens() {
        OffsetDateTime now = OffsetDateTime.now(ZoneOffset.UTC);
        long expiredDeleted = refreshTokenRepository.deleteByExpiresAtBefore(now);
        long revokedDeleted = refreshTokenRepository.deleteByRevokedAtIsNotNull();
        log.info("TokenCleanupScheduler: Se depuraron {} tokens expirados y {} tokens revocados.", expiredDeleted, revokedDeleted);
    }
}
