# Contexto de PathSeek para decisiones UI/UX

Este es un mapa de lectura, no una copia de la especificación. Las rutas siguientes parten de la raíz del repositorio. Revalida el estado al comenzar una tarea: el código y los sprints evolucionan.

## Fuentes funcionales y progreso

| Necesidad | Documento y términos de búsqueda |
| --- | --- |
| Criterios funcionales | `docs/01 Inicio/06. Requisitos funcionales V_1_0_0.md`: RF-002 pedidos, RF-003 generación, RF-004 mapa, RF-005 dashboard |
| Accesibilidad y conectividad | `docs/01 Inicio/07. Requisitos no funcionales V_1_0_0.md`: RNF-006 WCAG 2.1 AA, RNF-007 usabilidad, RNF-008 conectividad/datos cacheados |
| Roles objetivo y alcance histórico | `docs/01 Inicio/08. Usuarios V_1_0_0.md`: matriz RBAC y alcance implementado |
| Invariantes de negocio | `docs/01 Inicio/09. Reglas de negocio V_1_0_0.md`: capacidad, ventana, prioridad, CO2, modo conductor, duplicados |
| Arquitectura | `docs/01 Inicio/12. Modelo C4 V_1_1_0.md`: ADR-05 flutter_map/OSM, ADR-06 Cliente-Servidor, ADR-07 Java/Spring Boot |
| Historias y aceptación | `docs/02 Planificación/01 Transformando a ágil V_1_1_0.md`: US-005, US-007, US-008, EN-003, EN-006 y DoD |
| Avance por sprint | `docs/02 Planificación/02 Artefactos Jira V_1_1_0.md` y `docs/Sprint 2/01 Informe de estado del proyecto V_1_0_0.md` |
| Seguimiento posterior de mapa y permisos | `docs/Sprint 3/06 Continuidad mapa rutas y permisos V_1_0_0.md` |
| Otras fuentes | `docs/DOCUMENTATION_INDEX.md` permite localizar documentación adicional |

Los informes de Sprint 2 declaran terminadas tarjetas y gestión base de rutas; el backlog sitúa la visualización geográfica en el siguiente ciclo. El seguimiento de continuidad explica esa diferencia. Conserva la distinción entre objetivo, implementación y validación. El DoD conserva menciones históricas a Jest/Jasmine; en este frontend el stack verificable es Flutter/Dart, no una razón para introducir herramientas JavaScript.

## Implementación que conviene reutilizar

- `frontend/pubspec.yaml`: Flutter/Dart, Material 3, flutter_bloc, GoRouter, Dio, GetIt, flutter_map y latlong2. Usa las versiones del repositorio y sus APIs instaladas.
- `frontend/lib/core/theme/app_theme.dart`: tokens verdes y de superficie, tema de inputs, tarjetas y navegación. Una pantalla oscura o glassmorphic existente no obliga a replicar ese estilo en todos los módulos; comprueba legibilidad y consistencia del flujo.
- `frontend/lib/core/utils/responsive.dart`: breakpoint compartido. `core/widgets/responsive_field_row.dart`: formularios responsive.
- `frontend/lib/core/widgets/`: `SearchSortControls`, `LoadingIndicator`, `EmptyView`, `ErrorView`, `AppSnackBar` y componentes de formulario. Busca sus usos antes de crear equivalentes.
- `frontend/lib/core/router/home_shell.dart` y `app_router.dart`: navegación adaptativa, rutas y guards. No conviertas una edición sin entidad cargada en una creación.
- `frontend/lib/features/<feature>/presentation/{pages,widgets,bloc}`: organiza los cambios dentro de la feature. Los modelos/DTO viven en `data`, las entidades en `domain`.
- `frontend/lib/core/config/environment.dart`: URL por entorno. Los argumentos `--dart-define` se fijan al ejecutar/compilar; una vista no debe codificar otra base URL.

## Mapas: leer cuando la tarea toque geografía

Archivos de referencia:

- `frontend/lib/features/routes/presentation/widgets/interactive_route_map.dart`
- `frontend/lib/features/routes/presentation/widgets/route_coordinates.dart`
- `frontend/lib/features/routes/presentation/widgets/elevation_profile_widget.dart`
- `frontend/lib/features/routes/presentation/pages/route_detail_page.dart`
- `frontend/lib/features/routes/data/datasources/route_remote_datasource.dart`
- `frontend/lib/features/routes/domain/entities/delivery_route.dart`
- `frontend/lib/features/orders/presentation/widgets/delivery_location_picker.dart`

El detalle consulta ruta y geometría con el cliente autenticado. Los marcadores usan coordenadas validadas y las paradas se muestran por `orden`. El depósito de Atalaya 1280 es origen/retorno. El selector de destino devuelve GPS con seis decimales al formulario; confirmar y cancelar tienen efectos distintos.

El trazado actual y la altimetría/contexto vial no acreditan navegación real por calles ni tráfico observado. Mantén esa distinción en leyendas, colores, tooltips y métricas. Un error de teselas no debe borrar las entregas ya cargadas. Conserva la lista textual como alternativa al gesto y a la identificación visual de pines.

Los tests de `frontend/test/features/routes/` cubren modelos, repositorio, BLoC, coordenadas y widgets. El selector tiene pruebas en `frontend/test/features/orders/presentation/`. Usa inyección o los parámetros existentes para aislar las teselas en pruebas; prueba por separado su disponibilidad real cuando la tarea lo requiera.

## Roles: leer cuando cambien vistas, acciones o datos

La autoridad de UI es `frontend/lib/core/constants/permissions.dart`, coordinada con `frontend/lib/core/router/app_router.dart`. Contrasta con la seguridad backend y el seguimiento documental; no copies literalmente una matriz histórica desactualizada.

Estado observado al crear esta skill:

| Rol | Interfaz y límites que preservar |
| --- | --- |
| ADMIN / OPERADOR | Gestión operativa de flota, conductores, pedidos y rutas; dashboard. No habilitar por defecto módulos futuros. |
| AUDITOR | Lectura; sin crear, editar, eliminar o generar. |
| CONDUCTOR | Dashboard básico y rutas propias. Sin generación ni eliminación; un usuario sin vínculo a conductor puede tener lista vacía. |
| CLIENTE | Crear/leer pedidos propios; sin edición/eliminación ni dashboard global. El backend fija propietario y estado inicial. |

Los filtros de propiedad están en servicios backend apoyados en el JWT; el frontend no debe simular autorizaciones ni atribuir datos por email/nombre. Los IDs libres históricos de clientes no se vinculan automáticamente a cuentas. La restricción por placa está diferida por instrucción del usuario; no la reactives como parte de una mejora UI. Reoptimización, tráfico real, descanso/jornada y preferencias avanzadas siguen siendo dependencias funcionales, no adornos que la UI pueda dar por implementados.
