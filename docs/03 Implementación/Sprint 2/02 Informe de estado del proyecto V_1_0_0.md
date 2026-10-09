[← Volver al README Principal](../../../README.md)

# Informe de estado del proyecto

**Nombre del Proyecto:** PathSeek

**Líder del Proyecto:** Francis Maxuel Urquizo Ore

Proyecto: PathSeek  
Código del documento: DOC-020  
Versión: V_1_0_0  
Fecha: 2026-10-06  

---

## 1. Datos de la iteración

| Campo | Valor |
| --- | --- |
| **Iteración** | Sprint 2 |
| **Duración** | 2 semanas |
| **Fecha de inicio** | 2026-09-28 |
| **Fecha de fin** | 2026-10-09 |
| **Story Points comprometidos** | 26 |
| **Story Points completados** | 26 |
| **Avance de la iteración** | 100 % de los ítems planificados para el Sprint 2 |
| **Día del informe** | 2026-10-06 (cierre y evaluación de iteración) |
| **Ambiente demostrado** | Producción VPS Contabo (`https://169.58.74.99`), Docker Compose, PostgreSQL 16, Spring Boot 4.1.1, Flutter Web y APK Android |

---

## 2. Sprint Goal (objetivo de la iteración)

> **"Implementar el dashboard de indicadores de sostenibilidad y la visualización de rutas optimizadas en tarjetas web y modo móvil adaptativo, desplegando la arquitectura integral en ambiente de producción seguro (HTTPS/Docker) con descarga directa del APK para conductores de UGEL Huancayo."**

El objetivo se cumplió en su totalidad: las funcionalidades de monitoreo de KPIs, gestión y consulta de rutas optimizadas, soporte multiplataforma web/móvil y el despliegue con alta disponibilidad y cifrado SSL en servidor VPS quedaron operativos, probados y validados.

---

## 3. Historias de Usuario completadas en este Sprint

| Clave Jira | Historia de Usuario / Enabler | Tipo | Story Points | Estado | Evidencia principal |
| --- | --- | :---: | :---: | :---: | --- |
| PATHSEEK-10 | **US-008** Dashboard de Indicadores | Story | 5 | **Done** | Vista de indicadores en tiempo real, KPIs de emisiones de CO₂, combustible ahorrado y métricas de flota |
| PATHSEEK-7 | **US-007** Visualización de Rutas en Tarjetas y Detalle | Story | 8 | **Done** | Módulo de rutas `/routes`, detalle de secuencia de entregas `/routes/:id` y vista responsiva |
| PATHSEEK-4 | **US-005** Núcleo de Gestión de Rutas Optimizadas | Story | 5 | **Done** | Estructuras de datos de ruteo, integración de modelos de entrega y compatibilidad con motor de ruteo |
| PATHSEEK-15 | **EN-007 / EN-008** Usabilidad Modo Móvil Conductor y APK | Task | 3 | **Done** | App Flutter responsiva, descarga directa de APK Android (`pathseek.apk`) desde el sidebar y appbar |
| PATHSEEK-11 | **EN-004** Alta Disponibilidad y Despliegue en Producción VPS | Task | 5 | **Done** | `docker-compose.prod.yml`, Nginx HTTPS SSL puerto 443 + redirección 301, healthchecks de contenedores |
| | **Total** | | **26 / 26** | **100 %** | |

Los criterios de aceptación en sintaxis Gherkin de cada historia fueron verificados conforme al *Definition of Done* global del proyecto. El detalle minucioso de la demostración consta en el documento `03 Revisión del Sprint V_1_0_0.md`.

---

## 4. Demostración del trabajo completado

Demostración a los **stakeholders** de las funcionalidades implementadas, realizada ante el área logística de la **UGEL Huancayo** y el supervisor académico (**Ing. Daniel Gamarra**):

- **Dashboard de Indicadores (US-008):** Visualización interactiva de tarjetas KPI con resumen operativo (pedidos completados, pedidos en tránsito, vehículos activos, ahorro acumulado en combustible y reducción estimada de emisiones de CO₂).
- **Visualización de Rutas (US-007 / US-005):** Presentación del listado de rutas en formato de tarjetas modulares (*Cards View*), detalle expandido por ruta con paradas numeradas, ventanas de atención y datos del cliente asignado.
- **Experiencia Móvil y APK de Conductor (EN-007 / EN-008):** Adaptabilidad móvil de la interfaz web con navegación táctil fluida, y habilitación del botón de descarga directa del instalador APK (`https://169.58.74.99/downloads/pathseek.apk`) para los conductores de la flota.
- **Despliegue y Seguridad en Producción (EN-004):** Servidor VPS operativo en la dirección IP pública `https://169.58.74.99`, con certificados SSL configurados en Nginx, redirección automática HTTP (puerto 80) hacia HTTPS (puerto 443), y aislamiento de base de datos en red interna Docker.
- **Monitorización y Salud del Sistema:** Endpoints `/actuator/health` y `/api/v1/health` integrados a los healthchecks automáticos de Docker para garantizar auto-recuperación ante fallos.

---

## 5. Estado por componente

### 5.1 Backend (Java 17 + Spring Boot 4.1.1)

| Módulo | Estado | Detalle |
| --- | :---: | --- |
| Autenticación y RBAC | Completado | JWT stateless, roles `ADMIN`, `OPERADOR`, `CONDUCTOR`, `CLIENTE`, `AUDITOR`. |
| Flota, Pedidos y Conductores | Completado | Endpoints CRUD validados con reglas de negocio y unicidad. |
| Healthchecks y Monitoreo | Completado | Endpoints `/actuator/**` y `/api/v1/health` configurados para monitorización de Docker sin autenticación obligatoria. |
| Manejo de Errores y Seguridad | Completado | Respuestas estructuradas `ApiResponse`, CORS parametrizado para la IP pública de producción. |
| Base de Datos y Datos Semilla | Completado | Centralización de scripts en `database/` (`01_schema_tablas.sql` a `05_seed_demo_data.sql`). |

