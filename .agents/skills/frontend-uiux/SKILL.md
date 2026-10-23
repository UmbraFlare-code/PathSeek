---
name: frontend-uiux
description: "Mejorar el diseño UI/UX del frontend Flutter de PathSeek: componentes existentes, responsive, accesibilidad, mapas y visualización de rutas e interfaces según rol. Usar en cambios o revisiones de interfaz de este repositorio; no para desarrollo de backend sin trabajo de UI."
---

# PathSeek Frontend UI/UX

Mejora la experiencia de las pantallas operativas de PathSeek sin alterar sus reglas de negocio. Trabaja sobre Flutter y los componentes existentes; no sustituyas la aplicación por una web HTML/React ni cambies su arquitectura para renovar el aspecto.

## Contexto antes de diseñar

- Localiza la raíz del repositorio; las rutas de esta skill son relativas a ella. Desde esta carpeta, la raíz está tres niveles arriba. Inspecciona `frontend/pubspec.yaml`, el componente afectado, `frontend/lib/core/theme/app_theme.dart` y los helpers que ya utiliza.
- Identifica el objetivo del usuario, el flujo que debe preservar y su historia de usuario o criterio de aceptación cuando exista. Consulta solo los documentos pertinentes de `docs/`; usa [la guía de contexto](references/pathseek-context.md) para encontrarlos y para cambios de mapas o permisos.
- Contrasta documentos, código y seguimiento reciente: una matriz objetivo o un acta histórica no prueba que la capacidad esté implementada. Conserva los avances de sprints previos; registra una discrepancia relevante sin reescribir su historia ni declarar nuevos ítems Done sin evidencia.

## Diseño y reutilización

- Busca una mejora concreta en jerarquía, legibilidad, densidad de información y facilidad de acción. Las métricas logísticas, las ventanas de entrega y el estado operativo deben resultar fáciles de localizar; los adornos no deben competir con ellos.
- Usa Material 3 y `Theme.of(context).colorScheme` / `textTheme`, junto con los tokens de `AppTheme`. Mantén la identidad verde existente y una jerarquía coherente de superficies, espaciados, radios e iconos. Si el encargo cambia la identidad, actualiza los tokens compartidos de forma deliberada en vez de introducir paletas aisladas por pantalla.
- Reutiliza primero `frontend/lib/core/widgets/` y los widgets de cada feature. Extrae un componente compartido cuando exista una responsabilidad visual repetida; conserva componentes específicos cuando sus flujos o reglas difieran. No crees un framework de diseño nuevo para una corrección puntual.
- Mantén textos de interfaz en español y código en inglés, conforme al proyecto. Distingue acciones primarias, secundarias y destructivas. Contempla carga, vacío, error recuperable, éxito y acceso denegado cuando formen parte del flujo modificado.
- Conserva BLoC, eventos, estados, entidades, repositorios, inyección y GoRouter. Una mejora visual no debe cambiar endpoints, payloads, unidades, prioridades, validaciones, transiciones de estado ni el significado de una métrica. Las demostraciones o datos de ejemplo deben identificarse como tales.

## Responsive y accesibilidad

- Parte de `kMobileBreakpoint` / `isNarrow` (actualmente 600 dp) y `ResponsiveFieldRow`. Adapta controles al espacio disponible con constraints y layouts flexibles: campos apilados en móvil, tarjetas/listas legibles y tablas manejables en escritorio. No dependas de un ancho de teléfono específico.
- Revisa desbordamientos, teclado de formularios, texto ampliado y disponibilidad de acciones sin hover. Respeta la navegación móvil y de escritorio de `HomeShell` en lugar de duplicarla dentro de una feature.
- RNF-006 exige WCAG 2.1 AA. Verifica contraste real de texto y superficies; los comentarios del tema no certifican cumplimiento. Mantén foco visible y orden de teclado lógico, etiquetas persistentes, errores asociados al campo y nombres accesibles para botones de icono mediante `Tooltip`/`Semantics` según corresponda.
- Conserva objetivos táctiles cómodos (el tema usa botones de al menos 48 dp). No comuniques estado, prioridad o congestión solo mediante color. Evita animación gratuita y respeta las preferencias de movimiento al añadirla.

## Mapas y rutas

Para este trabajo, lee la sección de mapas de [la guía de contexto](references/pathseek-context.md) y los criterios de RF-004/US-007 aplicables.

- Reutiliza `flutter_map`, OpenStreetMap y el contrato de geometría existente. Conserva atribución visible, controles comprensibles, selección de entregas y una alternativa textual con secuencia, ventanas y ETA.
- Mantén los identificadores y el orden operativo de las paradas al cambiar su presentación. No sustituyas coordenadas ausentes por ubicaciones ficticias ni reordenes entregas desde un widget.
- Distingue trazado estimado, datos calculados, simulación y observaciones reales. No añadas tráfico en vivo, seguimiento GPS, navegación por calles o funcionamiento offline como afirmaciones visuales si el servicio no los proporciona.
- El depósito actual es el origen/retorno; el formulario de pedidos selecciona destinos. Cambiarlo requiere que el requisito y el contrato lo permitan. Una mejora de estilo no autoriza alterar el optimizador ni las restricciones de capacidad, ventanas y prioridad.

## Interfaces según permisos

Para modificar navegación, acciones o visibilidad de datos, lee la sección de roles de [la guía de contexto](references/pathseek-context.md).

- Reutiliza `AppPermissions`, el usuario autenticado y los guards de GoRouter; evita matrices de roles duplicadas en widgets. Preserva la experiencia de ADMIN al incorporar variantes para otros roles.
- Diferencia lectura de mutación y recursos propios de globales. No hagas visible una acción que el backend deniega ni expongas datos ajenos para completar una maqueta. Ocultar un botón no sustituye la autorización del servidor.
- No modifiques backend, base de datos o configuración de despliegue por una necesidad puramente visual. Si una interacción solicitada necesita un contrato nuevo, explica la dependencia y limita los cambios al alcance autorizado; continúa con las mejoras independientes. No amplíes permisos para evitar un 403.

## Verificar y entregar

- Ejecuta desde `frontend/` el análisis y las pruebas relevantes al cambio. Añade regresiones cuando protejan una interacción, un permiso o un comportamiento responsive; no añadas pruebas que solo repitan la implementación.
- Usa `flutter analyze`; para cambios de lógica o widgets, ejecuta sus pruebas y la suite completa cuando el alcance lo justifique. Compila web si cambia la integración o existe riesgo de compilación. Emplea el entorno local (`APP_ENV=dev` y la URL local apropiada) al comprobar la aplicación; no cambies destinos de producción para probar un diseño.
- Inspecciona la interfaz renderizada en tamaños representativos del cambio y con texto ampliado cuando las herramientas lo permitan. En mapas, las pruebas pueden desactivar teselas externas para comprobar interacción; eso no acredita la carga real de OpenStreetMap. Si no hubo inspección visual o una comprobación quedó bloqueada, dilo.
- Resume el flujo mejorado, componentes modificados, relación con el sprint, pruebas y límites. No declares accesibilidad completa, cobertura, APK validado o despliegue realizado por haber compilado la web. No reconstruyas contenedores ni publiques cambios salvo que la tarea lo incluya.
