ALTER TABLE ruta_pedidos ADD COLUMN IF NOT EXISTS entregado_en TIMESTAMP WITH TIME ZONE;
ALTER TABLE rutas ADD COLUMN IF NOT EXISTS completada_en TIMESTAMP WITH TIME ZONE;
CREATE INDEX IF NOT EXISTS idx_rutas_estado_completada_en ON rutas (estado, completada_en);
