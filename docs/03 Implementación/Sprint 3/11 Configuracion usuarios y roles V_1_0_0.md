# Configuración: gestión de usuarios y roles

Fecha: 2026-10-22. Fuentes: DOC-008 `01 Inicio/08. Usuarios V_1_0_0.md`, EN-003 del backlog y el seguimiento de permisos de la implementación. Esta entrega completa la interfaz administrativa sobre el RBAC existente; no reescribe el cierre de los sprints ni certifica todo EN-003.

## Acceso y alcance

La opción **Configuración**, ruta frontend `/settings`, se integra en HomeShell y en los guards de GoRouter. Se conservan Flutter, Material 3, BLoC, GetIt, Dio, Spring Security, JWT y PostgreSQL.

| Perfil | Configuración |
| --- | --- |
| ADMIN | Lista y gestiona cuentas; consulta Roles y permisos |
| OPERADOR / AUDITOR | Consulta Roles y permisos; sin lista de usuarios ni acciones de escritura |
| CONDUCTOR / CLIENTE | Sin acceso |

DOC-008 permite lectura de configuración a OPERADOR/AUDITOR, mientras asigna la administración de usuarios a ADMIN. Por ello la consulta de roles no expone nombres ni correos de cuentas a esos perfiles.

El catálogo conserva los cinco roles predefinidos: ADMIN, OPERADOR, AUDITOR, CONDUCTOR y CLIENTE. Se asignan a usuarios; no se crean roles arbitrarios ni se editan las reglas de autorización desde la pantalla. Las tarjetas describen capacidades efectivamente implementadas, sin anunciar como disponibles PDF, tráfico real, auditoría global o funcionalidades pendientes.

## Flujo de uso

1. Iniciar sesión como ADMIN y abrir Configuración.
2. En Usuarios, buscar por nombre/correo, filtrar por rol/estado o avanzar entre páginas.
3. Seleccionar Nuevo usuario, completar nombre, correo, contraseña inicial y elegir explícitamente un rol. El formulario no preselecciona ADMIN.
4. Para una cuenta existente, Editar usuario permite cambiar nombre, correo, rol y estado activo. No se muestra ni se modifica su contraseña.
5. Los cambios de correo, rol o estado requieren confirmación e informan del cierre de sesiones de la cuenta afectada.
6. Para retirar acceso se desactiva la cuenta; no hay borrado físico ni pérdida de sus relaciones históricas.

La cuenta actual no puede cambiar su propio rol ni desactivarse. El servidor preserva al menos un ADMIN activo y vuelve a comprobar la autorización después de adquirir bloqueos, incluyendo operaciones concurrentes. Una cuenta asociada a un perfil de conductor no puede cambiar de rol; conserva su asociación y sus rutas. Asignar CONDUCTOR a una cuenta sin vínculo no crea el perfil: debe vincularse explícitamente desde Conductores.

## API

Todos los endpoints requieren Bearer JWT. La autorización se aplica en el servidor además de la UI.

| Método | Endpoint | Permisos |
| --- | --- | --- |
| GET | `/api/v1/configuracion/roles` | ADMIN / OPERADOR / AUDITOR |
| GET | `/api/v1/usuarios` | ADMIN |
| POST | `/api/v1/usuarios` | ADMIN |
| PUT | `/api/v1/usuarios/{id}` | ADMIN |

Listado: `pagina` (base cero), `tamano` (1–100, por defecto 20), `buscar` (nombre/correo, máximo 254 caracteres), `rol` y `activo`. Respuesta: `contenido`, `pagina`, `total_paginas`, `total_elementos`. La UI solicita veinte cuentas por página. El servidor escapa comodines en la búsqueda y normaliza el correo.

Crear:

```json
{
  "nombre": "Operador de ejemplo",
  "email": "operador@example.test",
  "password": "EjemploSeguro123!",
  "rol": "OPERADOR"
}
```

Ejemplo ilustrativo, no credencial instalada. Respuesta HTTP 201. Editar usa `nombre`, `email`, `rol` y `activo`; no incluye password. Las respuestas de usuario contienen `usuario_id`, `nombre`, `email`, `rol`, `activo`, `bloqueado_hasta` y `ultimo_login`. Nunca devuelven hashes, tokens o versiones internas de sesión.

El correo es único sin distinguir mayúsculas/minúsculas. Nombre: hasta 120 caracteres; correo: hasta 254. La contraseña inicial requiere ocho caracteres como mínimo, mayúscula, minúscula y número, con límite de 72 bytes UTF-8 de bcrypt. Se guarda únicamente el hash. No se cambia la política de las contraseñas ya existentes ni las credenciales del `.env`.

Conflictos de negocio incluyen `USER_EMAIL_CONFLICT`, `SELF_ACCESS_CHANGE`, `LAST_ACTIVE_ADMIN` y `DRIVER_ACCOUNT_LINKED`. No hay DELETE; un método no permitido devuelve 405. La validación inválida devuelve 400 y los accesos no autorizados 401/403, con el formato de errores habitual.

