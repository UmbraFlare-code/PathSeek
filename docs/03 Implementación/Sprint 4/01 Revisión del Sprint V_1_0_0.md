[← Volver al README principal](../../../README.md)

# Revisión del sprint

**Nombre del Proyecto:** PathSeek — Optimizador de Rutas Sostenibles para UGEL Huancayo

**Líder del Proyecto:** Francis Maxuel Urquizo Ore

**Versión:** V_1_0_0  
**Fecha de corte:** 2026-11-16  
**Iteración:** Sprint 4 (Cierre e Inspección 5)  
**Entorno de despliegue auditado:** VPS Dokploy Producción (`https://169.58.74.99`)  
**Rama de cierre:** `main`

---

## Historias de Usuario completadas en este Sprint

Durante el Sprint 4 se completó el 100 % de los ítems remanentes del Product Backlog, alcanzando **89 de 89 Story Points (100 % de completitud global)** conforme al *Definition of Done* (DoD) institucional (análisis estático sin errores bloqueantes, cobertura de pruebas > 80 %, integración continua automatizada, revisión de pares y despliegue operativo en producción).

| Código | Título de la Historia / Enabler | SP | Criterios de Aceptación Verificados | Enlace de Cierre (Commit / PR) |
| :--- | :--- | :---: | :--- | :--- |
| **EN-005** | Escalabilidad de la Arquitectura | 5 | Verificación de concurrencia de reoptimización ante solicitudes simultáneas; tolerancia a picos de demanda en horas punta en Huancayo; estabilidad de pools de conexiones PostgreSQL con tiempos de respuesta p95 < 1200 ms. | [PR #12](https://github.com/UmbraFlare-code/PathSeek/pull/12) · [Commit c2732af](https://github.com/UmbraFlare-code/PathSeek/commit/c2732af) |
| **EN-006** | Accesibilidad WCAG 2.2 AA | 3 | Cumplimiento de contrastes de color (relación mínima 4.5:1 en texto normal y 3:1 en gráficos), navegación completa por teclado en web, etiquetas accesibles en controles interactivos (`Semantics` en Flutter) y ausencia de trampas de foco. | [PR #12](https://github.com/UmbraFlare-code/PathSeek/pull/12) · [Commit a1e6ca7](https://github.com/UmbraFlare-code/PathSeek/commit/a1e6ca7) |
| **EN-007** | Usabilidad del Modo Conductor y Evaluación en Campo | 3 | Interfaz adaptada con botones de toque ampliado (área táctil ≥ 48x48 dp), visualización simplificada de hoja de ruta, sincronización de estado de entrega con un solo toque y evaluación empírica SUS con puntaje sobresaliente (82.08/100). | [PR #13](https://github.com/UmbraFlare-code/PathSeek/pull/13) · [Commit fc74b61](https://github.com/UmbraFlare-code/PathSeek/commit/fc74b61) |
| **EN-009** | Documentación Técnica, Contratos OpenAPI y Cierre | 2 | Especificación OpenAPI 3.0 sincronizada con backend Spring Boot; actualización de manuales de usuario y administración; catálogos de endpoints validados y trazabilidad bidireccional en el repositorio. | [PR #13](https://github.com/UmbraFlare-code/PathSeek/pull/13) · [Commit fc74b61](https://github.com/UmbraFlare-code/PathSeek/commit/fc74b61) |
| **QA-E2E** | Suite Automatizada E2E con Playwright | 1 | Cobertura automatizada multi-navegador (Chromium, Firefox, WebKit) de flujos críticos: login/RBAC, gestión de pedidos, cálculo y visualización de rutas geográficas, validación de formularios y medición de Web Vitals. | [Commit b67f4b2](https://github.com/UmbraFlare-code/PathSeek/commit/b67f4b2) |

### Verificación del Definition of Done (DoD)

1. **Pruebas Automatizadas:** 121 pruebas en backend (Spring Boot / H2 / PostGIS) aprobadas; 292 pruebas en frontend (Flutter) aprobadas; suite E2E de Playwright ejecutada con 100 % de éxito en Chromium, Firefox y WebKit.
2. **Análisis Estático y Calidad:** Cero errores en `flutter analyze`; análisis estático Maven sin violaciones críticas; configuración de `.gitignore` libre de temporales y residuos.
3. **CI/CD Automatizado:** Flujos `ci.yml`, `tests.yml` y `deploy-production.yml` operativos en GitHub Actions con almacenamiento de artefactos de prueba.
4. **Despliegue Operativo:** Plataforma desplegada en producción mediante contenedores Docker orquestados por Dokploy con endpoints y certificados SSL activos.

---

## Demostración del trabajo completado

La sesión de demostración final (*Sprint Review & Final Acceptance Demo*) se llevó a cabo el día **14 de noviembre de 2026** ante los *stakeholders* y el comité evaluador de la UGEL Huancayo, encabezado por el supervisor académico Ing. Daniel Gamarra y el equipo de logística institucional.

### 1. Funcionalidades Exhibidas
- **Autenticación y RBAC Multinivel:** Inicio de sesión y segregación de vistas según perfiles Administrador, Operador Logístico y Conductor.
- **Motor de Optimización Heurística (VRPTW + Green VRP):** Generación en vivo de rutas para un lote de pedidos de distribución educativa en Huancayo en menos de 28 segundos, logrando una reducción estimada del 16.4 % en distancia y 11.2 % en emisiones de CO₂.
- **Visualización Georreferenciada OSRM:** Despliegue de trazados viales punto a punto sobre mapas de OpenStreetMap con marcadores interactivos de instituciones educativas.
- **Modo Conductor y Sincronización Offline:** Demostración de desconexión de red en dispositivo móvil, registro local de entregas con firma digital/conformidad y sincronización automática idempotente al recuperar enlace.
- **Módulo de Compensación de Carbono y Reportes:** Emisión de reportes de sostenibilidad en PDF con cálculo de ahorro de combustible y plan de compensación.
- **Suite Automatizada Playwright y Workflows:** Demostración de ejecución headless en GitHub Actions con reportes HTML de pruebas y métricas Web Vitals.

### 2. Entorno Utilizado
- **Producción:** Despliegue en VPS Dokploy en la dirección `https://169.58.74.99` bajo contenedor Nginx (Frontend Flutter Web) y Spring Boot 3 con base de datos PostgreSQL 16 y extensión PostGIS.
- **Staging / Local:** Demostración de cliente Android APK conectado a la API de producción.

### 3. Retroalimentación Recibida y Conformidad
- **Aceptación de la Solución:** Los representantes de UGEL Huancayo expresaron alta satisfacción con la fluidez del mapa interactivo y la claridad de la hoja de ruta para los conductores.
- **Acta de Conformidad:** Se suscribió el acta de conformidad del Sprint 4 con dictamen **APROBADO SIN RESERVAS CRÍTICAS**, validando que el sistema satisface plenamente los requisitos funcionales RF-001 al RF-010 y los objetivos del proyecto.

---

## Pendientes

Al ser el Sprint de cierre del ciclo de desarrollo de la plataforma, el backlog se encuentra cubierto al **100 % (89/89 SP)**. Se registraron los siguientes puntos de mantenimiento y evolución tecnológica para la fase post-MVP:

| Ítem | Clasificación | Justificación y Tratamiento Posterior |
| :--- | :--- | :--- |
| **Integración con sensores de tráfico municipal en tiempo real** | Deuda técnica evolutiva | Actualmente OSRM utiliza perfiles de velocidad estáticos basados en jerarquía vial de Huancayo. Para la versión 2.0 se planifica integrar feeds GTFS/tráfico en vivo de la Municipalidad Provincial de Huancayo. |
| **Compilación nativa para plataforma iOS** | Extensión de plataforma | La versión actual del cliente móvil se compiló y distribuyó en APK para Android (dispositivos institucionales de UGEL). La compilación para iOS quedó programada para la etapa de soporte anual tras la adquisición de certificados Apple Developer por la institución. |
| **Ampliación de capas satelitales offline de alta resolución** | Optimización de recursos | Se cuenta con caché vectorial y teselas estándar; para zonas rurales de difícil acceso se prevé incorporar almacenamiento precargado de ortofotos satelitales en la tarjeta de memoria del dispositivo. |

---

[← Volver al README principal](../../../README.md)
