# Guía de ejecución local V_1_0_0

**Proyecto:** PathSeek — Optimizador de Rutas Sostenibles para UGEL Huancayo
**Fecha:** 2026-09-29 · **Responsable:** Equipo PIPRE

Pasos para levantar el sistema completo en una máquina Windows de desarrollo:
PostgreSQL → backend (Spring Boot) → frontend (Flutter web y/o móvil).

## 1. Requisitos previos

| Herramienta | Versión | Verificación |
| --- | --- | --- |
| Java (JDK) | 17 | `java -version` |
| Flutter SDK | estable reciente | `flutter --version` |
| PostgreSQL | 16 o 17 | `psql --version` (ver §2.1) |
| Git | cualquiera | `git --version` |
| Android SDK | solo para correr en móvil | `flutter devices` |

> El backend usa Java 17 para compilar y correr (`mvnw test`, `spring-boot:run`).
> Para compilar la app Android, Flutter debe apuntar al JDK 17 (ver §6.1).

## 2. PostgreSQL: instalación y base de datos

### 2.1 Instalar

Descargar el instalador de <https://www.postgresql.org/download/windows/>
(versión 16 o 17), ejecutarlo y anotar la clave del superusuario `postgres`.

Si `psql` no se reconoce en PowerShell, usar la ruta completa
(ajustar el número de versión según lo instalado):

```powershell
& "C:\Program Files\PostgreSQL\17\bin\psql.exe" --version
```

Para evitar la ruta larga en cada uso, agregar la carpeta al PATH
de la terminal actual:

```powershell
$env:PATH += ";C:\Program Files\PostgreSQL\17\bin"
```

### 2.2 Crear usuario y base de datos

Conectarse como superusuario (`postgres`) y ejecutar:

```sql
CREATE USER pathseek WITH PASSWORD 'pathseek_local';
CREATE DATABASE pathseek OWNER pathseek;
```

El puerto por defecto es `5432`; la aplicación ya lo espera (`DB_PORT`),
por lo que no requiere configuración adicional. Solo si Postgres usara
otro puerto, definir `$env:DB_PORT` con ese valor.

Si la clave del usuario `pathseek` no coincide con la configurada
en la aplicación (error `password authentication failed`), alinearla:

```powershell
psql -U postgres -h localhost -c "ALTER USER pathseek WITH PASSWORD 'pathseek_local';"
```

## 3. Variables de entorno (cada terminal nueva)

PowerShell olvida las variables al cerrar la terminal: definirlas
antes de arrancar el backend (y repetir en cada terminal nueva).
Tip: guardarlas en un archivo `env-local.ps1` fuera del repositorio
(para no subir secretos a Git) y cargarlo con `. ruta\env-local.ps1`.

```powershell
$env:DB_HOST="localhost"
$env:DB_PORT="5432"
$env:DB_NAME="pathseek"
$env:DB_USER="pathseek"
$env:DB_PASSWORD="pathseek_local"
$env:JWT_SECRET=[Convert]::ToBase64String((1..48 | ForEach-Object { Get-Random -Maximum 256 }))
$env:CORS_ALLOWED_ORIGINS="http://localhost:5173,http://localhost:8080"
$env:APP_BOOTSTRAP_USER_ENABLED="true"
$env:APP_BOOTSTRAP_USER_NAME="Admin Local"
$env:APP_BOOTSTRAP_USER_EMAIL="admin@pathseek.pe"
$env:APP_BOOTSTRAP_USER_PASSWORD="Admin123!"
$env:APP_BOOTSTRAP_USER_ROLE="ADMIN"
```

| Variable | Obligatoria | Notas |
| --- | --- | --- |
| `JWT_SECRET` | Sí (mínimo 32 bytes) | Sin ella la API no arranca |
| `APP_BOOTSTRAP_USER_*` | Solo primer arranque | Crea el admin local para hacer login; Flyway crea las tablas solo |
| `CORS_ALLOWED_ORIGINS` | En web | Debe incluir el puerto fijo de Chrome (§5) |

## 4. Terminal 1 — Backend (Spring Boot)

```powershell
cd E:\PathSeek\backend
.\mvnw.cmd spring-boot:run
```

La primera vez descarga Maven y dependencias (tarda unos minutos).
Arranque correcto si el log muestra:

```text
Tomcat started on port 8080 (http)
Started BackendApplication in ... seconds
Usuario local de desarrollo creado
```

Verificación:

- Salud: `http://localhost:8080/api/v1/health` → `{"status":"UP",...}`
- Swagger UI: `http://localhost:8080/swagger-ui.html`
- OpenAPI: `http://localhost:8080/v3/api-docs`

> **No cerrar esta terminal**: aquí queda corriendo la API.

### 4.1 Probar la API con Swagger

1. `POST /api/v1/auth/login` con
   `{"email":"admin@pathseek.pe","password":"Admin123!"}` → copiar `token`.
2. Botón **Authorize** → pegar el JWT (`Bearer` lo agrega Swagger solo).
3. Probar los CRUD de `/api/v1/vehiculos`, `/api/v1/conductores`
   y `/api/v1/pedidos`.

## 5. Terminal 2 — Frontend web (Chrome)

Con el backend corriendo:

```powershell
cd E:\PathSeek\frontend
flutter pub get
flutter run -d chrome --web-port=5173
```

El `--web-port=5173` es obligatorio: fija el origen permitido
en el CORS del backend. Iniciar sesión con `admin@pathseek.pe` /
`Admin123!`; módulos disponibles: Flota, Conductores y Pedidos.

Calidad (DoD):

```powershell
flutter analyze          # 0 issues
flutter test             # 95 tests
```