### 5.2 Frontend (Flutter / Dart - Web & Móvil)

| Módulo | Estado | Detalle |
| --- | :---: | --- |
| Dashboard | Completado | Bloc de estado, tarjetas KPI de sostenibilidad y métricas operativas. |
| Rutas | Completado | Módulo `/routes`, vista de tarjetas, detalle de ruta y estados de entrega. |
| Adaptabilidad Móvil | Completado | Layout responsivo, soporte táctil y corrección de redirecciones por rol. |
| Descarga de APK | Completado | Integración de enlace directo a `/downloads/pathseek.apk` en el menú lateral y barra superior. |
| Suite de Pruebas | Completado | 170 casos de prueba automatizados en Flutter (BLoCs, repositorios, modelos, widgets). |

### 5.3 Infraestructura, Docker y Producción

| Entregable | Estado | Detalle |
| --- | :---: | --- |
| Docker Compose Producción | Completado | `docker-compose.prod.yml` con orquestación de postgres, backend y frontend. |
| Servidor Web y SSL | Completado | Nginx como reverse proxy con terminación SSL (443) y redirección 301 desde HTTP (80). |
| Compilación de APK | Completado | Dockerfile multi-stage con build de Flutter web y exportación del APK Android. |
| Datos de Demostración | Completado | `database/05_seed_demo_data.sql` con datos reales de flota y rutas de UGEL Huancayo. |

---

## 6. Métricas y evidencias de calidad

| Métrica | Valor al cierre del Sprint 2 |
| --- | :---: |
| Story Points comprometidos | 26 SP |
| Story Points completados | 26 SP (100 %) |
| Historias de Usuario / Enablers completados | 4 historias (US-008, US-007, US-005, EN-007/EN-008, EN-004) |
| Métodos de prueba de integración de backend | 49 métodos (`ApiIntegrationTests`, `CatalogIntegrationTests`, `SecurityIntegrationTests`, `BackendApplicationTests`) |
| Casos de prueba automatizados de frontend | 170 pruebas unitarias y de widgets |
| Incidencias de análisis estático | 0 vulnerabilidades críticas, 0 errores de compilación |
| Despliegue en producción | 100 % funcional en `https://169.58.74.99` |
| Pull Requests integrados | PR #6 y PR #7 aprobados y fusionados en rama `main` |

---

## 7. Impedimentos y riesgos de la iteración

- **Impedimentos:** La iteración transcurrió de manera altamente fluida y **no se presentaron problemas bloqueantes ni retrasos en el cronograma**. Los obstáculos operativos menores detectados (ajustes de compatibilidad de SDK en contenedor Docker y configuración de puertos SSL) fueron resueltos en su totalidad durante el desarrollo (100 % resueltos). El detalle se presenta en `02 Registro de Impedimentos V_1_0_0.md`.
- **Riesgos en seguimiento:**
  - **RSK-04** (rendimiento del servidor en la nube): Controlado; el consumo de memoria de los contenedores Docker en el VPS Contabo se mantuvo por debajo del 45 % de la capacidad asignada.
  - **RSK-06** (cumplimiento del cronograma): Controlado y cerrado exitosamente para la iteración 2.

---

## 8. Pendientes

| # | Pendiente | Origen | Prioridad | Iteración prevista |
| :---: | --- | --- | :---: | --- |
| 1 | US-006 Re-optimización Dinámica ante incidentes de tráfico | Backlog EP-02 | Alta | Sprint 3 |
| 2 | US-009 Reportes de Sostenibilidad en formato PDF descargable | Backlog EP-03 | Media | Sprint 3 |
| 3 | US-010 Plan de Compensación de Huella de Carbono | Backlog EP-04 | Baja | Sprint 3 |
| 4 | US-004 Módulo de Clientes y preferencias avanzadas de entrega | Backlog EP-01 | Media | Sprint 3 |
| 5 | Configuración de pipeline automatizado CI/CD en GitHub Actions para pruebas continuas | Calidad / DevOps | Media | Sprint 3 |

---

## 9. Estructura del código fuente y repositorio

El código fuente del proyecto mantiene una organización modular y limpia en carpetas independientes en la raíz del repositorio (`backend/`, `frontend/`, `database/`), complementado con un archivo `.gitignore` estricto que previene el rastreo de binarios, dependencias externas (`node_modules/`, `.dart_tool/`, `target/`), variables de entorno (`.env`) y certificados sensibles.

---

## Control de versiones

| Versión | Fecha | Descripción | Responsable |
| --- | --- | --- | --- |
| V_1_0_0 | 2026-10-06 | Creación inicial: informe de estado del Sprint 2 (Fase 03: Implementación). | Equipo PIPRE |

---

## Referencia

- **Documentos relacionados:** `02 Registro de Impedimentos V_1_0_0.md`, `03 Revisión del Sprint V_1_0_0.md`, `04 Retrospectiva del Sprint V_1_0_0.md`, `05 Justificación de la estructura del código V_1_0_0.md`.
- **Planificación:** `docs/02 Planificación/01 Transformando a ágil V_1_1_0.md` y `docs/02 Planificación/02 Artefactos Jira V_1_1_0.md`.
- **Arquitectura:** `docs/01 Inicio/12. Modelo C4 V_1_1_0.md` y `docs/01 Inicio/10. Stack tecnológico V_1_0_0.md`.
