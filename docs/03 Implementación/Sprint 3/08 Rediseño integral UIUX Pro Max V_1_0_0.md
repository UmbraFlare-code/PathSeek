# Rediseño integral UI/UX de PathSeek

Fecha: 2026-10-22. Skill utilizada: `.agents/skills/ui-ux-pro-max/SKILL.md`.

## Análisis previo y trazabilidad

Se revisaron las tecnologías, dependencias, capas del frontend, navegación, formularios, tarjetas, dashboard, mapas y pruebas. Se contrastaron los Markdown de `docs/` mediante su inventario y las secciones aplicables de requisitos funcionales/no funcionales, usuarios, reglas de negocio, stack, C4/ADR, backlog, artefactos Jira e informes de implementación 01–07.

La aplicación usa Flutter/Dart, Material 3, BLoC, GoRouter, GetIt, Dio, flutter_map y OpenStreetMap. Se conserva esa arquitectura y las versiones instaladas. No se añaden paquetes, proveedores de autenticación, endpoints ni cambios de backend/base de datos.

| Fuente | Aplicación en esta entrega |
| --- | --- |
| RF-001 / US-001; US-002 y US-003 | Consulta y formularios de flota, conductores y pedidos; conservar campos, filtros, validadores y eventos. |
| RF-002 | Destino GPS, carga, prioridad y ventana de entrega; confirmación/cancelación del selector. |
| RF-003 / US-005 | Conservar generación, estados, métricas y eventos existentes. |
| RF-004 / US-007 | Mapa, depósito, destinos numerados, trazado, contexto estimado y atribución. |
| RF-005 / US-008 | Organizar únicamente los indicadores que entrega el contrato actual. |
| RNF-006 / EN-006; RNF-007 | Contraste, etiquetas, teclado, tamaño de texto, controles táctiles y adaptación de layouts. |
| DOC-008 y seguimiento 06 | Mantener permisos efectivos y acceso a recursos propios. |

Los cierres de Sprint 2 registran la gestión base y tarjetas. La continuidad del mapa y sus límites está en el informe 06, y la primera mejora visual en el 07. Esta entrega amplía esa mejora a la aplicación completa sin reescribir los cierres ni certificar pendientes de sprints futuros como Done.

## Dirección de diseño y diagnóstico

Las búsquedas verificadas de la skill, sus resultados aplicables y las adaptaciones al proyecto están registradas en `design-system/pathseek/MASTER.md`. Se adopta la claridad del estilo Minimalism & Swiss Style, conservando verde/Roboto/Material. El patrón de landing sugerido no corresponde a una aplicación de gestión; después del reintento se conserva la estructura operativa existente como alternativa. No se persiste ni implementa esa plantilla comercial.

Problemas encontrados y corregidos:

- El prefijo `/` hacía que Inicio apareciera seleccionado al consultar otros módulos. Ahora se distingue la raíz de los prefijos de cada módulo.
- CLIENTE tiene un único destino autorizado; `NavigationBar` requiere al menos dos. Se añade una presentación válida para un destino sin ampliar permisos.
- El menú lateral y la navegación móvil se adaptan también a altura disponible y texto ampliado; en paisaje corto se utiliza un menú desplazable.
- Los encabezados de catálogos estaban duplicados, y las tarjetas usaban alturas fijas, filas de métricas pequeñas y truncación. Ahora tienen scroll único, altura natural, metadatos que envuelven y acciones reutilizadas.
- Los formularios añadían Scaffold/AppBar dentro de la shell y sus columnas dependían del ancho global. Se comparte un layout con retorno predecible, ancho legible y columnas según espacio real/tamaño de texto.
- El login mezclaba blur/glass y contraste oscuro con el tema operativo claro; además podía perder los campos al sustituir el formulario por carga. Ahora conserva sus campos durante carga/error, mantiene autofill/pegado y usa controles estándar etiquetados.
- Los estados tenían paletas aisladas y formatos poco legibles. Se centralizan tonos semánticos y badges con icono/texto.
- El dashboard presenta recursos, estado de pedidos y sostenibilidad en grupos; los valores pueden crecer con el texto y sus accesos mantienen los permisos.

## Mapas y generación

