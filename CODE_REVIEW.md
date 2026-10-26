# Revisión de código y lógica — 22 de octubre de 2026

Actualización posterior: el [seguimiento de mapa, rutas y permisos](docs/Sprint%203/06%20Continuidad%20mapa%20rutas%20y%20permisos%20V_1_0_0.md) implementa los filtros por propietario, la vista de rutas del conductor, el mapa geográfico y una metaheurística SA. Los pendientes de este informe describen el estado anterior a esa continuidad.

## Resultado

Se revisaron autenticación, renovación de tokens, autorización por rol, catálogos, pedidos, generación y eliminación de rutas, SQL, navegación y sincronización de la lista de rutas. Se corrigieron los fallos reproducibles descritos abajo. Esta revisión no certifica ausencia absoluta de errores ni cumplimiento completo del producto documentado.

Los cambios están en los fuentes del repositorio. No se reconstruyeron los contenedores ni se aplicaron nuevas reglas a los datos operativos durante esta revisión.

## Errores corregidos

| Prioridad | Fallo | Comportamiento corregido | Archivos principales |
| --- | --- | --- | --- |
| Alta | Generar rutas borraba todas las anteriores | Se conserva el historial y se excluyen recursos y pedidos de rutas activas | `RouteOptimizationService.java` |
| Alta | Se podían volver a planificar entregados, cancelados y pedidos en ruta | Solo participan pendientes sin asignación activa; los asignados pasan a `EN_RUTA` | `RouteOptimizationService.java` |
| Alta | Dos generaciones podían asignar los mismos recursos | Los planificadores se serializan mediante bloqueos de vehículos; los pedidos pendientes también se bloquean durante la asignación | Repositorios de vehículos y pedidos |
| Alta | Se ignoraban peso, volumen, disponibilidad y ventanas | Se comprueba capacidad acumulada, se usan conductores disponibles, se espera al inicio de ventana y se excluyen llegadas posteriores al fin | `RouteOptimizationService.java` |
| Alta | Eliminar rutas no liberaba los pedidos y permitía borrar historial completado | Solo se eliminan planificadas; sus pedidos en ruta vuelven a pendientes | `RouteOptimizationService.java` |
| Media | Java y PostgreSQL aplicaban diferentes reglas de duplicados | Pedido activo = PENDIENTE/EN_RUTA; coincidencia de cliente, dirección, inicio y fin. Entregados/cancelados no bloquean nuevas entregas | `OrderService.java`, `02_triggers.sql` |
| Alta | La comprobación SQL de duplicados permitía carreras entre inserciones | Índice único parcial para la ventana completa de pedidos activos | `02_triggers.sql` |
| Media | La auditoría de eliminación referenciaba al usuario ya eliminado | Auditoría con referencia nula y UUID del usuario en el detalle | `02_triggers.sql` |
| Media | Conflictos de integridad de datos acababan en 500 | Respuesta 409; los duplicados de pedidos se identifican como `ORDER_DUPLICATE` | `GlobalExceptionHandler.java` |
| Media | El frontend podía duplicar filas al combinar rutas | Combinación por identificador; una generación en curso ignora dobles eventos | `route_bloc.dart` |
| Media | El aviso de generación se repetía con cambios de estado no relacionados | El listener reacciona a un nuevo resultado o a un nuevo error | `route_list_page.dart` |
| Media | Un 401 retrasado podía volver a renovar un JWT ya renovado por otra petición | Se reutiliza el token nuevo y se comparte únicamente la renovación en curso | `api_client.dart` |
| Media | Recargar un enlace de edición sin `extra` abría un formulario de creación | Si falta el objeto correcto o su ID no coincide, se vuelve a la lista del módulo | `app_router.dart` |
| Media | Se aceptaban incidentes de rutas inexistentes, tipos desconocidos y coordenadas inválidas | Validación del DTO y comprobación de existencia; 400/404 según el caso | `RoadIncidentRequest.java`, `RouteController.java` |
| Media | El mapa de incidentes era concurrente, pero sus listas no | Listas seguras para concurrencia y devolución de copias | `RoutingContextService.java` |
| Media | Se anunciaba algoritmo genético y ahorros calculados como constantes por ruta | Se identifica la heurística implementada; ahorros devueltos como cero hasta disponer de una comparación medible | `RouteOptimizationService.java` |
| Baja | Fecha de planificación dependía de la zona horaria del servidor | Se usa el reloj inyectado y la zona `America/Lima`, correspondiente a Huancayo | `RouteOptimizationService.java` |

La heurística comprueba la hora de llegada; utiliza tiempos de viaje estimados y 15 minutos de servicio. No es un solucionador completo de VRPTW ni acredita una solución óptima. Las rutas activas ocupan sus recursos hasta su eliminación o cambio de estado, incluso si tienen una fecha anterior.

