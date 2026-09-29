# Módulo de Base de Datos - PathSeek

Este directorio contiene los scripts SQL ordenados y estructurados para la creación, configuración y migración del esquema de base de datos PostgreSQL de la plataforma **PathSeek** (Optimizador de Rutas Sostenibles para UGEL Huancayo).

---

## 📁 Estructura del Directorio

```text
database/
├── 01_schema_tablas.sql       # DDL: Definición de tablas, llaves primarias, foráneas, restricciones CHECK e índices.
├── 02_triggers.sql            # Triggers: Timestamp automático (updated_at), auditoría de usuarios/pedidos y validación RN-012.
├── 03_stored_procedures.sql   # Procedimientos almacenados y funciones PL/pgSQL consumibles por el Backend Spring Boot.
├── 04_seed_data.sql           # Datos semilla de prueba (usuarios, vehículos, conductores y pedidos en Huancayo).
├── README.md                  # Manual de uso y documentación completa del módulo de base de datos.
└── PENDIENTES_BACKEND.md      # Guía de tareas pendientes e integración para los desarrolladores de Backend.
```

---

## 🚀 Orden de Ejecución

Para inicializar o reconstruir una base de datos local desde cero, ejecute los scripts en el siguiente orden secuencial:

### Opción 1: Mediante la CLI de PostgreSQL (`psql`)

```bash
# 1. Crear la base de datos (si no existe)
psql -U postgres -c "CREATE DATABASE pathseek;"

# 2. Ejecutar los scripts en orden
psql -U pathseek -d pathseek -f database/01_schema_tablas.sql
psql -U pathseek -d pathseek -f database/02_triggers.sql
psql -U pathseek -d pathseek -f database/03_stored_procedures.sql
psql -U pathseek -d pathseek -f database/04_seed_data.sql
```

### Opción 2: Mediante DBeaver / pgAdmin / GUI

Abre una ventana de script SQL conectada a la base de datos `pathseek` y ejecuta los archivos secuencialmente: `01_schema_tablas.sql` ➔ `02_triggers.sql` ➔ `03_stored_procedures.sql` ➔ `04_seed_data.sql`.

---

## 📊 Modelo de Datos (Resumen de Entidades)

### Tablas del MVP (Implementadas y mapeadas en Spring Boot):
- **`usuarios`**: Gestión de credenciales, roles (`ADMIN`, `OPERADOR`, `CONDUCTOR`, `CLIENTE`, `AUDITOR`) e intentos fallidos de login.
- **`refresh_tokens`**: Tokens de refresco rotativos asociados a usuarios con revocación y caducidad.
- **`vehiculos`**: Flota vehicular con placas, capacidades (`kg`, `m³`), consumos, factor de emisión de CO₂ y restricción de pico y placa.
- **`conductores`**: Registro de conductores con DNI, licencia (`AII`, `AIII`, `BII`, `BIII`), años de experiencia y disponibilidad.
- **`pedidos`**: Pedidos de entrega con coordenadas GPS (Huancayo), ventanas de tiempo `HH:mm`, peso, volumen, prioridad y estado.

### Tablas del Roadmap (Diseño futuro según DOC-011):
- **`clientes`**: Módulo ampliado de clientes y direcciones frecuentes (RF-009).
- **`rutas`**: Rutas calculadas por la metaheurística con distancia total, combustible consumido y CO₂ (RF-003).
- **`ruta_pedidos`**: Secuencia ordenada de entregas asignadas a una ruta.
- **`auditoria`**: Bitácora centralizada de eventos de seguridad y negocio.

---

## ⚙️ Procedimientos Almacenados y Funciones

| Función / Procedimiento | Parámetros | Tipo Retorno | Descripción |
| --- | --- | --- | --- |
| `sp_registrar_pedido` | `p_cliente_id`, `p_direccion`, `p_gps_lat`, `p_gps_lon`, `p_peso`, `p_volumen`, `p_ventana_inicio`, `p_ventana_fin`, `p_prioridad`, `p_tipo_producto` | `UUID` | Registra un nuevo pedido aplicando validaciones de ventana de tiempo y rangos GPS. |
| `sp_bloquear_usuario_intentos` | `p_usuario_id` | `BOOLEAN` | Incrementa los intentos fallidos. Al 3er intento, bloquea la cuenta por 15 minutos (RN-001). Retorna `true` si quedó bloqueado. |
| `sp_limpiar_tokens_expirados` | *Ninguno* | `INT` | Elimina refresh tokens caducados o revocados. Retorna la cantidad de tokens eliminados. |
| `sp_obtener_resumen_dashboard` | *Ninguno* | `JSON` | Devuelve métricas consolidadas (conteos por estado, total de CO₂ y combustible) para el dashboard (RF-005). |
| `sp_obtener_pedidos_pendientes_optimizador` | *Ninguno* | `TABLE(...)` | Retorna todos los pedidos en estado `PENDIENTE` ordenados por prioridad y horario para el motor de optimización (RF-003). |

---

## 🔔 Disparadores (Triggers) Configurados

1. **`trg_*_updated_at`**: Actualiza automáticamente la columna `updated_at = CURRENT_TIMESTAMP` antes de cada `UPDATE` en las tablas principales (`vehiculos`, `usuarios`, `conductores`, `pedidos`, `clientes`, `rutas`).
2. **`trg_audit_usuarios`**: Inserta registros en la tabla `auditoria` ante acciones de creación, eliminación, cambio de rol o bloqueo de usuarios.
3. **`trg_audit_pedidos_estado`**: Registra en `auditoria` las transiciones de estado de un pedido (`PENDIENTE` ➔ `EN_RUTA` ➔ `ENTREGADO`).
4. **`trg_validar_pedido_duplicado`**: Aplica la regla **RN-012**, impidiendo la inserción de un pedido en estado activo con el mismo `cliente_id`, `direccion` y `ventana_inicio`.

---

## 🛠️ Notas de Integración con Spring Boot

- Hibernate está configurado con `ddl-auto: validate`. Asegúrate de que las entidades JPA coincidan exactamente con la estructura de las tablas.
- Para llamar a los procedimientos almacenados desde JPA, revisa la guía adjunta [PENDIENTES_BACKEND.md](file:///home/umbraflare/PathSeek/database/PENDIENTES_BACKEND.md).
