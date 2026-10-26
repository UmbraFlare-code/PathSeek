# Continuidad: mapa, rutas y permisos

Fecha: 2026-10-22. Seguimiento de RF-003/RF-004, US-005/US-007, EN-003 y RN-008/RN-010.

## 1. Estado inicial y dependencias

El repositorio ya contiene autenticación JWT rotativa, CRUD de vehículos/conductores/pedidos, dashboard, rutas y una revisión previa de integridad. El supuesto mapa era un lienzo normalizado con animación de GPS; no usaba flutter_map ni OpenStreetMap. Existía geometría en el backend pero el datasource de detalle no la solicitaba. El conductor no tenía acceso a la vista y la API de rutas carecía de filtro de identidad. CLIENTE podía consultar pedidos globales.

Se mantuvo la arquitectura Cliente-Servidor y las carpetas raíz `backend`, `frontend`, `database`; Spring Boot 4.1.1/Java 17, JPA y PostgreSQL; Flutter con BLoC, repositorios y Dio. Se reutilizaron DTOs, autenticación y servicios existentes. ADR-07 prevalece sobre el Node/Express revocado; ADR-05 determina flutter_map/OSM.

Los 24 Markdown originales de docs se inventariaron por tema en [DOCUMENTATION_INDEX.md](../../DOCUMENTATION_INDEX.md). Los criterios funcionales se contrastaron con DOC-006, DOC-007, DOC-008, DOC-009, C4/ADR y el backlog, además de los informes de cierre. No se modifican retrospectivamente las actas de cierre.

## 2. Sprint y discrepancias documentales

El cierre de Sprint 2 declara US-005/US-007 terminadas como gestión y tarjetas. El backlog asigna el mapa geográfico a Iteración 3/Sprints 3–5. Se trata esta entrega como continuidad y corrección de US-005/US-007 para Sprint 3, no como certificación del 100 % del motor. US-006 (reoptimización), US-009 (PDF), US-010 (compensación) y preferencias de US-004 siguen pendientes.

Contradicciones que afectan la implementación:

- Las actas afirman mapa terminado, pero el código inicial no tenía mapa geográfico. Se aporta el mapa real sin declarar completo el criterio de tráfico.
- DOC-006 admite GA, SA, ACO o Tabú; no selecciona uno. Se elige **enfriamiento simulado (SA)** como implementación incremental, con inicialización factible, búsqueda acotada y resultado que no empeora el inicial. No se afirma optimalidad global ni mejora porcentual certificada.
- RN-006 habla de penalización por tardanza y el escenario de US-005 exige dejar inalcanzables pendientes. Se mantiene la interpretación conservadora de ventanas duras: no planificar entregas tardías.
- RN-008 especifica `CO2 = distancia_km * factor_emision(kg/km)`; el código usaba litros. Se corrige la fórmula para rutas nuevas. Los valores históricos y factores cargados deben revisarse por unidad; no se recalculan automáticamente.
- Algunos documentos describen Redis, Flyway, PostGIS, tráfico y eventos como arquitectura objetivo. La ejecución actual no cuenta con todas esas integraciones; se distinguen de capacidades implementadas.

## 3. Cambios implementados

### Mapa y selección

- `interactive_route_map.dart`: flutter_map 8.3.2/OSM, desplazamiento, zoom, ajuste a extensión, depósito, marcadores de entregas ordenados y selección con dirección, cliente, ventana, ETA y peso. Atribución visible y enlazada. Se retira la animación de GPS ficticia.
- `route_remote_datasource.dart`: solicita detalle y `/geometria` con el mismo cliente autenticado. `route_coordinates.dart` decodifica la polilínea y rechaza datos inválidos; ante geometría vacía/inválida se dibuja la secuencia de coordenadas válidas. No se inventan coordenadas para pedidos incompletos.
- `delivery_location_picker.dart` y formulario de pedidos: seleccionar destino con un toque, confirmar o cancelar; las coordenadas retornan a los campos existentes con seis decimales y sus validaciones.
- El origen/retorno sigue siendo el depósito de Atalaya 1280 del modelo existente. No se incorpora un origen libre sin contrato persistente ni requisito logístico preciso. Cada pedido seleccionable es un destino.
- Si fallan las teselas del detalle, se informa y se conservan marcadores/trazado. Se requiere conectividad para el mapa base; no se ha implementado caché offline completa.

### Generación

- `RouteSequenceOptimizer.java`: SA acotado a 600 iteraciones por ruta; intercambios entre entregas de la misma prioridad y validación temporal de cada candidato. Capacidad y conjunto de pedidos se conservan al permutar.
- `RouteOptimizationService.java`: utiliza la secuencia mejorada, recalcula ETA/distancias, combustible y CO2 coherentes y mantiene las salvaguardas previas contra doble asignación, pérdida de historial y sobrecarga.
- Para un vehículo fijo, menor distancia reduce combustible y CO2 según las fórmulas documentadas. No se inventan pesos de una función multiobjetivo ni ahorros de referencia.

