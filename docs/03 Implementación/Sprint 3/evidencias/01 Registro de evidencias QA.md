# Registro de evidencias QA — corte 2026-10-27

Versión V_1_0_0. Rama `feature/sprint03-qa`. HEAD observado: `3d779b95103e1ea7f8636159a114c17024252bcb`. El árbol contiene cambios locales de etapas anteriores: el HEAD por sí solo no reproduce el código medido. Esta etapa no ejecutó Maven ni modificó esos cambios.

## Procedencia

- **D:** evidencia directa obtenida en esta auditoría mediante lectura de archivos, consultas HTTP y cálculos.
- **H:** antecedente documental o resultado aportado por el usuario; no reproducido aquí.
- **P:** evaluación pendiente, valor desconocido o acceso bloqueado.

## Inventario

| ID | Tipo | Fuente / método | Resultado y límite |
| --- | --- | --- | --- |
| E01 | D | `git branch --show-current`, `git status`, `git rev-parse HEAD` | Rama correcta; cambios locales previos en backend y `frontend/pubspec.lock`. No se cambió la rama. |
| E02 | H | Primer análisis SonarQube indicado por el usuario | Proyecto `PathSeek-Backend`: Gate PASSED, cobertura 85,8 %, duplicación 1,7 %, dos problemas; seguridad alta 1, fiabilidad media 1, mantenibilidad 0. Sin exportación autenticada ni ID/fecha del análisis. |
| E03 | D | `GET http://localhost:9000/api/system/status`, consulta fuera del aislamiento | HTTP 200, `status=UP`, versión `26.10.0.133078`. La consulta aislada había fallado; se descartó ese falso negativo. |
| E04 | D/P | API local: medidas, issues abiertos, hotspots y último análisis | Cuatro consultas devuelven HTTP 401 sin autenticación. Cantidad y revisión de hotspots desconocidas; no equivalen a cero. No se usó ni se solicitó token en mensajes. |
| E05 | H | Baseline Maven/JaCoCo facilitado por el usuario | 121 casos reportados, 0 fallos, 0 errores, 3 omitidos; líneas 92,38 %, ramas 69,54 %. 121 incluye los omitidos; no son 124. |
| E06 | D | Lectura de XML Surefire locales | 13 suites, 131 casos, 0 fallos, 0 errores, 2 omitidos. Es un agregado de una suite completa y una ejecución adicional de GenerationPerformanceTests; no una única ejecución de 131 activos. |
| E07 | D | Lectura de `backend/target/site/jacoco/jacoco.xml` | Líneas 2.106 cubiertas / 2.279 = 92,41 %; ramas 652 / 935 = 69,73 %; 126 clases. Cobertura acumulada local posterior a correcciones. |
| E08 | D | Código de SecurityConfig/AuthController, Flutter ApiClient/AuthRemoteDataSource/SharedPrefsTokenStorage | Bearer explícito; login y refresh/logout en JSON; stateless; CORS sin credenciales; sin cookies autenticadoras. Son inspección de fuentes y regresiones previas, no pentest del despliegue. |
| E09 | D | Código y reportes de SecurityIntegrationTests / StreetGeometryTests | 27 y 7 casos, respectivamente; todos aprobados. Incluyen 6 nuevas regresiones de transporte y 4 de normalización. |
| E10 | D | Código actual StreetGeometryService / application.yml | Recorrido lineal sin regex, URL vacía por defecto; respuesta esquemática si falta proveedor. Compose aún inyecta fallback público. Corrección local no certifica cierre de S8786 en Sonar. |
| E11 | D | Inventario navegador/control de Windows | Navegador disponible, pero automatización detenida al no identificar de forma confiable la URL actual. No hubo auditoría axe/Lighthouse, teclado ni lector de pantalla. |
| E12 | D | Lectura de app_theme.dart y cálculo de luminancia sRGB | Cinco ratios de contraste calculados; ver informe WCAG. No son mediciones de píxeles renderizados. |
| E13 | H | Documentos de Sprint 1, 2 y 3 | Cierres, reuniones y SP son afirmaciones históricas; sin actas firmadas o evidencia nueva de stakeholders en esta auditoría. |
| E14 | D | Organización, ignores y enlaces Markdown | Separación frontend/backend/database/docs; target, build, `.env`, logs y `*~` ignorados; sin temporales rastreados en las clases inspeccionadas. Ver alcance del validador en Revisión. |

## Consultas Sonar reproducibles (solo lectura)

Servidor: `http://localhost:9000`. Proyecto: `PathSeek-Backend`.

```text
GET /api/system/status
GET /api/measures/component?component=PathSeek-Backend&metricKeys=alert_status,coverage,line_coverage,branch_coverage,duplicated_lines_density,bugs,vulnerabilities,code_smells,security_hotspots,security_hotspots_reviewed
GET /api/issues/search?componentKeys=PathSeek-Backend&resolved=false&ps=100
GET /api/hotspots/search?projectKey=PathSeek-Backend&ps=100
GET /api/project_analyses/search?project=PathSeek-Backend&ps=1
```

