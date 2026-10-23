# Revisión de contratos backend / frontend

Actualización: la [revisión de código y lógica](CODE_REVIEW.md) corrige varios pendientes del optimizador indicados en este informe inicial y documenta el estado posterior.

## Errores corregidos

| Problema | Efecto | Corrección |
| --- | --- | --- |
| No existía `GET /api/v1/dashboard/resumen` | La pantalla inicial fallaba al cargar métricas | Endpoint con los nueve campos `snake_case` consumidos por Flutter, agregados desde las tablas reales; devuelve ceros sin datos. Permisos para ADMIN, OPERADOR, AUDITOR y CONDUCTOR; CLIENTE recibe 403. |
| Rutas respondían con `id`, `conductorId`, etc., en lugar del contrato documentado | El front dependía de nombres alternativos; la lista de pedidos no asignados se perdía | DTO de ruta y sus entregas con nombres explícitos `ruta_id`, `conductor_id`, `pedido_id`, etc. Generación devuelve `pedidos_no_asignados`; Flutter acepta también el nombre anterior durante una transición. |
| Generación sin vehículos/conductores devolvía dos listas vacías | La UI interpretaba que no había pedidos por asignar | La respuesta incluye los IDs de los candidatos que no pudieron asignarse. |
| Ruta inexistente lanzaba `IllegalArgumentException` | Detalle, geometría y eliminación devolvían 500 | Excepción de recurso inexistente y respuesta 404 con `RESOURCE_NOT_FOUND`. |
| `anio` de vehículo era nullable en API/DB, obligatorio al deserializar en Flutter | Un solo vehículo sin año rompía la carga de la flota | Año nullable en modelo y entidad; presentación, ordenamiento y formulario toleran el valor ausente. |
| Reintento tras refrescar JWT reconstruía opciones HTTP | Se perdía el timeout de 90 s de generación de rutas | Se conservan las opciones originales con `RequestOptions.copyWith`, cambiando el token y la marca de reintento. |
| Compose local construía el front de producción con URL remota y HTTPS sin certificados | El frontend local no arrancaba o apuntaba a la VPS | Etapa web local, HTTP, URL local y proxy `/api/`; espera al healthcheck real del backend. |
| Healthcheck local apuntaba a Actuator sin dependencia Actuator | Backend quedaba marcado como no saludable | Healthcheck usa `/api/v1/health`. |
| Compose no trasladaba las variables del usuario bootstrap | No era posible crear el acceso local desde `.env` | Se propagan las cinco variables de bootstrap. |
| README prometía migraciones Flyway que están desactivadas | Una DB vacía impedía iniciar el backend | Documentación corregida e inicialización explícita en `LOCAL.md`. |

Se revisaron rutas HTTP, DTOs de entrada/salida, modelos y datasources de autenticación, vehículos, conductores, pedidos, rutas y dashboard. Los nombres de campos principales de auth y CRUD ya coincidían. Los catálogos devuelven listas directas; no requieren paginación ni envoltorio `data`. Login y refresh mantienen `refreshToken` en camelCase.

## Compatibilidad

Los campos de ruta y sus entregas ahora siguen el contrato documentado en el frontend. Cualquier consumidor externo que solo lea los nombres camelCase anteriores debe migrar a snake_case. Los campos adicionales de estadísticas de generación y el endpoint de geometría conservan sus nombres existentes; Flutter todavía no consume esas estadísticas ni solicita geometría por separado.

## Límites y pendientes detectados

- El optimizador actual es una heurística de vecino más cercano. Todavía toma pedidos `EN_RUTA` y, si no hay candidatos, usa todos los pedidos; además elimina las rutas anteriores al regenerar. No valida de forma completa capacidad, disponibilidad ni ventanas de tiempo. Estas reglas requieren un cambio funcional separado antes de usar la planificación con datos operativos.
- El mapa y el contexto vial usan estimaciones locales; el frontend no integra el endpoint separado de geometría ni el reporte de incidentes. La corrección de contratos no convierte estas estimaciones en navegación vial real.
- La suite del backend usa H2 con esquema generado por Hibernate. No verifica triggers, funciones ni restricciones exclusivas de PostgreSQL.
- Docker no está disponible en el entorno de revisión. La configuración local fue revisada, pero falta ejecutar el conjunto Docker/PostgreSQL y comprobarlo desde un navegador con datos reales.

## Pruebas de regresión

- Backend: contrato del dashboard vacío y con datos, permisos de todos los roles, 401 sin JWT, campos de ruta/entregas, IDs no asignados cuando faltan recursos y 404 de rutas inexistentes.
- Frontend: año nullable de vehículo, lectura de pedidos no asignados de ambos contratos, conservación del timeout y parámetros tras refrescar JWT, además de la suite existente.
- Análisis estático y compilación web de Flutter.

Resultado en esta revisión: **55 pruebas backend y 202 pruebas frontend aprobadas**, `flutter analyze` sin incidencias y `flutter build web --release` completado. Backend ejecutado con Java 25 (objetivo de compilación Java 17) y frontend con Flutter 3.47.4 / Dart 3.13.3. Flutter ajustó dependencias de su SDK para la ejecución local; se conserva el lockfile original del repositorio. No se ejecutó el build de Docker ni una prueba completa contra PostgreSQL.
