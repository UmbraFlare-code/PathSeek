# Trazado de rutas por calles con OSRM

Fecha: 2026-10-22. Continuidad de RF-004 / US-007. No modifica las actas históricas de sprint.

Versión efectiva: V_1_1_0. Actualización documental: 2026-10-27.
El [informe QA](../Sprint%203/03%20Calidad%20de%20c%C3%B3digo%20V_1_0_0.md)
registra el recorrido lineal que sustituyó la regex y la configuración actual del proveedor;
correcciones locales pendientes de reanálisis Sonar, sin nuevo cambio de código en este corte.

### Corrección del decodificador web

La API podía responder `OSRM / OK` y aun así la web mostrar recorrido no disponible. Se reprodujo el error compilando el decodificador a JavaScript: el operador `~` devolvía un entero de 32 bits sin signo para los deltas negativos, a diferencia del comportamiento de la VM de Dart. El control de coordenadas descartaba entonces toda la polilínea. Se sustituye por la operación aritmética equivalente `-(result >> 1) - 1`. La polilínea de referencia pasó de cero a tres puntos en la ejecución JavaScript real, manteniendo coordenadas negativas. Se añade `frontend/tool/verify_polyline_web.dart` para evitar que la validación dependa únicamente de pruebas nativas:

```powershell
cd frontend
dart compile js tool/verify_polyline_web.dart -o build/verify_polyline_web.js
node build/verify_polyline_web.js
```

Este fallo explica por qué la respuesta vial de la API y las comprobaciones de Flutter nativo eran correctas mientras el navegador rechazaba el recorrido.

Corrección posterior: se elimina por completo el dibujo de líneas directas cuando no hay geometría vial. La captura reportada correspondía al esquema discontinuo de fallback, no a una polilínea OSRM. La API real de la ruta consultada devolvió después `OSRM / OK`, con 382 caracteres de geometría y cuatro waypoints. La UI ahora muestra únicamente marcadores en ausencia de ruta vial y permite reintentar. El datasource reintenta una sola vez, tras 1100 ms, ante `PROVIDER_UNAVAILABLE` o `RATE_LIMITED`. El cliente Java usa HTTP/1.1 para la consulta al proveedor.

## Causa y cambio

El endpoint de geometría interpolaba puntos entre destinos; esos puntos permanecían en la línea recta y no representaban calles. Cambiar las teselas de OpenStreetMap por un SDK de Google o Mapbox no soluciona ese cálculo.

Se conserva Flutter, `flutter_map`, OpenStreetMap, BLoC, JWT y el contrato `encodedPolyline`. El backend incorpora `StreetGeometryService`, que consulta **Route Service** de OSRM, perfil driving, con `overview=full&geometries=polyline`. Envía longitud,latitud, en el orden operativo de las paradas, incluyendo depósito y última posición aceptada cuando exista. No utiliza Trip Service ni permite que el proveedor reordene entregas. Las paradas se ordenan explícitamente por `orden`.

