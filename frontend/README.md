# PathSeek - Frontend (Flutter)

SPA Flutter de **PathSeek**: Optimizador de Rutas Sostenibles para UGEL Huancayo.
Cliente de la API REST de Spring Boot (arquitectura Cliente-Servidor, ver DOC-012).

## Stack

- **Flutter / Dart** (multi-plataforma: web + movil)
- **flutter_bloc** (estado), **go_router** (navegacion + guards RBAC)
- **dio** (HTTP + interceptores JWT/refresh), **get_it** (DI)
- **shared_preferences** (persistencia de sesion web + movil)

## Estructura (feature-first con capas)

```
lib/
├── main.dart                 # Bootstrap: DI, router, theme
├── core/                     # Transversal (sin logica de negocio)
│   ├── config/               # Entornos dev/staging/prod
│   ├── constants/            # Roles RBAC, rutas de API
│   ├── errors/               # Failures, exceptions, mapper Dio→Failure
│   ├── network/              # ApiClient (dio), TokenStorage, SessionStore
│   ├── router/               # AppRouter (go_router + redirect RBAC), HomeShell
│   ├── theme/                # Tema con contraste WCAG 2.1 AA
│   ├── utils/                # Validators, Formatters
│   └── widgets/              # Loading, Error, Empty, SnackBar
├── features/
│   ├── auth/                 # Login, sesion JWT (EN-003)
│   ├── fleet/                # US-001 Gestion de Flota
│   ├── drivers/              # US-003 Gestion de Conductores
│   ├── orders/               # US-002 Gestion de Pedidos
│   └── routes/               # Sprint 2: Generación de rutas + métricas P95
└── l10n/                     # Strings en espanol (app_es.arb)
```

### Capas por feature

`presentation (bloc/pages/widgets) → domain (entities/repositories) ← data (datasources/models/repositories)`

- **presentation**: widgets + estado (BLoC) + eventos/estados
- **domain**: entidades puras (Dart, sin Flutter/HTTP) e interfaces de repositorio
- **data**: DTOs, datasources remotos e implementaciones de repositorio

## Ejecutar

```bash
flutter pub get

# Web (operador/dashboard)
flutter run -d chrome

# Android (modo conductor - EP-03)
flutter run -d <device-id>
```

### Backend en paralelo

La URL base por entorno esta en `lib/core/config/environment.dart`:

| Entorno | URL |
| --- | --- |
| dev | `http://localhost:8080` |
| staging | `https://staging-api.pathseek.pe` |
| prod | `https://api.pathseek.pe` |

> Web en Chrome: usa un puerto fijo para que el CORS del backend lo acepte,
> por ejemplo `flutter run -d chrome --web-port=5173` (origen permitido por defecto).

Contrato esperado de la API (prefix `/api/v1`):

| Metodo | Ruta | Sprint |
| --- | --- | --- |
| POST | `/api/v1/auth/login` | EN-003 |
| POST | `/api/v1/auth/refresh` | EN-003 |
| CRUD | `/api/v1/vehiculos` | US-001 |
| CRUD | `/api/v1/conductores` | US-003 |
| CRUD | `/api/v1/pedidos` | US-002 |
| POST | `/api/v1/rutas/generar` | Sprint 2 Historia 1 |
| POST | `/api/v1/rutas/confirmar` | Sprint 2 (asignados → EN_RUTA) |
| GET | `/api/v1/rutas/metricas-rendimiento` | Sprint 2 Historia 2 |
| GET | `/api/v1/rutas/lock` | Sprint 2 Historia 2 |

Login devuelve `{ token, refreshToken, usuario: { usuario_id, nombre, email, rol } }`.

## Sprint 2: Generación de Rutas Optimizadas (RF-003)

Página `/routes` (solo `ADMIN`/`OPERADOR`): formulario `fecha_operacion + depósito + velocidad_kmh` → `POST /rutas/generar` → muestra plan + tarjeta P95.

Request ejemplo:

```json
{
  "fecha_operacion": "2026-10-05",
  "deposito": { "latitud": -12.065, "longitud": -75.204 },
  "velocidad_kmh": 40,
  "tiempo_servicio_min": 15
}
```

> `ApiClient` usa `receiveTimeout 30 s` global; `RouteRemoteDataSource` eleva a 60 s solo para `rutas/generar` (SLA 45 s).

> **Datos de ciudad:** el backend precarga solo la semilla de Huancayo al
> arrancar (idempotente, sin paso manual). Si un pedido sale como “ventana
> inalcanzable”, casi siempre es depósito lejano, velocidad baja o flota
> restringida ese día (no un bug). Usa el botón **“Usar UGEL”** (depósito
> `-12.0654, -75.2048`, zona Atalaya) y el botón **“Ver en mapa”**.
> Los no asignados muestran dirección, ventana, motivo legible y sugerencia
> de reprogramación (RF-003).

## Mapa de rutas (RF-004, `/map`, solo ADMIN/OPERADOR)

`route_map_page.dart` con `flutter_map` + OpenStreetMap: trazado por
vehículo con colores diferenciados, puntos numerados con hora de llegada,
depósito (casa), detalle al tocar (cliente, ventana, peso, tramo,
congestión) y lista expandible de tramos con tiempos estimados.
Congestión MVP por hora de llegada (hora punta Huancayo 7–9, 12–14, 18–20:
roja con borde; sin API de tráfico en Sprint 2).

