[← Volver al README Principal](../../README.md)

# Informe de estado del proyecto

**Nombre del Proyecto:** PathSeek

**Líder del Proyecto:** Francis Maxuel Urquizo Ore

Proyecto: PathSeek
Código del documento: DOC-020
Versión: V_1_0_0
Fecha: 2026-09-29

---

## 1. Datos de la iteración

| Campo | Valor |
| --- | --- |
| **Iteración** | Sprint 1 |
| **Duración** | 2 semanas |
| **Fecha de inicio** | 2026-09-14 |
| **Fecha de fin** | 2026-09-25 |
| **Story Points comprometidos** | 18 |
| **Story Points completados** | 18 |
| **Avance de la iteración** | 100 % de los ítems del Sprint 1 |
| **Día del informe** | 2026-09-29 (cierre de Sprint) |
| **Ambiente demostrado** | Local / Staging (API `http://localhost:8080`, PostgreSQL 17, Flutter web) |

---

## 2. Sprint Goal (objetivo de la iteración)

> **"Implementar el núcleo de gestión logística: registrar y administrar flota, pedidos y conductores con CRUD completo validado en el ambiente de pruebas, dejando la base de datos maestra lista para alimentar el motor de optimización del Sprint 2."**

El objetivo se cumplió en su totalidad: las tres historias de gestión (flota, pedidos y conductores) y el enabler de seguridad quedaron implementados, probados y demostrables.

---

## 3. Historias de Usuario completadas en este Sprint

| Clave Jira | Historia de Usuario | Tipo | Story Points | Estado | Evidencia principal |
| --- | --- | :---: | :---: | :---: | --- |
| PATHSEEK-1 | **US-001** Gestión de Flota | Story | 5 | **Done** | CRUD `/api/v1/vehiculos` + vista Flutter de flota |
| PATHSEEK-2 | **US-002** Gestión de Pedidos | Story | 5 | **Done** | CRUD `/api/v1/pedidos` + validación de ventanas de tiempo |
| PATHSEEK-3 | **US-003** Gestión de Conductores | Story | 3 | **Done** | CRUD `/api/v1/conductores` + vista Flutter de conductores |
| PATHSEEK-6 | **EN-003** Seguridad de la Plataforma (JWT + RBAC) | Task | 5 | **Done** | Login/refresh/logout + autorización por roles |
| | **Total** | | **18 / 18** | **100 %** | |

Los criterios de aceptación (Gherkin) de las cuatro historias fueron verificados conforme al Definition of Done global (`docs/02 Planificación/01 Transformando a ágil V_1_1_0.md`). El detalle de la demostración consta en el documento `03 Revisión del Sprint V_1_0_0.md`.

---

## 4. Demostración del trabajo completado

Demostración a los **stakeholders** de las funcionalidades implementadas, realizada al cierre de la iteración ante el área logística de la UGEL Huancayo y el supervisor académico (Ing. Daniel Gamarra):

- **Seguridad (EN-003):** autenticación JWT stateless con access token de 15 minutos, rotación de refresh token (7 días, hash SHA-256 en base de datos), bloqueo de cuenta tras 3 intentos fallidos y control de acceso por roles (`ADMIN`, `OPERADOR`, `CONDUCTOR`, `CLIENTE`, `AUDITOR`).
- **Gestión de Flota (US-001):** alta, consulta, edición y baja de vehículos con placa única (mayúsculas), tipo (`CAMIONETA`, `FURGON`, `MOTO`), capacidad, consumo y factor de emisión de CO₂.
- **Gestión de Pedidos (US-002):** registro de pedidos con dirección, coordenadas GPS, peso, volumen, ventana de tiempo (`HH:mm`), prioridad y tipo de producto; rechazo de ventana incompatible y de pedido duplicado (`409 ORDER_DUPLICATE`, RN-012).
- **Gestión de Conductores (US-003):** registro de conductores con DNI único (8 dígitos), licencia única, categoría, disponibilidad y contacto.
- **Documentación de API:** contrato OpenAPI/Swagger navegable en `http://localhost:8080/swagger-ui.html`.
- **Cliente Flutter:** SPA con login, guardas de ruta por rol y vistas de flota, conductores y pedidos consumiendo la API REST.

---

## 5. Estado por componente

### 5.1 Backend (Java 17 + Spring Boot 4.1.1)

| Módulo | Estado | Detalle |
| --- | :---: | --- |
| Autenticación y sesiones | Completado | `POST /auth/login`, `/auth/refresh`, `/auth/logout`; JWT HMAC SHA-256; bloqueo por intentos. |
| Flota | Completado | CRUD completo con validación Bean Validation y placa única. |
| Pedidos | Completado | CRUD con regla de duplicado y validación de ventanas. |
| Conductores | Completado | CRUD con DNI/licencia únicos y categorías válidas. |
| Manejo de errores | Completado | Respuestas con `code`, `message`, `errors`, sin stack traces. |
| Documentación API | Completado | SpringDoc OpenAPI / Swagger UI. |
| Migraciones de BD | Parcial | Flyway V1–V3 aplicadas; `V4` (triggers y procedimientos almacenados) pendiente. |

