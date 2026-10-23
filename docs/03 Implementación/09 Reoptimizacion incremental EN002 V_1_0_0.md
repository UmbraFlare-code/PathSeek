# Reoptimización incremental de rutas — EN-002 / US-006

Fecha: 2026-10-22. Implementación backend de RF-007, vinculada a la historia y al requisito EN-002 de `02 Planificación/01 Transformando a ágil V_1_1_0.md`. Este documento registra el alcance implementado; no cambia el estado histórico de los sprints.

## Comportamiento

`POST /api/v1/rutas/reoptimizar` procesa eventos `NUEVOS_PEDIDOS`, `CANCELACION`, `INCIDENTE` y `AVERIA`. Requiere un JWT de `ADMIN` u `OPERADOR`.

- Examina un ámbito acotado y conserva las rutas que no necesitan cambios; no llama a la generación global.
- Reutiliza las asignaciones existentes, preserva las entregas realizadas y modifica solamente la secuencia pendiente, sus ETA y los totales estimados.
- Respeta capacidad en kg y m³, prioridad EXPRESS → ESTANDAR → ECONOMICO y ventanas de entrega. Mantiene las reglas actuales: salida del depósito a las 08:00, velocidad estimada de 25 km/h, mínimo de 5 minutos por tramo y 15 minutos por parada. Cuando la hora actual supera la salida, utiliza la hora actual.
- Inserta pedidos nuevos únicamente en rutas `PLANIFICADA`; los que no caben o no cumplen ventanas quedan pendientes y aparecen en `pedidos_no_asignados`. No supone que un vehículo que ya circula puede recoger carga nueva.
- Una ruta `EN_PROGRESO` requiere su posición actual y fecha de hoy. Sus entregas completadas deben formar un prefijo. Congela ese prefijo, incluidos orden, ETA y consumo/emisiones estimados; conserva el acumulado entre eventos, incluso al cambiar de vehículo.
- Una avería requiere un vehículo sustituto libre y sin avería activa. El llamador confirma previamente el relevo operativo y la transferencia de carga: no existe un modelo de recogida o transbordo. La ruta conserva su identificador y conductor.
- Las zonas de incidentes persisten y se excluyen de los segmentos pendientes, incluido el regreso al depósito. Si no se encuentra una secuencia factible, responde `409 REOPTIMIZATION_INFEASIBLE` y revierte el evento completo.
- No aplica la restricción por último dígito de placa: continúa pendiente según la decisión del usuario.

El cálculo usa la distancia existente (haversine × 1,35) y segmentos geométricos. La respuesta identifica `modelo_distancia: ESTIMADO_SIN_RED_VIAL`. No hay proveedor vial, tráfico en tiempo real ni cálculo de desvíos por calles; un incidente que requiere esos datos puede resultar infactible en este modelo.

## Contrato y ejemplos

Todos los ejemplos requieren reemplazar los UUID por entidades reales de un entorno de prueba y enviar `Authorization: Bearer <token>` y `Content-Type: application/json`.

Nuevo pedido en una ruta planificada:

```json
{
  "evento_id": "10000000-0000-4000-8000-000000000001",
  "tipo": "NUEVOS_PEDIDOS",
  "fecha": "2026-10-22",
  "rutas_ids": ["20000000-0000-4000-8000-000000000001"],
  "pedidos_ids": ["30000000-0000-4000-8000-000000000001"]
}
```

Cancelar un pedido en una ruta en progreso:

```json
{
  "evento_id": "10000000-0000-4000-8000-000000000002",
  "tipo": "CANCELACION",
  "rutas_ids": ["20000000-0000-4000-8000-000000000001"],
  "pedidos_ids": ["30000000-0000-4000-8000-000000000001"],
  "posiciones": [{
    "ruta_id": "20000000-0000-4000-8000-000000000001",
    "lat": -12.065,
    "lon": -75.205
  }]
}
```

Reportar un incidente y reoptimizar atómicamente:

```json
{
  "evento_id": "10000000-0000-4000-8000-000000000003",
  "tipo": "INCIDENTE",
  "rutas_ids": ["20000000-0000-4000-8000-000000000001"],
  "incidente": {
    "tipo": "BLOQUEO",
    "descripcion": "Bloqueo reportado por operaciones",
    "lat": -12.065,
    "lon": -75.205,
    "radioAfectacionMetros": 250
  }
}
```

Para una avería, enviar `tipo: AVERIA`, `vehiculo_id`, `vehiculo_sustituto_id` y, si la ruta está en progreso, `posiciones`. No enviar `pedidos_ids`. Para recalcular por incidentes ya registrados, usar `tipo: INCIDENTE` sin `incidente` y seleccionar rutas que tengan incidentes activos.

