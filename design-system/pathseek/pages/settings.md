# Configuración: usuarios y roles

Extensión del sistema visual de PathSeek; conserva `MASTER.md`, el tema verde Material 3 y los componentes existentes. Fecha: 2026-10-22.

## Fuentes de diseño

Se ejecutaron búsquedas `ui-ux-pro-max` de sistema de diseño para `internal administration user management` y el reintento `enterprise dashboard settings`. El estilo **Minimalism & Swiss Style** es pertinente para la administración interna. La estructura Hero/Features/CTA devuelta no corresponde a esta pantalla y se descarta; tampoco se adoptan sus fuentes externas o paletas alternativas. Se mantiene la estructura operativa del sistema visual existente.

La consulta `form validation --stack flutter` recomienda Form/GlobalKey y validación al enviar, aplicadas al formulario. Se revisaron las pautas de accesibilidad, interacción, rendimiento y el checklist de `references/pro-rules.md`.

## Pantalla

- Entrada Configuración en HomeShell; en móvil se utiliza el menú lateral cuando hay más de cinco módulos autorizados.
- Encabezado y tarjetas reutilizan CatalogLayout, PageHeader, StatusBadge y ResponsiveFieldRow.
- ADMIN: pestañas Usuarios y Roles y permisos. OPERADOR/AUDITOR: solo consulta de roles, sin datos personales de cuentas.
- Búsqueda, filtros y paginación del servidor. Estados de carga, fallo con reintento, vacío y guardado.
- Formulario en diálogo desplazable: nombre y correo etiquetados, rol obligatorio sin selección predeterminada y contraseña inicial solo al crear.
- Confirmación antes de cambiar correo, rol o estado; informa que se cierran las sesiones de la cuenta.
- La cuenta actual no puede cambiar su propio rol ni desactivarse. El estado también se expresa con texto e icono.
- Uso de superficies claras, espaciado de 8 dp, campos apilados en móvil y texto ampliado. No se añaden fuentes, librerías o permisos arbitrarios.

Las capturas de pruebas en `frontend/build/settings-preview-*.png` se identifican como datos ficticios. Sirven para inspección de widgets; no acreditan auditoría WCAG completa ni ejecución en un navegador real.
