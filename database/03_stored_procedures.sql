-- =============================================================================
-- PATHSEEK - SCRIPT DE PROCEDIMIENTOS ALMACENADOS Y FUNCIONES (SP)
-- Motor: PostgreSQL 16+
-- Descripción: Procedimientos almacenados y funciones PL/pgSQL para la lógica
--              de negocio consumible desde el Backend Spring Boot.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. PROCEDIMIENTO: sp_registrar_pedido
-- Descripción: Registra un pedido aplicando validaciones de ventana horaria y GPS.
-- Retorna: UUID del pedido recién creado.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION sp_registrar_pedido(
    p_cliente_id VARCHAR(120),
    p_direccion VARCHAR(255),
    p_gps_lat NUMERIC(9, 6),
    p_gps_lon NUMERIC(9, 6),
    p_peso NUMERIC(10, 2),
    p_volumen NUMERIC(10, 2),
    p_ventana_inicio VARCHAR(5),
    p_ventana_fin VARCHAR(5),
    p_prioridad VARCHAR(20),
    p_tipo_producto VARCHAR(20)
)
RETURNS UUID AS $$
DECLARE
    v_new_id UUID;
BEGIN
    -- Validaciones de entrada
    IF p_ventana_fin <= p_ventana_inicio THEN
        RAISE EXCEPTION 'INVALID_ORDER_WINDOW: La hora fin (%s) debe ser posterior a la hora inicio (%s)', 
            p_ventana_fin, p_ventana_inicio USING ERRCODE = '22023';
    END IF;

    IF p_gps_lat < -90 OR p_gps_lat > 90 OR p_gps_lon < -180 OR p_gps_lon > 180 THEN
        RAISE EXCEPTION 'INVALID_COORDINATES: Las coordenadas GPS están fuera de rango válido' USING ERRCODE = '22023';
    END IF;

    IF p_peso <= 0 OR p_volumen <= 0 THEN
        RAISE EXCEPTION 'INVALID_DIMENSIONS: Peso y volumen deben ser mayores a cero' USING ERRCODE = '22023';
    END IF;

    v_new_id := gen_random_uuid();

    INSERT INTO pedidos (
        pedido_id, cliente_id, direccion, gps_lat, gps_lon, 
        peso, volumen, ventana_inicio, ventana_fin, 
        prioridad, tipo_producto, estado
    ) VALUES (
        v_new_id, p_cliente_id, p_direccion, p_gps_lat, p_gps_lon,
        p_peso, p_volumen, p_ventana_inicio, p_ventana_fin,
        p_prioridad, p_tipo_producto, 'PENDIENTE'
    );

    RETURN v_new_id;
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------------------------------------
-- 2. PROCEDIMIENTO: sp_bloquear_usuario_intentos (Regla RN-001)
-- Descripción: Incrementa el contador de intentos fallidos. Al 3er intento fallido
--              bloquea la cuenta por 15 minutos.
-- Retorna: BOOLEAN (true si la cuenta quedó bloqueada).
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION sp_bloquear_usuario_intentos(
    p_usuario_id UUID
)
RETURNS BOOLEAN AS $$
DECLARE
    v_intentos INT;
    v_bloqueado BOOLEAN := FALSE;
BEGIN
    UPDATE usuarios 
    SET intentos_fallidos = intentos_fallidos + 1,
        bloqueado_hasta = CASE 
            WHEN intentos_fallidos + 1 >= 3 THEN CURRENT_TIMESTAMP + INTERVAL '15 minutes'
            ELSE bloqueado_hasta
        END
    WHERE usuario_id = p_usuario_id
    RETURNING intentos_fallidos, (bloqueado_hasta IS NOT NULL AND bloqueado_hasta > CURRENT_TIMESTAMP)
    INTO v_intentos, v_bloqueado;

    RETURN v_bloqueado;
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------------------------------------
-- 3. PROCEDIMIENTO: sp_limpiar_tokens_expirados
-- Descripción: Limpia los refresh tokens caducados o revocados.
-- Retorna: INT (cantidad de filas eliminadas).
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION sp_limpiar_tokens_expirados()
RETURNS INT AS $$
DECLARE
    v_count INT;
BEGIN
    DELETE FROM refresh_tokens
    WHERE expires_at < CURRENT_TIMESTAMP OR revoked_at IS NOT NULL;
    
    GET DIAGNOSTICS v_count = ROW_COUNT;
    RETURN v_count;
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------------------------------------
-- 4. FUNCION: sp_obtener_resumen_dashboard (RF-005)
-- Descripción: Devuelve métricas consolidadas en formato JSON para el dashboard.
-- Retorna: JSON conteniendo conteos y métricas agregadas.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION sp_obtener_resumen_dashboard()
RETURNS JSON AS $$
DECLARE
    v_resumen JSON;
BEGIN
    SELECT json_build_object(
        'total_vehiculos', (SELECT COUNT(*) FROM vehiculos),
        'conductores_disponibles', (SELECT COUNT(*) FROM conductores WHERE disponible = TRUE),
        'pedidos_pendientes', (SELECT COUNT(*) FROM pedidos WHERE estado = 'PENDIENTE'),
        'pedidos_en_ruta', (SELECT COUNT(*) FROM pedidos WHERE estado = 'EN_RUTA'),
        'pedidos_entregados', (SELECT COUNT(*) FROM pedidos WHERE estado = 'ENTREGADO'),
        'pedidos_cancelados', (SELECT COUNT(*) FROM pedidos WHERE estado = 'CANCELADO'),
        'rutas_planificadas', (SELECT COUNT(*) FROM rutas WHERE estado = 'PLANIFICADA'),
        'co2_total_kg', COALESCE((SELECT SUM(co2_kg) FROM rutas), 0.00),
        'combustible_total_l', COALESCE((SELECT SUM(combustible_l) FROM rutas), 0.00)
    ) INTO v_resumen;

    RETURN v_resumen;
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------------------------------------
-- 5. FUNCION: sp_obtener_pedidos_pendientes_optimizador (RF-003)
-- Descripción: Obtiene todos los pedidos pendientes ordenados por prioridad 
--              y ventana de inicio para el algoritmo de optimización.
-- Retorna: TABLA de pedidos elegibles para ruteo.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION sp_obtener_pedidos_pendientes_optimizador()
RETURNS TABLE (
    pedido_id UUID,
    cliente_id VARCHAR(120),
    direccion VARCHAR(255),
    gps_lat NUMERIC(9, 6),
    gps_lon NUMERIC(9, 6),
    peso NUMERIC(10, 2),
    volumen NUMERIC(10, 2),
    ventana_inicio VARCHAR(5),
    ventana_fin VARCHAR(5),
    prioridad VARCHAR(20),
    tipo_producto VARCHAR(20)
) AS $$
BEGIN
    RETURN QUERY
    SELECT p.pedido_id, p.cliente_id, p.direccion, p.gps_lat, p.gps_lon,
           p.peso, p.volumen, p.ventana_inicio, p.ventana_fin,
           p.prioridad, p.tipo_producto
    FROM pedidos p
    WHERE p.estado = 'PENDIENTE'
    ORDER BY 
        CASE p.prioridad 
            WHEN 'EXPRESS' THEN 1 
            WHEN 'ESTANDAR' THEN 2 
            WHEN 'ECONOMICO' THEN 3 
            ELSE 4 
        END,
        p.ventana_inicio ASC;
END;
$$ LANGUAGE plpgsql;
