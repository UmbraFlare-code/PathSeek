CREATE TABLE vehiculos (
    vehiculo_id UUID PRIMARY KEY,
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
