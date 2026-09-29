[← Volver al README Principal](../../README.md)

# Retrospectiva del sprint

**Nombre del Proyecto:** PathSeek

**Líder del Proyecto:** Francis Maxuel Urquizo Ore

Proyecto: PathSeek
Código del documento: DOC-023
Versión: V_1_0_0
Fecha: 2026-09-29

---

## 1. Datos de la retrospectiva

| Campo | Valor |
| --- | --- |
| **Sprint** | Sprint 1 (2026-09-14 a 2026-09-25) |
| **Fecha de la sesión** | 2026-09-26 |
| **Facilitador** | Project Manager |
| **Participantes** | Project Manager, Software Architect, Developers (backend y frontend) y QA Engineer |
| **Resultado del Sprint** | 18 / 18 Story Points completados (100 %) |

---

## 2. ¿Qué aprendimos?

- **Separar el entorno de configuración desde el inicio.** El arranque del backend dependía de variables de entorno que Spring Boot no carga por sí solo (IMP-01); documentar `run-local.ps1` y `.env.example` evitó repetir el bloqueo.
- **Definir el contrato de la API antes de integrar.** Acordar el prefijo `/api/v1`, el uso de `snake_case` y la forma del objeto de sesión permitió que el frontend y el backend avanzaran en paralelo sin retrabajos.
- **La seguridad como enabler transversal.** Resolver temprano la autenticación JWT y el RBAC (EN-003) desbloqueó la protección del resto de los CRUD sin rehacerlos.
- **El pair programming acelera la adopción de un framework nuevo.** La curva de aprendizaje de Flutter (IMP-05) se redujo con sesiones guiadas y una arquitectura por capas reutilizable.

---

## 3. ¿Qué estamos haciendo bien?

- **Cumplimiento del compromiso:** se completaron las 4 historias comprometidas (18/18 SP) dentro de las fechas del Sprint.
- **Arquitectura consistente:** backend en capas `Controller → Service → Repository` y frontend `feature-first` por capas; separación limpia de responsabilidades.
- **Calidad incorporada al flujo:** 49 métodos de prueba de backend, 84 casos de frontend y `flutter analyze` sin incidencias.
- **Documentación viva:** Swagger/OpenAPI generado automáticamente y documentación de base de datos con tareas de integración explícitas.
- **Trabajo colaborativo con Pull Requests:** integración revisada por pares mediante PR #4 y #5.

---

## 4. ¿Qué podemos hacer mejor?

### Personas

- El conocimiento del stack de seguridad JWT y del nuevo framework de frontend quedó concentrado en pocas personas; falta rotar responsabilidades y difundir el conocimiento.
- La estimación inicial no contempló el tiempo de configuración del entorno (variables, CORS, puertos), que consumió esfuerzo no planificado.

### Relaciones

- La comunicación con el área logística de la UGEL Huancayo fue suficiente para el Sprint 1, pero conviene formalizar una reunión de validación temprana a mitad de iteración.
- La coordinación entre frontend y backend dependió de acuerdos informales; falta un espacio fijo de sincronización técnica.

### Procesos

- No existe aún un pipeline CI/CD que ejecute pruebas y mida cobertura automáticamente (IMP-07), por lo que los criterios del DoD se verifican de forma manual.
- La deuda técnica de base de datos (triggers y procedimientos almacenados) se detectó al final y quedó fuera del Sprint (IMP-04).
- La definición de "terminado" se aplicó de forma parcial: la revisión por pares se cumplió, pero la cobertura automatizada quedó pendiente.

### Herramientas

- Las capturas de evidencias de Jira siguen pendientes y deben recortarse a los paneles exigidos por la consigna.
- El build Android de Flutter emite advertencias del Kotlin Gradle Plugin (IMP-06) que se convertirán en fallos en versiones futuras.
- Falta un tablero de métricas de calidad (cobertura, deuda técnica) accesible para el equipo.

---

## 5. Acciones a realizar

| # | Acción | Tipo | Responsable | Fecha comprometida |
| :---: | --- | --- | --- | :---: |
| A-01 | Migrar triggers y procedimientos almacenados a la migración Flyway `V4` y validarla con pruebas. | Procesos | Developer Junior Backend | 2026-10-06 |
| A-02 | Configurar GitHub Actions con build, pruebas y reporte de cobertura. | Herramientas | Software Architect | 2026-10-09 |
| A-03 | Realizar una sesión de transferencia de conocimiento sobre seguridad JWT/RBAC y Flutter. | Personas | Software Architect / Developer Frontend | 2026-10-03 |
| A-04 | Establecer una reunión técnica semanal fija de sincronización frontend-backend. | Relaciones | Project Manager | 2026-10-02 |
| A-05 | Incorporar la configuración del entorno y el pipeline a la checklist de planificación del Sprint. | Procesos | Project Manager | 2026-10-02 |
| A-06 | Adjuntar las 5 evidencias de Jira recortadas exclusivamente a cada panel. | Herramientas | Project Manager | 2026-10-05 |
| A-07 | Planificar la migración del proyecto Android a Built-in Kotlin. | Herramientas | Developer Junior Frontend | 2026-10-09 |

---

## 6. Control de versiones

| Versión | Fecha | Descripción | Responsable |
| --- | --- | --- | --- |
| V_1_0_0 | 2026-09-29 | Creación inicial: retrospectiva del Sprint 1 (Fase 03: Implementación). | Equipo PIPRE |

---

## 7. Referencia

- **Documentos relacionados:** `01 Informe de estado del proyecto V_1_0_0.md`, `02 Registro de Impedimentos V_1_0_0.md`, `03 Revisión del Sprint V_1_0_0.md`.
- **Riesgos:** `docs/02 Planificación/03 Registro de riesgos V_1_0_0.md`.
