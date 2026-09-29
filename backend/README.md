# PathSeek Backend

API REST de PathSeek. Incluye autenticación stateless, autorización por roles y el catálogo operativo: Vehículos, Conductores y Pedidos.

## Tecnologías

- Java 17
- Spring Boot 4.1
- Maven Wrapper
- Spring Web MVC y Bean Validation
- Spring Data JPA
- Spring Security y OAuth2 Resource Server
- JWT firmado con HMAC SHA-256
- PostgreSQL
- Flyway
- SpringDoc OpenAPI / Swagger UI

## Requisitos

- Java 17
- PostgreSQL disponible localmente
- No es necesario instalar Maven; el repositorio incluye Maven Wrapper

## Configuración

La aplicación lee estas variables de entorno:

| Variable | Valor local por defecto |
| --- | --- |
| `DB_HOST` | `localhost` |
| `DB_PORT` | `5432` |
| `DB_NAME` | `pathseek` |
| `DB_USER` | `pathseek` |
| `DB_PASSWORD` | `pathseek_local` |
| `JWT_SECRET` | Sin valor; obligatorio |
| `JWT_ACCESS_EXPIRATION_MINUTES` | `15` |
| `JWT_REFRESH_EXPIRATION_DAYS` | `7` |
| `SESSION_INACTIVITY_MINUTES` | `30` |
| `CORS_ALLOWED_ORIGINS` | `http://localhost:5173,http://localhost:8080` |
| `APP_BOOTSTRAP_USER_ENABLED` | `false` |
| `APP_BOOTSTRAP_USER_NAME` | Vacío |
| `APP_BOOTSTRAP_USER_EMAIL` | Vacío |
| `APP_BOOTSTRAP_USER_PASSWORD` | Vacío |
| `APP_BOOTSTRAP_USER_ROLE` | `ADMIN` |

Usa `.env.example` como referencia. Spring Boot no carga archivos `.env` por sí solo: exporta las variables en tu terminal o configúralas en el IDE. No subas credenciales reales; `.env` está ignorado por Git.

Ejemplo en PowerShell:

```powershell
$env:DB_HOST="localhost"
$env:DB_PORT="5432"
$env:DB_NAME="pathseek"
$env:DB_USER="pathseek"
$env:DB_PASSWORD="tu_clave_local"
$env:JWT_SECRET="reemplaza-esto-por-un-secreto-aleatorio-de-al-menos-32-caracteres"
```

Flyway crea y versiona el esquema al iniciar la aplicación. Hibernate únicamente valida que las entidades coincidan con ese esquema.

## Ejecución

Desde el directorio `backend`:

```powershell
.\mvnw.cmd spring-boot:run
```

En Linux o macOS:

```bash
./mvnw spring-boot:run
```

La URL base es `http://localhost:8080/api/v1`.

- Health: `GET http://localhost:8080/api/v1/health`
- Swagger UI: `http://localhost:8080/swagger-ui.html`
- Especificación OpenAPI: `http://localhost:8080/v3/api-docs`

## Pruebas y build

```powershell
.\mvnw.cmd test
.\mvnw.cmd clean package
```

Las pruebas usan H2 en memoria con compatibilidad PostgreSQL y ejecutan las migraciones de Flyway. Esto mantiene la suite rápida y sin servicios externos. Antes de desplegar, se recomienda ejecutar una prueba de integración contra PostgreSQL real para detectar diferencias específicas del motor.

## Arquitectura

Cada módulo sigue el flujo:

```text
Controller -> Service -> Repository -> PostgreSQL
```

- Los controllers gestionan HTTP y validan DTOs.
- Los services contienen reglas de negocio y mapean entidades a DTOs.
- Los repositories gestionan persistencia mediante Spring Data JPA.
- Las entidades JPA no se exponen directamente por HTTP.
- La API usa `/api/v1`; conserva `snake_case` para los campos acordados con Flutter y `refreshToken` en camelCase.
- Los errores siempre incluyen `code`, `message` y `errors`, sin stack traces.

## Autenticación y sesiones

| Método | Endpoint | Uso |
| --- | --- | --- |
| `POST` | `/api/v1/auth/login` | Entrega access token, refresh token y usuario |
| `POST` | `/api/v1/auth/refresh` | Rota el refresh token y entrega un par nuevo |
| `POST` | `/api/v1/auth/logout` | Revoca el refresh token recibido |

El access token es un JWT firmado, dura 15 minutos por defecto y contiene `sub`, `rol`, `email`, `iat` y `exp`. La API valida firma y expiración en cada petición protegida. El refresh token es aleatorio, dura 7 días y en la base de datos solo se almacena su hash SHA-256. Cada refresh revoca el token usado y crea uno nuevo; un token expirado, revocado o reutilizado devuelve `401`.

