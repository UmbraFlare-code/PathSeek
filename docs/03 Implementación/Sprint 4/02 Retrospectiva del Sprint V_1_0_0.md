[← Volver al README principal](../../../README.md)

# Retrospectiva del sprint

**Nombre del Proyecto:** PathSeek — Optimizador de Rutas Sostenibles para UGEL Huancayo

**Líder del Proyecto:** Francis Maxuel Urquizo Ore

**Versión:** V_1_0_0  
**Fecha de sesión:** 2026-11-15  
**Iteración:** Sprint 4 (Cierre metodológico y técnico)  
**Facilitador:** Francis Maxuel Urquizo Ore (Scrum Master)  
**Participantes:** Equipo PIPRE (Desarrollo Frontend, Backend, Infraestructura y QA)

---

## ¿Qué aprendimos?

1. **Pruebas Automatizadas E2E en Aplicaciones Flutter Web con Playwright:**  
   Comprendimos la particularidad del renderizado CanvasKit/HTML de Flutter Web frente al DOM convencional. Aprendimos a combinar selectores semánticos con la API de navegación de Playwright para estabilizar pruebas automatizadas en Chromium, Firefox y WebKit sin recurrir a esperas arbitrarias (*flaky tests*).
2. **Optimización de Despliegues en Dokploy y Balance de Recursos:**  
   Aprendimos a dimensionar de forma precisa los límites de memoria de la JVM (Spring Boot 3 con `-Xmx512m`) y la base de datos PostgreSQL 16 con PostGIS en el VPS, evitando caídas por *Out of Memory* (OOM) durante ejecuciones concurrentes de reoptimización heurística.
3. **Estandarización de Métricas de Sostenibilidad Digital:**  
   La auditoría continua con herramientas Green IT y Lighthouse CI demostró que minimizar la transferencia de carga útil en JSON y habilitar compresión Gzip/Brotli en Nginx reduce directamente el consumo de energía en los dispositivos móviles de los conductores.
4. **Valor de la Retroalimentación Temprana con Usuarios de Campo:**  
   La prueba piloto con conductores reales de UGEL Huancayo evidenció que en campo la velocidad de interacción táctil con guantes o en cabina requiere áreas de pulsación mínimas de 48x48 dp y esquemas de alto contraste bajo luz solar directa.

---

## ¿Qué estamos haciendo bien?

1. **Cultura de Calidad Integral y Cobertura de Pruebas:**  
   Mantener más de 120 pruebas unitarias y de integración en backend y 292 pruebas de componentes y regresión UI/UX en Flutter, sumadas a la suite E2E de Playwright, nos permitió realizar refactorizaciones críticas sin regresiones funcionales.
2. **Arquitectura Limpia y Segregación de Responsabilidades:**  
   La arquitectura hexagonal en Spring Boot y el patrón BLoC en Flutter desacoplaron totalmente la lógica de negocio de los detalles de infraestructura, facilitando el cambio de perfiles H2 a PostgreSQL real y el soporte offline.
3. **Automatización de Integración y Despliegue (CI/CD):**  
   La separación formal de flujos de análisis estático (`ci.yml`), batería de pruebas (`tests.yml`) y entrega en producción (`deploy-production.yml`) garantizó que ningún cambio con advertencias del compilador o fallos de test llegara a la rama `main`.
4. **Disciplina de Documentación y Trazabilidad:**  
   Versionar rigurosamente cada decisión técnica, catálogo de requisitos y manual operativo enlazado bidireccionalmente desde el repositorio proporcionó claridad absoluta tanto al equipo como a los evaluadores académicos.

---

## ¿Qué podemos hacer mejor?

### Personas
- **Distribución de Carga en Días de Cierre:**  
  Durante la fase final de auditoría E2E y empaquetado, la carga de trabajo se concentró intensamente en los roles de QA y DevOps. Es necesario cross-capacitar a los desarrolladores de frontend y backend en la escritura de casos Playwright y configuración de GitHub Actions.
- **Especialización en Ergonomía Móvil:**  
  Fortalecer la formación del equipo en diseño accesible bajo normativas WCAG para interfaces vehiculares de transporte logístico.

### Relaciones
- **Sincronización de Contratos de API Frontend-Backend:**  
  Aunque se utilizó OpenAPI 3.0, en dos ocasiones se introdujeron cambios menores de nombres de propiedades DTO que requirieron ajustes manuales en los modelos Dart. Debe automatizarse la generación de clientes cliente-servidor a partir del esquema Swagger.
- **Comunicación con Áreas Operativas de UGEL Huancayo:**  
  Establecer canales de comunicación asíncrona más directos para validar restricciones de circulación de carga pesada en vías céntricas de Huancayo sin depender exclusivamente de reuniones formales quincenales.

### Procesos
- **Gestión de Ramas y Política de Merge:**  
  Mejorar la granularidad de los Pull Requests. En el Sprint 4 algunos PRs acumularon más de 15 archivos modificados simultáneamente; se debe limitar el alcance a unidades de trabajo de menor tamaño (*Work-Unit Commits*) para agilizar la revisión por pares.
- **Transición hacia Modelo de Mantenimiento:**  
  Adaptar el marco Scrum hacia Kanban para la etapa de soporte, facilitando la atención de incidencias operativas y solicitudes menores de mejora con SLAs definidos.

### Herramientas
- **Monitorización Proactiva y Alertas de Uptime:**  
  Implementar un bot de notificaciones en tiempo real (Discord / Telegram Webhook) que reporte inmediatamente caídas de salud del backend (`/actuator/health`) o tiempos de respuesta superiores a 2 segundos.
- **Automatización de Análisis de Accesibilidad en CI:**  
  Integrar herramientas como `axe-playwright` dentro del pipeline de GitHub Actions para certificar automáticamente el cumplimiento WCAG en cada pull request.

---

### Acciones a realizar

Para consolidar el cierre del proyecto y asegurar la estabilidad de la plataforma en producción, se establecen los siguientes compromisos formalizados con metodología **SMART**:

| ID | Acción de Mejora (SMART) | Responsable | Métrica de Éxito / Entregable | Plazo Límite |
| :---: | :--- | :--- | :--- | :---: |
| **A-17** | **Configurar Alertas Proactivas de Uptime:** Implementar un webhook ligero en Dokploy para alertar al canal técnico ante caídas del contenedor Spring Boot o Nginx. | Francis Urquizo (Líder / DevOps) | 100 % de caídas o reinicios notificados en menos de 60 segundos; disponibilidad mensual > 99.5 %. | 2026-11-20 |
| **A-18** | **Generación Automatizada de Modelos Dart:** Incorporar `openapi-generator-cli` al proceso de pre-construcción para sincronizar DTOs entre backend y frontend sin intervención manual. | Responsable Frontend | Cero discrepancias de tipos en tiempo de compilación; build en verde en `ci.yml`. | 2026-11-25 |
| **A-19** | **Integración de Auditoría Accesible Automatizada:** Añadir el paquete `@axe-core/playwright` a la suite E2E para auditar violaciones WCAG 2.2 AA en cada ejecución de `tests.yml`. | Responsable QA | Reporte de accesibilidad generado como artefacto con 0 violaciones de nivel crítico o severo. | 2026-11-25 |
| **A-20** | **Taller de Transferencia Tecnológica:** Realizar una sesión grabada de capacitación técnica y operativa para el personal de TI de UGEL Huancayo sobre mantenimiento del VPS y administración de usuarios. | Francis Urquizo y Equipo | Manual de administración validado, acta de entrega técnica firmada y video subido al repositorio documental. | 2026-11-28 |

---

[← Volver al README principal](../../../README.md)
