[← Volver al README Principal](../../README.md)

# Registro de impedimentos

**Nombre del Proyecto:** PathSeek

**Líder del Proyecto:** Francis Maxuel Urquizo Ore

Proyecto: PathSeek
Código del documento: DOC-021
Versión: V_1_0_0
Fecha: 2026-09-29

---

## 1. Resumen

El presente registro documenta los obstáculos **técnicos, operativos y organizativos** identificados durante el **Sprint 1** (2026-09-14 a 2026-09-25), con su impacto en el proyecto, prioridad, responsable del reporte y trazabilidad de su resolución.

| Estado | Cantidad |
| --- | :---: |
| Resueltos | 4 |
| En progreso | 1 |
| Abiertos | 2 |
| **Total registrados** | **7** |

Escala de prioridad aplicada: **Alta** (bloquea la iteración o compromete la seguridad), **Media** (afecta al cronograma o a la calidad) y **Baja** (deuda técnica sin impacto inmediato).

---

## 2. Tabla de impedimentos

| Impedimento # | Fecha de Registro | Descripción del Impedimento así como el Impacto en el Proyecto | Prioridad | Reportado por | Fecha tope de Resolución | Estado | Fecha de Resolución | Resolución/Comentarios |
| :---: | :---: | --- | :---: | --- | :---: | :---: | :---: | --- |
| IMP-01 | 2026-09-14 | La API no iniciaba en las máquinas locales porque Spring Boot no carga `backend/.env` por sí solo; sin `JWT_SECRET` el arranque fallaba con "JWT_SECRET debe contener al menos 32 bytes". **Impacto:** bloqueo del entorno de desarrollo y de las pruebas manuales de todo el equipo. | Alta | Developer Junior Backend | 2026-09-15 | Resuelto | 2026-09-15 | Se habilitó el arranque mediante `run-local.ps1` / `run-local.cmd` que carga el `.env`; `.env` quedó ignorado por Git y se versionó `.env.example`. |
| IMP-02 | 2026-09-28 | Conflicto entre el puerto de desarrollo de la SPA Flutter web y la API, y bloqueo por CORS. **Impacto:** el frontend no podía consumir la API desde el navegador; la demo de login quedaba bloqueada. | Alta | Software Architect | 2026-09-29 | Resuelto | 2026-09-29 | Se definió `CORS_ALLOWED_ORIGINS` (`http://localhost:5173`, `http://localhost:8080`) y se documentó ejecutar Flutter con `--web-port=5173`. |
| IMP-03 | 2026-09-28 | El endpoint de logout no revocaba correctamente el refresh token, permitiendo reutilizar una sesión cerrada. **Impacto:** riesgo de seguridad (OWASP A07 – fallas de identificación y autenticación) y sesiones no finalizadas. | Alta | QA Engineer | 2026-09-29 | Resuelto | 2026-09-29 | Se corrigió la revocación del token y se reforzó la suite de seguridad; commit "solución de un bug en el logout". |
| IMP-04 | 2026-09-29 | Los triggers y procedimientos almacenados (RN-001 bloqueo por intentos, RN-012 pedido duplicado) existen en `database/` pero no se migraron a Flyway; la migración `V4` quedó pendiente. **Impacto:** reglas de negocio no aplicadas a nivel de base de datos; deuda técnica que afecta la integridad de los datos. | Alta | Developer Junior Backend | 2026-10-06 | En progreso | — | Se documentó la guía de integración en `database/PENDIENTES_BACKEND.md`; la migración `V4` se ejecutará en el Sprint 2. |
| IMP-05 | 2026-09-08 | Curva de aprendizaje elevada al cambiar el stack de frontend de Angular a Flutter (RSK-02). **Impacto:** riesgo de retraso en el inicio del frontend y de afectar el cronograma de la iteración. | Media | Project Manager | 2026-09-22 | Resuelto | 2026-09-22 | Se realizaron sesiones de pair programming y se fijó una arquitectura por capas reutilizable; el frontend base se entregó el 2026-09-28. |
| IMP-06 | 2026-09-29 | El proyecto Android de Flutter emite una advertencia: varios plugins aplican el Kotlin Gradle Plugin (KGP), que provocará fallos de build en versiones futuras. **Impacto:** deuda técnica; posible fallo del build móvil en actualizaciones de Flutter. | Baja | Developer Junior Frontend | 2026-10-09 | Abierto | — | En análisis; se migrará a Built-in Kotlin siguiendo la guía oficial de Flutter antes de la entrega móvil. |
| IMP-07 | 2026-09-29 | No existe un pipeline CI/CD ni medición automatizada de cobertura de pruebas. **Impacto:** los criterios 1, 2 y 4 del Definition of Done global no pueden verificarse de forma automática. | Media | Software Architect | 2026-10-09 | Abierto | — | En análisis; se definirá un flujo de GitHub Actions (build + test + cobertura) en el Sprint 2. |

---

## 3. Seguimiento de impedimentos abiertos

| Impedimento # | Acción de resolución planificada | Responsable | Fecha comprometida |
| :---: | --- | --- | :---: |
| IMP-04 | Crear `V4__add_triggers_and_stored_procedures.sql` y validar `mvn test` sobre H2/PostgreSQL. | Developer Junior Backend | 2026-10-06 |
| IMP-06 | Migrar el proyecto Android a Built-in Kotlin. | Developer Junior Frontend | 2026-10-09 |
| IMP-07 | Configurar GitHub Actions con ejecución de pruebas y reporte de cobertura. | Software Architect | 2026-10-09 |

---

## 4. Control de versiones

| Versión | Fecha | Descripción | Responsable |
| --- | --- | --- | --- |
| V_1_0_0 | 2026-09-29 | Creación inicial: registro de impedimentos del Sprint 1 (Fase 03: Implementación). | Equipo PIPRE |

---

## 5. Referencia

- **Documentos relacionados:** `01 Informe de estado del proyecto V_1_0_0.md`, `03 Revisión del Sprint V_1_0_0.md`, `04 Retrospectiva del Sprint V_1_0_0.md`.
- **Riesgos:** `docs/02 Planificación/03 Registro de riesgos V_1_0_0.md`.
- **Deuda técnica de base de datos:** `database/PENDIENTES_BACKEND.md`.
