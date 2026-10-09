[← Volver al README Principal](../../../README.md)

# Planificación del Sprint 3

**Nombre del Proyecto:** PathSeek  
**Líder del Proyecto:** Francis Maxuel Urquizo Ore  
**Código del documento:** DOC-024-S3  
**Versión:** V_1_0_0  
**Fecha:** 2026-10-12  

---

## 1. Datos del Sprint

| Campo | Detalle |
| --- | --- |
| **Sprint** | Sprint 3 |
| **Duración** | 2 semanas (2026-10-12 al 2026-10-23) |
| **Capacidad del equipo** | 25 Story Points |
| **Story Points comprometidos** | 23 SP |
| **Meta del Sprint (Sprint Goal)** | Implementar la re-optimización dinámica de rutas en tiempo real ($\le 30\text{ s}$) ante incidentes viales en Huancayo, la generación y descarga de reportes de sostenibilidad en PDF, el módulo de preferencias de clientes, el plan de compensación de carbono y el sistema de auditoría/trazabilidad integral, manteniendo invariables los contratos REST existentes. |

---

## 2. Historias de Usuario e Incidencias Técnicas Seleccionadas

| Clave | Resumen | Épica | Story Points | Responsable | Criterios BDD Clave |
| :---: | --- | :---: | :---: | --- | --- |
| PATHSEEK-8 | **US-006** Re-optimización Dinámica | EP-02 | 8 | Software Architect / Backend | Recálculo de rutas afectadas en $\le 30\text{ s}$, evasión de incidentes |
| PATHSEEK-9 | **EN-002** Rendimiento de Re-optimización | EP-02 | 5 | Software Architect | SLA latencia P95 $\le 30\text{ s}$, registro de telemetría |
| PATHSEEK-13 | **US-009** Reportes de Sostenibilidad | EP-03 | 5 | Dev Junior Frontend/Backend | Resumen de emisiones, ahorro en Soles, exportación PDF/JSON por fechas |
| PATHSEEK-17 | **US-004** Módulo de Clientes | EP-01 | 2 | Dev Junior Backend | CRUD clientes, ventanas de atención y puntos de referencia |
| PATHSEEK-18 | **US-010** Compensación de Carbono | EP-04 | 3 | Dev Junior Backend | Cálculo de huella anual, equivalencia de árboles y proyectos de reforestación |
| PATHSEEK-AUD | **Trazabilidad y Auditoría** | EP-01 | Transversal | Dev Junior Backend | Tabla `auditoria`, logging, scheduler de limpieza de tokens |

---

## 3. Criterios de Aceptación del Sprint y Definition of Done (DoD)

1. Endpoint `POST /api/v1/rutas/{id}/reoptimizar` ejecutando recálculo en $\le 30\text{ s}$ y registrando trazabilidad en auditoría.
2. Endpoint `GET /api/v1/reportes/sostenibilidad` retornando métricas y soporte de PDF descargable.
3. Endpoints `/api/v1/clientes` con validación estricta de ventanas horarias y datos de contacto.
4. Endpoint `GET /api/v1/compensacion` calculando la equivalencia arbórea para las emisiones acumuladas.
5. Preservación al 100% de las rutas previas (`/auth`, `/vehiculos`, `/conductores`, `/pedidos`, `/rutas`, `/health`).
6. Suite de pruebas backend y frontend con 100% de ejecución exitosa y cobertura $\ge 80\%$.
