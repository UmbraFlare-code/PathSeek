[← Volver al README Principal](../../README.md)

# Revisión del sprint

**Nombre del Proyecto:** PathSeek

**Líder del Proyecto:** Francis Maxuel Urquizo Ore

Proyecto: PathSeek
Código del documento: DOC-022
Versión: V_1_0_0
Fecha: 2026-09-29

---

## 1. Datos de la revisión

| Campo | Valor |
| --- | --- |
| **Sprint revisado** | Sprint 1 (2026-09-14 a 2026-09-25) |
| **Fecha de la revisión** | 2026-09-25 |
| **Modalidad** | Reunión de revisión (Sprint Review) |
| **Participantes** | Equipo PIPRE, área logística de la UGEL Huancayo y supervisor académico (Ing. Daniel Gamarra) |
| **Story Points completados** | 18 / 18 (100 %) |

---

## 2. Historias de Usuario completadas en este Sprint

### US-001 · Gestión de Flota (PATHSEEK-1 · 5 SP · Done)

Como administrador logístico, se implementó el registro y la gestión de vehículos con placa, tipo, capacidad, consumo de combustible y factor de emisión de CO₂.

- Registro exitoso y aparición en el listado de flota.
- Actualización de capacidad, consumo y factor de emisión.
- Rechazo de **placa duplicada** con mensaje de error (validación de unicidad).
- Endpoints: `GET/POST/PUT/DELETE /api/v1/vehiculos`. Autorización: `ADMIN` y `OPERADOR` escriben; `AUDITOR` solo consulta.

### US-002 · Gestión de Pedidos (PATHSEEK-2 · 5 SP · Done)

Como operador logístico, se implementó el registro de pedidos con dirección, coordenadas GPS, peso, volumen, ventana de tiempo, prioridad y tipo de producto.

- Registro exitoso e inclusión en la cola de planificación.
- Aceptación de **punto de referencia** en lugar de dirección formal.
- Rechazo de **ventana de tiempo incompatible** (hora fin anterior a hora inicio).
- Rechazo de **pedido duplicado** (`409 ORDER_DUPLICATE`, RN-012).
- Endpoints: `GET/POST/PUT/DELETE /api/v1/pedidos`.

### US-003 · Gestión de Conductores (PATHSEEK-3 · 3 SP · Done)

Como administrador logístico, se implementó el registro de conductores con DNI, licencia, categoría, disponibilidad y contacto.

- Registro exitoso con DNI (8 dígitos) y licencia únicos; categorías `AII`, `AIII`, `BII`, `BIII`.
- Asociación opcional a un usuario de la plataforma.
- Endpoints: `GET/POST/PUT/DELETE /api/v1/conductores`.

### EN-003 · Seguridad de la Plataforma (PATHSEEK-6 · 5 SP · Done)

Como equipo de desarrollo, se implementó la seguridad transversal de la plataforma.

- Autenticación JWT (HMAC SHA-256) y rotación de refresh token (hash SHA-256 en base de datos).
- Control de acceso por roles (RBAC): `ADMIN`, `OPERADOR`, `CONDUCTOR`, `CLIENTE`, `AUDITOR`.
- Bloqueo temporal de cuenta tras intentos fallidos y revocación de sesión en logout.
- Protección contra accesos no autorizados (respuesta de error sin exponer datos).

---

## 3. Demostración del trabajo completado

Demostración a los **stakeholders** de las funcionalidades implementadas durante el Sprint 1:

| # | Funcionalidad demostrada | Escenario presentado | Evidencia |
| :---: | --- | --- | --- |
| 1 | Autenticación y RBAC | Login, refresco de token y acceso denegado a un rol no autorizado | Swagger UI y cliente Flutter |
| 2 | Gestión de Flota | Alta, edición y listado de vehículos; rechazo de placa duplicada | CRUD `/api/v1/vehiculos` |
| 3 | Gestión de Pedidos | Registro con ventana de tiempo válida; error por ventana incompatible | CRUD `/api/v1/pedidos` |
| 4 | Gestión de Conductores | Registro y listado de conductores | CRUD `/api/v1/conductores` |
| 5 | Documentación de API | Navegación del contrato OpenAPI | `http://localhost:8080/swagger-ui.html` |
| 6 | Calidad | Ejecución de la suite de pruebas | 49 métodos backend · 84 casos frontend |

**Resultado de la revisión:** los stakeholders validaron las funcionalidades y confirmaron que el Sprint Goal se cumplió. Se acordó continuar con el motor de optimización (US-005) en el Sprint 2.

**Trazabilidad técnica:** los cambios se integraron mediante los Pull Requests **#4** (`Feature/backend-sprint1`) y **#5** (`feature/database`), con revisión por pares sobre la rama `main`.

---

## 4. Pendientes

| # | Pendiente | Origen | Prioridad | Iteración prevista |
| :---: | --- | --- | :---: | --- |
| 1 | Migración Flyway `V4` con triggers y procedimientos almacenados | IMP-04 | Alta | Sprint 2 |
| 2 | Endpoint `GET /api/v1/dashboard/resumen` (RF-005) | Backlog EP-03 | Media | Sprint 2 |
| 3 | Pipeline CI/CD con pruebas y cobertura (DoD #1, #2 y #4) | IMP-07 | Media | Sprint 2 |
| 4 | US-004 Módulo de Clientes | Backlog EP-01 | Baja | Sprint 2/3 |
| 5 | US-005 Generación de Rutas Optimizadas y EN-001 Rendimiento del Motor | Backlog EP-02 | Alta | Sprint 2 |
| 6 | Migración a Built-in Kotlin en Android | IMP-06 | Baja | Sprint 2 |

**Compromisos de la revisión:** integrar la deuda técnica de base de datos (`V4`) e iniciar el motor de optimización (US-005 + EN-001) en el Sprint 2, manteniendo el Definition of Done global.

---

## 5. Control de versiones

| Versión | Fecha | Descripción | Responsable |
| --- | --- | --- | --- |
| V_1_0_0 | 2026-09-29 | Creación inicial: revisión del Sprint 1 (Fase 03: Implementación). | Equipo PIPRE |

---

## 6. Referencia

- **Documentos relacionados:** `01 Informe de estado del proyecto V_1_0_0.md`, `02 Registro de Impedimentos V_1_0_0.md`, `04 Retrospectiva del Sprint V_1_0_0.md`.
- **Planificación:** `docs/02 Planificación/01 Transformando a ágil V_1_1_0.md` y `docs/02 Planificación/02 Artefactos Jira V_1_1_0.md`.
