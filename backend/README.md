# PathSeek Backend

API REST de PathSeek. Esta base implementa el módulo de Vehículos y sirve como referencia sencilla para los siguientes módulos del proyecto.

## Tecnologías

- Java 17
- Spring Boot 4.1
- Maven Wrapper
- Spring Web MVC y Bean Validation
- Spring Data JPA
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

Usa `.env.example` como referencia. Spring Boot no carga archivos `.env` por sí solo: exporta las variables en tu terminal o configúralas en el IDE. No subas credenciales reales; `.env` está ignorado por Git.

Ejemplo en PowerShell:

```powershell
$env:DB_HOST="localhost"
$env:DB_PORT="5432"
$env:DB_NAME="pathseek"
$env:DB_USER="pathseek"
$env:DB_PASSWORD="tu_clave_local"
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
- La API usa `/api/v1`, JSON en `snake_case` según el contrato Flutter y respuestas de error con un campo `message` estable.

## Vehículos

| Método | Endpoint | Descripción |
| --- | --- | --- |
| `GET` | `/api/v1/vehiculos` | Lista vehículos |
| `GET` | `/api/v1/vehiculos/{id}` | Obtiene un vehículo |
| `POST` | `/api/v1/vehiculos` | Crea un vehículo |
| `PUT` | `/api/v1/vehiculos/{id}` | Actualiza un vehículo |
| `DELETE` | `/api/v1/vehiculos/{id}` | Elimina un vehículo |

Los tipos permitidos son `CAMIONETA`, `FURGON` y `MOTO`. Las placas se guardan en mayúsculas y deben ser únicas.