## Sesiones y relaciones

La columna `usuarios.token_version` permite revocar los access tokens previamente emitidos. El JWT incluye `ver`; el backend verifica versión, rol y estado actual de la cuenta en cada petición. Los tokens anteriores sin `ver` son compatibles únicamente con cuentas cuya versión permanezca en cero.

Cambiar correo, rol o estado incrementa la versión y revoca sus refresh tokens en la misma transacción. Cambiar solo el nombre conserva sesiones. La rotación de refresh bloquea usuario antes que token para no recrear sesiones mientras se revocan. La web elimina la sesión local y vuelve al login cuando la renovación es rechazada; un error transitorio del servidor no provoca ese cierre.

La asociación con un conductor valida que la cuenta esté activa, tenga rol CONDUCTOR y no esté vinculada a otro perfil. No se infiere identidad por nombre o correo.

Los triggers PostgreSQL existentes registran creación y cambios de rol/estado en `auditoria`; esta entrega no añade una pantalla de auditoría ni afirma trazabilidad completa del actor. Los registros históricos actuales identifican al usuario modificado.

## Diseño y accesibilidad

Se aplicaron `frontend-uiux` y `ui-ux-pro-max`, conservando el sistema visual verde existente. Las decisiones están en `design-system/pathseek/pages/settings.md`. Se reutilizan CatalogLayout, PageHeader, ResponsiveFieldRow y StatusBadge.

La interfaz ofrece carga, error recuperable, vacío, confirmación y estado de guardado. Los formularios conservan los datos ante fallos, tienen etiquetas visibles y errores de validación; las acciones usan texto e iconos. Se comprueban 320 dp y texto 2×. Para evitar seis destinos en la barra inferior del ADMIN, el móvil utiliza el menú lateral; se conserva la selección activa y el acceso a los demás módulos.

## Activación en una base existente

**Actualización:** Flyway aplica ahora las migraciones automáticamente antes de iniciar el backend. Los pasos manuales siguientes son históricos; utiliza `docker compose up --build -d` según `LOCAL.md`.

**Aplicar `database/06_user_administration.sql` antes de iniciar el backend actualizado.** Es aditiva e idempotente: añade `token_version` con valor inicial cero y un índice único para correo normalizado. No borra usuarios. Las bases locales nuevas reciben el script mediante el montaje de inicialización de Compose; un volumen existente requiere aplicación explícita porque Flyway sigue desactivado.

Desde la raíz, con PostgreSQL local Docker en ejecución:

```powershell
Get-Content -Raw .\database\06_user_administration.sql |
  docker compose exec -T postgres sh -c 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -v ON_ERROR_STOP=1'
docker compose up --build -d --wait backend frontend
```

Después, recargar con Ctrl+F5 e iniciar sesión como ADMIN. En PostgreSQL nativo, aplicar el mismo script con `psql -v ON_ERROR_STOP=1 -f` a la base configurada y ejecutar los lanzadores habituales.

En el VPS se debe aplicar la migración a la base de producción antes del despliegue usando su configuración y procedimiento operativo. El workflow de despliegue existente no ejecuta automáticamente migraciones. Esta entrega no modifica ni inicia el despliegue del VPS.

## Verificación

Resultados locales: **105 pruebas backend H2**, **55 pruebas de la suite PostgreSQL 16** y **268 pruebas Flutter**, todas aprobadas. `flutter analyze` sin incidencias y compilación web release correcta. Las pruebas de integración HTTP se ejecutan con MockMvc y clientes simulados en frontend; no sustituyen una prueba manual del flujo completo en navegador. La ejecución remota del workflow de GitHub sigue pendiente.

Las pruebas se ejecutan con datos de prueba. PostgreSQL se comprueba en un contenedor temporal independiente, con puerto aleatorio y sin montar el volumen de PathSeek. Se aplican scripts 01–06 y se verifica la migración 06 dos veces. El workflow de comprobaciones incorpora la nueva migración y las suites de administración y seguridad.

La suite cubre autorización por perfil, alta/edición, correos duplicados, contraseña, preservación del ADMIN, JWT/refresh revocados, sujetos JWT inválidos y operaciones concurrentes. Frontend cubre contratos HTTP, permisos, navegación, búsqueda/paginación, formulario, confirmación, guardado y diseño responsive. Los logs locales de resultados están en `backend/settings-*-tests.log` y `frontend/settings-*.log`.

Se inspeccionaron `frontend/build/settings-preview-desktop.png` y `settings-preview-mobile.png`, renderizados con fuentes reales y datos ficticios claramente identificados. No se realizó una inspección manual en navegador de esta nueva pantalla ni se certifica cumplimiento WCAG completo o funcionamiento de APK por estas pruebas.
