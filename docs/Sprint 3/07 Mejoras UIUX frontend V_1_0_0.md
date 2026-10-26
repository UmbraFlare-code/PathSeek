# Mejoras UI/UX del frontend PathSeek

Fecha: 2026-10-22. Trabajo realizado con la skill del repositorio `frontend-uiux`.

## Contexto y alcance

Se revisaron la estructura, dependencias y documentos de requisitos, roles, reglas, stack, C4/ADR, backlog y seguimiento de sprints, apoyándose en el inventario de `docs/DOCUMENTATION_INDEX.md`.

El frontend actual utiliza Flutter, Material 3, BLoC, GetIt, GoRouter, Dio y flutter_map/OpenStreetMap. Se conservan sus capas, contratos, eventos y permisos. Esta entrega modifica presentación y pruebas; no añade cambios al backend, SQL, dependencias o despliegue.

La intervención da continuidad a RF-003/US-005 (generación), RF-004/US-007 (mapa), RF-005/US-008 (dashboard), RNF-006/EN-006 (accesibilidad) y RNF-007 (usabilidad). El cierre histórico de Sprint 2 describe la gestión base; el mapa geográfico y sus límites se documentan en el informe 06. Estas mejoras no cambian retrospectivamente los cierres ni declaran completas las capacidades pendientes de los sprints siguientes.

## Diagnóstico y cambios

| Hallazgo | Mejora implementada |
| --- | --- |
| Encabezados y superficies inconsistentes | Encabezado compartido, jerarquía tipográfica, identidad verde, tarjetas y botones coherentes mediante el tema existente. |
| Consulta de rutas sin filtros | Búsqueda por fecha, placa o conductor; filtros por estado; orden visual por fecha, distancia o CO2. No se cambia el orden operativo de las entregas. |
| La generación sustituía la consulta por una espera | Progreso visible conservando las rutas existentes y mensaje de resultado mediante los estados del BLoC. |
| Tabla y filas rígidas en pantallas pequeñas | Tarjetas en móvil o con texto ampliado; tabla en escritorio con acciones compactas etiquetadas y desplazamiento horizontal para contenido largo. |
| Estados y mensajes poco ajustados al rol | Estado real de cada ruta con icono y texto; generación/eliminación según `AppPermissions`; estados vacíos específicos para conductor y lectura. Solo las rutas planificadas muestran eliminación, con confirmación. |
| Controles y detalle del mapa competían por una altura fija | El viewport del mapa tiene altura propia; controles y detalle crecen con el texto. Ajuste de ruta completa, zoom y selector de entrega accesible mediante controles estándar de Flutter. |
| Detalle de ruta denso y poco adaptable | Métricas agrupadas, mapa y entregas en columnas cuando hay espacio; disposición vertical en móvil; ventanas, ETA, peso y contexto vial conservados. |
| Dashboard dependiente de alturas rígidas | Distribución flexible de KPI y accesos rápidos, sin pedir generación a usuarios de lectura. |
| Borrar búsqueda no actualizaba siempre los resultados | El botón de limpieza también ejecuta el callback de filtrado. Campos y ordenamiento se adaptan al ancho real del contenedor. |

Se conservan el depósito, la geometría recibida, los marcadores y el orden de las paradas, las coordenadas válidas, la atribución OSM y el tratamiento de teselas fallidas. La interfaz identifica el trazado y contexto como estimados y no afirma disponer de tráfico en vivo.

## Archivos de esta entrega

Las rutas siguientes son relativas a `frontend/`:

- `lib/core/theme/app_theme.dart`: superficies, tipografía, tablas y controles.
- `lib/core/widgets/page_header.dart`: nuevo encabezado reutilizable.
- `lib/core/widgets/search_sort_controls.dart`: etiquetas, limpieza y distribución adaptable.
- `lib/core/widgets/empty_view.dart` y `error_view.dart`: contenido desplazable y contraste.
- `lib/features/dashboard/presentation/pages/dashboard_page.dart`: encabezado, KPI, accesos y mensajes según permisos.
- `lib/features/dashboard/presentation/widgets/kpi_card.dart`: altura natural del contenido.
- `lib/features/routes/presentation/pages/route_list_page.dart`: búsqueda, filtros, estado, progreso y acciones.
- `lib/features/routes/presentation/pages/route_detail_page.dart`: navegación, estado real, métricas y distribución del detalle.
- `lib/features/routes/presentation/widgets/interactive_route_map.dart`: controles, selección y detalle adaptable.
- `lib/features/routes/presentation/widgets/elevation_profile_widget.dart`: encabezado flexible y dimensiones adaptadas al tamaño del texto.
- `lib/features/routes/presentation/widgets/route_status_badge.dart`: nuevo indicador compartido de estado.
- `test/uiux_regression_test.dart`: diez casos de regresión de interacción, permisos y pantallas pequeñas.
- `test/features/routes/presentation/interactive_route_map_test.dart`: actualización de los controles y etiquetas conservando las comprobaciones de interacción y altitud.

Los demás cambios que ya estaban en el árbol de trabajo pertenecen a revisiones anteriores.

## Verificación

Desde `frontend/`:

```powershell
flutter analyze
flutter test
flutter build web --release --dart-define=APP_ENV=dev --dart-define=API_BASE_URL=http://localhost:8080
```

- Análisis estático: sin incidencias (`ui-analyze.log`).
- Suite completa: 218 pruebas aprobadas, incluidas diez nuevas regresiones (`ui-full-tests.log`).
- Compilación web release local: completada correctamente en `build/web`, con la URL base `http://localhost:8080` (`ui-build-web.log`).
- Widgets probados a 1280 × 900, 390 × 844 y 320 × 640, con escala de texto de hasta 2. Se verificaron generación mediante el evento existente, filtrado/limpieza, ausencia de mutaciones para AUDITOR/CONDUCTOR, selección de entregas, perfil vial y dashboard.
- Inspección visual de capturas de escritorio y móvil generadas con datos de prueba en `frontend/build/uiux/`: `routes-desktop.png`, `routes-mobile.png` y `map-mobile.png`. Son vistas de widgets; las teselas externas están desactivadas en estas pruebas. Las fuentes del SDK no reproducen todo el fallback tipográfico de un navegador real.
- Contraste calculado de texto primario sobre blanco: 17.19:1; verde primario sobre blanco: 6.43:1; texto de los cuatro indicadores de estado sobre sus fondos: entre 7.21:1 y 7.68:1. Esto comprueba esas combinaciones, no certifica WCAG de toda la aplicación.

## Límites y continuidad

Quedan pendientes las pruebas manuales de extremo a extremo con API, navegador, teclado y lector de pantalla, descarga real de teselas y Android. No se acredita WCAG completa, cobertura global o rendimiento de producción con estas pruebas.

Se mantienen los pendientes del informe 06: tráfico real y navegación por calles, jornadas/descansos, reoptimización, preferencias de clientes y reportes. La restricción por placa sigue pospuesta por instrucción del usuario. No se reconstruyeron contenedores ni se publicó esta entrega.

Para revisar el frontend con el backend local ya iniciado, ejecutar desde `frontend/`:

```powershell
flutter run -d chrome --dart-define=APP_ENV=dev --dart-define=API_BASE_URL=http://localhost:8080
```

Una instancia servida por Docker seguirá mostrando la imagen anterior hasta que se reconstruya. La URL base local no lleva `/api`: los paths del cliente ya incluyen `/api/v1`.