`fecha` es opcional y toma hoy en `America/Lima`. Sin `rutas_ids`, se infiere el ámbito: rutas planificadas de la fecha para nuevos pedidos; rutas activas que contienen los pedidos para cancelaciones; rutas activas del vehículo para averías; rutas activas de la fecha para incidentes. Conviene indicar el ámbito para reducir contención. Todas las rutas seleccionadas deben estar activas y corresponder a la fecha. Cancelación y avería deben incluir todas las rutas afectadas. Una posición solo puede pertenecer a una ruta del ámbito; proporcionar posición para cada ruta en progreso seleccionada.

La respuesta contiene:

| Campo | Significado |
| --- | --- |
| `evento_id`, `tipo` | Identidad del evento procesado |
| `rutas_reoptimizadas` | DTO de las rutas modificadas, con el contrato existente |
| `rutas_sin_cambios` | UUID del resto del ámbito |
| `pedidos_no_asignados` | Pedidos nuevos que permanecen pendientes |
| `notificaciones_generadas` | Avisos persistidos con cuenta de conductor destinataria |
| `conductores_sin_usuario` | Rutas actualizadas cuyo conductor no tiene cuenta vinculada |
| `tiempo_calculo_ms` | Tiempo interno hasta construir la respuesta; no incluye commit ni red |
| `horario_punta` | Inicio del evento en 07:00–09:00 o 17:00–20:00, `America/Lima`, fin excluyente |
| `modelo_distancia` | `ESTIMADO_SIN_RED_VIAL` |

La geometría existente incorpora un waypoint adicional `POSICION_ACTUAL` después del prefijo entregado cuando hay progreso confirmado. Es la última posición aceptada, no seguimiento en vivo. Se mantiene `encodedPolyline`, consumido actualmente por Flutter.

## Integración con eventos y avisos

El consumidor de eventos u operador debe invocar explícitamente `/reoptimizar`; el CRUD de pedidos y el registro antiguo de incidentes no disparan el recálculo automáticamente. La cancelación puede realizarse directamente mediante el evento, de modo que estado y recálculo sean atómicos.

| Método y ruta bajo `/api/v1/rutas` | Uso y permisos |
| --- | --- |
| `GET /notificaciones?pagina=0` | Hasta 100 avisos por página. CONDUCTOR ve solo los propios; ADMIN/OPERADOR/AUDITOR pueden consultar todos |
| `POST /notificaciones/{id}/leida` | CONDUCTOR reconoce únicamente su propio aviso; devuelve 204 |
| `GET /{id}/incidentes` | Lista incidentes activos, incluido `incidente_id`; conserva acceso por propiedad de ruta |
| `POST /{id}/incidentes/{incidenteId}/resolver` | ADMIN/OPERADOR desactiva el incidente; devuelve 204 |
| `POST /averias/{vehiculoId}` | ADMIN/OPERADOR registra avería física sin exigir recálculo factible; devuelve 204 |
| `POST /averias/{vehiculoId}/resolver` | ADMIN/OPERADOR rehabilita el vehículo; devuelve 204 |

Los avisos sobreviven reinicios y se crean en la misma transacción que el cambio de ruta. Son una bandeja de consulta HTTP: falta integrar su consulta en Flutter o un transporte push. Su persistencia no demuestra que el conductor los haya recibido. Registrar la avería física por separado permite excluir el vehículo aunque no exista un sustituto factible. El generador global también excluye los vehículos con avería activa.

## Integridad y presupuesto de ejecución

Un `evento_id` identifica una solicitud inmutable. Reintentar exactamente el mismo cuerpo devuelve la respuesta persistida, sin repetir cambios ni avisos. Reutilizarlo con otro contenido produce `409 EVENT_ID_REUSED`. Si hay conflicto concurrente, reintentar el mismo evento tras consultar el estado; no generar otro identificador para un reintento de transporte.

Se bloquean vehículos → rutas → pedidos en orden determinista y sin esperar por bloqueos de planificación. Los cambios de pedidos también bloquean la fila antes de escribir. Dos eventos no pueden asignar el mismo pedido simultáneamente. Los conflictos de bloqueo/timeout devuelven `409 PLANNING_BUSY`. Otros conflictos incluyen `ORDER_ALREADY_ASSIGNED`, `ORDER_ALREADY_DELIVERED`, `REPLACEMENT_UNAVAILABLE` y `INCOMPLETE_ROUTE_SCOPE`.

Valores predeterminados en `application.yml`:

| Configuración | Valor |
| --- | --- |
| `app.reoptimization.budget-ms` / `REOPTIMIZATION_BUDGET_MS` | 25000 ms; rango permitido 100–27000 |
| `app.reoptimization.max-routes` | 15 rutas por evento |
| `app.reoptimization.max-orders` | 300 pedidos existentes + entrantes; configurable hasta 500 |
| `app.reoptimization.iterations` | 200 intentos acotados de mejora por ruta |

