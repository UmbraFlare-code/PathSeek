-- =============================================================================
-- PATHSEEK - V9: PREFERENCIAS DE CLIENTES (RF-009 / US-004)
-- Motor: PostgreSQL 16+. Aditiva e idempotente.
-- =============================================================================

ALTER TABLE clientes ADD COLUMN IF NOT EXISTS horario_atencion_inicio VARCHAR(5);
ALTER TABLE clientes ADD COLUMN IF NOT EXISTS horario_atencion_fin VARCHAR(5);
ALTER TABLE clientes ADD COLUMN IF NOT EXISTS restricciones_acceso TEXT;
