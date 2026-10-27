# Evaluación de Calidad de Código — SonarQube

**Nombre del Proyecto:** PathSeek

**Fecha de Análisis:** 2026-10-27 (corte documental y consulta del servidor; fecha del primer análisis Sonar no disponible).

**Versión del Análisis:** V_1_0_0. **Proyecto Sonar:** `PathSeek-Backend`. **Rama de trabajo:** `feature/sprint03-qa`.

## 1. Resumen Ejecutivo de Quality Gate

- **Estado del Quality Gate:** PASSED, resultado del primer análisis verificado por el usuario; no vuelto a comprobar por API autenticada.
- **Porcentaje de Cobertura de Pruebas:** 85,8 % global SonarQube, mismo corte histórico.
- **Duplicación de Código:** 1,7 %, mismo corte.
- **Problemas abiertos:** 2 según ese análisis. No se declaran cerrados por correcciones locales.

Quality Gate (conjunto de condiciones automáticas de aceptación del análisis) aprobado no equivale a ausencia de vulnerabilidades. Tampoco prueba que cada historia cumpla el DoD ni que los cambios locales se hayan analizado.

Consulta directa: servidor `http://localhost:9000` UP, versión `26.10.0.133078`; medidas, issues, hotspots y último análisis devuelven 401 (requieren autenticación). No se conoce analysisId, fecha exacta, perfil de reglas ni condiciones del Gate. Detalle reproducible en [E02–E04](evidencias/01%20Registro%20de%20evidencias%20QA.md).

## 2. Métricas Principales

### Métricas aportadas y clasificación

| Categoría de la plantilla | Cantidad detectada | Severidad / procedencia | Interpretación |
| --- | --- | --- | --- |
| Bugs | No desglosada por tipo legado | 1 problema de fiabilidad, Medium, según usuario | Registrar fiabilidad sin asumir automáticamente `type=BUG` de la API. |
| Vulnerabilidades | No confirmada por API ni explotación | 1 problema de seguridad, High, según usuario | Issue de seguridad no demuestra vulnerabilidad explotable. Falta tipo exacto y revisión. |
| Code Smells | No desglosada por tipo legado | 0 problemas de mantenibilidad abiertos, según usuario | No se inventa métrica `code_smells` a partir de una clasificación distinta. |
| Security Hotspots | **No disponible** | Cantidad y revisión pendientes; API 401 | No registrar cero ni confundirlos con los dos issues. |

Sonar puede presentar categorías por impacto (seguridad, fiabilidad, mantenibilidad) o tipos de incidencia. Sin respuesta autenticada, no se fuerza una equivalencia entre ambos modelos.

La documentación actual de SonarSource indica una transición de reglas que antes producían
hotspots hacia issues de seguridad/vulnerabilidades. Por ello, en este servidor 26.10 hay que
consultar tipo y capacidades reales: no asumir que S4502 siga siendo un hotspot ni que
`/api/hotspots/search` y las métricas heredadas estén disponibles tras autenticarse.

### Tres cortes que deben mantenerse separados

| Corte | Fuente | Casos / resultado | Cobertura |
| --- | --- | --- | --- |
| Primer análisis Sonar | Información verificada por usuario | 2 problemas, Gate PASSED | Global 85,8 %; duplicación 1,7 %. |
| Baseline Maven/JaCoCo | Resultado anterior aportado por usuario | 121 casos reportados, 0 fallos/errores, 3 omitidos | Líneas 92,38 %; ramas 69,54 %. |
| Árbol local posterior a correcciones | XML Surefire y JaCoCo leídos directamente | 131 casos acumulados, 129 aprobados, 0 fallos/errores, 2 omitidos | Líneas 92,41 % (2.106/2.279); ramas 69,73 % (652/935). |

Cobertura de líneas indica líneas ejecutadas; cobertura de ramas indica alternativas recorridas en decisiones. Sonar y JaCoCo pueden tener ámbito, fórmulas y análisis distintos: no se atribuye la diferencia a una corrección sin comparar scope y analysisId. No hay medición de cobertura de código nuevo disponible para certificar el DoD ≥ 80 % en cada cambio.

### Pruebas y artefactos

El [registro E06–E09](evidencias/01%20Registro%20de%20evidencias%20QA.md) contiene las 13 suites. Los reportes proceden de `clean verify` completo y un `verify` adicional de GenerationPerformanceTests con `PATHSEEK_LOAD_TEST=true` en la etapa anterior. Esta etapa documental solo los leyó.

