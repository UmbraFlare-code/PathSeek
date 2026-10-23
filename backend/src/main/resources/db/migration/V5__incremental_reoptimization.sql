-- Additive migration. Apply once to existing volumes before starting the new backend.
-- Idempotent; does not delete routes, assignments, orders or users.
CREATE TABLE IF NOT EXISTS reoptimizacion_eventos (
    evento_id UUID PRIMARY KEY,
    solicitud_hash VARCHAR(64) NOT NULL,
    respuesta_json TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL
);
CREATE TABLE IF NOT EXISTS ruta_incidentes (
    incidente_id UUID PRIMARY KEY,
    ruta_id UUID NOT NULL REFERENCES rutas(ruta_id) ON DELETE CASCADE,
    tipo VARCHAR(30) NOT NULL,
    descripcion VARCHAR(1000) NOT NULL,
    lat NUMERIC(9,6) NOT NULL CHECK (lat BETWEEN -90 AND 90),
    lon NUMERIC(9,6) NOT NULL CHECK (lon BETWEEN -180 AND 180),
    radio_metros INTEGER NOT NULL CHECK (radio_metros BETWEEN 1 AND 5000),
    activa BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_ruta_incidentes_activos ON ruta_incidentes(ruta_id, activa);
CREATE TABLE IF NOT EXISTS vehiculo_averias (
    vehiculo_id UUID PRIMARY KEY REFERENCES vehiculos(vehiculo_id) ON DELETE CASCADE,
    activa BOOLEAN NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
);
CREATE TABLE IF NOT EXISTS ruta_progreso (
    ruta_id UUID PRIMARY KEY REFERENCES rutas(ruta_id) ON DELETE CASCADE,
    lat NUMERIC(9,6) NOT NULL,
    lon NUMERIC(9,6) NOT NULL,
    ultimo_orden INTEGER NOT NULL,
    distancia_km NUMERIC(12,6) NOT NULL,
    combustible_l NUMERIC(12,6) NOT NULL,
    co2_kg NUMERIC(12,6) NOT NULL
);
CREATE TABLE IF NOT EXISTS ruta_notificaciones (
    notificacion_id UUID PRIMARY KEY,
    evento_id UUID NOT NULL,
    ruta_id UUID NOT NULL,
    conductor_id UUID NOT NULL,
    usuario_id UUID,
    mensaje VARCHAR(500) NOT NULL,
    leida BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL,
    CONSTRAINT uq_ruta_notificacion_evento UNIQUE (evento_id, ruta_id)
);
CREATE INDEX IF NOT EXISTS idx_ruta_notificaciones_usuario ON ruta_notificaciones(usuario_id, created_at);
