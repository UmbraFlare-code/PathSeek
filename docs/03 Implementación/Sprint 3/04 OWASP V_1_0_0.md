# Reporte de Seguridad OWASP Top 10 (2025)

**Nombre del Proyecto:** PathSeek

**Herramienta de Escaneo:** SonarQube local, proyecto `PathSeek-Backend`; evaluación complementaria mediante inspección de fuentes y lectura de resultados funcionales existentes.

**Fecha / versión:** 2026-10-27 / V_1_0_0. **Rama:** `feature/sprint03-qa`.

## 1. Matriz de Cumplimiento OWASP Top 10 2025

Se utiliza la [clasificación oficial OWASP 2025](https://owasp.org/Top10/2025/), consultada en esta auditoría. La plantilla académica recibida se conserva en la [consigna](evidencias/00%20Consigna%20y%20r%C3%BAbrica%20recibidas.md); mezcla principalmente numeración 2021 con el título 2025. La matriz siguiente corrige la clasificación del informe sin alterar lo que el docente proporcionó.

Estados de la plantilla: **Limpio**, **Vulnerable**, **Bajo Revisión**. Todos quedan Bajo Revisión: hay controles verificados y riesgos acotados, pero ninguna categoría dispone de evaluación completa para declararla Limpia, ni de explotación demostrada para declararla Vulnerable en su totalidad.

### Correspondencia con la plantilla académica

| Plantilla recibida | Clasificación oficial 2025 utilizada |
| --- | --- |
| A01 Broken Access Control | A01 Broken Access Control |
| A02 Cryptographic Failures | A04 Cryptographic Failures |
| A03 Injection | A05 Injection |
| A04 Insecure Design | A06 Insecure Design |
| A05 Security Misconfiguration | A02 Security Misconfiguration |
| A06 Vulnerable and Outdated Components | A03 Software Supply Chain Failures, alcance ampliado |
| A07 Identification and Authentication Failures | A07 Authentication Failures |
| A08 Software and Data Integrity Failures | A08 Software or Data Integrity Failures |
| A09 Security Logging and Monitoring Failures | A09 Security Logging and Alerting Failures |
| A10 SSRF | Sin categoría autónoma en 2025; evaluar el riesgo en A01 según el caso. A10:2025 trata condiciones excepcionales. |

### Evaluación basada en evidencia

Las referencias E02–E10 remiten al [registro](evidencias/01%20Registro%20de%20evidencias%20QA.md). Los hallazgos de Sonar por categoría no se inventan: las dos reglas aportadas no incluyen un mapeo OWASP exportado. Su correspondencia temática en esta tabla es análisis manual, no etiqueta confirmada del servidor.

| Categoría oficial | Riesgo y componente | Evidencia disponible | Hallazgos / estado en el proyecto | Limitaciones | Acción recomendada |
| --- | --- | --- | --- | --- | --- |
| **A01:2025 Broken Access Control** | Acceso a flota o recursos de otro usuario; SecurityConfig, CurrentActor y servicios de rutas/clientes | E08/E09: RBAC, filtros de propietario y regresiones con usuarios reales en H2; cookies/sesión no autentican | **Bajo Revisión**. S4502 relacionado temáticamente con CSRF; contexto local justificado. Sin vulnerabilidad confirmada | Sin pentest completo de IDs, todos los roles y objetos en despliegue. URL OSRM proviene de configuración del servidor, no de un parámetro público; SSRF no descartado exhaustivamente | Matriz negativa por endpoint/propiedad; revisar redirecciones/egress del proveedor y futura introducción de cookies. |
| **A02:2025 Security Misconfiguration** | Exposición de Swagger, rutas Actuator o configuración por defecto; SecurityConfig, YAML y Compose | Lectura: Swagger/actuator permitidos; Actuator sin dependencia en pom; CORS orígenes configurados, credenciales false | **Bajo Revisión**. Compose conserva fallback público OSRM; URL retirada solo del backend. S4502 requiere decisión documentada | No inspección del servidor/proxy desplegado, headers ni variables reales. No se publican valores sensibles | Revisar exposición por entorno; proveedor explícito; no asumir que permitir Actuator implica que sus endpoints existan. |
| **A03:2025 Software Supply Chain Failures** | Dependencias comprometidas o builds no reproducibles; pom, Wrapper, pubspec.lock, Actions | Versiones y wrapper visibles; workflows presentes | **Bajo Revisión**. No hay resultado de SCA/SBOM en esta auditoría | Sonar de Java no acredita ausencia de CVE transitivas ni seguridad de Actions | Generar SBOM (inventario de componentes), ejecutar análisis de dependencias y revisar procedencia/pinning en etapa autorizada. |
| **A04:2025 Cryptographic Failures** | Exposición de claves, contraseñas o tokens; JwtService, RefreshTokenService y almacenamiento Flutter | BCrypt, firma HS256, refresh SHA-256 y SecureRandom; E09 prueba hashes; JWT secret por entorno | **Bajo Revisión**. SharedPreferences expone tokens al código cliente; no es almacén secreto frente a XSS | No validación TLS/rotación de claves en producción ni análisis del dispositivo | Evaluar almacenamiento móvil seguro y mitigación XSS web; revisar ciclo de claves y TLS sin copiar secretos. |
| **A05:2025 Injection** | SQL/expresiones/control de datos; repositorios y reporte JDBC | Métodos JPA parametrizados; SustainabilityReportService construye consulta fija y usa parámetros para filtros | **Bajo Revisión**. S8786 era riesgo de coste de regex; no se reclasifica automáticamente como inyección SQL | No fuzzing ni revisión exhaustiva de todas las consultas y salidas | Probar payloads y límites en un entorno dedicado; conservar parametrización y validar entradas. |
| **A06:2025 Insecure Design** | Abuso de procesos, capacidad y planificación concurrente; AuthService, rutas | Reglas de capacidad/ventana, bloqueo de login e idempotencia probados | **Bajo Revisión**. Transacciones largas y dependencia de proveedor pueden afectar disponibilidad | Sin modelo de amenazas completo, prueba de abuso distribuido ni SLA staging | Formalizar amenazas, límites, presupuesto de ejecución y controles de abuso por contexto. |
| **A07:2025 Authentication Failures** | Robo/reuso de sesión; AuthService, RefreshTokenService, UserSessionValidator, Flutter | Firma/expiración, refresh rotativo, revocación, inactividad, bloqueo 3/15 y RBAC; E09 | **Bajo Revisión**. Transporte Bearer comprobado; no se usan roles suministrados libremente por el cliente | Sin prueba de fuerza bruta distribuida, robo de tokens ni toda la concurrencia sobre PostgreSQL | Repetir regresiones contra staging y evaluar protección ante abuso sin cambiar contratos en esta etapa. |
| **A08:2025 Software or Data Integrity Failures** | Alteración de datos, migraciones y entregas; JWT, Flyway, offline y CI | Firma JWT, validación de migraciones configurada e idempotencia; tests de rutas/clientes | **Bajo Revisión**. Existen scripts SQL paralelos a Flyway en despliegue | Dos pruebas Flyway omitidas; sin auditoría de cadena de publicación ni sincronización real del APK | Ejecutar pruebas PostgreSQL autorizadas; reconciliar fuente única de esquema y validar integridad de artefactos. |
| **A09:2025 Security Logging and Alerting Failures** | Incidentes sin detección; GlobalExceptionHandler, logs de reoptimización y auditoría SQL | Logging de errores y eventos, tabla/triggers de auditoría documentados | **Bajo Revisión**. No evidencia de alertas, retención y monitoreo de seguridad completos | No inspección de logs productivos ni pruebas de alertado; evitar filtración de secretos en excepciones | Definir eventos de seguridad, saneamiento, retención y alertas comprobables. |
| **A10:2025 Mishandling of Exceptional Conditions** | Agotamiento de recursos y fallos ante proveedor/datos; StreetGeometryService y manejo global | Timeout, límite/cache, fallback, interrupción preservada; pruebas de JSON/proveedor inválidos | **Bajo Revisión**. S8786 corregido localmente por recorrido O(n), aún abierto según baseline Sonar | No nuevo análisis autenticado ni prueba de fallos general en producción | Confirmar cierre de regla y evaluar condiciones excepcionales sin ocultar fallos ni enviar stack traces al cliente. |

## 2. Detalles de Security Hotspots y Vulnerabilidades Críticas

### Resultado consultable

Servidor UP; `/api/hotspots/search?projectKey=PathSeek-Backend&ps=100` devuelve 401. **Cantidad de hotspots: desconocida. Estado de revisión: desconocido.** No se inventan Hotspot #1/#2 ni se supone que coinciden con S4502/S8786.

El usuario verificó dos problemas abiertos: seguridad High y fiabilidad Medium. No hay prueba suficiente para afirmar vulnerabilidades críticas confirmadas ni ausencia de ellas. Cero problemas de mantenibilidad reportados no significa deuda técnica cero.

### Tratamiento de los dos hallazgos conocidos

| Regla | Hallazgo del análisis inicial | Evidencia local | Estado de cierre |
| --- | --- | --- | --- |
| java:S4502 | CSRF deshabilitado, ubicación histórica SecurityConfig.java:43 | Header Bearer explícito; refresh/logout JSON; sin cookies autenticadoras/sesiones; CORS sin credenciales; regresiones aprobadas | Decisión técnicamente justificada para diseño actual. Revisión Safe/Accepted según tipo pendiente en Sonar. |
| java:S8786 | Regex con retroceso no lineal, StreetGeometryService.java:28 histórico | Recorrido final lineal, pruebas largas y HTTP local; comportamiento de barras conservado | Corregido en árbol local; sigue abierto según último corte informado. Reanálisis pendiente. |

CSRF (petición falsificada aprovechando credenciales automáticas del navegador) y XSS (ejecución de código malicioso en el origen legítimo) son riesgos distintos. La justificación de CSRF no protege los tokens de SharedPreferences frente a XSS.

### Análisis estático frente a seguridad funcional

Sonar inspecciona código sin ejecutar todos sus flujos: una alerta es un indicio que requiere contexto. Los tests funcionales existentes ejecutan rutas concretas con H2 y MockMvc; comprueban respuestas, autorización y efectos, pero no sustituyen pentest, inspección de navegador o pruebas de infraestructura. Aquí solo se recopilaron sus resultados, sin ejecutar ataques ni alterar el sistema.

### Evidencia requerida para completar seguridad

Exportar todas las páginas de hotspots e issues con rule, archivo, estado, resolución, severidad/impacto, fecha y analysisId; revisar cada hotspot y anexar justificación sin secretos. Repetir análisis sobre revisión identificable y conservar decisión del revisor. Un nuevo análisis sin esos datos no autoriza a marcar una categoría «Limpio».

## Control de versiones

| Versión | Fecha | Cambio |
| --- | --- | --- |
| V_1_0_0 | 2026-10-27 | Diez categorías oficiales, correspondencia docente y límites de evidencia Sonar/funcional. |

[README principal](../../../README.md) · [Índice](../../DOCUMENTATION_INDEX.md) · [Revisión](01%20Revisi%C3%B3n%20del%20Sprint%20V_1_0_0.md) · [Calidad](03%20Calidad%20de%20c%C3%B3digo%20V_1_0_0.md) · [Evidencias](evidencias/01%20Registro%20de%20evidencias%20QA.md)
