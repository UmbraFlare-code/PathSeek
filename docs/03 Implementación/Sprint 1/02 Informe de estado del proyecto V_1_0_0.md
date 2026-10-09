[← Volver al README Principal](../../../README.md)

# Informe de estado del proyecto (Sprint 1)

**Nombre del Proyecto:** PathSeek  
**Líder del Proyecto:** Francis Maxuel Urquizo Ore  
**Código del documento:** DOC-018  
**Versión:** V_1_0_0  
**Fecha:** 2026-09-25  

---

## 1. Datos de la Iteración

| Campo | Valor |
| --- | --- |
| **Iteración** | Sprint 1 |
| **Duración** | 2 semanas (2026-09-14 al 2026-09-25) |
| **Story Points Comprometidos** | 18 SP |
| **Story Points Completados** | 18 SP (100 %) |
| **Ambiente Demostrado** | Local Staging / Test H2 y PostgreSQL 16 |
| **Pull Requests Integrados** | PR #4 (`Feature/backend-sprint1`) y PR #5 (`feature/database`) |

---

## 2. Cumplimiento de Historias de Usuario

| Clave | Elemento | SP | Estado | Resultado |
| :---: | --- | :---: | :---: | --- |
| PATHSEEK-1 | US-001 Gestión de Flota | 5 | **Done** | CRUD completo de vehículos con validaciones de placa única y consumo. |
| PATHSEEK-2 | US-002 Gestión de Pedidos | 5 | **Done** | Registro de pedidos con geolocalización GPS y ventanas horarias. |
| PATHSEEK-3 | US-003 Gestión de Conductores | 3 | **Done** | CRUD de conductores con control de jornada y validación de licencias. |
| PATHSEEK-6 | EN-003 Seguridad de la Plataforma | 5 | **Done** | Autenticación JWT Stateless, Refresh Token rotativo y RBAC. |

---

## 3. Métricas de Calidad

- **Pruebas de Integración:** 41 pruebas automatizadas en Spring Boot con resultado exitoso.
- **Análisis de Vulnerabilidades:** 0 vulnerabilidades críticas según SonarQube/CodeQL.
- **Trazabilidad:** Cobertura 100% de los criterios BDD/Gherkin estipulados en la planificación.
