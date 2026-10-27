# Retrospectiva del sprint

**Nombre del Proyecto:** PathSeek

**Líder del Proyecto:** Francis Maxuel Urquizo Ore (referencia histórica).

**Versión:** V_1_0_0. **Fecha:** 2026-10-27. **Alcance:** retrospectiva técnica documental del Sprint 3. La [retrospectiva histórica](../Sprint%203/15%20Retrospectiva%20del%20Sprint%203%20V_1_0_0.md) menciona una sesión anterior; no hay evidencia directa de esa reunión en esta auditoría. Las acciones siguientes son propuestas concretas, pendientes de ratificación del equipo; no compromisos inventados.

## ¿Qué aprendimos?

1. El resultado de una herramienta necesita contexto. Sonar histórico 85,8 % y JaCoCo local 92,41 % pertenecen a métricas y cortes distintos; no se puede atribuir la diferencia únicamente a una mejora del código.
2. El conteo de pruebas debe separar casos, aprobados y omitidos. La frase histórica «124 = 121 + 2 + 1» vuelve a contar tres casos ya incluidos en 121. Hoy existen 131 casos en los reportes, 129 aprobados y dos omitidos.
3. Stateless (sin sesión de servidor) no justifica por sí solo desactivar CSRF. Se inspeccionó cómo Flutter transmite credenciales y se probaron cookies, sesión, Bearer y CORS antes de documentar la decisión.
4. Corrección local y cierre de Sonar son eventos distintos. Sustituir la regex no cambia automáticamente el estado del issue en el último análisis publicado.
5. Etiquetas, foco y colores en Flutter son controles de diseño verificables en fuentes; no acreditan por sí solos el árbol semántico que recibe un lector de pantalla.
6. La demostración funcional y el DoD (condiciones de terminado) requieren evidencias propias. Una suite verde no sustituye encuesta de campo, revisión por pares, p95 de staging o aceptación humana.

## ¿Qué estamos haciendo bien?

- La estructura separa componentes y sus pruebas. Los `.gitignore` evitan rastrear salidas de Maven/Flutter, variables de entorno y temporales en las clases de archivos examinadas.
- Hay pruebas de seguridad y negocio con persistencia H2 real, además de un servidor HTTP local para el proveedor de geometría. Esta etapa no añadió mocks ni cambió las pruebas.
- El tratamiento previo de los dos hallazgos quedó documentado con seis nuevas regresiones de transporte y cuatro de normalización, verificables en los resultados locales.
- La geometría vial distingue un resultado del proveedor y una respuesta esquemática; no presenta una estimación como trazado vial confirmado.
- Se conserva la historia documental y se agregan aclaraciones fechadas, con enlaces a la evidencia actual.

## ¿Qué podemos hacer mejor?

### Personas

Distribuir el conocimiento de JWT, revisión de hotspots y generación/importación de cobertura. Cada revisión debe poder ser repetida por otra persona con resultados saneados y sin depender de credenciales compartidas en un chat.

### Relaciones

Formalizar aceptación con operador, conductor y supervisor. Separar la validación técnica interna de la validación del cliente UGEL. Confirmar participantes y fechas reales antes de publicar actas.

### Procesos

Registrar analysisId, revisión Git, estado del árbol, herramienta, ámbito y fecha en cada medición. Evitar contabilizar nuevamente EN-007/008 al ampliar una entrega entre sprints. Vincular cada criterio del DoD a un artefacto, no a una afirmación global de «100 %».

### Herramientas

Obtener exportaciones de lectura de Sonar; conservar resúmenes QA fuera de target; preparar auditoría real de Flutter Web con semántica activada y teclado. El acceso UI falló por verificación de URL; no debe confundirse ese impedimento con un fallo de accesibilidad de la aplicación.

### Acciones a realizar

Fechas expresadas como plazo desde la ratificación; no se atribuye una fecha comprometida a personas sin su aprobación. Los roles son responsables propuestos.

| ID | Acción verificable | Eje | Responsable propuesto | Plazo propuesto | Evidencia de cierre |
| --- | --- | --- | --- | --- | --- |
| QA-01 | Exportar métricas, issues y hotspots del proyecto, sin secretos | Herramientas | Administrador Sonar / QA | 1 día hábil | JSON saneado, fecha y analysisId. |
| QA-02 | Hacer revisión cruzada de S4502 y confirmar nuevo análisis de S8786 | Personas | Backend / AppSec, con un par técnico | 2 días hábiles | Justificación de Safe/Accepted según tipo y estado real del issue. |
| QA-03 | Ejecutar axe/Lighthouse y recorrido manual por los roles definidos | Herramientas | QA accesibilidad / Frontend | 3 días hábiles | Informes por pantalla, teclado y lector; matriz WCAG completada. |
| QA-04 | Realizar demo y confirmar historias mediante criterios de aceptación | Relaciones | Líder / stakeholder | Próxima sesión que el equipo acuerde | Acta real con asistentes, decisiones y pendientes. |
| QA-05 | Conciliar estimaciones EN-004/007/008 y SP del cierre | Procesos | Líder / responsable de backlog | 2 días hábiles | Exportación Jira y tabla sin doble conteo. |
| QA-06 | Validar cobertura de código nuevo y pruebas PostgreSQL en entorno autorizado | Procesos | Backend / QA | Antes del cierre definitivo | Reporte de código nuevo y ejecución PostgreSQL sin omitidos. |
| QA-07 | Transferir el procedimiento de QA a otro integrante | Personas | QA / Backend | Próxima revisión técnica | Reproducción independiente y checklist firmado. |

Las acciones A-13 a A-16 del documento histórico siguen siendo antecedentes, no se declaran realizadas. QA-03 continúa A-14; QA-04 continúa la validación de campo de A-13; el p95 de A-15 y tráfico/teselas de A-16 siguen pendientes según alcance.

## Control de versiones

| Versión | Fecha | Cambio |
| --- | --- | --- |
| V_1_0_0 | 2026-10-27 | Consolidación con cuatro ejes y acciones propuestas; sin simular una sesión ni acuerdos. |

[README principal](../../../README.md) · [Índice](../../DOCUMENTATION_INDEX.md) · [Revisión](01%20Revisi%C3%B3n%20del%20Sprint%20V_1_0_0.md) · [Evidencias](evidencias/01%20Registro%20de%20evidencias%20QA.md)