## 6. Opcional — Frontend en móvil Android (terminal 3)

Requiere Android SDK. En Windows solo Android (iOS exige una Mac).

```powershell
cd E:\PathSeek\frontend
flutter devices                                  # ver ID del equipo
adb reverse tcp:8080 tcp:8080                    # localhost del móvil → PC
flutter run -d <id-del-dispositivo>              # ej. RFCTB10CP7V, sin <>
```

### 6.1 Incompatibilidad Java/Gradle

Si el build Android falla por Java 25 vs Gradle 8.14, fijar el JDK 17
de Flutter (configuración global de la máquina, no toca el proyecto):

```powershell
flutter config --jdk-dir="C:\Users\<usuario>\AppData\Local\Programs\Eclipse Adoptium\jdk-17.0.20.101-hotspot"
```

Las advertencias `Warning: Flutter support for ... will soon be dropped`
(Gradle/AGP/Kotlin) no bloquean el build: ignorarlas por ahora.

### 6.2 Error de caché incremental de Kotlin

Si aparecen errores `Could not close incremental caches` /
`different roots` (proyecto en `E:\` y caché de paquetes en `C:\`),
ya está mitigado en `android/gradle.properties` con
`kotlin.incremental=false`. Si reaparece, ejecutar:

```powershell
flutter clean
flutter pub get
```

### 6.3 APK instalable

```powershell
flutter build apk
```

Queda en `build\app\outputs\flutter-apk\app-release.apk`. Para usarlo
fuera de depuración USB, apuntar `environment.dart` a la IP LAN del PC
(en vez de `localhost`) y abrir el puerto en el firewall:

```powershell
New-NetFirewallRule -DisplayName "PathSeek API" -Direction Inbound -LocalPort 8080 -Protocol TCP -Action Allow
```

## 7. Datos de ejemplo para probar el registro

**Vehículo** → `POST /api/v1/vehiculos` (placa única, máx. 10 caracteres;
formatos válidos: `ABC123`, `AB1234`, `A1B234`, con o sin guion):

```json
{
  "placa": "ABC-123",
  "tipo": "CAMIONETA",
  "capacidad_kg": 1000,
  "capacidad_m3": 8.5,
  "consumo_km_l": 11.3,
  "factor_emision": 0.24,
  "anio": 2024,
  "restriccion_placa_digito": 3
}
```

**Conductor** → `POST /api/v1/conductores` (DNI de 8 dígitos y licencia
formato `Q12345678`, ambos únicos; categoría `AII/AIII/BII/BIII`):

```json
{
  "dni": "12345678",
  "nombre": "Juan Pérez",
  "licencia": "Q12345678",
  "categoria": "AII",
  "experiencia": 5,
  "disponible": true,
  "contacto": "999888777"
}
```

**Pedido** → `POST /api/v1/pedidos` (ventana `HH:mm` con fin posterior
a inicio; `estado` por defecto `PENDIENTE`):

```json
{
  "cliente_id": "CLI-001",
  "direccion": "Av. Ferrocarril 123, Huancayo",
  "gps_lat": -12.0651,
  "gps_lon": -75.2045,
  "peso": 25.5,
  "volumen": 1.2,
  "ventana_inicio": "08:00",
  "ventana_fin": "12:00",
  "prioridad": "ESTANDAR",
  "tipo_producto": "NO_PERECEDERO"
}
```

Cada registro exitoso devuelve `201` con su identificador
(`vehiculo_id`, `conductor_id`, `pedido_id`).

## 8. Dónde ver los registros

1. **App Flutter**: listas de Flota, Conductores y Pedidos.
2. **Swagger**: `GET /api/v1/vehiculos`, `/api/v1/conductores`,
   `/api/v1/pedidos` (con JWT autorizado).
3. **PostgreSQL** (tablas `vehiculos`, `conductores`, `pedidos`),
   vía pgAdmin o `psql -U pathseek -h localhost -d pathseek`:

```sql
SELECT placa, tipo, capacidad_kg FROM vehiculos;
SELECT dni, nombre, licencia, categoria FROM conductores;
SELECT cliente_id, direccion, ventana_inicio, ventana_fin, estado FROM pedidos;
```

## 9. Problemas típicos

| Síntoma | Causa | Solución |
| --- | --- | --- |
| `password authentication failed for user "pathseek"` | `DB_PASSWORD` no coincide con Postgres | §2.2 (`ALTER USER ...`) o corregir `$env:DB_PASSWORD` |
| `JWT_SECRET debe contener al menos 32 bytes` | Secreto ausente o corto | Regenerarlo como en §3 y reintentar |
| `psql` no se reconoce | Carpeta `bin` fuera del PATH | §2.1 (ruta completa o `$env:PATH += ...`) |
| Frontend web: error de conexión | Backend caído o Chrome en otro puerto | Verificar §4 y usar `--web-port=5173` |
| Login `401` con usuario bootstrap | La app arrancó antes sin bootstrap y el usuario nunca se creó | Usar otro email en `APP_BOOTSTRAP_USER_EMAIL` y reiniciar |
| Build Android falla por Java 25 | Gradle 8.14 no soporta Java 25 | §6.1 (`flutter config --jdk-dir=...` al JDK 17) |
| Placa rechazada | No calza el formato o ya existe | §7 (formatos) o probar otra placa |

## Control de versiones

| Versión | Fecha | Descripción | Responsable |
| --- | --- | --- | --- |
| V_1_0_0 | 2026-09-29 | Creación de la guía (PostgreSQL, backend, frontend web/móvil, datos de ejemplo) | Equipo del proyecto |
