[← Volver al README Principal](../../../README.md)

# Planificación del Sprint 1

**Nombre del Proyecto:** PathSeek  
**Líder del Proyecto:** Francis Maxuel Urquizo Ore  
**Código del documento:** DOC-017-S1  
**Versión:** V_1_0_0  
**Fecha:** 2026-09-14  

---

## 1. Datos del Sprint

| Campo | Detalle |
| --- | --- |
| **Sprint** | Sprint 1 |
| **Duración** | 2 semanas (10 días laborables) |
| **Fecha de inicio** | 2026-09-14 |
| **Fecha de fin** | 2026-09-25 |
| **Capacidad del equipo** | 20 Story Points |
| **Story Points comprometidos** | 18 SP (90 % de la capacidad) |
| **Meta del Sprint (Sprint Goal)** | Implementar el núcleo de gestión logística: registrar y administrar flota, pedidos y conductores con CRUD completo validado en ambiente de desarrollo y pruebas, asegurando la autenticación JWT y el modelo relacional base (V1-V3) para alimentar el motor de optimización. |

---

## 2. Historias de Usuario e Incidencias Seleccionadas

| Clave | Resumen | Épica | Story Points | Responsable | Criterios BDD Clave |
| :---: | --- | :---: | :---: | --- | --- |
| PATHSEEK-1 | **US-001** Gestión de Flota | EP-01 | 5 | Dev Junior Backend | Placa única, cálculo consumo km/L, factor emisión CO₂ |
| PATHSEEK-2 | **US-002** Gestión de Pedidos | EP-01 | 5 | Dev Junior Backend | Georreferenciación GPS, peso, volumen, ventana horaria |
| PATHSEEK-3 | **US-003** Gestión de Conductores | EP-01 | 3 | Dev Junior Backend | DNI/Licencia única, jornada máxima Ley 30224, disponibilidad |
| PATHSEEK-6 | **EN-003** Seguridad de la Plataforma | EP-01 | 5 | Software Architect | JWT Stateless, RBAC (5 roles), hash BCrypt, OWASP Top 10 |

---

## 3. Criterios de Aceptación del Sprint y Definition of Done (DoD)

1. Endpoints REST operativos con respuestas en formato `ApiResponse` estructurado.
2. Manejo de excepciones centralizado (`GlobalExceptionHandler`) con códigos HTTP canónicos (400, 401, 403, 404, 409).
3. Migraciones de base de datos Flyway `V1__init_schema.sql`, `V2__seed_users.sql`, `V3__seed_catalogs.sql` ejecutables.
4. Cobertura de pruebas de integración $\ge 80\%$ en controladores y repositorios.
5. Control de versiones mediante Pull Requests (`#4 Feature/backend-sprint1` y `#5 feature/database`) con revisión por pares.
