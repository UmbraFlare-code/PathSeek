[← Volver al README principal](../../../README.md)

# Revisión del sprint

- **Proyecto:** PathSeek, optimizador de rutas sostenibles para UGEL Huancayo
- **Líder:** Francis Maxuel Urquizo Ore
- **Iteración:** Sprint 4 (Inspección 5)
- **Corte del sprint:** 2026-11-16
- **Revisión:** V_1_1_0 · 2026-11-17

## Historias de usuario y validaciones del sprint

El backlog suma 89 puntos en 19 ítems. La revisión anterior registró 14 puntos para el Sprint 4. Con las estimaciones del backlog, los cuatro enablers suman 11 puntos y el trabajo QA-E2E añade 1 punto de alcance del sprint. Jira debe conciliar la aceptación y el cómputo acumulado de los ítems que ya figuraron en otros sprints. [Backlog canónico](../../02%20Planificaci%C3%B3n/01%20Transformando%20a%20%C3%A1gil%20V_1_1_0.md) · [Cierre de Jira](../../02%20Planificaci%C3%B3n/02%20Artefactos%20Jira%20V_1_1_0.md#48-cierre-del-sprint-4-inspecci%C3%B3n-5)

| Ítem | SP | Verificación disponible | Pendiente de aceptación |
| --- | ---: | --- | --- |
| EN-005 Escalabilidad | 3 | En PostgreSQL 16 con PostGIS, el escenario sintético asignó 1.000 pedidos con 50 vehículos en 4,91 s de un máximo de 45 s. `EXPLAIN` confirmó el uso del índice GiST en la consulta de proximidad. | Medición representativa p95 en staging. |
| EN-006 Accesibilidad | 3 | Idioma español declarado, configuración de viewport que permite zoom y menú lateral en el árbol semántico. Axe y login por teclado pasaron en los tres navegadores. En Chromium también se comprobó la activación por teclado y axe en pedidos, rutas, reportes y compensación. | Recorrido completo por teclado y lector de pantalla, contraste de los elementos dibujados en el canvas y revisión de los criterios AA restantes. |
| EN-007 Modo conductor y usabilidad | 3 | El informe registra SUS global de **81,67/100** con seis respuestas. | Evidencia de uso del APK en campo sin ayuda y encuesta de satisfacción específica de conductores **≥ 4/5**. |
| EN-009 Documentación y API | 2 | Manuales de usuario y administrador y contexto logístico. Se verificó el OpenAPI 3.1 generado por el backend de pruebas con los endpoints de salud, reoptimización y PDF. | Corroborar la versión expuesta en el ambiente de entrega. |
| QA-E2E | 1 | Playwright aprobó 33 casos locales sobre Flutter Web compilado y una API con PostgreSQL. La suite cubre formulario, autenticación, autorización, módulos principales, PDF y resiliencia. | Adjuntar la corrida de GitHub Actions de la revisión corregida. |

### Definition of Done

GitHub Actions guarda los resultados de Maven y Flutter, los reportes JaCoCo y LCOV y la cobertura de las líneas modificadas que reportan esas herramientas en los PR. El criterio del backlog es **≥ 80 %**. La existencia de un reporte global o un número de pruebas aprobadas no acredita por sí sola la cobertura de cada cambio.

La ejecución local de regresión aprobó 292 casos de Flutter y 118 de Maven. Maven omitió cuatro casos condicionales en la configuración por defecto. Los tres casos del perfil de carga con PostGIS pasaron en su ejecución específica. El cálculo de cobertura por cambio cubrió las cuatro líneas de Flutter reportadas por LCOV. La inicialización de semántica web se verificó mediante Playwright.

El despliegue exige una ejecución exitosa de CI en `main`, el webhook de Dokploy y respuestas HTTPS del frontend compilado y la API. La corrida histórica quedó marcada como exitosa con un webhook simulado y código HTTP `000`. [Log de GitHub Actions](https://github.com/UmbraFlare-code/PathSeek/actions/runs/44010264499/job/133795319138)

La configuración de GitHub requiere el secreto `DOKPLOY_WEBHOOK_URL` y la variable `PRODUCTION_BASE_URL` con el origen HTTPS de la instancia. El workflow verifica la disponibilidad de la web y de la API. El registro de Dokploy debe vincular la revisión de Git con el despliegue efectivo. [Workflow](../../../.github/workflows/deploy-production.yml)

## Demostración del trabajo completado

El [informe de Playwright](03%20Analisis%20PlayWrigth%20V_1_0_0.md) documenta cómo reproducir login por teclado, permisos del backend, pedidos, rutas, mapa, compensación, descarga PDF y consulta de una ruta almacenada durante una interrupción de red. Se usa una base aislada con datos de demostración.

La revisión anterior registró una demostración ante UGEL Huancayo el 14 de noviembre. Está pendiente adjuntar el acta firmada o un registro de conformidad que permita verificar fecha, asistentes, versión presentada y alcance aceptado.

## Pendientes

- Ejecutar en staging las mediciones p95 con datos independientes. Usar `backend/tools/benchmark_generation.py` y `backend/tools/benchmark_reoptimization.py` con la URL del entorno, un JWT temporal de pruebas en `PATHSEEK_BENCH_TOKEN` y eventos preparados para reoptimización. Guardar los JSON junto con el SHA y la configuración de staging.
- Adjuntar la evidencia WCAG de los flujos no auditados, la prueba de campo del APK y la encuesta de conductores.
- Conciliar las estimaciones y los estados en Jira, adjuntar el acta y enlazar las ejecuciones de CI y Dokploy de la versión entregada.
- Mantener en el backlog de evolución la evaluación de tráfico en tiempo real, iOS y caché de teselas de mayor resolución. [Retrospectiva](02%20Retrospectiva%20del%20Sprint%20V_1_0_0.md)

[← Volver al README principal](../../../README.md)
