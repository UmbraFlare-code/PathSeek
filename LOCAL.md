# Ejecutar PathSeek en local

## Opción 1: todo con Docker

Requiere Docker Desktop iniciado, con contenedores Linux y Docker Compose. No requiere instalar Java ni Flutter en el host.

Desde PowerShell:

```powershell
cd E:\PathSeek
Copy-Item .env.example .env   # solo si todavía no existe .env
```

Edita `.env`: reemplaza `JWT_SECRET` por un secreto aleatorio de 32 o más caracteres y configura un usuario local:

```dotenv
APP_BOOTSTRAP_USER_ENABLED=true
APP_BOOTSTRAP_USER_NAME=Administrador local
APP_BOOTSTRAP_USER_EMAIL=admin@pathseek.local
APP_BOOTSTRAP_USER_PASSWORD=elige-una-clave-local
APP_BOOTSTRAP_USER_ROLE=ADMIN
```

Puedes generar el secreto en PowerShell:

```powershell
$bytes = New-Object byte[] 48
[System.Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($bytes)
[Convert]::ToBase64String($bytes)
```

Arranca desde la raíz:

```powershell
docker compose up --build -d
docker compose ps
docker compose logs -f backend
```

Abre [la aplicación](http://localhost) e inicia sesión con el email y la contraseña que elegiste. El frontend local usa HTTP y envía `/api/` al backend mediante Nginx. Esta variante construye solo la web; el Dockerfile de producción conserva la compilación del APK y HTTPS.

- API: [health](http://localhost:8080/api/v1/health).
- Documentación interactiva: [Swagger](http://localhost:8080/swagger-ui.html).
- Detener conservando la base de datos: `docker compose down`.

**Las migraciones son automáticas.** Al arrancar el backend, Flyway crea las tablas que falten o actualiza una base existente antes de que JPA valide el esquema. Basta con `docker compose up --build -d`, tanto en otra PC como al actualizar esta instalación. No necesitas ejecutar manualmente los scripts 05, 06 o 07 ni borrar volúmenes. Flyway registra las versiones en `flyway_schema_history` y no repite migraciones ya aplicadas.

En volúmenes locales nuevos, PostgreSQL conserva la carga inicial 01–04 con los datos demo; las ampliaciones y futuras actualizaciones las administra Flyway desde el backend. El bootstrap crea el usuario únicamente si el email no existe: cambiar su contraseña en `.env` no modifica una cuenta ya creada.

Si una migración falla, el backend no inicia: consulta `docker compose logs backend`, corrige la causa y vuelve a levantarlo. No borres el volumen ni uses `flyway clean` como solución. Los comandos manuales de migraciones de guías anteriores quedan sustituidos por este flujo.

## Opción 2: backend y Flutter con recarga durante desarrollo

Requiere Java 17 o superior compatible con el proyecto, Flutter con soporte web, Chrome y PostgreSQL 16. El Maven Wrapper descarga Maven y sus dependencias. Usa dos terminales para backend y frontend.

1. Inicializa la base. Puedes usar solo el servicio de PostgreSQL del Compose:

   ```powershell
   cd E:\PathSeek
   docker compose up -d postgres
   ```

   Si instalaste PostgreSQL directamente, crea únicamente el usuario y la base `pathseek`, con permisos para crear tablas. Al arrancar Java, Flyway inicializa o actualiza automáticamente el esquema. La carga de datos demo es opcional; el usuario local puede crearse con el bootstrap del paso siguiente.

2. Prepara y arranca el backend:

   ```powershell
   cd E:\PathSeek\backend
   Copy-Item .env.example .env   # solo si todavía no existe
   ```

   Edita `backend/.env`: establece `JWT_SECRET`, los datos de PostgreSQL y las cinco variables `APP_BOOTSTRAP_USER_*` del ejemplo anterior. La contraseña de DB debe coincidir con la configurada en el `.env` de la raíz si usas el contenedor. Conserva `CORS_ALLOWED_ORIGINS=http://localhost:5173,http://localhost:8080`.

   ```powershell
   .\run-local.cmd
   ```

   El lanzador carga `backend/.env`; Spring Boot no lo lee automáticamente. Comprueba [health](http://localhost:8080/api/v1/health) antes de abrir el front.

3. En otra terminal, arranca Flutter:

   ```powershell
   cd E:\PathSeek\frontend
   flutter pub get
   flutter run -d chrome --web-port=5173 --dart-define=APP_ENV=dev --dart-define=API_BASE_URL=http://localhost:8080
   ```

   Abre [el frontend de desarrollo](http://localhost:5173). El puerto fijo coincide con el CORS permitido por el backend.

Para Android Emulator, usa `--dart-define=API_BASE_URL=http://10.0.2.2:8080`; para un teléfono físico, usa la IP LAN del equipo y permite el puerto 8080 en su firewall. `localhost` en el teléfono apunta al propio teléfono.

Si ya levantaste todo con Docker, detén `backend` y `frontend` antes de arrancarlos manualmente para liberar los puertos: `docker compose stop backend frontend`.

## Verificación

```powershell
cd E:\PathSeek\backend
.\mvnw.cmd test
cd E:\PathSeek\frontend
flutter analyze
flutter test
flutter build web --dart-define=APP_ENV=dev --dart-define=API_BASE_URL=http://localhost:8080
```

Tras iniciar sesión, comprueba dashboard, listas de vehículos/conductores/pedidos y generación y detalle de rutas. Sin vehículos o conductores, la generación informa los IDs de pedidos no asignados.

## Login del administrador demo

El seed de desarrollo incluye `admin@pathseek.pe` con contraseña `Admin123!`.
Una versión anterior de `04_seed_data.sql` contenía un hash que no correspondía a esa contraseña.
Si tu volumen se creó con esa versión, actualizar el archivo o reconstruir las imágenes no corrige los usuarios existentes.
Desde la raíz puedes aplicar esta reparación puntual:

```powershell
Get-Content -Raw database/fix_local_admin_login.sql | docker compose exec -T postgres sh -c 'psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB"'
```

Solo actualiza al administrador demo si conserva exactamente el hash defectuoso original; no cambia otras cuentas ni contraseñas personalizadas. No es necesario eliminar el volumen ni reiniciar el backend.
Si tienes PostgreSQL instalado en Windows y también en Docker, comprueba los usuarios en el contenedor con `docker compose exec postgres psql -U pathseek -d pathseek`; una conexión a `localhost:5432` puede consultar otra instancia según la configuración de red.
