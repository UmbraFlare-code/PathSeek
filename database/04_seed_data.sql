-- =============================================================================
-- PATHSEEK - SCRIPT DE DATOS DE PRUEBA / SEMILLA (SEED DATA)
-- Motor: PostgreSQL 16+
-- Descripción: Carga de datos iniciales para desarrollo y pruebas en Huancayo.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. USUARIOS INICIALES (Contraseña por defecto: Admin123! hashed en BCrypt)
-- -----------------------------------------------------------------------------
INSERT INTO usuarios (usuario_id, nombre, email, password_hash, rol, activo) VALUES
('11111111-1111-1111-1111-111111111111', 'Administrador Principal', 'admin@pathseek.pe', '$2a$10$76dYqQdF/8lHkF1aV.X72O1.A2m/o.1yN/Zp4Z.sQ7v.4vN/Zp4Z.', 'ADMIN', TRUE),
('22222222-2222-2222-2222-222222222222', 'Operador Logístico UGEL', 'operador@pathseek.pe', '$2a$10$76dYqQdF/8lHkF1aV.X72O1.A2m/o.1yN/Zp4Z.sQ7v.4vN/Zp4Z.', 'OPERADOR', TRUE),
('33333333-3333-3333-3333-333333333333', 'Conductor Juan Pérez', 'juan.perez@pathseek.pe', '$2a$10$76dYqQdF/8lHkF1aV.X72O1.A2m/o.1yN/Zp4Z.sQ7v.4vN/Zp4Z.', 'CONDUCTOR', TRUE)
ON CONFLICT (email) DO NOTHING;

-- -----------------------------------------------------------------------------
-- 2. VEHICULOS INICIALES (Flota UGEL Huancayo)
-- -----------------------------------------------------------------------------
INSERT INTO vehiculos (vehiculo_id, placa, tipo, capacidad_kg, capacidad_m3, consumo_km_l, factor_emision, anio, restriccion_placa_digito) VALUES
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'W1A-100', 'FURGON', 2500.00, 15.00, 8.50, 0.2650, 2022, 0),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', 'W2B-200', 'CAMIONETA', 1000.00, 6.00, 11.20, 0.1980, 2021, 2),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a33', 'W3C-300', 'MOTO', 150.00, 0.80, 35.00, 0.0620, 2023, NULL)
ON CONFLICT (placa) DO NOTHING;

-- -----------------------------------------------------------------------------
-- 3. CONDUCTORES INICIALES
-- -----------------------------------------------------------------------------
INSERT INTO conductores (conductor_id, usuario_id, dni, nombre, licencia, categoria, experiencia, disponible, contacto) VALUES
('b0eebc99-9c0b-4ef8-bb6d-6bb9bd380b11', '33333333-3333-3333-3333-333333333333', '45891234', 'Juan Pérez Gómez', 'Q45891234', 'AIII', 8, TRUE, '+51 964123456'),
('b0eebc99-9c0b-4ef8-bb6d-6bb9bd380b22', NULL, '71234567', 'Carlos Mendoza Ramos', 'Q71234567', 'AII', 4, TRUE, '+51 954789012')
ON CONFLICT (dni) DO NOTHING;

-- -----------------------------------------------------------------------------
-- 4. PEDIDOS INICIALES (Entregas en Huancayo)
-- -----------------------------------------------------------------------------
INSERT INTO pedidos (pedido_id, cliente_id, direccion, gps_lat, gps_lon, peso, volumen, ventana_inicio, ventana_fin, prioridad, tipo_producto, estado) VALUES
('c0eebc99-9c0b-4ef8-bb6d-6bb9bd380c11', 'IE-SAN-CARLOS', 'Av. Ferrocarril 450, Huancayo', -12.065400, -75.204800, 350.00, 2.50, '08:00', '11:00', 'EXPRESS', 'NO_PERECEDERO', 'PENDIENTE'),
('c0eebc99-9c0b-4ef8-bb6d-6bb9bd380c22', 'IE-MARISCAL-CASTILLA', 'Jr. Real 1250, El Tambo', -12.052100, -75.213200, 180.00, 1.20, '09:00', '13:00', 'ESTANDAR', 'PERECEDERO', 'PENDIENTE'),
('c0eebc99-9c0b-4ef8-bb6d-6bb9bd380c33', 'IE-ENRIQUE-GUZMAN', 'Av. Giraldez 310, Huancayo', -12.068900, -75.208900, 75.00, 0.50, '14:00', '17:00', 'ECONOMICO', 'NO_PERECEDERO', 'PENDIENTE')
ON CONFLICT (pedido_id) DO NOTHING;
