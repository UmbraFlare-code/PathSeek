CREATE TABLE usuarios (
    usuario_id UUID PRIMARY KEY,
    nombre VARCHAR(120) NOT NULL,
    email VARCHAR(254) NOT NULL UNIQUE,
    password_hash VARCHAR(100) NOT NULL,
    rol VARCHAR(20) NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    intentos_fallidos INTEGER NOT NULL DEFAULT 0,
    bloqueado_hasta TIMESTAMPTZ,
    ultimo_login TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_usuarios_rol CHECK (rol IN ('ADMIN', 'OPERADOR', 'CONDUCTOR', 'CLIENTE', 'AUDITOR')),
    CONSTRAINT chk_usuarios_intentos CHECK (intentos_fallidos >= 0),
    CONSTRAINT chk_usuarios_email_normalizado CHECK (email = LOWER(TRIM(email)))
);

CREATE TABLE refresh_tokens (
    refresh_token_id UUID PRIMARY KEY,
    usuario_id UUID NOT NULL,
    token_hash CHAR(64) NOT NULL UNIQUE,
    expires_at TIMESTAMPTZ NOT NULL,
    last_used_at TIMESTAMPTZ NOT NULL,
    revoked_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_refresh_tokens_usuario
        FOREIGN KEY (usuario_id) REFERENCES usuarios (usuario_id) ON DELETE CASCADE
);

CREATE INDEX idx_refresh_tokens_usuario ON refresh_tokens (usuario_id);
