[← Volver al README Principal](../../../README.md)

# Informe de estado del proyecto (Sprint 3)

**Nombre del Proyecto:** PathSeek  
**Líder del Proyecto:** Francis Maxuel Urquizo Ore  
**Código del documento:** DOC-025  
**Versión:** V_1_0_0  
**Fecha:** 2026-10-23  

---

## 1. Datos de la Iteración

| Campo | Valor |
| --- | --- |
| **Iteración** | Sprint 3 |
| **Duración** | 2 semanas (2026-10-12 al 2026-10-23) |
| **Story Points Comprometidos** | 23 SP |
| **Story Points Completados** | 23 SP (100 %) |
| **Story Points Acumulados Totales** | 67 / 89 SP (75.3 % del backlog general) |
| **Ambiente Demostrado** | VPS Contabo (`https://169.58.74.99`), Swagger OpenAPI, Docker Compose |

---

## 2. Historias de Usuario e Incidencias Completadas

| Clave Jira | Historia de Usuario / Enabler | SP | Estado | Evidencia Principal |
| :---: | --- | :---: | :---: | --- |
| PATHSEEK-8 | **US-006** Re-optimización Dinámica | 8 | **Done** | Endpoint `/api/v1/rutas/{id}/reoptimizar`, evasión de incidentes viales |
| PATHSEEK-9 | **EN-002** Rendimiento de Re-optimización | 5 | **Done** | Latencia de recálculo $\le 1.5\text{ s}$ (SLA objetivo $\le 30\text{ s}$) |
| PATHSEEK-13 | **US-009** Reportes de Sostenibilidad | 5 | **Done** | Endpoint `/api/v1/reportes/sostenibilidad` con descarga PDF y filtros |
| PATHSEEK-17 | **US-004** Módulo de Clientes | 2 | **Done** | CRUD completo `/api/v1/clientes` con ventanas y georreferencia |
| PATHSEEK-18 | **US-010** Compensación de Carbono | 3 | **Done** | Endpoint `/api/v1/compensacion` con catálogo de árboles y proyectos |
| PATHSEEK-AUD | **Trazabilidad y Auditoría** | Transv. | **Done** | Tabla `auditoria`, `AuditService` y `TokenCleanupScheduler` |

---

## 3. Métricas de Calidad

- **Pruebas Automatizadas Backend:** Cobertura integral con pruebas de integración en Spring Boot pasando al 100%.
- **Pruebas Frontend:** 200 pruebas en Flutter sin regresiones.
- **Seguridad:** RBAC configurado para endpoints de auditoría y reportes institucionales.
