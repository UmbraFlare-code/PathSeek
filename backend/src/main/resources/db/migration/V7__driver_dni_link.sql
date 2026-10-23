ALTER TABLE usuarios ADD COLUMN IF NOT EXISTS dni VARCHAR(8);
UPDATE usuarios u SET dni = d.dni FROM conductores d
WHERE d.usuario_id = u.usuario_id AND u.dni IS NULL;
CREATE UNIQUE INDEX IF NOT EXISTS uq_usuarios_dni ON usuarios(dni) WHERE dni IS NOT NULL;
