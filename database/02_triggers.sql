-- =============================================================================
-- PATHSEEK - SCRIPT DE FUNCIONES DISPARADORAS Y TRIGGERS
-- Motor: PostgreSQL 16+
-- Descripción: Implementa triggers para auditoría, actualización automática 
--              de timestamps y validaciones de reglas de negocio a nivel BD.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. FUNCION DISPARADORA: Actualización Automática de Timestamp updated_at
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers de timestamp para tablas principales
DROP TRIGGER IF EXISTS trg_vehiculos_updated_at ON vehiculos;
CREATE TRIGGER trg_vehiculos_updated_at
    BEFORE UPDATE ON vehiculos
    FOR EACH ROW
    EXECUTE FUNCTION fn_update_timestamp();

DROP TRIGGER IF EXISTS trg_usuarios_updated_at ON usuarios;
CREATE TRIGGER trg_usuarios_updated_at
    BEFORE UPDATE ON usuarios
    FOR EACH ROW
    EXECUTE FUNCTION fn_update_timestamp();

DROP TRIGGER IF EXISTS trg_conductores_updated_at ON conductores;
CREATE TRIGGER trg_conductores_updated_at
    BEFORE UPDATE ON conductores
    FOR EACH ROW
    EXECUTE FUNCTION fn_update_timestamp();

DROP TRIGGER IF EXISTS trg_pedidos_updated_at ON pedidos;
CREATE TRIGGER trg_pedidos_updated_at
    BEFORE UPDATE ON pedidos
    FOR EACH ROW
    EXECUTE FUNCTION fn_update_timestamp();

DROP TRIGGER IF EXISTS trg_clientes_updated_at ON clientes;
CREATE TRIGGER trg_clientes_updated_at
    BEFORE UPDATE ON clientes
    FOR EACH ROW
    EXECUTE FUNCTION fn_update_timestamp();

DROP TRIGGER IF EXISTS trg_rutas_updated_at ON rutas;
CREATE TRIGGER trg_rutas_updated_at
    BEFORE UPDATE ON rutas
    FOR EACH ROW
    EXECUTE FUNCTION fn_update_timestamp();

-- -----------------------------------------------------------------------------
-- 2. FUNCION DISPARADORA: Auditoría de Usuarios
-- Regla: Registra en 'auditoria' cambios de estado, rol o accesos de usuario.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_audit_usuarios()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO auditoria (usuario, accion, entidad, entidad_id, detalles)
        VALUES (NEW.email, 'CREAR_USUARIO', 'usuarios', NEW.usuario_id::text,
                format('Usuario creado con email %s y rol %s', NEW.email, NEW.rol));
    ELSIF (TG_OP = 'UPDATE') THEN
        IF OLD.activo <> NEW.activo THEN
            INSERT INTO auditoria (usuario, accion, entidad, entidad_id, detalles)
            VALUES (NEW.email, 
                    CASE WHEN NEW.activo THEN 'ACTIVAR_USUARIO' ELSE 'DESACTIVAR_USUARIO' END, 
                    'usuarios', NEW.usuario_id::text,
                    format('Estado activo cambió de %s a %s', OLD.activo, NEW.activo));
        END IF;
        IF OLD.rol <> NEW.rol THEN
            INSERT INTO auditoria (usuario, accion, entidad, entidad_id, detalles)
            VALUES (NEW.email, 'CAMBIO_ROL', 'usuarios', NEW.usuario_id::text,
                    format('Rol modificado de %s a %s', OLD.rol, NEW.rol));
        END IF;
        IF OLD.bloqueado_hasta IS NULL AND NEW.bloqueado_hasta IS NOT NULL THEN
            INSERT INTO auditoria (usuario, accion, entidad, entidad_id, detalles)
            VALUES (NEW.email, 'BLOQUEO_CUENTA', 'usuarios', NEW.usuario_id::text,
                    format('Cuenta bloqueada hasta %s por intentos fallidos', NEW.bloqueado_hasta));
        END IF;
    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO auditoria (usuario, accion, entidad, entidad_id, detalles)
        VALUES (OLD.email, 'ELIMINAR_USUARIO', 'usuarios', OLD.usuario_id::text,
                format('Usuario con email %s fue eliminado', OLD.email));
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_audit_usuarios ON usuarios;
CREATE TRIGGER trg_audit_usuarios
    AFTER INSERT OR UPDATE OR DELETE ON usuarios
    FOR EACH ROW
    EXECUTE FUNCTION fn_audit_usuarios();

-- -----------------------------------------------------------------------------
-- 3. FUNCION DISPARADORA: Auditoría y Cambio de Estado de Pedidos
-- Regla: Registra transiciones de estado de pedidos (PENDIENTE -> EN_RUTA -> ENTREGADO).
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_audit_pedidos_estado()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO auditoria (usuario, accion, entidad, entidad_id, detalles)
        VALUES ('SISTEMA', 'CREAR_PEDIDO', 'pedidos', NEW.pedido_id::text,
                format('Pedido %s creado para cliente %s con prioridad %s', NEW.pedido_id, NEW.cliente_id, NEW.prioridad));
    ELSIF (TG_OP = 'UPDATE') THEN
        IF OLD.estado <> NEW.estado THEN
            INSERT INTO auditoria (usuario, accion, entidad, entidad_id, detalles)
            VALUES ('SISTEMA', 'CAMBIO_ESTADO_PEDIDO', 'pedidos', NEW.pedido_id::text,
                    format('Pedido %s cambió de estado %s a %s', NEW.pedido_id, OLD.estado, NEW.estado));
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_audit_pedidos_estado ON pedidos;
CREATE TRIGGER trg_audit_pedidos_estado
    AFTER INSERT OR UPDATE ON pedidos
    FOR EACH ROW
    EXECUTE FUNCTION fn_audit_pedidos_estado();

-- -----------------------------------------------------------------------------
-- 4. FUNCION DISPARADORA: Validación de Regla de Negocio RN-012
-- Regla: Evitar duplicado de pedido activo (mismo cliente_id + direccion + ventana_inicio)
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_validar_pedido_duplicado()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM pedidos 
        WHERE cliente_id = NEW.cliente_id 
          AND direccion = NEW.direccion 
          AND ventana_inicio = NEW.ventana_inicio
          AND estado IN ('PENDIENTE', 'EN_RUTA')
          AND (TG_OP = 'INSERT' OR pedido_id <> NEW.pedido_id)
    ) THEN
        RAISE EXCEPTION 'ORDER_DUPLICATE: Ya existe un pedido activo para el cliente % en la dirección % para el horario %', 
            NEW.cliente_id, NEW.direccion, NEW.ventana_inicio
            USING ERRCODE = '23505';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_validar_pedido_duplicado ON pedidos;
CREATE TRIGGER trg_validar_pedido_duplicado
    BEFORE INSERT OR UPDATE ON pedidos
    FOR EACH ROW
    EXECUTE FUNCTION fn_validar_pedido_duplicado();
