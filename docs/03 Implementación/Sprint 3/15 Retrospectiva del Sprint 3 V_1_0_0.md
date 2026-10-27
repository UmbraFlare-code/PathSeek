[← Volver al README Principal](../../../README.md)

# Retrospectiva del Sprint 3

**Nombre del Proyecto:** PathSeek

**Líder del Proyecto:** Francis Maxuel Urquizo Ore

Proyecto: PathSeek
Código del documento: DOC-032
Versión: V_1_1_0
Fecha: 2026-10-25

> **Aclaración QA 2026-10-27:** se conserva el relato histórico; no se acredita aquí una sesión,
> participantes o compromisos nuevos. La [retrospectiva consolidada](../Sprint%203/02%20Retrospectiva%20del%20Sprint%20V_1_0_0.md)
> contiene acciones propuestas y distingue su ratificación pendiente. Los SP no se vuelven a aceptar.

---

## 1. Datos de la retrospectiva

| Campo | Valor |
| --- | --- |
| **Sprint** | Sprint 3 (2026-10-12 a 2026-10-23) |
| **Fecha de la sesión** | 2026-10-25 |
| **Facilitador** | Project Manager |
| **Participantes** | Project Manager, Software Architect, Developers Junior (Backend y Frontend), QA Engineer y UI/UX Designer |
| **Resultado del Sprint** | 31 / 31 Story Points completados (100 %) |

---

## 2. ¿Qué aprendimos?

- **Reportes PDF sin infraestructura adicional:** OpenPDF (Java puro) permitió generar el reporte de sostenibilidad dentro del mismo backend, sin servidores de reporting ni nuevas instancias.
- **La caché offline es best-effort:** un fallo de almacenamiento local nunca debe romper el flujo en línea; se aislaron las escrituras de caché para que no compitan con la API.
- **Idempotencia como base de la sincronización:** diseñar los endpoints de ejecución (posición y entregas) idempotentes simplificó la cola offline: repetir una acción jamás duplica efectos.
- **Migraciones versionadas:** Flyway registra `V8`/`V9` y aplica cada versión pendiente una vez. La presencia de sentencias idempotentes no autoriza a repetir manualmente toda migración ni demuestra ausencia de riesgo; las pruebas PostgreSQL no se ejecutaron en este corte documental.

---

## 3. ¿Qué estamos haciendo bien?

- **Cumplimiento estricto del compromiso:** 31/31 SP del sprint y 75/89 SP del backlog (84.3 %).
- **Pruebas por módulo:** el baseline correcto es 121 casos backend totales con tres omitidos; 292 frontend es antecedente documental. El corte QA posterior reúne 131 casos backend, 129 aprobados y dos omitidos. Cantidad de pruebas no equivale a cobertura ni aceptación integral.
- **Trazabilidad documental:** cada entrega técnica registra alcance, límites y validación (docs 06–12 y 13–19), sin declarar Done lo que no se verificó.
- **CI por componente:** workflow de frontend (analyze + test) y extensión del workflow de backend con las suites nuevas y las migraciones 08/09.

---

## 4. ¿Qué podemos hacer mejor?

### Personas
- Rotar la revisión de infraestructura para que más integrantes conozcan el despliegue de la VPS.

### Relaciones
- Coordinar la demostración presencial ante UGEL Huancayo y la prueba de campo del APK (encuesta EN-007).
- Confirmar con el docente supervisor el alcance post-MVP (tráfico real, teselas offline).

### Procesos
- Medir p95 de generación y reoptimización en staging con datos representativos antes de declarar los SLA operativos.
- Incorporar auditoría axe/Lighthouse al pipeline o a una tarea QA fija.

### Herramientas
- Revisar un proveedor de tráfico para la congestión por tramo y su presupuesto.
- Evaluar caché de teselas en el APK para el modo offline completo.

---

## 5. Acciones a realizar

| # | Acción | Eje | Responsable | Fecha comprometida |
| :---: | --- | :---: | --- | --- |
| A-13 | Prueba de campo del APK con conductores de UGEL y encuesta de satisfacción (EN-007) | Relaciones | Project Manager / UI/UX | Sprint 4 |
| A-14 | Auditoría axe/Lighthouse y teclado en navegador real (EN-006) | Herramientas | QA / Frontend | Sprint 4 |
| A-15 | Medición p95 de generación y reoptimización en staging (EN-001/EN-002) | Procesos | Software Architect | Sprint 4 |
| A-16 | Evaluar proveedor de tráfico y caché de teselas para el alcance post-MVP | Procesos | Project Manager / Arquitecto | Sprint 4 |

---

## 6. Control de versiones

| Versión | Fecha | Descripción | Responsable |
| --- | --- | --- | --- |
| V_1_0_0 | 2026-10-25 | Creación inicial: retrospectiva del Sprint 3. | Equipo PIPRE |
| V_1_1_0 | 2026-10-27 | Rectifica conteo y distingue retrospectiva histórica de propuestas QA pendientes de ratificación. | Auditoría documental QA |

---

## 7. Referencia

- **Documentos relacionados:** `13 Informe de estado del proyecto Sprint 3 V_1_0_0.md`, `14 Revisión del Sprint 3 V_1_0_0.md`, `16 Registro de Impedimentos Sprint 3 V_1_0_0.md`.
- **Planificación:** `docs/02 Planificación/01 Transformando a ágil V_1_1_0.md`.