El detalle identifica el depósito UGEL, Atalaya 1280, como origen/retorno fijo y permite centrarlo con un botón. Se mantienen ajuste de recorrido, zoom, selector de entregas, detalle textual y marcadores. Se añade leyenda y reintento del mapa base. Los controles y mensajes quedan fuera del viewport, salvo la atribución OSM.

El selector de destino permite tocar el mapa o introducir latitud/longitud y ubicarlas mediante un botón. Las coordenadas manuales se validan, incluidos valores no finitos. Editar una selección desactiva su confirmación hasta ubicar las coordenadas nuevas; cancelar retorna sin cambiar el destino del pedido. Los botones de cancelar/confirmar permanecen al pie del diálogo mientras el contenido se desplaza.

No se incorpora un origen libre porque el modelo documentado y el contrato actuales usan el depósito. No se cambian secuencias, capacidades, ventanas, prioridades, fórmulas ni algoritmo. El trazado continúa identificado como estimado y sin tráfico en vivo. Los errores de teselas no borran entregas ni coordenadas.

## Roles

| Rol | Interfaz preservada |
| --- | --- |
| ADMIN / OPERADOR | Gestión de catálogos/pedidos, dashboard y generación/gestión de rutas autorizadas. |
| AUDITOR | Consulta, búsqueda, filtros y navegación; sin crear, editar, eliminar ni generar. |
| CONDUCTOR | Resumen y rutas propias; navegación móvil adaptable; sin generación ni eliminación. |
| CLIENTE | Crear/leer sus pedidos; módulo único válido en móvil; sin módulos globales ni edición/eliminación. |

Se reutilizan `AppPermissions`, usuario autenticado y guards existentes. No se modifican autenticación, autorización, filtros de propiedad ni payloads. Los eventos originales de los BLoC siguen siendo los puntos de entrada de las acciones.

## Archivos de esta entrega

Rutas relativas al repositorio; los otros cambios que ya existían en el árbol de trabajo pertenecen a tareas anteriores.

| Archivos | Cambio |
| --- | --- |
| `frontend/lib/core/theme/app_theme.dart` | Tokens semánticos, lectura, superficies, navegación, controles y feedback. |
| `frontend/lib/core/router/home_shell.dart` | Navegación adaptable, selección activa y módulo único; acceso por rol conservado. |
| `frontend/lib/core/widgets/catalog_layout.dart` | Nuevo layout compartido, scroll único y tarjetas de altura natural. |
| `frontend/lib/core/widgets/record_details.dart` | Nuevos metadatos y acciones compartidas de registros. |
| `frontend/lib/core/widgets/status_badge.dart` | Nuevo badge semántico con icono/texto. |
| `frontend/lib/core/widgets/form_page_layout.dart` | Nuevo layout compartido de formularios con navegación de retorno. |
| `frontend/lib/core/widgets/responsive_field_row.dart` | Columnas según constraints y escala de texto. |
| `frontend/lib/features/auth/presentation/pages/login_page.dart` | Rediseño coherente, campos persistentes, foco, autofill y feedback. |
| `frontend/lib/features/fleet/presentation/pages/fleet_list_page.dart` y `widgets/vehicle_card.dart` | Catálogo y tarjeta de vehículos. |
| `frontend/lib/features/drivers/presentation/pages/driver_list_page.dart` y `widgets/driver_card.dart` | Catálogo y tarjeta de conductores. |
| `frontend/lib/features/orders/presentation/pages/order_list_page.dart` y `widgets/order_card.dart` | Catálogo, tarjeta, prioridad y estado de pedidos. |
| `frontend/lib/features/fleet/presentation/pages/vehicle_form_page.dart` | Formulario compartido, selectores y etiquetas. |
| `frontend/lib/features/drivers/presentation/pages/driver_form_page.dart` | Formulario compartido y acciones adaptables. |
| `frontend/lib/features/orders/presentation/pages/order_form_page.dart` | Formulario compartido y selectores legibles conservando valores API. |
| `frontend/lib/features/dashboard/presentation/pages/dashboard_page.dart` y `widgets/kpi_card.dart` | Indicadores agrupados y accesos coherentes. |
| `frontend/lib/features/orders/presentation/widgets/delivery_location_picker.dart` | Selección adaptable con mapa/coordenadas y acciones al pie. |
| `frontend/lib/features/routes/presentation/widgets/interactive_route_map.dart` | Origen fijo visible, leyenda, estados y reintento del mapa base. |
| `frontend/lib/features/routes/presentation/widgets/route_status_badge.dart` | Reutilización del badge central. |
| `frontend/test/uiux_pro_max_test.dart` | 18 regresiones nuevas de navegación, roles, interacción y responsive; capturas con fixtures. |
| `frontend/test/uiux_regression_test.dart` | Ajuste de etiqueta del acceso a rutas; conserva la suite anterior. |
| `design-system/pathseek/MASTER.md` | Dirección visual, fuentes verificadas, tokens y reglas para continuidad. |

