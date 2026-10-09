[← Volver al README Principal](../../../README.md)

# Revisión del sprint

**Nombre del Proyecto:** PathSeek

**Líder del Proyecto:** Francis Maxuel Urquizo Ore

Proyecto: PathSeek  
Código del documento: DOC-022  
Versión: V_1_0_0  
Fecha: 2026-10-06  

---

## 1. Datos de la revisión

| Campo | Valor |
| --- | --- |
| **Sprint revisado** | Sprint 2 (2026-09-28 a 2026-10-09) |
| **Fecha de la revisión** | 2026-10-06 |
| **Modalidad** | Reunión de revisión formal (Sprint Review) |
| **Participantes** | Equipo de Desarrollo PIPRE, Representantes del Área Logística de UGEL Huancayo y Supervisor Académico (Ing. Daniel Gamarra) |
| **Story Points completados** | 26 / 26 SP (100 %) |
| **Entorno de Demostración** | Servidor de Producción VPS (`https://169.58.74.99`) |

---

## 2. Historias de Usuario completadas en este Sprint

### US-008 · Dashboard de Indicadores (PATHSEEK-10 · 5 SP · Done)

Como gerente de operaciones y operador logístico, se implementó el panel de control integral con métricas en tiempo real de sostenibilidad y eficiencia operativa:

- Tarjetas KPI con cálculo automático de pedidos completados, pedidos en tránsito y vehículos en operación.
- Métricas ambientales de reducción de emisiones de CO₂ (kg) y ahorro proyectado en combustible (S/.).
- Gráficos y resúmenes comparativos del desempeño de la flota respecto a rutas no optimizadas.
- Arquitectura desacoplada en Flutter mediante `DashboardBloc` y consumo de servicios agregados.

### US-007 / US-005 · Visualización y Gestión de Rutas Optimizadas (PATHSEEK-7 / PATHSEEK-4 · 13 SP · Done)

Como operador logístico, se implementó la visualización y exploración de rutas generadas para la distribución de UGEL Huancayo:

- Módulo interactivo de rutas `/routes` con diseño moderno en tarjetas (*Cards View*), identificando vehículo asignado, conductor, distancia total y tiempo estimado.
- Vista de detalle de ruta `/routes/:id` con la secuencia ordenada de paradas, horarios previstos de atención y datos de contacto de cada punto de entrega.
- Modelado de datos en backend y frontend para soportar secuencias de entrega y estados de despacho (`PENDIENTE`, `EN_TRANSITO`, `ENTREGADO`).

### EN-007 / EN-008 · Usabilidad en Modo Móvil y Distribución de APK (PATHSEEK-15 / PATHSEEK-16 · 3 SP · Done)

Como conductor y equipo operativo en campo, se optimizó la plataforma para dispositivos móviles:

- Diseño responsivo adaptativo con navegación táctil, menús colapsables y contrastes acordes a estándares WCAG 2.1 AA.
- Generación automatizada del paquete instalador Android (`pathseek.apk`) en el proceso de construcción de Docker.
- Acceso y descarga directa del APK desde el menú lateral y la barra superior de la aplicación web (`https://169.58.74.99/downloads/pathseek.apk`).

### EN-004 · Alta Disponibilidad y Despliegue en Producción VPS (PATHSEEK-11 · 5 SP · Done)

Como arquitecto y DevOps, se puso en producción la infraestructura completa del proyecto:

- Orquestación con `docker-compose.prod.yml` conectando PostgreSQL 16, backend Spring Boot Java 17 y frontend Nginx/Flutter.
- Cifrado seguro HTTPS en puerto 443 con certificado SSL y redirección forzada 301 desde el puerto HTTP 80.
- Configuración de healthchecks automatizados con exclusión pública de seguridad en `/actuator/**` y `/api/v1/health`.

---

## 3. Demostración del trabajo completado

Demostración a los **stakeholders** de las funcionalidades implementadas durante el Sprint 2:

