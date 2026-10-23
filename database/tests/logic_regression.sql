-- Ejecutar tras 01_schema_tablas.sql y 02_triggers.sql dentro de una transacción
-- y un esquema aislado. El ejecutor debe terminar con ROLLBACK.
DO $$
DECLARE
    user_id UUID := gen_random_uuid();
BEGIN
    INSERT INTO usuarios(usuario_id,nombre,email,password_hash,rol)
    VALUES(user_id,'Prueba','review@pathseek.test','hash-de-prueba','ADMIN');
    DELETE FROM usuarios WHERE usuario_id=user_id;
    IF NOT EXISTS(SELECT 1 FROM auditoria WHERE accion='ELIMINAR_USUARIO') THEN
        RAISE EXCEPTION 'No se auditó la eliminación';
    END IF;

    INSERT INTO pedidos(cliente_id,direccion,gps_lat,gps_lon,peso,volumen,ventana_inicio,ventana_fin,prioridad,tipo_producto)
    VALUES('review','Entrega',-12.06,-75.21,1,1,'08:00','12:00','ESTANDAR','NO_PERECEDERO');
    BEGIN
        INSERT INTO pedidos(cliente_id,direccion,gps_lat,gps_lon,peso,volumen,ventana_inicio,ventana_fin,prioridad,tipo_producto)
        VALUES('review','Entrega',-12.06,-75.21,1,1,'08:00','12:00','ESTANDAR','NO_PERECEDERO');
        RAISE EXCEPTION 'Se aceptó un pedido activo duplicado';
    EXCEPTION WHEN unique_violation THEN
        NULL;
    END;
    INSERT INTO pedidos(cliente_id,direccion,gps_lat,gps_lon,peso,volumen,ventana_inicio,ventana_fin,prioridad,tipo_producto)
    VALUES('review','Entrega',-12.06,-75.21,1,1,'08:00','13:00','ESTANDAR','NO_PERECEDERO');
    UPDATE pedidos SET estado='ENTREGADO' WHERE cliente_id='review';
    INSERT INTO pedidos(cliente_id,direccion,gps_lat,gps_lon,peso,volumen,ventana_inicio,ventana_fin,prioridad,tipo_producto)
    VALUES('review','Entrega',-12.06,-75.21,1,1,'08:00','12:00','ESTANDAR','NO_PERECEDERO');
    INSERT INTO pedidos(cliente_id,direccion,gps_lat,gps_lon,peso,volumen,ventana_inicio,ventana_fin,prioridad,tipo_producto,estado)
    VALUES('review','Entrega',-12.06,-75.21,1,1,'08:00','12:00','ESTANDAR','NO_PERECEDERO','CANCELADO');
END;
$$;
