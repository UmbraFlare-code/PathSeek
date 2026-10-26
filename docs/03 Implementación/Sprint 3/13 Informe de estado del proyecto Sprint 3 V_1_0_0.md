[← Volver al README Principal](../../../README.md)

# Informe de estado del proyecto — Sprint 3

**Nombre del Proyecto:** PathSeek

**Líder del Proyecto:** Francis Maxuel Urquizo Ore

Proyecto: PathSeek
Código del documento: DOC-030
Versión: V_1_0_0
Fecha: 2026-10-25

---

## 1. Datos de la iteración

| Campo | Valor |
| --- | --- |
| **Iteración** | Sprint 3 |
| **Duración** | 2 semanas |
| **Fecha de inicio** | 2026-10-12 |
| **Fecha de fin** | 2026-10-23 |
| **Story Points comprometidos** | 31 (US-004, US-006, US-009, US-010, EN-002, EN-007, EN-008, EN-009 + CI/CD) |
| **Story Points completados** | 31 |
| **Avance de la iteración** | 100 % de los ítems planificados; quedan validaciones externas documentadas |
| **Día del informe** | 2026-10-25 (cierre y evaluación) |
| **Ambiente demostrado** | Local Docker Compose (PostgreSQL 16 + Spring Boot + Flutter web) y suites H2/Flutter |

---

## 2. Sprint Goal (objetivo de la iteración)

> **"Completar la reoptimización dinámica con bandeja de avisos para el conductor, habilitar la operación offline con sincronización, y entregar los módulos de clientes, reportes PDF y compensación de carbono con sus pruebas automatizadas y documentación."**

El objetivo se cumplió en su totalidad funcional; las únicas actividades no ejecutables en este entorno (validación de campo con conductores reales, auditoría WCAG en navegador y medición p95 en staging) quedan registradas como pendientes externos.

---

## 3. Historias completadas en este Sprint

| Clave | Historia / Enabler | Tipo | SP | Estado |
| --- | --- | --- | --- | --- |
| PATHSEEK-8 | **US-006** Re-optimización Dinámica | Story | 8 | **Done** |
| PATHSEEK-9 | **EN-002** Rendimiento de Re-optimización | Task | 5 | **Done** (herramientas + regresión; p95 staging pendiente) |
| PATHSEEK-17 | **US-004** Módulo de Clientes | Story | 2 | **Done** |
| PATHSEEK-13 | **US-009** Reportes de Sostenibilidad | Story | 5 | **Done** |
| PATHSEEK-18 | **US-010** Compensación de Carbono | Story | 3 | **Done** |
| PATHSEEK-15/16 | **EN-007 / EN-008** Modo Conductor y Offline | Task | 6 | **Done** (encuesta de campo y teselas offline pendientes externas) |
| PATHSEEK-19 | **EN-009** Documentación y API | Task | 2 | **Done** |
| — | **EN-001 / EN-005** Benchmarks de generación y carga | Task | — | **Done** (herramientas + artefactos locales) |
| — | Pipeline CI/CD frontend (A-11) | Task | — | **Done** |

**Story Points acumulados:** 44 (Sprint 1–2) + 31 (Sprint 3) = **75 / 89 SP (84.3 % del backlog)**.

---

## 4. Demostración del trabajo completado

- **Reoptimización (US-006/EN-002):** `POST /api/v1/rutas/reoptimizar` ya integrado a la interfaz: reporte de incidente vial con tipo, descripción, coordenadas y radio, y botón *Reoptimizar* que recalcula la secuencia pendiente, conserva entregas realizadas y genera avisos al conductor. El conductor consulta su bandeja de avisos (`/notifications`) y los marca como leídos.
- **Modo offline (EN-008):** la app guarda la lista y el detalle de las rutas propias; sin conexión muestra los datos cacheados con un banner, encola la posición y las entregas completadas y las sincroniza automáticamente al recuperar la red. Los endpoints `POST /api/v1/rutas/{id}/posicion` y `POST /api/v1/rutas/{id}/entregas/{pedidoId}/completar` son idempotentes por diseño.
- **Clientes (US-004):** CRUD `/api/v1/clientes` con preferencias de entrega (dirección, referencia, teléfono, horario de atención y restricciones de acceso). El cliente gestiona su propio perfil vinculado a su cuenta.
- **Reportes PDF (US-009):** página `/reports` con rango de fechas y descarga del PDF generado en el backend (resumen del período y detalle por ruta).
- **Compensación (US-010):** página `/carbon` con emisiones anuales de rutas completadas, árboles equivalentes y proyectos locales con costo estimado.
- **Calidad y CI:** backend 124 pruebas (121 en H2 por defecto, 2 PostgreSQL y 1 de carga opt-in; incluidas las nuevas de clientes, reportes, compensación y ejecución), 292 pruebas Flutter, `flutter analyze` sin incidencias, build web release e imágenes Docker construidas. Nuevo workflow `frontend-checks.yml` (analyze + test en PRs y pushes que tocan el frontend) y artefacto de benchmark de generación 150/15.

