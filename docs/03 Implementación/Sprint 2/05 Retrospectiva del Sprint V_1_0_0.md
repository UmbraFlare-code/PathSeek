[← Volver al README Principal](../../../README.md)

# Reprospectiva del sprint

**Nombre del Proyecto:** PathSeek

**Líder del Proyecto:** Francis Maxuel Urquizo Ore

Proyecto: PathSeek  
Código del documento: DOC-023  
Versión: V_1_0_0  
Fecha: 2026-10-06  

---

## 1. Datos de la retrospectiva

| Campo | Valor |
| --- | --- |
| **Sprint** | Sprint 2 (2026-09-28 a 2026-10-09) |
| **Fecha de la sesión** | 2026-10-06 |
| **Facilitador** | Project Manager |
| **Participantes** | Project Manager, Software Architect, Developers Junior (Backend y Frontend), QA Engineer y UI/UX Designer |
| **Resultado del Sprint** | 26 / 26 Story Points completados (100 %) |

---

## 2. ¿Qué aprendimos?

- **Optimización de compilaciones multi-etapa con Docker:** La integración de un `Dockerfile` multi-stage para Flutter permitió compilar la versión Web y al mismo tiempo generar y disponibilizar el paquete instalador Android (`pathseek.apk`), reduciendo drásticamente el tiempo de distribución hacia los usuarios finales.
- **Configuración desacoplada de seguridad para observabilidad:** Comprendimos la necesidad de excluir explícitamente las rutas de telemetría (`/actuator/**`, `/api/v1/health`) del filtro de autenticación JWT para permitir que los healthchecks de Docker monitoreen la salud del backend sin sobrecargar la capa de seguridad.
- **Diseño web adaptativo centrado en tarjetas:** La transición hacia un diseño en tarjetas modulares (*Cards View*) mejoró sustancialmente la legibilidad de la información logística tanto en pantallas de escritorio como en smartphones de conductores.
- **Terminación SSL y seguridad perimetral:** La implementación de Nginx como proxy inverso con redirección permanente 301 garantizó el cumplimiento de los estándares OWASP y el cifrado de datos en tránsito sin afectar el rendimiento.

---

## 3. ¿Qué estamos haciendo bien?

- **Cumplimiento estricto del compromiso:** Se completaron la totalidad de las historias y tareas técnicas planificadas (26/26 SP), sin desvíos en el cronograma.
- **Alta cobertura y rigor en pruebas:** Se alcanzaron 170 pruebas automatizadas en Flutter y 49 métodos de integración en Spring Boot, asegurando una base de código robusta y mantenible.
- **Disponibilidad inmediata en entorno real:** El sistema se encuentra 100 % desplegado y operativo en la VPS Contabo (`https://169.58.74.99`), facilitando la validación directa por parte de los stakeholders de la UGEL Huancayo.
- **Flujo de trabajo ágil y colaborativo:** Integración continua mediante Pull Requests (#6 y #7) con revisión por pares efectiva antes del merge a `main`.

---

## 4. ¿Qué podemos hacer mejor?

### Personas

- Promover mayor intercambio de conocimientos sobre la configuración de infraestructura Docker y optimización móvil entre los miembros del equipo.
- Continuar balanceando las cargas de trabajo para evitar concentración de tareas de diseño en un solo integrante.

### Relaciones

- Coordinar sesiones cortas de validación de usabilidad móvil con conductores reales de la UGEL Huancayo para recibir retroalimentación ergonómica del APK.
- Mantener comunicación constante con el docente supervisor para la aprobación temprana de los formatos de reportes PDF planificados para el Sprint 3.

### Procesos

- Formalizar una lista de verificación de pre-despliegue que asegure que todos los scripts de prueba se ejecuten automáticamente antes de actualizar el contenedor en producción.
- Afinar los criterios de aceptación de re-optimización dinámica para definir claramente los umbrales de tiempo de recálculo ante incidentes viales.

### Herramientas

- Configurar un visor liviano de logs de contenedores en la VPS para simplificar la supervisión en tiempo real del backend y frontend.
- Integrar la medición de cobertura de código en el flujo de integración continua de GitHub Actions.

---

## 5. Acciones a realizar

| # | Acción | Eje | Responsable | Fecha comprometida |
| :---: | --- | :---: | --- | :---: |
| A-08 | Implementar el motor de re-optimización dinámica (US-006) y validarlo con escenarios de incidentes viales en Huancayo. | Procesos | Software Architect / Backend | 2026-10-16 |
| A-09 | Desarrollar el módulo de generación de reportes de sostenibilidad en PDF (US-009) con filtros por fecha y flota. | Herramientas | Developer Junior Frontend | 2026-10-18 |
| A-10 | Realizar una prueba de campo con el APK móvil junto a los conductores de UGEL Huancayo para validar la usabilidad de las paradas. | Relaciones | Project Manager / UI/UX | 2026-10-15 |
| A-11 | Configurar la ejecución automatizada de la suite de pruebas (170 frontend + 49 backend) en GitHub Actions en cada PR. | Herramientas | Software Architect | 2026-10-14 |
| A-12 | Documentar la guía de despliegue y mantenimiento preventivo del servidor VPS en `README.md`. | Personas | DevOps Engineer | 2026-10-12 |

---

## 6. Control de versiones

| Versión | Fecha | Descripción | Responsable |
| --- | --- | --- | --- |
| V_1_0_0 | 2026-10-06 | Creación inicial: retrospectiva del Sprint 2 (Fase 03: Implementación). | Equipo PIPRE |

---

## 7. Referencia

- **Documentos relacionados:** `01 Informe de estado del proyecto V_1_0_0.md`, `02 Registro de Impedimentos V_1_0_0.md`, `03 Revisión del Sprint V_1_0_0.md`.
- **Planificación:** `docs/02 Planificación/01 Transformando a ágil V_1_1_0.md` y `docs/02 Planificación/02 Artefactos Jira V_1_1_0.md`.
