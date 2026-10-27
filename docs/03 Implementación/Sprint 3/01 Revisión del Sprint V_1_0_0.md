# Revisión del sprint

**Nombre del Proyecto:** PathSeek

**Líder del Proyecto:** Francis Maxuel Urquizo Ore (según documentación histórica).

**Versión:** V_1_0_0. **Fecha del corte documental:** 2026-10-27. **Sprint histórico:** 2026-10-12 a 2026-10-23. **Rama auditada:** `feature/sprint03-qa`.

Esta revisión consolida evidencia técnica; no constituye acta de una nueva reunión ni aceptación del producto. Los términos D/H/P y los cortes de métricas se definen en el [registro de evidencias](evidencias/01%20Registro%20de%20evidencias%20QA.md). Se siguen las secciones de la [consigna recibida](evidencias/00%20Consigna%20y%20r%C3%BAbrica%20recibidas.md).

## Historias de Usuario completadas en este Sprint

La revisión histórica registra los ítems siguientes como Done (terminados). La columna de auditoría indica qué puede sustentarse ahora; no se reabre ni se cierra Jira sin autorización del equipo.

| Ítem | SP del backlog | Implementación/evidencia disponible | Dictamen de auditoría |
| --- | ---: | --- | --- |
| US-006 Reoptimización dinámica | 8 | RouteReoptimizationService; 16 casos de ReoptimizationIntegrationTests; incidentes, cancelación, avería e idempotencia | Implementación y regresiones verificables; demostración humana pendiente de evidencia. |
| EN-002 Rendimiento de reoptimización | 5 | Presupuesto de ejecución y benchmark local; herramientas en backend/tools | Parcial para SLA: falta p95 en staging y repetición representativa. |
| US-004 Clientes | 2 | ClientController/Service; pruebas de identidad y preferencias en Sprint3ModulesIntegrationTests | Implementación y regresiones verificables; aceptación del stakeholder no acreditada aquí. |
| US-009 Reportes sostenibles | 5 | SustainabilityReportService/OpenPDF; regresiones PDF y rango de fechas | Implementación comprobable; métricas del reporte son estimaciones del optimizador. |
| US-010 Compensación de carbono | 3 | CarbonOffsetService; regresiones de agregación y emisiones cero | Implementación comprobable; no prueba compensación efectivamente realizada ni créditos certificados. |
| EN-007 Usabilidad del conductor | 3 | UI/avisos descritos históricamente | Parcial: sin encuesta de campo ≥ 4/5 ni usuarios representativos. |
| EN-008 Offline | 3 | Caché/cola documentadas; endpoints de ejecución e idempotencia probados | Parcial para experiencia integral: sin prueba nueva de navegador/APK ni teselas offline. |
| EN-009 Documentación y API | 2 | Swagger, manuales históricos y estos cinco informes | Documentación consolidada; consigna PFA adicional y validaciones externas pendientes. |

La suma es 31 SP como alcance histórico. **No equivale a 31 SP nuevamente aceptados bajo el DoD.** Los 75/89 SP históricos requieren reconciliar EN-007/008 ya contados en Sprint 2, diferencias de estimación EN-004 y la evidencia de aceptación. No se calcula una velocidad nueva con esos datos.

### Verificación del Definition of Done

DoD (Definition of Done, condiciones para considerar terminado un ítem): [backlog](../../02%20Planificaci%C3%B3n/01%20Transformando%20a%20%C3%A1gil%20V_1_1_0.md).

| Condición | Evidencia actual | Límite |
| --- | --- | --- |
| Cobertura ≥ 80 % de código nuevo/modificado | Global Sonar histórico 85,8 %; JaCoCo local 92,41 % líneas | No se dispone de métrica de código nuevo por ítem; global no la sustituye. |
| Análisis estático sin críticos/bloqueantes | Gate histórico PASSED; dos issues abiertos declarados | API de proyecto 401; no certifica ausencia universal de vulnerabilidades. |
| Peer review aprobado | Historial de integración y PRs citados | No se consultaron aprobaciones de PR para los cambios locales actuales. |
| Despliegue automatizado en staging | Workflows presentes | No se ejecutó ni verificó el despliegue de este árbol de trabajo. |
| API/documentación actualizada | Código OpenAPI y manuales; cinco informes | Validación documental, no prueba en vivo de todos los endpoints. |
| Criterios funcionales ejecutados | Reportes locales: 129 aprobados de 131; dos PostgreSQL omitidos | No se verificaron todos los criterios Gherkin de todos los ítems. |
| OWASP y accesibilidad | Matrices de los informes 04 y 05 | Revisión parcial; sin auditoría WCAG completa ni pentest. |
| Sin deuda crítica | Dos hallazgos con tratamiento local documentado | Cierre Sonar y hotspots no verificables sin autenticación. |

