# PathSeek: sistema visual de la aplicación

Fecha: 2026-10-22. Alcance: Flutter/Material 3, web y móvil. Mantener BLoC, GoRouter, GetIt, Dio y flutter_map.

## Dirección y fuentes

La búsqueda local de `ui-ux-pro-max` con `logistics operations dashboard` y el reintento `internal logistics dashboard` devuelve **Minimalism & Swiss Style**, adecuado a paneles empresariales: contenido primero, contraste, superficies claras y jerarquía tipográfica. Se adopta ese criterio.

El patrón **Real-Time / Operations Landing** sigue siendo una landing de captación tras el reintento y no es una coincidencia válida para la navegación interna. No se incorpora su estructura, CTA comercial ni telemetría. Como alternativa se conserva la estructura operativa ya verificada en el repositorio.

La paleta azul/naranja y Fira Code/Fira Sans propuestas son recomendaciones, no requisitos. Se adaptan a la identidad verde de PathSeek y a la tipografía Material/Roboto existente para conservar consistencia sin añadir dependencias ni descargas de fuentes.

Búsquedas adicionales verificadas:

- `dragging movements --domain ux`: añadir alternativas a gestos; selector de entregas, zoom y coordenadas manuales.
- `accessible authentication --domain ux`: conservar autofill y pegado; nombrar controles; no cambiar mecanismos de autenticación.
- `adaptive navigation forms --stack flutter`: sin resultados; reintento `form --stack flutter`: Form/GlobalKey y validación al enviar. Se preservan los validadores y eventos del proyecto.
- `references/quick-reference.md`, categorías 1–3 y navegación/formularios; `references/pro-rules.md`, checklist de entrega.

## Tokens

La fuente de implementación es `frontend/lib/core/theme/app_theme.dart`.

| Uso | Valor |
| --- | --- |
| Primario / énfasis | `#1B6D29` / `#0D4715` |
| Fondo / tarjeta | `#F5F7F5` / blanco |
| Texto principal / secundario | `#191C19` / `#47564C` |
| Superficie secundaria / borde | `#EDF3ED` / `#E0E5DF` |
| Información | texto `#204B80`, fondo `#E7F0FD` |
| Advertencia | texto `#704600`, fondo `#FFEFCF` |
| Éxito | texto `#145528`, fondo `#E1F2E5` |
| Peligro | texto `#8C2820`, fondo `#FFE9E7` |

- Usar `Theme.of(context).textTheme` y `colorScheme`, o estos tokens compartidos; evitar nuevas paletas por pantalla.
- Texto de lectura 16, secundario 14, etiquetas Material de 12–14; títulos 22–28 según jerarquía; peso 600–700 para títulos y métricas. El texto ampliado debe crecer y envolver.
- Ritmo de 4/8: controles y separaciones 8/12/16, grupos 24/32, gutters 16 móvil y 32 escritorio. Radios 8 en badges, 12 controles, 16 tarjetas, 20 diálogos.
- Iconos Material, contorno para navegación normal y relleno para opción seleccionada; controles táctiles de al menos 48 dp. Los iconos decorativos no duplican etiquetas accesibles.

## Navegación y responsive

- Una sola `HomeShell`; formularios con encabezado, retorno y superficie de ancho legible, sin Scaffold/AppBar duplicados.
- Desde 1100 dp y 560 dp de alto, con tamaño de texto normal: panel lateral de 240 dp. Contenido principal centrado, máximo 1520 dp; formulario máximo 960 dp.
- Teléfono por debajo de 600 dp: navegación inferior con un máximo de cinco módulos autorizados. Si solo hay un módulo, mostrar un destino único sin usar una barra que exige al menos dos.
- Tableta, paisaje corto o texto ampliado: menú lateral desplazable. Misma matriz de permisos y mismas URLs.
- Selección activa por coincidencia del módulo; `/` solo coincide con la raíz.
- Catálogos: un solo scroll, filas de tarjetas de altura natural y carga diferida por filas. Columnas según espacio real; una columna con texto ampliado. Búsqueda/ordenamiento apilados cuando falta ancho.
- Formularios: columnas según el ancho del contenedor y el tamaño de texto, no solo el tamaño de la ventana; acciones que envuelven.

## Flujos y estados

- Una acción principal por pantalla; actualización/cancelación secundarias; eliminación roja con confirmación. Conservar todos los campos, métricas y acciones autorizadas.
- Login: fondo claro, panel de identidad sobrio en escritorio, formulario persistente durante carga/error, visibilidad de contraseña etiquetada, autofill, errores junto al contenido y foco de validación. No crear mecanismos de recuperación o proveedores que la API no tenga.
- Dashboard: separar recursos, estado de pedidos y sostenibilidad; no presentar ahorros ni datos en vivo que el contrato no entregue.
- Catálogos: estados de carga/error/vacío/búsqueda sin resultados; no recortar nombres, direcciones ni datos operativos para ajustarlos a una altura fija.
- Mapa: controles fuera del viewport; depósito identificado como origen/retorno fijo; entregas numeradas y seleccionables; información textual, leyenda, ajuste de cámara y alternativas a gestos. No mover el depósito ni reordenar entregas.
- Destino: mapa o coordenadas; selección preliminar, confirmación y cancelación distintas. La atribución OSM permanece visible. Un fallo de teselas no elimina las coordenadas ni el trazado.
- Diferenciar trazado/contexto estimados de tráfico observado. Mantener pendientes de US-006, descanso, reporte PDF y restricciones por placa pospuestas.

## Permisos

Usar exclusivamente `AppPermissions` y los guards existentes para acceso. ADMIN/OPERADOR gestionan; AUDITOR lee; CONDUCTOR consulta dashboard/rutas propias; CLIENTE crea/lee sus pedidos. No ampliar permisos ni mostrar datos ficticios para llenar un panel.

## Validación y límites

Probar 375×812, 812×375, 768×1024 y 1440×900, más pantallas de 320 dp y texto ampliado. Verificar opciones por rol, foco/teclado, errores y recuperación, selección/confirmación/cancelación de destino y eventos originales de generación.

La aplicación expone un tema claro; no se añade un modo oscuro sin validación independiente. Las capturas de widgets con datos de prueba no acreditan lector de pantalla, navegador real, descarga de teselas, APK, WCAG completo ni rendimiento de producción. El informe de implementación registra qué comprobaciones se ejecutaron.