El DTO admite hasta 150 pedidos entrantes. Un ámbito mayor se rechaza; debe dividirse por rutas independientes. La caché de distancias vive solo durante el evento. La mejora opcional se detiene al consumir el 90 % del presupuesto; el chequeo de plazo aborta con `409 REOPTIMIZATION_TIMEOUT` y rollback. La transacción tiene timeout de 28 s. Se reserva margen para persistencia y respuesta frente al objetivo de 30 s; esto no constituye una garantía bajo saturación del pool, fallos de infraestructura o latencia de red.

El log `reoptimization` mide el servicio y su flush; `reoptimization_http` incluye commit y serialización del handler. La medición desde un cliente externo añade filtros, cola y red. Los logs no incluyen JWT ni datos de pedidos/conductores.

## Instalación y Docker

La migración aditiva es `database/05_incremental_reoptimization.sql`: crea eventos idempotentes, incidentes, averías, progreso y avisos. No elimina datos. En una base nueva, Compose ejecuta los scripts 01–05 automáticamente. En un volumen existente se debe aplicar 05 **antes** de iniciar el backend actualizado, porque JPA valida el esquema y Flyway sigue desactivado.

Desde la raíz del repositorio, con Docker Desktop iniciado y el servicio PostgreSQL disponible:

```powershell
Get-Content -Raw .\database\05_incremental_reoptimization.sql |
  docker compose exec -T postgres sh -c 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -v ON_ERROR_STOP=1'
docker compose up --build -d backend
```

Para PostgreSQL nativo, usar `psql -h <host> -p <puerto> -U <usuario> -d <base> -v ON_ERROR_STOP=1 -f .\database\05_incremental_reoptimization.sql` y reiniciar el backend con su configuración habitual. La migración puede ejecutarse de nuevo; no es necesario borrar el volumen.

## Verificación y evidencia

Resultados locales del 2026-10-22:

- Suite completa H2: **89 pruebas, 0 fallos, 0 errores**.
- Suite específica con PostgreSQL **17.11**, esquema real 01–05, triggers activos y `ddl-auto=validate`: **22 pruebas, 0 fallos, 0 errores**. Base temporal aislada; no se utilizaron datos de la aplicación.
- Migración 05 aplicada dos veces correctamente sobre ese esquema PostgreSQL.
- Herramienta de medición: **3 pruebas Python aprobadas**.

Las pruebas cubren idempotencia, concurrencia, rollback, capacidades, prioridades, ventanas, cancelación, incidentes, sustitución de vehículo, exclusión de averiados, progreso congelado, permisos y propiedad de avisos.

Los dos escenarios de carga usan reloj de negocio a las 07:30 y 17:30 de Lima, con 150 pedidos ya asignados a 15 vehículos y 5 pedidos nuevos. En cada caso se modifica una ruta y se conservan las otras 14. Tiempo completo local medido por MockMvc (sin red externa):

| Motor | 07:30 | 17:30 |
| --- | --- | --- |
| H2 | 287,75 ms | 94,69 ms |
| PostgreSQL 17.11 | 548,57 ms | 101,46 ms |

Son muestras locales, no un p95 de producción. Los escenarios verifican `< 30000 ms` y generan `backend/target/reoptimization-benchmark-*.json`. El workflow `.github/workflows/reoptimization-check.yml` deja preparadas regresiones H2 y PostgreSQL 16 con artefactos; su ejecución remota queda pendiente.

Ejecutar desde `backend/`:

```powershell
.\mvnw.cmd test
python -m unittest discover -s tools -p 'test_*.py'
```

### Medir HTTP real en staging

`backend/tools/benchmark_reoptimization.py` usa únicamente la biblioteca estándar de Python. Se ejecuta contra un entorno de prueba dedicado porque **modifica rutas y pedidos**. Preparar un archivo JSON con un array de eventos independientes y pedidos/rutas frescos; repetir un pedido ya asignado debe fallar, no contar como recálculo válido.

Desde `backend/`, con JWT de ADMIN/OPERADOR del entorno de prueba:

```powershell
$env:PATHSEEK_BENCH_TOKEN = '<JWT del entorno de prueba>'
python tools/benchmark_reoptimization.py --base-url https://staging.example.test --events target/eventos-prueba.json --concurrency 4 --output target/reoptimization-staging.json
Remove-Item Env:PATHSEEK_BENCH_TOKEN
```

El script asigna un UUID nuevo a cada evento para evitar medir replays, mide respuesta HTTP completa, calcula máximo y p95, exige al menos una ruta recalculada por muestra y termina con código 1 si alguna falla o tarda 30 s o más. No imprime el token. Eventos concurrentes deben afectar recursos independientes para medir capacidad; probar contención por separado y esperar conflictos 409.

Antes de dar EN-002 por validado en operación, ejecutar suficientes muestras con la concurrencia, infraestructura y datos representativos de ambas franjas punta y conectar la recepción de avisos por el conductor. La red vial, tráfico real, notificación push y verificación de disponibilidad/descansos del conductor requieren integración adicional.