### Roles e identidad

| Rol | Acceso implementado |
| --- | --- |
| ADMIN / OPERADOR | CRUD operativo, generación y eliminación de rutas planificadas; consulta completa |
| AUDITOR | Lectura de catálogos, pedidos, rutas y dashboard; sin mutaciones |
| CONDUCTOR | Dashboard y vista de rutas propias; detalle y geometría requieren `conductores.usuario_id = JWT.sub`; no genera ni elimina rutas |
| CLIENTE | Crear y leer sus pedidos; el servidor asigna `cliente_id = JWT.sub` y estado PENDIENTE; no puede elegir otro propietario ni editar/eliminar |

`CurrentActor.java` obtiene identidad y roles del JWT validado, no de parámetros enviados por el navegador. Se aplica el filtro en backend, no solo en botones. El frontend permite la vista de rutas del conductor y hace el identificador del cliente de solo lectura en su formulario. El backend responde 403 a lecturas ajenas.

Compatibilidad: ADMIN/OPERADOR conservan IDs de cliente de texto para la gestión existente. Los pedidos históricos de cliente con códigos libres quedan visibles para esos roles, pero no se asignan automáticamente a un usuario. Su vinculación necesita una tabla explícita y migración de US-004/RF-009; no se infiere por nombre o email.

## 4. Validación

Resultado de esta entrega: **67 pruebas backend aprobadas**, **207 pruebas de la suite frontend aprobadas y una prueba adicional del datasource aprobada** (208 verificadas en total), análisis Flutter sin incidencias y build web release completado.

Backend: suite de integración con pruebas adicionales de aislamiento de cliente y conductor, bloqueo de generación al conductor, preservación de pedidos y factibilidad en SA. Carga sintética de 150 pedidos/15 vehículos dentro de 45 s en H2 (caso local observado: 0.773 s, incluye preparación del método). No equivale a p95 ni a prueba de producción.

Frontend: pruebas de selección de una parada, recentrado, selección/confirmación de destino y decodificación de geometría válida/inválida. Las pruebas de widgets desactivan las teselas externas: verifican interacciones sin depender de la red. Análisis estático, suite completa y build web release registrados localmente en `frontend/sprint-*.log`; backend en `backend/sprint-tests.log`.

No se han reconstruido contenedores ni actualizado una base persistente para esta entrega. La validación aquí no acredita descarga real de teselas en todos los navegadores ni APK Android.

## 5. Pendientes y criterios que no se declaran Done

1. **Tráfico y navegación por calles:** no hay proveedor/ruteador configurado. La polilínea del backend interpola coordenadas y las distancias usan una aproximación geográfica. La interfaz indica trazado estimado y ausencia de tráfico en vivo; no se muestran colores de congestión como si fueran observaciones reales.
2. **Jornadas y descansos:** falta representar jornada/historial de conducción para aplicar RN-004 de forma integral. No se infieren horas ya trabajadas a partir de un flag de disponibilidad.
3. **Restricción por placa:** el usuario pidió expresamente ignorarla por el momento. No se configura calendario ni se afirma RN-003 cumplida.
4. **Reoptimización e incidentes:** US-006 requiere evitar tramos afectados y notificar al conductor; los incidentes actuales en memoria no cumplen persistencia ni recálculo. Requiere red vial, persistencia y mecanismo de notificación.
5. **Clientes:** preferencias, referencias, restricciones de acceso y asociación explícita de datos históricos forman parte de US-004/RF-009 y no se consideran completadas por el filtro de propiedad.
6. **Calidad:** medir p95 en PostgreSQL, carga concurrente, WCAG, Android y uso real de teselas; el DoD de cobertura >=80 % no se ha acreditado aquí.

## 6. Próximos pasos y ejecución

Validar con producto un proveedor de rutas/tráfico y el modelo de jornadas. Completar US-004 para vincular clientes sin perder sus datos históricos. Continuar US-006 antes de declarar reoptimización terminada. Mantener fuera las restricciones por placa hasta nueva instrucción.

Para ver los cambios locales se deben reconstruir las imágenes. Si todavía no se aplicaron las correcciones SQL de la revisión anterior, seguir primero [CODE_REVIEW.md](../../../CODE_REVIEW.md); conservar el volumen y no usar `down -v`.

```powershell
docker compose up --build -d
```

Los usuarios CONDUCTOR necesitan `conductores.usuario_id` vinculado a su UUID. Un conductor sin vínculo verá lista vacía; nunca recibe rutas ajenas como fallback. Para pruebas manuales: ADMIN genera/consulta; AUDITOR consulta sin botones de escritura; CONDUCTOR abre solo sus rutas y prueba un UUID ajeno; CLIENTE crea con mapa y comprueba que solo ve sus pedidos.