La sesión requiere actividad de refresh dentro de 30 minutos. Si se supera ese tiempo desde `last_used_at`, el token se revoca y se exige un login nuevo. Como el access token dura 15 minutos, normalmente el cliente deberá refrescar antes de alcanzar ese límite.

Después de tres contraseñas incorrectas consecutivas, la cuenta queda bloqueada durante 15 minutos. Un login exitoso reinicia el contador, elimina el bloqueo y actualiza el último acceso. Los usuarios inactivos no reciben tokens.

Los roles válidos son `ADMIN`, `OPERADOR`, `CONDUCTOR`, `CLIENTE` y `AUDITOR`. El rol usado para autorizar procede exclusivamente del JWT validado por el servidor.

### Usuario local de desarrollo

El bootstrap está desactivado por defecto. Para crear una cuenta local reproducible, configura `APP_BOOTSTRAP_USER_ENABLED=true` y completa nombre, email y contraseña antes de iniciar la aplicación. La contraseña se guarda con BCrypt, solo se crea el usuario si el email aún no existe y nunca se sobrescriben cuentas ni se imprime la contraseña.

### Probar con Swagger

1. Inicia la API y abre `http://localhost:8080/swagger-ui.html`.
2. Ejecuta `POST /api/v1/auth/login` con el usuario local.
3. Copia el campo `token` de la respuesta.
4. Pulsa **Authorize**, pega el JWT y prueba los endpoints protegidos.

Health, login, refresh, logout y Swagger son públicos. El resto de la API requiere Bearer JWT.

## Vehículos

| Método | Endpoint | Descripción |
| --- | --- | --- |
| Método | Endpoint | ADMIN | OPERADOR | AUDITOR | CONDUCTOR / CLIENTE |
| --- | --- | --- | --- | --- | --- |
| `GET` | `/api/v1/vehiculos` | Sí | Sí | Sí | No |
| `GET` | `/api/v1/vehiculos/{id}` | Sí | Sí | Sí | No |
| `POST` | `/api/v1/vehiculos` | Sí | Sí | No | No |
| `PUT` | `/api/v1/vehiculos/{id}` | Sí | Sí | No | No |
| `DELETE` | `/api/v1/vehiculos/{id}` | Sí | Sí | No | No |

Los tipos permitidos son `CAMIONETA`, `FURGON` y `MOTO`. Las placas se guardan en mayúsculas y deben ser únicas.

## Conductores

| Método | Endpoint | ADMIN | OPERADOR | AUDITOR | CONDUCTOR / CLIENTE |
| --- | --- | --- | --- | --- | --- |
| `GET` | `/api/v1/conductores` | Sí | Sí | Sí | No |
| `GET` | `/api/v1/conductores/{id}` | Sí | Sí | Sí | No |
| `POST` | `/api/v1/conductores` | Sí | Sí | No | No |
| `PUT` | `/api/v1/conductores/{id}` | Sí | Sí | No | No |
| `DELETE` | `/api/v1/conductores/{id}` | Sí | Sí | No | No |

Las categorías permitidas son `AII`, `AIII`, `BII` y `BIII`. El DNI (8 dígitos) y la licencia (formato `Q12345678`, se guarda en mayúsculas sin guiones) deben ser únicos. `usuario_id` es opcional: se omite o se envía vacío cuando el conductor aún no tiene cuenta; si se envía, debe ser un UUID válido. `disponible` por defecto es `true`.

## Pedidos

| Método | Endpoint | ADMIN | OPERADOR | AUDITOR | CLIENTE | CONDUCTOR |
| --- | --- | --- | --- | --- | --- | --- |
| `GET` | `/api/v1/pedidos` | Sí | Sí | Sí | Sí | No |
| `GET` | `/api/v1/pedidos/{id}` | Sí | Sí | Sí | Sí | No |
| `POST` | `/api/v1/pedidos` | Sí | Sí | No | Sí | No |
| `PUT` | `/api/v1/pedidos/{id}` | Sí | Sí | No | No | No |
| `DELETE` | `/api/v1/pedidos/{id}` | Sí | Sí | No | No | No |

Valores permitidos: prioridad `EXPRESS`, `ESTANDAR`, `ECONOMICO`; tipo de producto `PERECEDERO`, `NO_PERECEDERO`; estado `PENDIENTE` (por defecto), `EN_RUTA`, `ENTREGADO`, `CANCELADO`. La ventana de tiempo usa formato `HH:mm` y la hora de fin debe ser posterior a la de inicio. No se admite un pedido activo duplicado (mismo cliente, dirección y ventana): responde `409 ORDER_DUPLICATE` (RN-012). `cliente_id` se guarda como texto libre hasta contar con el módulo de Clientes.