Los paths `widgets/...` de las filas agrupadas son hermanos de `pages/` dentro de `presentation/` de la misma feature.

## Resultados de validación

Desde `frontend/`:

```powershell
flutter analyze
flutter test
flutter build web --release --dart-define=APP_ENV=dev --dart-define=API_BASE_URL=http://localhost:8080
```

- **Análisis estático: sin incidencias**, registrado en `frontend/ux-pro-analyze.log`.
- **236 pruebas aprobadas**: las 218 existentes y 18 nuevas, registradas en `frontend/ux-pro-tests.log`.
- **Compilación web release local completada**, con salida en `frontend/build/web` y resultado en `frontend/ux-pro-build-web.log`; no equivale a reconstruir una imagen Docker.
- Tamaños de regresión: 320×480, 375×812, 812×375, 768×1024, 1024×768 y 1440×900, además de los tamaños de la suite anterior. Texto ampliado hasta 2 y preferencia de movimiento reducido activada en los nuevos escenarios.
- Navegación: selección de módulo en enlace profundo, cambio de módulo, menú del conductor en paisaje, catálogo de cliente con un solo destino y restricciones del auditor.
- Login: evento original, salto de teclado al campo de contraseña, visibilidad etiquetada y conservación de campos después de carga/error.
- Formularios: acciones alcanzables con texto ampliado; se conservan validadores, payloads y eventos.
- Mapa: pruebas existentes de selección/recentrado/generación, nueva selección por coordenadas, rechazo de rango y NaN, confirmación y cancelación sin efectos. Las pruebas desactivan teselas externas.
- Inspección visual de `frontend/build/uiux-pro/`: `fleet-desktop.png`, `login-desktop.png`, `dashboard-desktop.png`, `client-mobile.png` y `destination-mobile.png`. Son datos de prueba, no datos de producción. También se regeneraron las capturas anteriores en `frontend/build/uiux/`.
- `git diff --check` de los archivos frontend modificados: sin errores de whitespace; los avisos de conversión LF/CRLF son del entorno Git.

Contrastes calculados de los pares usados: texto principal/blanco 17.19:1, secundario/blanco 7.77:1, verde primario/blanco 6.43:1, blanco/panel de identidad 10.89:1 y estados entre 7.21:1 y 7.68:1. Esto acredita esas combinaciones, no el cumplimiento completo de WCAG.

## Pendientes y límites

1. Validación manual de extremo a extremo con API/usuarios reales, teclado completo y lector de pantalla; auditoría axe/Lighthouse en el entorno definido por EN-006. Las pruebas de widgets con BLoC simulados no sustituyen esa auditoría.
2. Descarga real de teselas, recuperación de red en navegador y comprobación de Android/APK. Las capturas usan fuentes del SDK, cuyo fallback no reproduce todos los glifos del navegador.
3. La aplicación expone tema claro; no se introduce ni se acredita modo oscuro. El escalado verificado hasta 2 no certifica todos los tamaños de texto de cada sistema operativo.
4. Siguen pendientes los criterios funcionales del informe 06: tráfico real, navegación por calles, offline integral, jornadas/descansos, reoptimización, preferencias y reportes PDF. La restricción por placa permanece pospuesta por el usuario.

No se publicaron cambios ni se reconstruyeron contenedores. Para ver la entrega mediante Docker Desktop, desde la raíz ejecutar:

```powershell
docker compose up --build -d
```

Si todos los servicios ya están funcionando y solo se desea reconstruir el frontend:

```powershell
docker compose up --build -d --no-deps frontend
```

Abrir `http://localhost/#/login` y actualizar con Ctrl+F5. El entorno Docker conserva el proxy Nginx local; no requiere ejecutar Flutter manualmente.
