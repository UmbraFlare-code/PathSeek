-- =============================================================================
-- PATHSEEK - SEED DATA DEMO (UGEL HUANCAYO)
-- Motor: PostgreSQL 16+
-- =============================================================================

-- 1. USUARIOS (Password: Admin123! hashed en BCrypt)
INSERT INTO usuarios (usuario_id, nombre, email, password_hash, rol, activo) VALUES
('11111111-1111-1111-1111-111111111111', 'Administrador General', 'admin@pathseek.pe', '$2a$10$76dYqQdF/8lHkF1aV.X72O1.A2m/o.1yN/Zp4Z.sQ7v.4vN/Zp4Z.', 'ADMIN', TRUE),
('22222222-2222-2222-2222-222222222222', 'Operador Logística', 'operador@pathseek.pe', '$2a$10$76dYqQdF/8lHkF1aV.X72O1.A2m/o.1yN/Zp4Z.sQ7v.4vN/Zp4Z.', 'OPERADOR', TRUE),
('33333333-3333-3333-3333-333333333333', 'Juan Pérez Gómez', 'conductor.juan@pathseek.pe', '$2a$10$76dYqQdF/8lHkF1aV.X72O1.A2m/o.1yN/Zp4Z.sQ7v.4vN/Zp4Z.', 'CONDUCTOR', TRUE),
('44444444-4444-4444-4444-444444444444', 'UGEL Huancayo Recepción', 'cliente.ugel@pathseek.pe', '$2a$10$76dYqQdF/8lHkF1aV.X72O1.A2m/o.1yN/Zp4Z.sQ7v.4vN/Zp4Z.', 'CLIENTE', TRUE)
ON CONFLICT (email) DO NOTHING;

-- 2. VEHÍCULOS DE LA FLOTA UGEL HUANCAYO
INSERT INTO vehiculos (vehiculo_id, placa, tipo, capacidad_kg, capacidad_m3, consumo_km_l, factor_emision, anio, restriccion_placa_digito) VALUES
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'W1A-101', 'FURGON', 2500.00, 15.00, 8.50, 0.2650, 2022, 1),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', 'W2B-202', 'CAMIONETA', 1200.00, 7.50, 11.00, 0.1980, 2021, 2),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a33', 'W3C-303', 'MOTO', 150.00, 0.80, 35.00, 0.0620, 2023, 3),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a44', 'W4D-404', 'FURGON', 3000.00, 18.00, 7.80, 0.2800, 2023, 4),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a55', 'W5E-505', 'CAMIONETA', 1000.00, 6.00, 12.50, 0.1850, 2024, 5)
ON CONFLICT (placa) DO NOTHING;

-- 3. CONDUCTORES
INSERT INTO conductores (conductor_id, usuario_id, dni, nombre, licencia, categoria, experiencia, disponible, contacto) VALUES
('b0eebc99-9c0b-4ef8-bb6d-6bb9bd380b11', '33333333-3333-3333-3333-333333333333', '45891234', 'Juan Pérez Gómez', 'Q45891234', 'AIII', 8, TRUE, '+51 964123456'),
('b0eebc99-9c0b-4ef8-bb6d-6bb9bd380b22', NULL, '71234567', 'Carlos Mendoza Ramos', 'Q71234567', 'AII', 5, TRUE, '+51 954789012'),
('b0eebc99-9c0b-4ef8-bb6d-6bb9bd380b33', NULL, '48901234', 'Luis Quispe Aliaga', 'Q48901234', 'AIII', 10, TRUE, '+51 964987654'),
('b0eebc99-9c0b-4ef8-bb6d-6bb9bd380b44', NULL, '72345678', 'Mario Rojas Torres', 'Q72345678', 'AII', 3, FALSE, '+51 978123456')
ON CONFLICT (dni) DO NOTHING;

-- 4. PEDIDOS EN INSTITUCIONES EDUCATIVAS DE HUANCAYO
INSERT INTO pedidos (pedido_id, cliente_id, direccion, gps_lat, gps_lon, peso, volumen, ventana_inicio, ventana_fin, prioridad, tipo_producto, estado) VALUES
('c0eebc99-9c0b-4ef8-bb6d-6bb9bd380c11', 'IE-SAN-CARLOS', 'Av. Ferrocarril 450, Huancayo Centro', -12.065400, -75.204800, 350.00, 2.50, '08:00', '11:00', 'EXPRESS', 'NO_PERECEDERO', 'PENDIENTE'),
('c0eebc99-9c0b-4ef8-bb6d-6bb9bd380c22', 'IE-MARISCAL-CASTILLA', 'Jr. Real 1250, El Tambo', -12.052100, -75.213200, 180.00, 1.20, '09:00', '13:00', 'ESTANDAR', 'PERECEDERO', 'EN_RUTA'),
('c0eebc99-9c0b-4ef8-bb6d-6bb9bd380c33', 'IE-ENRIQUE-GUZMAN', 'Av. Giraldez 310, Huancayo', -12.068900, -75.208900, 75.00, 0.50, '14:00', '17:00', 'ECONOMICO', 'NO_PERECEDERO', 'PENDIENTE'),
('c0eebc99-9c0b-4ef8-bb6d-6bb9bd380c44', 'IE-JOSE-CARLOS-MARIATEGUI', 'Av. Huancavelica 890, Chilca', -12.081200, -75.215600, 420.00, 3.10, '08:30', '12:00', 'EXPRESS', 'NO_PERECEDERO', 'PENDIENTE'),
('c0eebc99-9c0b-4ef8-bb6d-6bb9bd380c55', 'IE-SANTA-ISABEL', 'Jr. Ayacucho 640, Huancayo', -12.063200, -75.207800, 210.00, 1.80, '10:00', '14:00', 'ESTANDAR', 'PERECEDERO', 'ENTREGADO'),
('c0eebc99-9c0b-4ef8-bb6d-6bb9bd380c66', 'IE-TUPAC-AMARU', 'Av. Esperanza 120, El Tambo', -12.048900, -75.218900, 95.00, 0.70, '13:00', '16:30', 'ECONOMICO', 'NO_PERECEDERO', 'PENDIENTE')
ON CONFLICT (pedido_id) DO NOTHING;
