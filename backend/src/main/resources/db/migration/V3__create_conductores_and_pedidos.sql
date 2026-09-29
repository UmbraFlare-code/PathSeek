CREATE TABLE conductores (
    conductor_id UUID PRIMARY KEY,
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

CREATE TABLE pedidos (
    pedido_id UUID PRIMARY KEY,
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

CREATE INDEX idx_pedidos_cliente ON pedidos (cliente_id);
CREATE INDEX idx_pedidos_estado ON pedidos (estado);