Referencia: [API oficial OSRM](https://project-osrm.org/docs/v5.24.0/api/#route-service). Google también distingue [dibujar polilíneas en Flutter](https://developers.google.com/maps/flutter-package/samples/polylines) de [obtenerlas mediante Routes API](https://developers.google.com/maps/documentation/routes/traffic_on_polylines). Por ello no fue necesario instalar `flutter_mapbox` ni `google_maps_flutter`.

## Configuración

| Variable | Valor |
| --- | --- |
| `ROUTING_ENABLED` | `false` por defecto en Spring; `true` por defecto en Compose |
| `ROUTING_BASE_URL` | Sin valor por defecto en backend; Compose conserva fallback público hasta configuración explícita. |

Para desarrollo nativo, configurar `ROUTING_ENABLED=true` y `ROUTING_BASE_URL` explícitamente en el entorno leído por el lanzador. Sin URL el backend devuelve `SCHEMATIC / PROVIDER_UNAVAILABLE`; no elige un proveedor público. En Compose se pueden sobrescribir ambas variables en el `.env` raíz. El fallback público de Compose no garantiza el SLA. Las coordenadas de las paradas se envían al proveedor configurado; no se envían nombres, direcciones, JWT ni identificadores.

Control de cambios: V_1_1_0, 2026-10-27, actualización del fallback/configuración y enlace a evidencia QA; cifras de verificación más abajo conservadas como antecedentes de 2026-10-22.

Cada instancia del backend admite como máximo una solicitud externa por segundo, sin esperar; mantiene hasta 128 geometrías por cinco minutos, identificadas por coordenadas y secuencia. Una consulta limitada devuelve estado explícito y puede reintentarse al volver a abrir el detalle. La caché es local a cada proceso, no compartida entre réplicas. Hasta 100 puntos por solicitud, conexión de 3 s, respuesta de 8 s y ajuste a la vía limitado a 100 m. No se desactiva TLS ni se usa HTTP como fallback automático.

## Contrato y estados de UI

`GET /api/v1/rutas/{id}/geometria` conserva la autorización por rol/propiedad y añade:

- `geometrySource`: `OSRM` o `SCHEMATIC`.
- `geometryStatus`: `OK`, `DISABLED`, `WAYPOINT_LIMIT`, `PROVIDER_UNAVAILABLE`, `NO_ROUTE`, `INVALID_RESPONSE`, `RATE_LIMITED` o `ACTIVE_INCIDENTS`.
- `roadDistanceKm`: distancia del recorrido vial, independiente del KPI del optimizador.
- `roadTravelMinutes`: conducción estimada sin servicio en paradas ni tráfico real.

La UI identifica **Por calles (OSRM)** y muestra los valores viales cuando hay geometría válida. Ante fallo, mantiene marcadores y secuencia textual, sin dibujar líneas de unión, y advierte **Recorrido vial no disponible** con opción de reintentar. El estado `SCHEMATIC` se conserva como metadato compatible, pero `encodedPolyline` es null cuando no hay recorrido vial. El fallo del proveedor no impide cargar el detalle.

OSRM no recibe los incidentes internos de PathSeek. Si la ruta tiene incidentes activos, se muestra esquema con `ACTIVE_INCIDENTS`, sin afirmar que el proveedor los evita. La posición de destino puede ajustarse hasta 100 m a una calle; el marcador conserva las coordenadas originales del pedido. Un destino sin calle cercana produce fallback.

## Alcance y límites

Este cambio mejora la visualización y añade distancia/tiempo viales separados. **La generación y reoptimización conservan sus métricas estimadas y reglas existentes**; no usan aún una matriz vial OSRM. No altera capacidades, prioridades, ventanas, asignaciones, ETA operativas ni el presupuesto de reoptimización. El perfil driving no acredita restricciones particulares de peso/altura para camiones. No hay tráfico en vivo, navegación giro a giro ni reconstrucción del trayecto realmente recorrido por el conductor.

## Verificación

- Suite backend: 92 pruebas aprobadas, incluidas tres nuevas de contrato OSRM mediante servidor HTTP local: orden y coordenadas, conversión de unidades, fallo/JSON inválido y límites sin llamada externa.
- Pruebas frontend: se amplía el contrato del datasource y la distinción visual entre geometría vial y esquema. Consultar los logs `frontend/street-routing-*.log` para los resultados de análisis, pruebas y build.
- Consulta real desde la red Docker al endpoint HTTPS público con coordenadas de ejemplo en Huancayo: `code=Ok`, recorrido de 1221,4 m, polilínea de 89 caracteres. La conexión HTTPS directa desde Windows falló durante la comprobación; desde Docker respondió correctamente. Esto verifica el servicio externo, no certifica la precisión de todas las entregas ni la disponibilidad en producción.
- No se ha realizado inspección visual manual en navegador de la nueva versión.

## Aplicar en Docker local

No requiere migración de base de datos. Para incorporar código backend, bundle Flutter y configuración:

```powershell
docker compose up --build -d --wait backend frontend
```

Después, recargar con Ctrl+F5, abrir el detalle de una ruta sin incidentes activos y comprobar **Por calles (OSRM)**. Si aparece esquema, revisar `geometryStatus` en la respuesta de `/geometria`, la conectividad HTTPS y `ROUTING_ENABLED`. No hace falta borrar volúmenes ni regenerar rutas para obtener la nueva geometría.
