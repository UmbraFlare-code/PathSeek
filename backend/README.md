# PathSeek Backend

API REST de PathSeek. Incluye autenticación stateless, autorización por roles, el catálogo operativo (Vehículos, Conductores, Pedidos y Clientes), rutas con optimización y reoptimización, ejecución del conductor, reportes PDF y compensación de carbono.

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

Spring Boot **no** carga archivos `.env` por sí solo: la variable debe existir en el entorno de la proceso. Sin esto, cada terminal nueva arranca sin `JWT_SECRET` y la aplicación muere con `JWT_SECRET debe contener al menos 32 bytes`. No subas credenciales reales; `.env` está ignorado por Git.

### Opción recomendada: `run-local.ps1`

Carga `backend/.env` en el entorno y arranca la API. Es la vía que evita el error anterior:

```powershell
cd backend
Copy-Item .env.example .env   # solo la primera vez
# edita .env y pon un JWT_SECRET de 32+ caracteres
.\run-local.ps1
```

Si PowerShell bloquea el script (ExecutionPolicy), usa el lanzador `.cmd`
—hace lo mismo sin cambiar la configuración del sistema—:

```cmd
cd backend
.\run-local.cmd
```

Generar un secreto aleatorio:

```powershell
$b = New-Object byte[] 48
[System.Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($b)
([System.BitConverter]::ToString($b) -replace '-','').ToLower()
```

### Opción manual: variables en la terminal

```powershell
$env:DB_HOST="localhost"
$env:DB_PORT="5432"
$env:DB_NAME="pathseek"
$env:DB_USER="pathseek"
$env:DB_PASSWORD="tu_clave_local"
$env:JWT_SECRET="reemplaza-esto-por-un-secreto-aleatorio-de-al-menos-32-caracteres"
```

Flyway migra PostgreSQL automáticamente antes de la validación de Hibernate, tanto en bases nuevas como existentes. No hace falta aplicar SQL manualmente. Las migraciones versionadas viven en `src/main/resources/db/migration/`; consulta la [guía local](../LOCAL.md).

## Ejecución

Desde el directorio `backend`:

```powershell
.\run-local.ps1
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

Las pruebas H2 en memoria mantienen Flyway desactivado y Hibernate crea su esquema. Las pruebas PostgreSQL validan además migraciones reales desde una base vacía o histórica. En la aplicación, Flyway está activado por defecto y se ejecuta antes de validar JPA.

## Reoptimización incremental

Para la visualización por calles, consulta la [integración OSRM y configuración Docker](../docs/03%20Implementaci%C3%B3n/Sprint%203/10%20Trazado%20vial%20OSRM%20V_1_0_0.md). La geometría vial conserva la secuencia operativa y expone métricas separadas de las estimaciones del optimizador.

`POST /api/v1/rutas/reoptimizar` permite a ADMIN/OPERADOR procesar nuevos pedidos, cancelaciones, incidentes y averías sin regenerar todas las rutas. Incluye idempotencia por `evento_id`, presupuesto de cálculo, preservación de entregas realizadas y bandeja persistente de avisos.

La migración de reoptimización se aplica automáticamente al iniciar el backend. Consulta el [contrato, ejemplos, límites, instrucciones Docker y validación de EN-002](../docs/03%20Implementaci%C3%B3n/Sprint%203/09%20Reoptimizacion%20incremental%20EN002%20V_1_0_0.md). La distancia continúa siendo estimada, sin red vial; el SLA operativo requiere medición en staging.

## Configuración y usuarios

La nueva sección `/settings` permite a ADMIN crear y editar cuentas, asignar roles y activar/desactivar acceso. OPERADOR/AUDITOR pueden consultar únicamente el catálogo de roles. El backend aplica automáticamente las migraciones de usuarios y DNI al iniciar. Consulta el [contrato, permisos y pasos Docker](../docs/03%20Implementaci%C3%B3n/Sprint%203/11%20Configuracion%20usuarios%20y%20roles%20V_1_0_0.md).

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

Valores permitidos: prioridad `EXPRESS`, `ESTANDAR`, `ECONOMICO`; tipo de producto `PERECEDERO`, `NO_PERECEDERO`; estado `PENDIENTE` (por defecto), `EN_RUTA`, `ENTREGADO`, `CANCELADO`. La ventana de tiempo usa formato `HH:mm` y la hora de fin debe ser posterior a la de inicio. No se admite un pedido activo duplicado (mismo cliente, dirección y ventana): responde `409 ORDER_DUPLICATE` (RN-012). Para el rol CLIENTE, `cliente_id` es el UUID de su cuenta y corresponde al `usuario_id` del perfil en el módulo de Clientes; ADMIN/OPERADOR conservan identificadores libres históricos.

## Clientes (US-004)

| Método | Endpoint | ADMIN | OPERADOR | AUDITOR | CLIENTE |
| --- | --- | --- | --- | --- | --- |
| `GET` | `/api/v1/clientes` | Sí | Sí | Sí | Solo su perfil |
| `GET` | `/api/v1/clientes/{id}` | Sí | Sí | Sí | Solo su perfil |
| `POST` | `/api/v1/clientes` | Sí | Sí | No | Crea su perfil |
| `PUT` | `/api/v1/clientes/{id}` | Sí | Sí | No | Solo su perfil |
| `DELETE` | `/api/v1/clientes/{id}` | Sí | Sí | No | No |

El perfil se vincula a una cuenta activa con rol `CLIENTE` (`usuario_id`). La cuenta no puede cambiarse después (`409 CLIENT_USER_LOCKED`), no puede duplicarse el perfil de una cuenta (`409 CLIENT_ALREADY_LINKED`) y el horario de atención requiere inicio y fin válidos (`HH:mm`, fin posterior al inicio). La migración `V9` añade las columnas de preferencias sin alterar datos existentes.

## Ejecución de rutas del conductor (EN-008)

| Método | Endpoint | Permiso |
| --- | --- | --- |
| `POST` | `/api/v1/rutas/{id}/posicion` | CONDUCTOR dueño de la ruta |
| `POST` | `/api/v1/rutas/{id}/entregas/{pedidoId}/completar` | CONDUCTOR dueño de la ruta |

Ambos endpoints son idempotentes para la cola de sincronización offline del frontend. Completar una entrega exige que las anteriores estén `ENTREGADO` (`409 ORDER_PREFIX_INCOMPLETE`); al completar todas, la ruta pasa a `COMPLETADA`. La posición actualiza el progreso estimado (último orden entregado, distancia, combustible y CO₂ del prefijo). El detalle de ruta incluye `pedido_estado` por parada.

## Reportes de sostenibilidad (US-009)

`GET /api/v1/reportes/sostenibilidad?desde=YYYY-MM-DD&hasta=YYYY-MM-DD` (ADMIN/OPERADOR/AUDITOR) devuelve un PDF con el resumen del período (rutas, distancia, CO₂, combustible y cumplimiento de ventanas) y el detalle por ruta. El rango de fechas es opcional; `desde` posterior a `hasta` responde `422 INVALID_REPORT_RANGE`. Las métricas son estimaciones del optimizador, no recorrido vial real.

## Compensación de carbono (US-010)

`GET /api/v1/compensacion/plan` (ADMIN/OPERADOR/AUDITOR) calcula las emisiones anuales de las rutas `COMPLETADA` de los últimos 12 meses, los árboles equivalentes (1 árbol ≈ 0.02 t CO₂/año) y sugiere los proyectos activos de `proyectos_compensacion` (migración `V8` + catálogo sembrado de forma idempotente).
