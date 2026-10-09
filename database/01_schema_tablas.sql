-- =============================================================================
-- PATHSEEK - SCRIPT DE CREACIÓN DE TABLAS E ÍNDICES (DDL)
-- Motor: PostgreSQL 16+
-- Descripción: Define el esquema completo para la plataforma PathSeek, 
--              incluyendo tablas del MVP (V1-V3) y tablas del Roadmap futuro.
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- -----------------------------------------------------------------------------
-- 1. TABLA: vehiculos (MVP - Flyway V1)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS vehiculos (
    vehiculo_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    placa VARCHAR(10) NOT NULL UNIQUE,
    tipo VARCHAR(30) NOT NULL,
    capacidad_kg NUMERIC(10, 2) NOT NULL,
    capacidad_m3 NUMERIC(10, 2) NOT NULL,
    consumo_km_l NUMERIC(10, 2) NOT NULL,
    factor_emision NUMERIC(10, 4) NOT NULL,
    anio INTEGER,
    restriccion_placa_digito INTEGER,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_vehiculos_tipo CHECK (tipo IN ('CAMIONETA', 'FURGON', 'MOTO')),
    CONSTRAINT chk_vehiculos_capacidad_kg CHECK (capacidad_kg > 0),
    CONSTRAINT chk_vehiculos_capacidad_m3 CHECK (capacidad_m3 > 0),
    CONSTRAINT chk_vehiculos_consumo CHECK (consumo_km_l > 0),
    CONSTRAINT chk_vehiculos_factor_emision CHECK (factor_emision >= 0),
    CONSTRAINT chk_vehiculos_anio CHECK (anio IS NULL OR anio BETWEEN 1900 AND 2100),
    CONSTRAINT chk_vehiculos_restriccion CHECK (
        restriccion_placa_digito IS NULL OR restriccion_placa_digito BETWEEN 0 AND 9
    )
);