## Demostración del trabajo completado

El [acta histórica de revisión](../Sprint%203/14%20Revisi%C3%B3n%20del%20Sprint%203%20V_1_0_0.md) afirma una reunión con equipo/supervisor y una futura demostración a UGEL. No se encontraron acta firmada, grabación ni checklist de aceptación que permitan repetir esa afirmación como hecho observado. No hubo nueva demostración en esta etapa.

| Escenario para la demostración | Evidencia técnica existente | Evidencia humana requerida |
| --- | --- | --- |
| Incidente → reoptimización → aviso | Tests de reoptimización y código de bandeja | Grabación saneada y conformidad del operador/conductor. |
| Crear/consultar perfil propio de cliente | Pruebas de permisos y vínculo | Aceptación de flujo por usuario representativo. |
| Generar PDF y plan de carbono | Tests de documento/agrupación | Archivo ejemplo sin datos personales y validación del responsable logístico. |
| Registrar entrega sin red y sincronizar | Código/antecedente de cola e idempotencia | Video en dispositivo con cambio real de conectividad. |
| Login y gestión de vehículos | 27 regresiones de seguridad aprobadas | Demo web y móvil con cuentas de prueba gestionadas fuera del informe. |

## Pendientes

| Prioridad | Pendiente | Evidencia para cerrarlo |
| --- | --- | --- |
| Alta | Acceso de lectura a métricas/issues/hotspots Sonar | Exportación saneada con fecha, analysisId y estados. |
| Alta | Auditoría WCAG 2.2 AA | axe/Lighthouse por pantalla, teclado y lector de pantalla; ver informe 05. |
| Alta | Ratificar Review/Retro y DoD | Acta/checklist de aceptación y acuerdos reales del equipo. |
| Media | PostgreSQL/Flyway y p95 staging | Ejecución en entorno de pruebas autorizado; fuera de esta etapa documental. |
| Media | SP y cierre de EN-007/008 | Exportación Jira con estimación, sprint y aceptación, evitando doble contabilización. |
| Media | Nueva ejecución Sonar | Confirmar S8786 y revisar S4502; no cambiar estados basándose solo en código local. |
| Media | Consigna PFA | Adjuntar norma completa para comprobar requisitos adicionales. |

### Matriz de los ocho criterios oficiales

«Cumplido» significa cumplimiento sustentado del criterio, no calificación académica asignada.

| # | Criterio | Estado | Evidencia / documento | Intervención necesaria |
| --- | --- | --- | --- | --- |
| 1 | Revisión | Parcial | Este informe, matriz de historias y DoD | Acta/demo y aceptación de stakeholders. |
| 2 | Retrospectiva | Parcial | [Informe 02](02%20Retrospectiva%20del%20Sprint%20V_1_0_0.md), cuatro ejes y acciones concretas | Ratificar responsables/plazos y acuerdos. |
| 3 | Calidad Sonar | Parcial | [Informe 03](03%20Calidad%20de%20c%C3%B3digo%20V_1_0_0.md), baseline y reportes directos | Métricas autenticadas, deuda y hotspots. |
| 4 | OWASP 2025 | Parcial | [Informe 04](04%20OWASP%20V_1_0_0.md), diez categorías oficiales | Hotspots/estado Sonar y pruebas adicionales. |
| 5 | WCAG AA | Parcial | [Informe 05](05%20WCAG%20V_1_0_0.md), cuatro principios, contrastes y plan por pantalla | Navegador habilitado, reportes axe/Lighthouse y revisión manual. |
| 6 | Organización e ignore | Cumplido | Frontend/backend separados; E14; ignore efectivo de temporales | Mantener higiene en futuros cambios. |
| 7 | Coherencia/versionado | Cumplido | Fe de erratas formal en documentos afectados; conciliación en este informe | Ratificación de cifras históricas sigue como pendiente explícito. |
| 8 | Ruta/enlaces | Enlaces cumplidos; excepción de nombre documentada | Cinco informes y dos registros en Sprint 3 por decisión explícita del equipo, distinta de Sprint 03 en la consigna | No se declara coincidencia literal con la rúbrica; consigna PFA adicional sin evaluar. |

