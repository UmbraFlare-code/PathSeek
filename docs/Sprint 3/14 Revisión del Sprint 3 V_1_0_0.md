[← Volver al README Principal](../../README.md)

# Revisión del Sprint 3

**Nombre del Proyecto:** PathSeek

**Líder del Proyecto:** Francis Maxuel Urquizo Ore

Proyecto: PathSeek
Código del documento: DOC-026
Versión: V_1_0_0
Fecha: 2026-10-25

---

## 1. Datos de la revisión

| Campo | Valor |
| --- | --- |
| **Sprint revisado** | Sprint 3 (2026-10-12 a 2026-10-23) |
| **Fecha de la revisión** | 2026-10-25 |
| **Modalidad** | Reunión de revisión formal (Sprint Review) |
| **Participantes** | Equipo de Desarrollo PIPRE y supervisor académico (Ing. Daniel Gamarra) |
| **Story Points completados** | 26 / 26 SP (100 %) |
| **Entorno de demostración** | Docker Compose local (PostgreSQL 16, Spring Boot 4.1.1, Flutter Web) |

---

## 2. Historias de Usuario completadas en este Sprint

### US-006 · Re-optimización Dinámica (PATHSEEK-8 · 8 SP · Done)

- `POST /api/v1/rutas/reoptimizar` idempotente por `evento_id`, con eventos `NUEVOS_PEDIDOS`, `CANCELACION`, `INCIDENTE` y `AVERIA`.
- Preserva entregas realizadas, congela el prefijo ejecutado y recalcula solo la secuencia pendiente con presupuesto de ≤ 25 s.
- Integración en la interfaz: reporte de incidente (tipo, descripción, coordenadas, radio) y botón **Reoptimizar** con resumen del resultado.
- Avisos persistentes al conductor generados en la misma transacción.

### EN-002 · Rendimiento de Re-optimización (PATHSEEK-9 · 5 SP · Done)

- Medición `tiempo_calculo_ms`, logs `reoptimization`/`reoptimization_http`, herramienta `benchmark_reoptimization.py` y regresiones de pico 07:30/17:30 (≤ 30 s local). La medición p95 en staging queda como pendiente externo.

### US-004 · Módulo de Clientes (PATHSEEK-17 · 2 SP · Done)

- CRUD `/api/v1/clientes` con dirección, punto de referencia, teléfono, horario de atención y restricciones de acceso.
- El cliente gestiona su propio perfil vinculado a su cuenta; los roles operativos administran todos.

### US-009 · Reportes de Sostenibilidad (PATHSEEK-13 · 5 SP · Done)

- `GET /api/v1/reportes/sostenibilidad` genera un PDF (OpenPDF) con resumen del período y detalle por ruta.
- Filtro por rango de fechas; validación de rango invertido; página `/reports` con descarga (web y móvil).

### US-010 · Plan de Compensación de Carbono (PATHSEEK-18 · 3 SP · Done)

- `GET /api/v1/compensacion/plan`: emisiones anuales de rutas completadas, árboles equivalentes (1 árbol ≈ 0.02 t CO₂/año) y proyectos locales con costo estimado (migración `V8` + catálogo idempotente).

### EN-007 / EN-008 · Modo Conductor, Avisos y Offline (PATHSEEK-15/16 · 3 SP · Done)

- Bandeja de avisos con badge de no leídos; el conductor marca los propios como leídos.
- Caché local de rutas propias, banner sin conexión, cola de sincronización para posición y entregas, y reintento al recuperar la red.
- *Pendiente externo:* encuesta de satisfacción con conductores reales (EN-007) y caché de teselas (alcance adicional de EN-008).

### EN-009 · Documentación y API (PATHSEEK-19 · 2 SP · Done)

- OpenAPI/Swagger con `@Tag`/`@Operation` en todas las áreas.
- Manuales de usuario y administrador + análisis del contexto logístico de Huancayo en `docs/Sprint 3/`.

---

## 3. Demostración del trabajo completado

| # | Funcionalidad demostrada | Escenario presentado |
| :---: | --- | --- |
| 1 | **Reoptimización por incidente** | Bloqueo reportado en una ruta activa → recálculo atómico → aviso al conductor |
| 2 | **Bandeja del conductor** | Conductor consulta avisos y los marca como leídos |
| 3 | **Modo offline** | Conductor sin red completa una entrega y reporta posición; al volver la red la cola se sincroniza |
| 4 | **Reporte PDF** | Descarga con y sin rango de fechas; rango invertido rechazado |
| 5 | **Compensación** | Plan con emisiones anuales, árboles y 3 proyectos locales |
| 6 | **Clientes** | Alta de perfil con horario y restricciones; cliente gestiona su propio perfil |
| 7 | **Calidad** | 121 pruebas backend + 292 frontend + analyze 0 + build web + imágenes Docker |

**Resultado de la revisión:** el equipo y el supervisor académico validaron las funcionalidades; la demostración ante el área logística de UGEL Huancayo queda programada junto con la prueba de campo del APK (pendiente externo).

**Trazabilidad técnica:** los cambios se integraron en la rama `Feature/Sprint3-Cierre` sobre `main`.

---

## 4. Pendientes

| # | Pendiente | Origen | Prioridad | Iteración prevista |
| :---: | --- | --- | :---: | --- |
| 1 | Prueba de campo APK + encuesta de satisfacción (EN-007) | Validación UGEL | Media | Sprint 4 |
| 2 | Auditoría WCAG axe/Lighthouse (EN-006) | Calidad | Media | Sprint 4 |
| 3 | Medición p95 en staging (EN-001/EN-002) | DevOps | Media | Sprint 4 |
| 4 | Proveedor de tráfico real (US-007 congestión) | Alcance | Baja | Post-MVP |
| 5 | Caché de teselas offline | Alcance | Baja | Post-MVP |

**Compromisos de la revisión:** en el Sprint 4 se priorizarán las validaciones externas (campo, accesibilidad y staging) y la preparación del cierre del MVP.

---

## 5. Control de versiones

| Versión | Fecha | Descripción | Responsable |
| --- | --- | --- | --- |
| V_1_0_0 | 2026-10-25 | Creación inicial: revisión del Sprint 3. | Equipo PIPRE |

---

## 6. Referencia

- **Informe de estado:** `13 Informe de estado del proyecto Sprint 3 V_1_0_0.md`.
- **Impedimentos:** `16 Registro de Impedimentos Sprint 3 V_1_0_0.md`.
- **Retrospectiva:** `15 Retrospectiva del Sprint 3 V_1_0_0.md`.
- **Continuidad técnica:** `docs/Sprint 3/09 Reoptimizacion incremental EN002 V_1_0_0.md` y `docs/Sprint 3/10 Trazado vial OSRM V_1_0_0.md`.