## Guion de demo (evidencias)

1. **Generar**: banner “Optimizando rutas… Ns (límite 45s · SLA RNF-001)”
   con cronómetro real durante el cálculo.
2. **Snackbar**: “X rutas generadas. Y pedidos quedaron sin asignar”.
3. **Tarjetas**: fecha, placa, distancia_km, co2_kg, combustible_l,
   Estado “Planificada”, ahorro estimado vs referencia secuencial ingenua
   (ida-vuelta por pedido, etiquetado como estimado; KPI ≥15%).
   Conductor figura “por asignar”: no hay vínculo vehículo-conductor en el
   modelo Sprint 2.
4. **Detalle**: entregas ordenadas con orden, hora estimada, dirección,
   peso, ventana y chip de prioridad (EXPRESS destacado → evidencia RN-007).
5. **2.º día con EXPRESS**: cambia la fecha y verifica que el EXPRESS sale
   primero en el orden.
6. **Confirmar**: botón “Confirmar (N → EN_RUTA)” tras generar; sin
   confirmar, regenerar repite el plan (cálculo en memoria). Sin pendientes,
   la API responde `422 NO_PENDING_ORDERS`.
7. **Mapa**: chips “Ver vehículos” aíslan cada ruta (todas salen del mismo
   depósito UGEL etiquetado); paradas con `#orden + hora` y cliente.

## Guía para IA (contrato Sprint 2 — no romper)

Resoluciones de incongruencias aplicadas en Sprint 2, mantenerlas:

1. **Historias separadas:** Historia 1 = corrección (capacidad, ventanas, placa, motivo no-asignado). Historia 2 = rendimiento (dataset 150+15, `metricas-rendimiento`, P95 < 45 s, varias mediciones). No mezclar DoDs.
2. **Placa en Vehicle:** la restricción vive en `Vehicle.placa` + `restriccion_placa_digito` (override). Tabla MVP en `PlateRestrictionService`: Lun {1,2}, Mar {3,4}, Mié {5,6}, Jue {7,8}, Vie {9,0}, Sáb/Dom {}. `fecha_operacion` → `DayOfWeek` → último dígito → excluir. `restriccionPlacaDigito` sigue nullable (flota histórica sin dato).
3. **Ventana inalcanzable:** `Order.estado=PENDIENTE` + `motivo_no_asignado ∈ {VENTANA_INALCANZABLE, CAPACIDAD, RESTRICCION_PLACA}` (columna nullable, migración `V4`). `motivo=null` = esperando asignación. No crear nuevo estado.
4. **Descansos (RN-004):** fuera de MVP. `Driver` solo tiene `disponible:Boolean`. El optimizador NO calcula jornada 8h/1h×4h; documentarlo como alcance Sprint 3+.
5. **Inputs VRP mínimos:** `fecha_operacion + deposito{lat,lon} + velocidad_kmh + tiempo_servicio_min(15 default)` en el request; por pedido se usa `gps_lat/lon, ventana_inicio/fin HH:mm, peso, volumen, prioridad`; por vehículo `capacidad_kg/m3, consumo_km_l, factor_emision, placa`. Sin matriz persistida: Haversine en memoria (`GeoUtils`).
6. **Fórmulas canónicas:** `factor_emision` = kg CO₂ por **litro**. `combustible_l = distancia_km / consumo_km_l`; `co2_kg = combustible_l × factor_emision`. NO usar `distancia × factor`.
7. **Concurrencia:** `POST /rutas/generar` corre en hilo único + `AtomicBoolean` lock + timeout 45 s. Si `GET /rutas/lock → {en_ejecucion:true}`, el frontend avisa y no reintenta. `409 ROUTE_GENERATION_BUSY`, `422 ROUTE_TIMEOUT`. RBAC: generar `ADMIN/OPERADOR`, métricas/lock + `AUDITOR`.
8. **Archivos fuente de verdad backend:** `route/controller/RouteController.java`, `route/service/RouteService.java` (lock/timeout/métricas), `route/service/RouteOptimizationService.java` (greedy), `route/service/PlateRestrictionService.java`, `route/service/RouteMetricsService.java`, `order/entity/MotivoNoAsignado.java`.
9. **Archivos fuente de verdad frontend:** `features/routes/` (entities, models, datasource, repository, `route_bloc.dart` factory —cada página crea la suya y `BlocProvider` la cierra—, `route_generate_page.dart`, `route_map_page.dart` que recibe el plan por `extra`), `core/constants/api_paths.dart` (`rutasGenerar/Metricas/Lock`), `core/di/injection.dart` (`_registerRoutes`), `core/router/app_router.dart` (`/routes`, `/map`), `core/router/home_shell.dart` (ítem Rutas).

## Calidad (DoD global)

```bash
flutter analyze          # 0 issues
flutter test             # 95 tests
flutter test --coverage  # >= 80% cobertura (requisito DoD)
flutter build web        # compilacion release
```

## Convenciones

- Codigo en ingles, UI en espanol (l10n)
- BLoC para CRUD con estados; Cubit para casos simples
- Modelos: entidades de dominio separadas de DTOs (mapeo tolerante al contrato API)
- Nombres de rutas de API centralizados en `core/constants/api_paths.dart`
