-- Ejecutar con psql en una base con los paquetes de PostGIS instalados.
-- Flujos de rutas existentes siguen utilizando sus coordenadas numéricas.
BEGIN;

CREATE EXTENSION IF NOT EXISTS postgis;

CREATE INDEX IF NOT EXISTS idx_pedidos_gps_geography
    ON pedidos USING gist ((ST_SetSRID(ST_MakePoint(gps_lon, gps_lat), 4326)::geography));

COMMIT;