| # | Funcionalidad demostrada | Escenario presentado | Evidencia / URL |
| :---: | --- | --- | --- |
| 1 | **Acceso Seguro a Producción** | Navegación cifrada por HTTPS con redirección automática desde HTTP | `https://169.58.74.99/` |
| 2 | **Dashboard de Sostenibilidad** | Visualización de KPIs de ahorro en combustible, reducción de CO₂ y pedidos activos | Vista `/` con rol Operador/Admin |
| 3 | **Visualización de Rutas** | Exploración del catálogo de rutas en tarjetas y desglose de paradas por ruta | Vista `/routes` y `/routes/:id` |
| 4 | **Descarga y Uso de App Móvil** | Descarga del archivo APK de Android directamente desde la interfaz y navegación móvil adaptativa | Botón en AppBar / Sidebar (`/downloads/pathseek.apk`) |
| 5 | **Datos Semilla UGEL Huancayo** | Consulta de datos reales de instituciones educativas, vehículos y conductores de Huancayo | Base de datos poblada con `05_seed_demo_data.sql` |
| 6 | **Calidad y Pruebas** | Ejecución exitosa de la suite completa de pruebas | 49 métodos de integración backend y 170 pruebas frontend |

### Cuentas de Acceso Utilizadas en la Demostración

- **Administrador:** `admin@pathseek.pe` / `Admin123!`
- **Operador Logístico:** `operador@pathseek.pe` / `Admin123!`
- **Conductor:** `conductor.juan@pathseek.pe` / `Admin123!`

**Resultado de la revisión:** Los representantes de la UGEL Huancayo y el docente supervisor validaron satisfactoriamente la disponibilidad de la plataforma en la VPS y el diseño intuitivo de las tarjetas de rutas y el dashboard. Se dio conformidad al cumplimiento de la meta del Sprint 2.

**Trazabilidad técnica:** Los cambios fueron integrados y validados mediante los Pull Requests **#6** y **#7** (`fix-app-mobile` / mejoras web y móvil) sobre la rama `main`.

---

## 4. Pendientes

| # | Pendiente | Origen | Prioridad | Iteración prevista |
| :---: | --- | --- | :---: | --- |
| 1 | US-006 Re-optimización Dinámica ante incidencias en la vía | Backlog EP-02 | Alta | Sprint 3 |
| 2 | US-009 Generación de Reportes PDF de Sostenibilidad descargables | Backlog EP-03 | Media | Sprint 3 |
| 3 | US-010 Plan de Compensación de Huella de Carbono y cálculo anual | Backlog EP-04 | Baja | Sprint 3 |
| 4 | US-004 Módulo de Clientes (registro de ventanas de atención personalizadas) | Backlog EP-01 | Media | Sprint 3 |
| 5 | Pipeline de integración continua CI/CD para ejecución automática de pruebas en GitHub Actions | Calidad / DevOps | Media | Sprint 3 |

**Compromisos de la revisión:** Enfocar el Sprint 3 en el motor de re-optimización dinámica (US-006) y la emisión de reportes ejecutivos en PDF (US-009) para consolidar las capacidades analíticas solicitadas por la UGEL Huancayo.

---

## 5. Control de versiones

| Versión | Fecha | Descripción | Responsable |
| --- | --- | --- | --- |
| V_1_0_0 | 2026-10-06 | Creación inicial: revisión del Sprint 2 (Fase 03: Implementación). | Equipo PIPRE |

---

## 6. Referencia

- **Documentos relacionados:** `01 Informe de estado del proyecto V_1_0_0.md`, `02 Registro de Impedimentos V_1_0_0.md`, `04 Retrospectiva del Sprint V_1_0_0.md`.
- **Planificación:** `docs/02 Planificación/01 Transformando a ágil V_1_1_0.md` y `docs/02 Planificación/02 Artefactos Jira V_1_1_0.md`.
- **Infraestructura:** `docker-compose.prod.yml`.
