-- Additive migration for existing installations; run before starting the updated backend.
ALTER TABLE usuarios ADD COLUMN IF NOT EXISTS token_version BIGINT NOT NULL DEFAULT 0;
CREATE UNIQUE INDEX IF NOT EXISTS uq_usuarios_email_ci ON usuarios (LOWER(TRIM(email)));