### Organización, versiones y enlaces

### Contradicciones identificadas y resolución documental

| Contradicción demostrada | Resolución de este corte |
| --- | --- |
| Histórico: 124 pruebas = 121 + 2 PostgreSQL + 1 carga | Se corrige doble conteo: 121 ya incluía tres omitidas; 131 es el agregado posterior, no el baseline. |
| Gate PASSED frente a dos issues abiertos | Gate es una política, no ausencia de hallazgos; se conservan ambos abiertos hasta evidencia de servidor. |
| Regex corregida en fuentes frente a issue abierto | Separar estado local de estado del análisis; no se marca como resuelto en Sonar. |
| HTTPS como garantía de cumplimiento OWASP | Se rectifica en retrospectiva S2: es control de transporte, no certificación de diez categorías. |
| Declaración WCAG 2.1 AA frente a auditoría pendiente | Se limita afirmación S2 y se documenta evaluación parcial 2.2 AA. |
| EN-005 Done por benchmark local | Se rectifica informe S3: no hay PostGIS ni evidencia de índice/SLA PostgreSQL en esa prueba. |
| DoD dice Jest/Jasmine frente a Java/Flutter | Backlog actualizado documentalmente a JaCoCo/JUnit y Flutter; cobertura nueva sigue pendiente. |
| SP históricos EN-004 y EN-007/008 inconsistentes | Se anotan diferencias sin inventar una cifra definitiva; requiere Jira/aceptación del equipo. |
| Manual dice que respuestas no exponen tokens | Se corrige: login/refresh devuelven tokens por contrato; hashes y stack traces no deben exponerse. |
| OSRM con fallback en Java y Compose | Documento actualizado: backend local ahora exige URL; Compose conserva fallback. |
| Metadatos V_1_3_0 frente a historial V_1_4_0 | Metadatos de planificación conciliados a V_1_5_0 con entrada fechada de esta auditoría. |
| Misma numeración IMP-08/09/10 con distintos eventos S2/S3 | Se aclara lectura con prefijo de sprint; no se fusionan eventos ni resoluciones. |

### Verificación de organización

**Decisión explícita y definitiva del equipo:** la carpeta única es `docs/03 Implementación/Sprint 3/`. Difiere del nombre `Sprint 03` indicado en la consigna; la excepción queda registrada sin declarar cumplimiento literal de esa denominación. Reúne informes y antecedentes, sin carpeta duplicada ni cambios en la numeración histórica. La versión efectiva figura en metadatos y control de cambios, aunque el nombre histórico permanezca V_1_0_0 para conservar referencias. V_1_0_0 de los cinco informes es su primera edición consolidada, con esta decisión incorporada antes de su primer commit.

El validador comprueba destinos de enlaces Markdown locales de README y docs, decodifica espacios/acentos y verifica su existencia. No certifica URLs externas, contenido de páginas, rutas en texto sin enlace ni anclas de encabezado. `.gitignore` no elimina secretos ya rastreados: el chequeo no es un escaneo exhaustivo de toda la historia Git.

## Control de versiones

| Versión | Fecha | Cambio |
| --- | --- | --- |
| V_1_0_0 | 2026-10-27 | Consolidación documental basada en consigna, evidencia y limitaciones. Sin nueva reunión ni aceptación atribuida. |

[README principal](../../../README.md) · [Índice documental](../../DOCUMENTATION_INDEX.md) · [Retrospectiva](02%20Retrospectiva%20del%20Sprint%20V_1_0_0.md) · [Calidad](03%20Calidad%20de%20c%C3%B3digo%20V_1_0_0.md) · [OWASP](04%20OWASP%20V_1_0_0.md) · [WCAG](05%20WCAG%20V_1_0_0.md)