## Duplicaciones revisadas

- No se encontraron archivos de contenido idéntico entre `backend/src/main`, `frontend/lib` y `database` durante el escaneo por SHA-256.
- Sí existe estructura repetida en repositorios, datasources, mapeos y BLoCs CRUD. Cada módulo tiene entidades y reglas diferentes; no se fusionaron solo por su parecido. El desenvolvimiento JSON y el mapeo de errores podrían centralizarse posteriormente.
- Las validaciones Java y SQL son dos capas intencionales de integridad. Se alineó la regla de duplicados y se añadió una restricción real para concurrencia.
- Se retiró el método de ordenamiento antiguo, sustituido por la selección de entregas factibles, y la dependencia de repositorio sin uso en el planificador.
- Consulta de solo lectura en el PostgreSQL de Docker actual: **0 grupos de pedidos activos duplicados** por cliente, dirección y ventana completa. Esto no implica que no existan otros tipos de duplicados o diferencias semánticas en direcciones escritas de distinta manera.

## Pendientes confirmados

| Prioridad | Pendiente | Evidencia / límite |
| --- | --- | --- |
| Alta | Aislamiento de datos por usuario | CLIENTE puede listar/consultar todos los pedidos y enviar un `cliente_id` libre. La brecha ya está documentada en `docs/01 Inicio/08. Usuarios V_1_0_0.md`; requiere vincular la identidad autenticada con el cliente y migrar los datos existentes. |
| Alta | Lectura propia del conductor | Los GET de rutas permiten CONDUCTOR, pero el servicio no filtra por `Driver.usuarioId`; la UI todavía no ofrece ese módulo. Antes de habilitarlo, debe limitarse a sus rutas asignadas. |
| Media | Reglas completas de planificación | Faltan compatibilidad licencia/vehículo, restricciones de placa, jornada de conducción y un ciclo completo de estados de ruta. Los cálculos de tráfico, superficie y elevación son estimaciones. |
| Media | Persistencia de incidentes | Se guardan en memoria; se pierden al reiniciar y no se comparten entre instancias. No hay reoptimización real basada en incidentes. |
| Media | Sesión expirada en la interfaz | Si el refresh deja de ser válido, no existe una notificación central que limpie toda la sesión y redirija automáticamente al login. La restauración local tampoco verifica la sesión con el servidor. |
| Baja | Mensajes de conflictos de catálogos | Los métodos de guardado de conductor/vehículo traducen cualquier `DataIntegrityViolationException` como conflicto de DNI/placa. Una carrera por licencia puede producir un mensaje de DNI incorrecto. |
| Baja | Eficiencia de listados | Rutas incluyen pedidos y asociaciones; con muchos registros puede aparecer N+1. No hay paginación ni presupuesto de consultas medido. |

## Verificación

- Backend: **63 pruebas aprobadas**, incluidas concurrencia, conservación del historial, liberación de pedidos, disponibilidad, capacidades, ventanas, terminales excluidos, validación de incidentes y duplicados.
- Frontend: **204 pruebas aprobadas**, `flutter analyze` sin incidencias y compilación web release completada. Resultados registrados en `frontend/review-*-results.log` (archivos locales ignorados por Git).
- PostgreSQL 16 dentro de Docker: creación del esquema y triggers corregidos en un esquema aislado, ejecución de `database/tests/logic_regression.sql` y `ROLLBACK` final. Se comprobaron eliminación auditada, rechazo de duplicado activo, ventanas distintas, reapertura tras entrega y creación de cancelado. No se modificaron registros de la aplicación.
- La prueba de dos planificadores concurrentes corre sobre H2; no sustituye una prueba de carga y concurrencia de la aplicación completa contra PostgreSQL.

## Aplicar los cambios en Docker

Como Flyway está desactivado, reconstruir imágenes no actualiza triggers ni índices de una base ya creada.
Antes de aplicar el índice, esta consulta no debe devolver filas:

```sql
SELECT cliente_id, direccion, ventana_inicio, ventana_fin, COUNT(*)
FROM pedidos WHERE estado IN ('PENDIENTE', 'EN_RUTA')
GROUP BY cliente_id, direccion, ventana_inicio, ventana_fin
HAVING COUNT(*) > 1;
```

Con la aplicación detenida para evitar escrituras durante la actualización, desde la raíz:

```powershell
docker compose stop backend frontend
Get-Content -Raw database/02_triggers.sql | docker compose exec -T postgres sh -c 'psql -v ON_ERROR_STOP=1 --single-transaction -U "$POSTGRES_USER" -d "$POSTGRES_DB"'
docker compose up --build -d
```

Continúa con la reconstrucción solo si el comando SQL finaliza correctamente. Estos comandos conservan el volumen. No ejecutes `down -v` para aplicar esta revisión.
