ALTER TABLE pedidos
    ADD COLUMN motivo_no_asignado VARCHAR(30);

ALTER TABLE pedidos
    ADD CONSTRAINT chk_pedidos_motivo CHECK (
        motivo_no_asignado IS NULL
        OR motivo_no_asignado IN ('VENTANA_INALCANZABLE', 'CAPACIDAD', 'RESTRICCION_PLACA')
    );