- SecurityIntegrationTests: 27 casos aprobados.
- StreetGeometryTests: 7 casos aprobados.
- Dos casos Flyway omitidos porque requieren PostgreSQL real.
- El escenario 1.000/50 sí figura ejecutado en la segunda ejecución local H2; no es una prueba de carga HTTP ni una medida p95 en producción.

JaCoCo XML/HTML y el JAR son artefactos locales bajo target, ignorados por Git. Se conserva el resumen y la huella del XML, sin copiar propiedades de entorno de Surefire. No se modificaron exclusiones para elevar cobertura.

## 3. Plan de Remediación y Deuda Técnica

**Deuda Técnica Estimada:** no disponible desde SonarQube. No se inventan minutos ni horas de remediación. Los plazos de seguimiento propuestos en la retrospectiva no son el indicador de deuda calculado por Sonar.

| Hallazgo del primer análisis | Situación local comprobada | Situación Sonar | Acción verificable |
| --- | --- | --- | --- |
| `java:S4502`, SecurityConfig.java:43 histórico, High | CSRF deshabilitado intencionalmente; Bearer/JSON explícitos, stateless, sin cookies autenticadoras; Basic/form/session logout deshabilitados; seis regresiones nuevas aprobadas | Abierto según baseline; revisión actual no consultable | Revisor AppSec adjunta evidencia y decide Safe si es hotspot o aceptación justificada según tipo. Reevaluar si se incorporan cookies/sesiones. |
| `java:S8786`, StreetGeometryService.java:28 histórico, Medium | `replaceAll` sustituido por recorrido lineal; conserva barras internas y elimina finales. Cuatro regresiones nuevas, una con HTTP local y secuencias de 100.000 barras | Abierto según baseline; no se afirma cierre automático | Publicar nuevo análisis del árbol corregido y comprobar estado resuelto de la misma incidencia. |

Las líneas citadas pertenecen al primer análisis y pueden haberse desplazado. Identificar por regla y archivo, no por número de línea únicamente.

El fallback OSRM público fue retirado del backend local en la etapa anterior, pero los Compose conservan su valor por defecto. Documentarlo y acordar configuración explícita de proveedor antes del despliegue; no se cambiaron Docker ni variables en esta etapa.

### Distinciones AppSec y Security Hotspots

Un problema de seguridad es una alerta del analizador. Una vulnerabilidad confirmada requiere validación de alcance y explotación/impacto. Un Security Hotspot (punto sensible que requiere revisión humana) no es automáticamente una vulnerabilidad ni un issue abierto de seguridad. La cantidad, estado `TO_REVIEW`/`REVIEWED` y resolución de hotspots no se pudieron consultar; permanecen **pendientes**, sin inventar Hotspot #1 o #2.

Para completar el informe se necesita exportación saneada de medidas, todos los issues y todos los hotspots, con fecha, analysisId, revisión analizada y paginación completa. No incorporar tokens, cookies de sesión ni contraseñas a los artefactos.

## 4. Resultado y límites

Existe una primera evaluación Sonar histórica y evidencia local posterior reproducible. No se certifica Quality Gate actual, cierre de los dos issues, ausencia de críticos en todo el sistema ni deuda cero. Frontend, SQL de producción y dependencias transitivas no quedan certificados por un análisis del backend Java.

## Control de versiones y referencias

| Versión | Fecha | Cambio |
| --- | --- | --- |
| V_1_0_0 | 2026-10-27 | Baseline Sonar, conciliación de pruebas/cobertura y tratamiento sustentado de dos hallazgos. |

- [Documentación de Security Hotspots](https://docs.sonarsource.com/sonarqube-server/user-guide/security-hotspots): revisión humana y diferencia con vulnerabilidades.
- [Cobertura Java](https://docs.sonarsource.com/sonarqube-server/analyzing-source-code/test-coverage/java-test-coverage): importación de JaCoCo.

[README principal](../../../README.md) · [Índice](../../DOCUMENTATION_INDEX.md) · [Revisión](01%20Revisi%C3%B3n%20del%20Sprint%20V_1_0_0.md) · [OWASP](04%20OWASP%20V_1_0_0.md) · [Retrospectiva](02%20Retrospectiva%20del%20Sprint%20V_1_0_0.md)
