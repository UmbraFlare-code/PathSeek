[← Volver al README principal](../../../README.md)

# Retrospectiva del sprint

**Nombre del Proyecto:** PathSeek — Optimizador de Rutas Sostenibles para UGEL Huancayo

**Líder del Proyecto:** Francis Maxuel Urquizo Ore

**Versión:** V_1_1_0\
**Fecha de sesión:** 2026-11-15  
**Iteración:** Sprint 4 (Cierre metodológico y técnico)  
**Facilitador:** Francis Maxuel Urquizo Ore (Scrum Master)  
**Participantes:** Equipo PIPRE (Desarrollo Frontend, Backend, Infraestructura y QA)

---

## ¿Qué aprendimos?

1. **Pruebas Automatizadas E2E en Aplicaciones Flutter Web con Playwright:**  
   El renderizado CanvasKit requiere usar el árbol semántico y comprobar elementos de la aplicación compilada. La suite original aceptaba comprobaciones de URL y título que podían pasar sin ejecutar el flujo.
2. **Optimización de Despliegues en Dokploy y Balance de Recursos:**  
   El tamaño de la JVM y la concurrencia deben verificarse con métricas del entorno desplegado. La prueba sintética de PostgreSQL y PostGIS aporta una referencia de carga para el seguimiento en staging.
3. **Estandarización de Métricas de Sostenibilidad Digital:**  
   Lighthouse CI se configuró para ejecutar y guardar la auditoría del login compilado. El alcance se concentra en la carga y experiencia de laboratorio de esa pantalla.
4. **Valor de la Retroalimentación Temprana con Usuarios de Campo:**  
   El informe SUS recoge observaciones de dos participantes con perfil de conductor. La prueba del APK en campo debe comprobar la interacción táctil y la legibilidad en sus condiciones de trabajo.

---

## ¿Qué estamos haciendo bien?

1. **Cultura de Calidad Integral y Cobertura de Pruebas:**  
   CI conserva informes de regresión y cobertura de Maven y Flutter. La suite Playwright usa tres motores y un backend de pruebas con base de datos aislada.
2. **Arquitectura Limpia y Segregación de Responsabilidades:**  
   La arquitectura hexagonal en Spring Boot y el patrón BLoC en Flutter desacoplaron totalmente la lógica de negocio de los detalles de infraestructura, facilitando el cambio de perfiles H2 a PostgreSQL real y el soporte offline.
3. **Automatización de Integración y Despliegue (CI/CD):**  
   CI integra compilación y pruebas antes de habilitar el despliegue. La aceptación operativa requiere una corrida con el webhook y una respuesta HTTPS válida.
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
  Configurar notificaciones cuando falle el endpoint `/api/v1/health` o se supere el tiempo de respuesta acordado.
- **Automatización de Análisis de Accesibilidad en CI:**  
  Ampliar la auditoría de axe a los flujos principales y complementar los resultados con recorridos de teclado y lector de pantalla.

---

### Acciones a realizar

Para consolidar el cierre del proyecto y asegurar la estabilidad de la plataforma en producción, se establecen los siguientes compromisos formalizados con metodología **SMART**:

| ID | Acción de Mejora (SMART) | Responsable | Métrica de Éxito / Entregable | Plazo Límite |
| :---: | :--- | :--- | :--- | :---: |
| **A-17** | **Configurar Alertas Proactivas de Uptime:** Implementar un webhook ligero en Dokploy para alertar al canal técnico ante caídas del contenedor Spring Boot o Nginx. | Francis Urquizo (Líder / DevOps) | 100 % de caídas o reinicios notificados en menos de 60 segundos; disponibilidad mensual > 99.5 %. | 2026-11-20 |
| **A-18** | **Generación Automatizada de Modelos Dart:** Incorporar `openapi-generator-cli` al proceso de pre-construcción para sincronizar DTOs entre backend y frontend sin intervención manual. | Responsable Frontend | Cero discrepancias de tipos en tiempo de compilación; build en verde en `ci.yml`. | 2026-11-25 |
| **A-19** | **Integración de Auditoría Accesible Automatizada:** Extender la auditoría automatizada de login y panel a los procesos principales. | Responsable QA | Reportes axe por pantalla y registro manual por criterio. | 2026-11-25 |
| **A-20** | **Taller de Transferencia Tecnológica:** Realizar una sesión grabada de capacitación técnica y operativa para el personal de TI de UGEL Huancayo sobre mantenimiento del VPS y administración de usuarios. | Francis Urquizo y Equipo | Manual de administración validado, acta de entrega técnica firmada y video subido al repositorio documental. | 2026-11-28 |

---

[← Volver al README principal](../../../README.md)
