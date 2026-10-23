# Vinculación de conductor y cuenta por DNI

La administración de cuentas usa el DNI de ocho dígitos para asociar una cuenta CONDUCTOR y su perfil operativo. Se mantiene la autorización DOC-008: ADMIN crea/edita cuentas; ADMIN/OPERADOR gestionan conductores. El DNI es un identificador de asociación, no una contraseña ni un medio para iniciar sesión.

## Uso

1. En Configuración → Nuevo usuario, seleccionar CONDUCTOR e ingresar su DNI, correo y contraseña inicial.
2. En Conductores, crear el perfil con el mismo DNI. La asociación es automática: no se copia ningún usuario_id.
3. También se puede crear el conductor primero, sin cuenta; al crear posteriormente la cuenta con ese DNI, se vincula el perfil existente.
4. Si no existe una cuenta coincidente, el perfil puede registrarse sin acceso a la aplicación. Las rutas propias requieren una cuenta CONDUCTOR activa vinculada.

El UUID continúa siendo la clave interna y no se solicita al usuario. La API rechaza un UUID explícito que no corresponda al DNI. Los cambios de DNI en cuentas o perfiles ya vinculados se bloquean para preservar la identidad y las asignaciones. El DNI de cuenta es único; las operaciones de creación/edición se serializan con la administración de cuentas para evitar vínculos concurrentes incompatibles. Una cuenta inactiva o de otro rol no recibe acceso como conductor.

La migración aditiva `database/07_driver_dni_link.sql` añade `usuarios.dni`, conserva los vínculos existentes copiando el DNI desde el perfil y crea su índice único. No modifica contraseñas ni roles.

## Activar en Docker existente

**Actualización del arranque:** las migraciones se ejecutan automáticamente mediante Flyway. Para instalaciones nuevas y existentes basta con `docker compose up --build -d`, siguiendo `LOCAL.md`. El procedimiento manual siguiente se conserva como referencia histórica y ya no es necesario con esta versión del backend.

Aplicar después de la migración 06 y antes de reconstruir el backend:

```powershell
Get-Content -Raw .\database\07_driver_dni_link.sql |
  docker compose exec -T postgres sh -c 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -v ON_ERROR_STOP=1'
docker compose up --build -d --wait backend frontend
```

El montaje para bases nuevas y el workflow de pruebas incluyen la migración 07. La API de usuarios añade `dni` a las respuestas y admite `dni` al crear/editar. Las cuentas nuevas CONDUCTOR requieren DNI; las cuentas históricas sin asociación se regularizan al editarlas. La vinculación no altera el inicio de sesión por correo/contraseña ni la comprobación de propietario de rutas mediante JWT.
