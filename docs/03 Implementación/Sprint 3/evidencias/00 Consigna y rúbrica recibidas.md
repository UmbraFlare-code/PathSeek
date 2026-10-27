# Consigna oficial recibida — Sprint 03

Fecha de incorporación: 2026-10-27. Fuente: transcripción de la consigna y rúbrica proporcionada directamente por el usuario en esta sesión. Asignatura: Taller de Proyectos 2; programa: Ingeniería de Sistemas e Informática. Título: «Consigna Oficial del Sprint 3: Implementación, Calidad de Código y Evaluación».

Este registro conserva los requisitos y las secciones exigidas; es una síntesis trazable de la transcripción, no una copia certificada del HTML docente. La consigna adicional «TP2-ISI Consigna del repositorio PFA» no fue suministrada ni localizada: su comprobación íntegra queda pendiente.

**Decisión posterior explícita del equipo (2026-10-27):** conservar definitivamente `docs/03 Implementación/Sprint 3/` para los cinco informes y los dos registros. Se documenta la diferencia con `Sprint 03` de la fuente académica, que se mantiene literalmente en la tabla siguiente como antecedente. No existe una segunda carpeta para la entrega.

## Entregables y secciones obligatorias

| Ítem | Archivo / requisito | Secciones de la plantilla |
| --- | --- | --- |
| 1 | `01 Revisión del Sprint V_1_0_0.md` | Nombre y líder del proyecto; Historias de Usuario completadas en este Sprint; Demostración del trabajo completado; Pendientes. |
| 2 | `02 Retrospectiva del Sprint V_1_0_0.md` | Nombre y líder; ¿Qué aprendimos?; ¿Qué estamos haciendo bien?; ¿Qué podemos hacer mejor?; Personas, Relaciones, Procesos, Herramientas; Acciones a realizar. |
| 3 | `03 Calidad de código V_1_0_0.md` | Nombre, fecha y versión; 1. Resumen Ejecutivo de Quality Gate; 2. Métricas Principales (Bugs, Vulnerabilidades, Code Smells, Security Hotspots y severidades); 3. Plan de Remediación y Deuda Técnica. |
| 4 | `04 OWASP V_1_0_0.md` | Nombre y herramienta; 1. Matriz de Cumplimiento OWASP Top 10 2025; 2. Detalles de Security Hotspots y Vulnerabilidades Críticas. Estados permitidos: Limpio, Vulnerable, Bajo Revisión. |
| 5 | `05 WCAG V_1_0_0.md` | Nombre, nivel objetivo y herramientas; 1. Resumen de Accesibilidad por Principios; 2. Hallazgos Principales y Correcciones (criterio, problema, componente, solución aplicada). |
| 6 | Organización | Frontend y backend separados; `.gitignore` que evite temporales, incluido `.gitignore~`. |
| 7 | Coherencia | Revisar sprints anteriores; actualizar contradicciones y versionar formalmente. |
| 8 | Ubicación y enlaces | Cinco documentos en `docs/03 Implementación/Sprint 03/`, enlazados desde y hacia README. Respetar también la consigna PFA. |

## Rúbrica recibida

Los ocho ítems tienen igual peso. Niveles: Excelente 100 %, Satisfactorio 75 %, En Proceso 50 %, Insuficiente 0 %. Esta auditoría no asigna nota académica; usa Cumplido / Parcial / Pendiente según evidencia.

| Criterio | Excelente | Satisfactorio | En Proceso | Insuficiente |
| --- | --- | --- | --- | --- |
| 1. Revisión | Secciones completas, historias con DoD, demostración y pendientes reales | Plantilla completa con detalle superficial | Secciones incompletas o pendientes sin detalle | Sin documento o estructura requerida |
| 2. Retrospectiva | Aprendizajes y acciones concretas en cuatro ejes | Acciones vagas | Omite dos o más dimensiones | Sin documento/estructura |
| 3. Calidad | Gate, métricas y plan de deuda | Métricas sin plan explícito | Faltan cobertura o duplicación | Sin análisis o documento |
| 4. OWASP | Diez categorías 2025, hotspots y correcciones | Versión obsoleta o hotspots sin detalle | Mención superficial sin clasificación 2025 | Sin evaluación |
| 5. WCAG | Cuatro principios AA, tabla de hallazgos y correcciones | Sin tabla o componentes | Solo automatización parcial sin interpretación/corrección | Sin evaluación |
| 6. Organización | Separación modular y temporales ignorados | Estructura adecuada con ignore incompleto | Código mezclado | Desorganización y ausencia de ignore |
| 7. Versiones | Documentos afectados actualizados y versionados | Actualizados sin incrementar versión | Contradicciones evidentes | Sin trazabilidad |
| 8. Enlaces | Ruta exacta y enlaces bidireccionales | Ruta correcta con enlaces rotos | Ruta incorrecta o sin README | Incumplimiento total |

## Dos advertencias expresas de la fuente

La tabla docente enumera A02 Cryptographic Failures, A03 Injection, A04 Insecure Design, A05 Security Misconfiguration, A06 Vulnerable and Outdated Components y A10 SSRF bajo el título 2025. Esa numeración corresponde principalmente a 2021; la [evaluación OWASP](../04%20OWASP%20V_1_0_0.md) incluye la correspondencia con 2025 sin atribuir al docente otra tabla.

Los ejemplos WCAG «imagen sin alt», «botón con contraste < 4,5:1» y «menú sin Tab» son ejemplos didácticos. No se registran como fallos reales de PathSeek sin verificarlos.

## Límites de ejecución

Solo documentación y recopilación de evidencia. Sin modificar código, dependencias, configuración, pruebas, SQL o migraciones; sin commit, push, merge ni cambio de rama. No fabricar demostraciones, actas, acuerdos, porcentajes ni resultados.

[Revisión y matriz de cumplimiento](../01%20Revisi%C3%B3n%20del%20Sprint%20V_1_0_0.md) · [README](../../../../README.md) · [Índice](../../../DOCUMENTATION_INDEX.md)