### 5.2 Frontend (Flutter / Dart)

| Módulo | Estado | Detalle |
| --- | :---: | --- |
| Arquitectura | Completado | `feature-first` por capas (`presentation` → `domain` ← `data`) con `flutter_bloc`, `go_router`, `dio`, `get_it`. |
| Autenticación | Completado | Login, sesión JWT, interceptor de refresh y guardas RBAC. |
| Flota / Conductores / Pedidos | Completado | Vistas de listado y formularios con validación. |
| Calidad | Completado | `flutter analyze` sin incidencias; 84 casos de prueba. |

### 5.3 Base de datos y datos maestros

| Entregable | Estado | Detalle |
| --- | :---: | --- |
| Esquema de tablas | Completado | `database/01_schema_tablas.sql`. |
| Triggers | Completado (archivo) | `database/02_triggers.sql`; pendiente migración Flyway `V4`. |
| Procedimientos almacenados | Completado (archivo) | `database/03_stored_procedures.sql`. |
| Datos semilla | Completado | `database/04_seed_data.sql`. |

---

## 6. Métricas y evidencias de calidad

| Métrica | Valor al cierre del Sprint 1 |
| --- | :---: |
| Story Points completados | 18 / 18 (100 %) |
| Historias de Usuario / Enabler completados | 4 (US-001, US-002, US-003, EN-003) |
| Métodos de prueba de backend | 49 (`ApiIntegrationTests`, `CatalogIntegrationTests`, `SecurityIntegrationTests`, `BackendApplicationTests`) |
| Casos de prueba de frontend | 84 |
| Análisis estático de frontend (`flutter analyze`) | 0 incidencias |
| Migraciones Flyway aplicadas | 3 (V1, V2, V3) |
| Endpoints REST publicados | Health, Auth (3) y CRUD de Vehículos, Conductores y Pedidos |

---

## 7. Impedimentos y riesgos de la iteración

- **Impedimentos:** se registraron **7** obstáculos durante el Sprint 1 (4 resueltos, 1 en progreso y 2 abiertos al cierre). El detalle con impacto, prioridad y acciones de resolución consta en `02 Registro de Impedimentos V_1_0_0.md`.
- **Riesgos en seguimiento:**
  - **RSK-02** (curva de aprendizaje del framework de frontend): se materializó parcialmente y se mitigó con pair programming; estado **cerrado**.
  - **RSK-06** (retrasos en iteraciones del cronograma): en **observación**; el cierre del Sprint 1 dentro de las fechas previstas reduce la exposición.

---

## 8. Pendientes

| # | Pendiente | Origen | Prioridad | Iteración prevista |
| :---: | --- | --- | :---: | --- |
| 1 | Migración Flyway `V4` con triggers y procedimientos almacenados | Deuda técnica (IMP-04) | Alta | Sprint 2 |
| 2 | Endpoint `GET /api/v1/dashboard/resumen` (consumo de `sp_obtener_resumen_dashboard`) | RF-005 | Media | Sprint 2 |
| 3 | Pipeline CI/CD con build, pruebas y cobertura (DoD #1, #2 y #4) | Deuda técnica (IMP-07) | Media | Sprint 2 |
| 4 | US-004 Módulo de Clientes | Backlog EP-01 | Baja | Sprint 2/3 |
| 5 | US-005 Generación de Rutas Optimizadas y EN-001 Rendimiento del Motor | Backlog EP-02 | Alta | Sprint 2 |
| 6 | Migración a Built-in Kotlin en el proyecto Android de Flutter | Deuda técnica (IMP-06) | Baja | Sprint 2 |

---

## 9. Estructura del código fuente

El código se organiza en carpetas independientes y claramente identificadas (`frontend/`, `backend/`, `database/`) directamente en la raíz del repositorio. La justificación técnica de esta decisión frente a la alternativa `src/frontend` + `src/backend` se desarrolla en `05 Justificación de la estructura del código V_1_0_0.md`.

---

## Control de versiones

| Versión | Fecha | Descripción | Responsable |
| --- | --- | --- | --- |
| V_1_0_0 | 2026-09-29 | Creación inicial: informe de estado del Sprint 1 (Fase 03: Implementación). | Equipo PIPRE |

---

## Referencia

- **Documentos relacionados:** `02 Registro de Impedimentos V_1_0_0.md`, `03 Revisión del Sprint V_1_0_0.md`, `04 Retrospectiva del Sprint V_1_0_0.md`, `05 Justificación de la estructura del código V_1_0_0.md`.
- **Planificación:** `docs/02 Planificación/01 Transformando a ágil V_1_1_0.md` y `docs/02 Planificación/02 Artefactos Jira V_1_1_0.md`.
- **Arquitectura y stack:** `docs/01 Inicio/12. Modelo C4 V_1_1_0.md` y `docs/01 Inicio/10. Stack tecnológico V_1_0_0.md`.