---

## 5. Estado por componente

### 5.1 Backend

| Módulo | Estado |
| --- | --- |
| Reoptimización incremental | Completado (Sprint 3: UI y avisos consumibles) |
| Ejecución del conductor | Completado (posición y entregas idempotentes) |
| Clientes y preferencias | Completado |
| Reportes PDF (OpenPDF) | Completado |
| Compensación de carbono | Completado |
| Migraciones Flyway | Completado (V8 proyectos, V9 preferencias; aditivas e idempotentes) |
| OpenAPI/Swagger | Completado (todas las áreas con `@Tag`/`@Operation`) |
| Benchmarks | Herramientas `benchmark_generation.py` + prueba de carga opt-in 1000/50 |

### 5.2 Frontend

| Módulo | Estado |
| --- | --- |
| Bandeja de avisos y badge | Completado |
| Incidentes + reoptimizar | Completado (detalle de ruta) |
| Offline (caché, banner, cola sync) | Completado para datos de ruta; teselas pendientes |
| Reportes | Completado |
| Compensación | Completado |
| Clientes | Completado |
| Suite de pruebas | Completado (292 pruebas) |

### 5.3 DevOps

| Entregable | Estado |
| --- | --- |
| Workflow frontend-checks.yml | Completado |
| Workflow backend extendido | Completado (Sprint3ModulesIntegrationTests + migraciones 08/09) |
| Imágenes Docker locales | Completado (backend + frontend) |

---

## 6. Métricas y evidencias de calidad

| Métrica | Valor al cierre del Sprint 3 |
| --- | :---: |
| Story Points del sprint | 31 / 31 (100 %) |
| Backlog acumulado | 75 / 89 SP (84.3 %) |
| Pruebas backend | 124 (121 H2 + 2 PostgreSQL + 1 carga opt-in, 0 fallos) |
| Pruebas frontend | 292 (0 fallos) |
| `flutter analyze` | 0 incidencias |
| Build web release | Correcto |
| Imágenes Docker (compose local) | Construidas correctamente |
| Benchmark generación 150/15 | 0.5–1 s local (SLA ≤ 45 s) |

---

## 7. Impedimentos y riesgos

- **Impedimentos bloqueantes:** ninguno. El daemon de Docker Desktop requería arranque manual para la verificación local (resuelto).
- **Riesgos en seguimiento:**
  - **RSK-04** (rendimiento del servidor): controlado; medición p95 en staging queda pendiente.
  - **RSK-06** (cronograma): controlado y cerrado para la iteración 3.

---

## 8. Pendientes externos (no bloquean el cierre)

| # | Pendiente | Origen |
| :---: | --- | --- |
| 1 | Prueba de campo del APK con conductores reales y encuesta de satisfacción ≥ 4.0/5.0 (EN-007) | Validación UGEL Huancayo |
| 2 | Auditoría axe/Lighthouse y navegación completa por teclado (EN-006) | Navegador real |
| 3 | Medición p95 en staging de generación y reoptimización (EN-001/EN-002) | Infraestructura de pruebas |
| 4 | Proveedor de tráfico real para congestión por tramo (US-007) | Contratación de servicio |
| 5 | Caché de teselas para mapas offline (EN-008, alcance adicional) | Roadmap |
| 6 | Restricción por placa (DS N.° 033-2012-MTC) | Pos puesta por instrucción del usuario |

---

## Control de versiones

| Versión | Fecha | Descripción | Responsable |
| --- | --- | --- | --- |
| V_1_0_0 | 2026-10-25 | Creación inicial: informe de estado del Sprint 3. | Equipo PIPRE |
| V_1_1_0 | 2026-10-25 | Corrección de Story Points (31 SP, 75/89) y conteo de pruebas (124 backend); verificación final del cierre. | Equipo PIPRE |

## Referencia

- **Cierre Sprint 2:** `docs/03 Implementación/Sprint 2/01 Informe de estado del proyecto V_1_0_0.md`.
- **Continuidad técnica:** `docs/03 Implementación/Sprint 3/06` a `12` (mapa, UIUX, reoptimización, OSRM, usuarios y DNI).
- **Planificación:** `docs/02 Planificación/01 Transformando a ágil V_1_1_0.md` y `02 Artefactos Jira V_1_1_0.md`.
