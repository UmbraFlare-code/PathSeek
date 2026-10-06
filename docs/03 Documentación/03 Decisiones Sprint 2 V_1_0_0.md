# Decisiones Sprint 2 — Generación de Rutas (RF-003)

Proyecto: PathSeek · Versión: V_1_0_0 · Fecha: 2026-10-05

## 1. Alcance

- Historia 1 (corrección): `POST /api/v1/rutas/generar` asigna pedidos `PENDIENTE`
  respetando capacidad (RN-005), ventanas (RN-006) y placa (RN-003).
- Historia 2 (rendimiento): `GET /api/v1/rutas/metricas-rendimiento` expone
  `{total_solicitudes, p50_ms, p95_ms, media_ms, min_ms, max_ms, ultima_ms,
  sla_45s_cumplido}`. DoD: dataset 150 pedidos + 15 vehículos, P95 < 45 s,
  varias mediciones registradas.

## 2. Las 7 resoluciones aplicadas

1. **Historias separadas:** DoD funcional ≠ DoD rendimiento (ver §1).
2. **Placa en Vehicle:** `placa` + `restriccion_placa_digito` (override, nullable).
   `PlateRestrictionService`: Lun {1,2}, Mar {3,4}, Mié {5,6}, Jue {7,8},
   Vie {9,0}, Sáb/Dom {}. Flujo: `fecha_operacion → DayOfWeek →
   dígitos → último dígito placa → excluir o no`.
3. **Ventana inalcanzable:** sin nuevo estado. `pedidos.motivo_no_asignado`
   nullable ∈ `VENTANA_INALCANZABLE, CAPACIDAD, RESTRICCION_PLACA`
   (migración `V4`). `null` = esperando asignación.
4. **Descansos RN-004 fuera de MVP:** `Driver` solo tiene `disponible`.
   El optimizador no calcula jornada 8h / 1h×4h. Alcance Sprint 3+.
5. **Inputs VRP mínimos:** request con `fecha_operacion, deposito{lat,lon},
   velocidad_kmh, tiempo_servicio_min=15`; por pedido `gps, ventana HH:mm,
   peso, volumen, prioridad`; por vehículo `capacidad, consumo, factor,
   placa`. Matriz Haversine en memoria (`GeoUtils`), sin tabla persistida.
6. **Fórmulas canónicas:** `factor_emision` = kg CO₂/L.
   `combustible_l = distancia_km / consumo_km_l`;
   `co2_kg = combustible_l × factor_emision`.
7. **Concurrencia:** `RouteService` con `SingleThreadExecutor +
   AtomicBoolean` + `Future.get(45 s)`. `GET /rutas/lock` expone el estado.
   `409 ROUTE_GENERATION_BUSY`, `422 ROUTE_TIMEOUT`. RBAC: generar
   ADMIN/OPERADOR; métricas/lock + AUDITOR.

## 3. Contratos

- `POST /api/v1/rutas/generar` → `{ruta_id, fecha_operacion, duracion_ms,
  metricas{distancia_km, combustible_l, co2_kg, cumplimiento_pct,
  total_asignados, total_no_asignados, penalizacion},
  rutas[{vehiculo_id, placa, distancia_km, combustible_l, co2_kg,
  paradas[{pedido_id, orden, llegada_estimada, distancia_tramo_km}]}],
  no_asignados[{pedido_id, motivo}]}`.
- Frontend: `features/routes/` + `ApiPaths.rutasGenerar/Metricas/Lock` +
  ruta `/routes` (guía IA completa en `frontend/README.md`).

## 4. Verificación

- Backend: `.\mvnw.cmd test` → 49 tests, 0 fallos (incluye migración V4 en H2).
- Frontend: `flutter analyze` sin issues en archivos nuevos; timeout de
  generación elevado a 60 s solo para `rutas/generar`.

## 5. Adenda: despliegue simple + mapa (RF-004)

- **Sin semilla manual:** `CitySeedRunner` (ApplicationRunner, idempotente)
  precarga 3 vehículos + 3 pedidos de Huancayo al arrancar. Opt-out con
  `APP_SEED_CITY_DATA_ENABLED=false`.
- **Paradas enriquecidas:** `StopDto` incluye `gps_lat/lon, cliente_id,
  ventana_inicio/fin, peso`; la respuesta incluye `deposito`, para que el
  mapa no necesite llamadas extra.
- **Mapa `/map` (ADMIN/OPERADOR):** `flutter_map` + OSM. Colores por vehículo, puntos con hora
  de llegada, detalle (cliente, ventana, peso), tramos con tiempos y
  congestión MVP por hora punta (roja 7–9/12–14/18–20); sin API de tráfico
  en Sprint 2.

## 6. Adenda: confirmar asignación + mapa legible

- Generar no persiste: `POST /rutas/confirmar {pedido_ids}` pasa
  asignados a `EN_RUTA`; sin pendientes, generar responde
  `422 NO_PENDING_ORDERS` (evita replanificar lo mismo).
- Mapa: el plan viaja por navegación (`extra`, no bloc compartido);
  chips filtran vehículos (mismo depósito UGEL etiquetado), paradas con
  `#orden + hora` y cliente.
