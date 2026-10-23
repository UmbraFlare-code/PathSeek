-- Reparación puntual del administrador DEMO local: contraseña Admin123!.
-- Ejecutar únicamente en la base de desarrollo que tenga el seed original.
-- No modifica otras cuentas ni reemplaza contraseñas personalizadas.
UPDATE usuarios
SET password_hash = '$2a$10$5m7lxJwYnjj8NJY.KYpYlu7GUF8WcKx1jx.nzz0QwTZLxBBhBStxy',
    intentos_fallidos = 0,
    bloqueado_hasta = NULL
WHERE usuario_id = '11111111-1111-1111-1111-111111111111'
  AND email = 'admin@pathseek.pe'
  AND password_hash = '$2a$10$76dYqQdF/8lHkF1aV.X72O1.A2m/o.1yN/Zp4Z.sQ7v.4vN/Zp4Z.';
