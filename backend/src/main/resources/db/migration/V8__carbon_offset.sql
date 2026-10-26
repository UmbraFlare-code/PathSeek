-- =============================================================================
-- PATHSEEK - V8: PROYECTOS DE COMPENSACIÓN DE CARBONO (RF-010 / US-010)
-- Motor: PostgreSQL 16+. Aditiva e idempotente.
-- =============================================================================

CREATE TABLE IF NOT EXISTS proyectos_compensacion (
    proyecto_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre VARCHAR(160) NOT NULL UNIQUE,
    descripcion TEXT,
    tipo VARCHAR(40) NOT NULL,
    costo_tonelada NUMERIC(12, 2) NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_proyectos_tipo CHECK (tipo IN ('REFORESTACION', 'ENERGIA_RENOVABLE', 'EFICIENCIA_ENERGETICA', 'GESTION_RESIDUOS')),
    CONSTRAINT chk_proyectos_costo CHECK (costo_tonelada >= 0)
);

INSERT INTO proyectos_compensacion (nombre, descripcion, tipo, costo_tonelada, activo) VALUES
    ('Reforestación Valle del Mantaro', 'Plantación de árboles nativos (queñual, quishuar) en laderas del Valle del Mantaro, Junín.', 'REFORESTACION', 35.00, TRUE),
    ('Agroforestería comunal Huancayo', 'Sistemas agroforestales con familias campesinas de Huancayo, El Tambo y Chilca.', 'REFORESTACION', 28.50, TRUE),
    ('Eficiencia energética en escuelas', 'Cambio de luminarias y aislamiento térmico en instituciones educativas de UGEL Huancayo.', 'EFICIENCIA_ENERGETICA', 42.00, TRUE)
ON CONFLICT (nombre) DO NOTHING;