Las cuatro últimas requieren acceso autorizado. Si hay más páginas, exportar todas y conservar paginación, fecha, versión, identificadores de issues y estados. Facilitar exportación saneada o acceso local por entorno, sin pegar secretos en la documentación o el chat.

## Resultados Surefire disponibles

| Suite | Casos | Fallos / errores | Omitidos |
| --- | ---: | --- | ---: |
| ApiIntegrationTests | 7 | 0 / 0 | 0 |
| BackendApplicationTests | 1 | 0 / 0 | 0 |
| CatalogIntegrationTests | 24 | 0 / 0 | 0 |
| FlywayMigrationTests | 2 | 0 / 0 | 2 |
| GenerationPerformanceTests | 2 | 0 / 0 | 0 |
| ReoptimizationIntegrationTests | 16 | 0 / 0 | 0 |
| IncrementalPlannerTests | 6 | 0 / 0 | 0 |
| StreetGeometryTests | 7 | 0 / 0 | 0 |
| RouteIntegrationTests | 15 | 0 / 0 | 0 |
| UserSessionValidatorTests | 2 | 0 / 0 | 0 |
| SecurityIntegrationTests | 27 | 0 / 0 | 0 |
| Sprint3ModulesIntegrationTests | 11 | 0 / 0 | 0 |
| UserAdministrationIntegrationTests | 11 | 0 / 0 | 0 |
| Total acumulado | 131 | 0 / 0 | 2 |

Las dos pruebas Flyway requieren PostgreSQL y permanecen omitidas. Las demás usan H2 y/o pruebas unitarias/HTTP local. No acreditan migraciones ni rendimiento PostgreSQL en producción.

## Integridad y conservación

SHA-256 del XML JaCoCo leído: `96657D8C6C06D963C2985ABB579D679D5466945266410C18C94C10668678D597`.

El XML y el HTML están en `backend/target/site/jacoco/`; los resultados en `backend/target/surefire-reports/`. Son artefactos locales ignorados, por lo que no se enlazan como evidencia portable obligatoria ni se garantiza que sobrevivan a `clean`. Este registro conserva el resumen saneado. No se copian los XML Surefire crudos: pueden contener variables del entorno y datos de pruebas.

Huella del diff no Markdown al iniciar: `DC1725456E9D920B376DF9249FF3F32EF0509E586B230A8FEE6F4BEE06AF8BE8`. Permite comprobar que los cambios funcionales previos no fueron alterados por esta etapa documental; no es una firma del repositorio completo.

## Verificación final de esta etapa

| Comprobación | Resultado directo |
| --- | --- |
| Rama | `feature/sprint03-qa`, conservada. |
| Enlaces locales Markdown | 54 archivos de README/docs inspeccionados, 198 destinos locales verificados, cero destinos inexistentes. No incluye anclas ni URLs externas. |
| Enlaces bidireccionales | Los cinco informes tienen entrada en README/índice y retorno al README/índice. |
| Formato del diff | `git diff --check` sin errores tras corregir dos espacios finales introducidos en metadatos Markdown. |
| Código/configuración/pruebas | Huella del diff no Markdown final idéntica a la inicial indicada arriba. |
| Reporte JaCoCo | SHA-256 final idéntico al inicial. No se regeneró ni reinterpretó como análisis Sonar nuevo. |
| Datos sensibles | Sin coincidencias en los nuevos documentos para los patrones examinados de token Sonar, JWT o Bearer largo; no equivale a auditoría exhaustiva de secretos históricos. |
| Acciones externas de la auditoría documental inicial | Sin commit, push, merge, cambio de rama, despliegue ni cambio de estado de Sonar durante aquella etapa. El cierre Git posterior fue autorizado explícitamente por el usuario. |

Los siete archivos nuevos son cinco informes y dos registros de evidencia. Se actualizaron además README, índice y diez documentos anteriores con contradicciones demostradas. Los cambios funcionales visibles en Git al terminar ya existían al inicio.

## Cierre Git documental autorizado — 2026-10-27

El equipo decidió explícitamente la carpeta única `docs/03 Implementación/Sprint 3/`, distinta de `Sprint 03` indicada en la consigna. Al inspeccionar el cierre, los siete archivos ya estaban en `Sprint 3/`; se corrigieron las referencias pendientes, sin volver a renombrar la carpeta.

Se autorizan dos commits: `docs(sprint-3): add sprint reports and QA evidence` (los siete archivos nuevos) y `docs: update sprint documentation and navigation` (README, índice y diez documentos anteriores), seguidos de push exclusivo a `feature/sprint03-qa`. Los hashes y el resultado efectivo se entregan en el informe final; no se predice el éxito del push en esta evidencia. Código, pruebas, dependencias, configuraciones y el README del backend preexistentes quedan fuera de ambos commits.

[Calidad](../03%20Calidad%20de%20c%C3%B3digo%20V_1_0_0.md) · [OWASP](../04%20OWASP%20V_1_0_0.md) · [WCAG](../05%20WCAG%20V_1_0_0.md) · [Revisión](../01%20Revisi%C3%B3n%20del%20Sprint%20V_1_0_0.md) · [README](../../../../README.md)
