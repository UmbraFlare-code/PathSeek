[← Volver al README Principal](../../README.md)

# Registro de impedimentos

**Nombre del Proyecto:** PathSeek

**Líder del Proyecto:** Francis Maxuel Urquizo Ore

Proyecto: PathSeek  
Código del documento: DOC-021  
Versión: V_1_0_0  
Fecha: 2026-10-06  

---

## 1. Resumen

El presente registro documenta los obstáculos **técnicos, operativos y organizativos** gestionados durante el **Sprint 2** (2026-09-28 a 2026-10-09). Durante esta iteración el equipo experimentó un flujo de trabajo óptimo y **no se presentaron problemas críticos o bloqueantes**. Los obstáculos identificados correspondieron a ajustes operativos menores de configuración de contenedores, certificados SSL y redirecciones de navegación móvil, los cuales fueron resueltos en su totalidad dentro del mismo ciclo de trabajo (100 % de efectividad en resolución).

| Estado | Cantidad |
| --- | :---: |
| Resueltos en Sprint 2 | 4 |
| Deudas de Sprint 1 Resueltas | 2 |
| En progreso | 0 |
| Abiertos | 0 |
| **Total activos al cierre** | **0** |

Escala de prioridad aplicada: **Alta** (bloquea la iteración o compromete la seguridad), **Media** (afecta al despliegue o la usabilidad) y **Baja** (deuda técnica o advertencias menores).

---

## 2. Tabla de impedimentos

| Impedimento # | Fecha de Registro | Descripción del Impedimento así como el Impacto en el Proyecto | Prioridad | Reportado por | Fecha tope de Resolución | Estado | Fecha de Resolución | Resolución/Comentarios |
| :---: | :---: | --- | :---: | :---: | :---: | :---: | :---: | --- |
| IMP-08 | 2026-10-01 | Discrepancia de versión del SDK Dart en el contenedor multi-stage de Docker para Flutter Web con el paquete `intl`. **Impacto:** Falla en el comando de compilación web dentro de la imagen de producción. | Media | DevOps Engineer | 2026-10-02 | Resuelto | 2026-10-01 | Se fijó la dependencia `intl` en `^0.20.2` y se homologó la versión base en el Dockerfile con `instrumentisto/flutter:3.24`, logrando builds limpios y reproducibles. |
| IMP-09 | 2026-10-01 | Las sondas de monitorización de Docker (*Healthcheck*) recibían error `401 Unauthorized` al consultar `/actuator/health` y `/api/v1/health`. **Impacto:** Los contenedores se marcaban como *unhealthy* en el servidor de producción VPS. | Alta | Software Architect | 2026-10-02 | Resuelto | 2026-10-01 | Se ajustó la configuración de Spring Security en `SecurityConfig.java` para permitir el acceso público sin autenticación a `/actuator/**` y `/api/v1/health`. |
| IMP-10 | 2026-10-01 | Las peticiones al servidor VPS por HTTP (puerto 80) no migraban automáticamente al canal seguro HTTPS (puerto 443). **Impacto:** Riesgo de transmisión de credenciales en texto plano si el usuario omitía el protocolo `https://`. | Alta | Software Architect | 2026-10-02 | Resuelto | 2026-10-01 | Se incorporó en la configuración de Nginx una regla de redirección 301 permanente desde el puerto 80 hacia el puerto 443 con terminación SSL. |
| IMP-11 | 2026-10-05 | La redirección por defecto tras el login en pantallas móviles dirigía a roles sin acceso al Dashboard a rutas no permitidas. **Impacto:** Bloqueo de la experiencia de usuario para roles operativos en la aplicación móvil. | Media | Developer Junior Frontend | 2026-10-06 | Resuelto | 2026-10-05 | Se corrigió el método `AppRouter.defaultHomeFor(user)` para enrutar según la matriz RBAC (`/orders` para clientes/conductores), integrado mediante Pull Request #7. |
| IMP-04 (Seguimiento S1) | 2026-09-29 | Centralización de scripts de base de datos, triggers y datos de prueba. **Impacto:** Necesidad de consistencia en el esquema relacional de PostgreSQL. | Alta | Developer Junior Backend | 2026-10-06 | Resuelto | 2026-10-01 | Se consolidaron los scripts SQL en `database/` (`01_schema_tablas.sql` a `05_seed_demo_data.sql`) integrándolos directamente con el contenedor PostgreSQL de producción. |
| IMP-07 (Seguimiento S1) | 2026-09-29 | Ausencia de ambiente de producción desplegable y automatizado. **Impacto:** Imposibilidad de validar la solución en un entorno real con acceso para los stakeholders. | Alta | Software Architect | 2026-10-06 | Resuelto | 2026-10-01 | Se configuró el despliegue con Docker Compose en el servidor VPS Contabo (`169.58.74.99`), dejando la plataforma completamente accesible para la UGEL Huancayo. |

---

## 3. Estado de resolución

Todos los impedimentos registrados en la iteración fueron abordados de manera inmediata y se encuentran en estado **Resuelto**. No existen impedimentos abiertos o bloqueos técnicos que comprometan el inicio del Sprint 3.

---

## 4. Control de versiones

| Versión | Fecha | Descripción | Responsable |
| --- | --- | --- | --- |
| V_1_0_0 | 2026-10-06 | Creación inicial: registro de impedimentos del Sprint 2 (Fase 03: Implementación). | Equipo PIPRE |

---

## 5. Referencia

- **Documentos relacionados:** `01 Informe de estado del proyecto V_1_0_0.md`, `03 Revisión del Sprint V_1_0_0.md`, `04 Retrospectiva del Sprint V_1_0_0.md`.
- **Riesgos:** `docs/02 Planificación/03 Registro de riesgos V_1_0_0.md`.
- **Configuración de Producción:** `docker-compose.prod.yml` y `README.md`.