-- -----------------------------------------------------------------------------
-- 2. TABLA: usuarios (MVP - Flyway V2)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS usuarios (
    usuario_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
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

-- -----------------------------------------------------------------------------
-- 3. TABLA: refresh_tokens (MVP - Flyway V2)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS refresh_tokens (
    refresh_token_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    usuario_id UUID NOT NULL,
    token_hash CHAR(64) NOT NULL UNIQUE,
    expires_at TIMESTAMPTZ NOT NULL,
    last_used_at TIMESTAMPTZ NOT NULL,
    revoked_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_refresh_tokens_usuario
        FOREIGN KEY (usuario_id) REFERENCES usuarios (usuario_id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_refresh_tokens_usuario ON refresh_tokens (usuario_id);

-- -----------------------------------------------------------------------------
-- 4. TABLA: conductores (MVP - Flyway V3)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS conductores (
    conductor_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    usuario_id UUID,
    dni CHAR(8) NOT NULL UNIQUE,
    nombre VARCHAR(120) NOT NULL,
    licencia VARCHAR(20) NOT NULL UNIQUE,
    categoria VARCHAR(10) NOT NULL,
    experiencia INTEGER NOT NULL DEFAULT 0,
    disponible BOOLEAN NOT NULL DEFAULT TRUE,
    contacto VARCHAR(140),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_conductores_categoria CHECK (categoria IN ('AII', 'AIII', 'BII', 'BIII')),
    CONSTRAINT chk_conductores_experiencia CHECK (experiencia >= 0)
);

-- -----------------------------------------------------------------------------
-- 5. TABLA: pedidos (MVP - Flyway V3)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS pedidos (
    pedido_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cliente_id VARCHAR(120) NOT NULL,
    direccion VARCHAR(255) NOT NULL,
    gps_lat NUMERIC(9, 6) NOT NULL,
    gps_lon NUMERIC(9, 6) NOT NULL,
    peso NUMERIC(10, 2) NOT NULL,
    volumen NUMERIC(10, 2) NOT NULL,
    ventana_inicio VARCHAR(5) NOT NULL,
    ventana_fin VARCHAR(5) NOT NULL,
    prioridad VARCHAR(20) NOT NULL,
    tipo_producto VARCHAR(20) NOT NULL,
    estado VARCHAR(20) NOT NULL DEFAULT 'PENDIENTE',
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_pedidos_gps_lat CHECK (gps_lat BETWEEN -90 AND 90),
    CONSTRAINT chk_pedidos_gps_lon CHECK (gps_lon BETWEEN -180 AND 180),
    CONSTRAINT chk_pedidos_peso CHECK (peso > 0),
    CONSTRAINT chk_pedidos_volumen CHECK (volumen > 0),
    CONSTRAINT chk_pedidos_ventana_orden CHECK (ventana_fin > ventana_inicio),
    CONSTRAINT chk_pedidos_prioridad CHECK (prioridad IN ('EXPRESS', 'ESTANDAR', 'ECONOMICO')),
    CONSTRAINT chk_pedidos_tipo_producto CHECK (tipo_producto IN ('PERECEDERO', 'NO_PERECEDERO')),
    CONSTRAINT chk_pedidos_estado CHECK (estado IN ('PENDIENTE', 'EN_RUTA', 'ENTREGADO', 'CANCELADO'))
);

CREATE INDEX IF NOT EXISTS idx_pedidos_cliente ON pedidos (cliente_id);
CREATE INDEX IF NOT EXISTS idx_pedidos_estado ON pedidos (estado);
CREATE INDEX IF NOT EXISTS idx_pedidos_ventana ON pedidos (ventana_inicio, ventana_fin);

-- =============================================================================
-- TABLAS DEL ROADMAP (Objetivo futuro - DOC-011)
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 6. TABLA: clientes (Módulo de Clientes - DOC-024)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS clientes (
    cliente_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre VARCHAR(150) NOT NULL,
    direccion VARCHAR(200) NOT NULL,
    punto_referencia VARCHAR(200),
    telefono VARCHAR(20),
    contacto VARCHAR(100),
    gps_lat NUMERIC(10, 7),
    gps_lon NUMERIC(10, 7),
    ventana_inicio_preferida VARCHAR(5),
    ventana_fin_preferida VARCHAR(5),
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    creado_en TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_clientes_activo ON clientes(activo);

-- -----------------------------------------------------------------------------
-- 7. TABLA: rutas (Roadmap RF-003 / EN-002)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS rutas (
    ruta_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    fecha DATE NOT NULL,
    conductor_id UUID NOT NULL REFERENCES conductores(conductor_id),
    vehiculo_id UUID NOT NULL REFERENCES vehiculos(vehiculo_id),
    distancia_km NUMERIC(10, 2) NOT NULL DEFAULT 0,
    co2_kg NUMERIC(10, 2) NOT NULL DEFAULT 0,
    combustible_l NUMERIC(10, 2) NOT NULL DEFAULT 0,
    estado VARCHAR(20) NOT NULL DEFAULT 'PLANIFICADA',
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_rutas_estado CHECK (estado IN ('PLANIFICADA', 'EN_PROGRESO', 'COMPLETADA', 'CANCELADA', 'REOPTIMIZADA'))
);

CREATE INDEX IF NOT EXISTS idx_rutas_fecha ON rutas(fecha);
CREATE INDEX IF NOT EXISTS idx_rutas_conductor ON rutas(conductor_id);
CREATE INDEX IF NOT EXISTS idx_rutas_vehiculo ON rutas(vehiculo_id);

-- -----------------------------------------------------------------------------
-- 8. TABLA: ruta_pedidos (Roadmap RF-003)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ruta_pedidos (
    ruta_id UUID NOT NULL REFERENCES rutas(ruta_id) ON DELETE CASCADE,
    pedido_id UUID NOT NULL REFERENCES pedidos(pedido_id) ON DELETE CASCADE,
    orden INT NOT NULL,
    hora_estimada TIME,
    cumplio_ventana BOOLEAN,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (ruta_id, pedido_id)
);

CREATE INDEX IF NOT EXISTS idx_ruta_pedidos_ruta ON ruta_pedidos(ruta_id);
CREATE INDEX IF NOT EXISTS idx_ruta_pedidos_pedido ON ruta_pedidos(pedido_id);

-- -----------------------------------------------------------------------------
-- 9. TABLA: auditoria (Auditoría del Sistema - Sprint 3)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS auditoria (
    auditoria_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    usuario VARCHAR(100),
    accion VARCHAR(100) NOT NULL,
    entidad VARCHAR(100) NOT NULL,
    entidad_id VARCHAR(100),
    detalles TEXT,
    ip_origen VARCHAR(45),
    fecha_hora TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_auditoria_fecha ON auditoria(fecha_hora);

