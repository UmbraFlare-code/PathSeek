[← Volver al README Principal](../../../README.md)

# Análisis del contexto logístico de Huancayo V_1_0_0

**Proyecto:** PathSeek · **Código del documento:** DOC-036 · **Fecha:** 2026-10-25 · **Responsable:** Equipo PIPRE

Contexto operativo de la distribución de UGEL Huancayo y su modelado en la plataforma (EN-009).

---

## 1. Contexto operativo

| Dato | Valor |
| --- | --- |
| Depósito de origen/retorno | Atalaya 1280, Huancayo (−12.0683, −75.2100) |
| Flota típica | ~15 camionetas de distribución |
| Emisiones históricas | ~3.5 t CO₂ mensuales |
| Incumplimiento de ventanas | ~22 % |
| Altitud de operación | ~3 260 m s.n.m. (zonas altas hasta ~3 450 m) |
| Destinos | Instituciones educativas urbanas y rurales del Valle del Mantaro |

Restricciones normativas relevantes: Ley N.° 30224 (jornadas de conducción), DS N.° 033-2012-MTC (restricción por placa, pospuesta por instrucción del usuario) y Ley N.° 29733 (datos personales).

---

## 2. Problema que resuelve

La distribución se planificaba de forma manual: rutas por experiencia del conductor, sin consolidar ventanas de atención, prioridades ni emisiones. PathSeek automatiza el VRPTW con consideraciones ambientales (Green VRP) para reducir distancia, combustible y CO₂, y mejorar el cumplimiento de ventanas.

---

## 3. Modelado en la plataforma

| Aspecto real | Modelado en PathSeek |
| --- | --- |
| Distancias entre destinos | Haversine × 1.35 (estimación sin red vial) + geometría OSRM opcional para visualización |
| Velocidad operativa | 25 km/h estimada; 5 min mínimos por tramo |
| Servicio por parada | 15 minutos |
| Salida del depósito | 08:00 (hora del día planificado) |
| Ventanas de entrega | Duras: no se planifican llegadas tardías; pedidos inalcanzables quedan pendientes |
| Prioridades | EXPRESS → ESTANDAR → ECONÓMICO |
| Superficie y altitud | Contexto vial estimado por coordenadas (ASFALTO/AFIRMADO, pendiente, altitud) |
| Emisiones | `CO₂ = distancia_km × factor_emision(kg/km)` del vehículo |
| Incidentes viales | Zonas de exclusión geométrica persistente hasta su resolución |
| Averías | Exclusión del vehículo hasta rehabilitación explícita |

---

## 4. Límites conocidos

- **Sin tráfico en vivo:** la congestión por tramo es una estimación; no hay proveedor contratado.
- **Sin matriz vial en la optimización:** la generación y reoptimización usan distancias estimadas; el trazado OSRM es de visualización.
- **Jornadas de conducción:** la disponibilidad del conductor se modela como bandera; no hay historial de horas acumuladas.
- **Restricción por placa:** no configurada por decisión del usuario.
- **Relevo de carga:** una avería exige confirmar operativamente el traslado; no existe modelo de transbordo.

---

## 5. Datos de referencia

- Flota, conductores y pedidos de demostración: `database/05_seed_demo_data.sql`.
- Fórmulas y reglas: `docs/01 Inicio/09. Reglas de negocio V_1_0_0.md`.
- Métricas del optimizador: `backend/README.md` (Rutas y ejecución).

---

## Control de versiones

| Versión | Fecha | Descripción | Responsable |
| --- | --- | --- | --- |
| V_1_0_0 | 2026-10-25 | Creación del análisis del contexto logístico de Huancayo (EN-009). | Equipo PIPRE |
