# Guía para IA V_1_0_0

**Proyecto:** PathSeek · **Fecha:** 2026-09-29 · **Responsable:** Equipo PIPRE

Guía operativa para que una IA (o un desarrollador nuevo) trabaje en este
repositorio sin romper el contrato entre frontend, backend y documentación.
Leer antes de implementar, corregir o refactorizar.

## 1. El proyecto en 30 segundos

Plataforma web de optimización de rutas de última milla para UGEL Huancayo.
Monorepo con backend y frontend **independientes**: solo se comunican por
HTTP/JSON. Arquitectura Cliente-Servidor (ver ADR-06 y ADR-07 en DOC-012).

| Capa | Tecnología | Ubicación |
| --- | --- | --- |
| Backend (API REST) | Java 17 + Spring Boot 4.1 + PostgreSQL + Flyway | `backend/` |
| Frontend (web + móvil) | Flutter/Dart (BLoC, go_router, dio, get_it) | `frontend/` |
| Documentación | Markdown + Mermaid en `docs/` | `docs/01 Inicio/`, `docs/02 Planificación/`, `docs/03 Documentación/` |

Estado MVP: autenticación JWT, Vehículos, Conductores y Pedidos (CRUD).
Pendiente: Clientes, Rutas/Optimizador, Mapa, Dashboard, Reportes.

## 2. Mapa del repositorio

```text
backend/src/main/java/com/pathseek/backend/
├── auth/        login, refresh rotativo, logout
├── user/        entidad User, roles, bootstrap local
├── vehicle/     CRUD /api/v1/vehiculos      (módulo de referencia)
├── driver/      CRUD /api/v1/conductores
├── order/       CRUD /api/v1/pedidos
├── health/      GET /api/v1/health (público)
├── security/    JWT, RBAC, CORS (SecurityConfig)
├── config/      OpenAPI/Swagger
└── exception/   GlobalExceptionHandler → {code, message, errors}

frontend/lib/
├── core/        config, constants, errors, network, router, di, theme, utils, widgets
└── features/    auth, fleet, drivers, orders (cada uno: data/domain/presentation)
```

## 3. Contrato sagrado frontend ↔ backend

### 3.1 Endpoints implementados

| Método | Ruta | Roles lectura | Roles escritura |
| --- | --- | --- | --- |
| `POST` | `/api/v1/auth/login`, `/auth/refresh`, `/auth/logout` | público | público |
| `GET` | `/api/v1/health` | público | — |
| CRUD | `/api/v1/vehiculos` | ADMIN, OPERADOR, AUDITOR | ADMIN, OPERADOR |
| CRUD | `/api/v1/conductores` | ADMIN, OPERADOR, AUDITOR | ADMIN, OPERADOR |
| CRUD | `/api/v1/pedidos` | ADMIN, OPERADOR, AUDITOR, CLIENTE | ADMIN, OPERADOR (+CLIENTE solo `POST`) |

Rutas centralizadas en `frontend/lib/core/constants/api_paths.dart`.
Nunca hardcodear URLs en features.

### 3.2 Formato JSON

- Campos en `snake_case`, salvo `refreshToken` (camelCase, histórico).
- IDs como `vehiculo_id`, `conductor_id`, `pedido_id`, `usuario_id` (UUID string).
- Enums en MAYÚSCULAS (`CAMIONETA`, `AII`, `EXPRESS`, `PENDIENTE`...).
- Tiempos de ventana como `HH:mm` (string, ej. `"08:00"`).
- Listas: el backend devuelve array plano; el frontend acepta array o `{data: [...]}`.

### 3.3 Errores (siempre con esta forma, sin stack traces)

```json
{ "code": "VALIDATION_ERROR", "message": "Los datos enviados no son válidos", "errors": [...] }
```

| Situación | HTTP | `code` |
| --- | --- | --- |
| Validación Bean Validation | 400 | `VALIDATION_ERROR` |
| JSON/enum/UUID malformado | 400 | `INVALID_REQUEST` |
| Sin token o inválido | 401 | `UNAUTHORIZED` |
| Sin rol suficiente | 403 | `FORBIDDEN` |
| No encontrado | 404 | `RESOURCE_NOT_FOUND` |
| Regla de negocio (año, ventana, usuario_id) | 422 | `INVALID_*` |
| Conflicto de unicidad/duplicado | 409 | `*_CONFLICT`, `ORDER_DUPLICATE` |

Códigos existentes: `VEHICLE_PLATE_CONFLICT`, `DRIVER_DNI_CONFLICT`,
`DRIVER_LICENSE_CONFLICT`, `ORDER_DUPLICATE`, `INVALID_VEHICLE_YEAR`,
`INVALID_ORDER_WINDOW`, `INVALID_DRIVER_USER`, más los de auth
(`INVALID_CREDENTIALS`, `ACCOUNT_LOCKED`, `ACCOUNT_INACTIVE`,
`INVALID_REFRESH_TOKEN`, `SESSION_INACTIVE`).

## 4. Cómo agregar un módulo backend (checklist)

Seguir el patrón de `vehicle/` (módulo de referencia):

1. `entity/` — `@Table`, UUID `@GeneratedValue(UUID)`, `created_at/updated_at`
   con `@PrePersist/@PreUpdate`; enums con `@Enumerated(STRING)`;
   columnas `CHAR` requieren `@JdbcTypeCode(SqlTypes.CHAR)`.
2. `repository/` — extender `JpaRepository<Entity, UUID>` + métodos
   `existsBy...[AndIdNot]` para unicidades.
3. `dto/` — `Request` (record + Bean Validation + `@JsonProperty` snake_case)
   y `Response` (record, nunca exponer la entidad).
4. `service/` — `@Transactional`; `findAll` ordenado; pre-chequeo de
   unicidad → `BusinessConflictException`; reglas → `BusinessRuleException`;
   `saveAndFlush` envuelto para `DataIntegrityViolationException`.
5. `controller/` — `@RequestMapping("/api/v1/...")`, CRUD con `UUID`,
   `@Valid`, `201` en POST, `204` en DELETE, `@Tag`/`@Operation` Swagger.
6. Migración Flyway `VN__descripcion.sql` (nunca editar migraciones aplicadas).
   `ddl-auto: validate`: la entidad debe calzar exacto con el DDL.
7. `SecurityConfig` — matchers por método con roles de la matriz DOC-008 §3.1.
8. Tests en `CatalogIntegrationTests` (crear, validar, duplicar, 404, 401/403).
9. Actualizar `backend/README.md` (tabla del módulo + valores permitidos).

## 5. Cómo agregar un feature frontend (checklist)

Estructura `features/<nombre>/{data/{datasources,models,repositories},domain/{entities,repositories},presentation/{bloc,pages,widgets}}`:

1. `ApiPaths` — agregar la ruta una sola vez en `core/constants/`.
2. `Model.fromJson` tolerante (`??` con defaults, `_toDouble/_toInt/_toTime`);
   `toJson` en snake_case; entidad de dominio separada del DTO.
3. **Validadores del form deben espejar al backend** (ver §6):
   si el backend exige `> 0`, rango o formato, el form lo valida primero
   (`core/utils/validators.dart`); el 400/422 del servidor es red de
   seguridad, no validador principal.
4. `go_router` — registrar la ruta y sus roles en `_routeRoles`
   (`core/router/app_router.dart`); ocultar botones de crear/editar
   según rol si la ruta es visible para roles de solo lectura.
5. Registrar datasource/repository/bloc en `core/di/injection.dart`.
6. Tests de bloc + modelo en `test/`; `flutter analyze` en 0 issues.

## 6. Reglas de validación espejadas (no desincronizar)

| Campo | Backend | Frontend (`Validators`) |
| --- | --- | --- |
| Capacidades, consumo, peso, volumen | `> 0` | `positive` |
| Factor de emisión | `>= 0` | `decimal` |
| Año vehículo | 1900–año actual+1 | `year` |
| Latitud / longitud | −90..90 / −180..180 | `range` |
| Ventana `HH:mm`, fin > inicio | `@Pattern` + `INVALID_ORDER_WINDOW` | picker `HH:mm` + `timeWindow` en `_submit` |
| DNI `^\d{8}$`, licencia `^[A-Z][0-9]{7,9}$` | `@Pattern` + unicidad | `dni`, `license` |
| Placa (3 patrones PE, única, mayúsculas) | `@Size` + unicidad | `plate` |
| Experiencia `>= 0` | `@Min(0)` | `integer` |

## 7. Reglas de negocio implementadas (RN → código)

| RN | Regla | Dónde |
| --- | --- | --- |
| RN-001 | 3 intentos → bloqueo 15 min | `AuthService` |
| RN-006 | Ventana fin > inicio | `OrderService.validateWindow` |
| RN-007 | Prioridad como enum ordenable | `OrderPriority` |
| RN-012 | Pedido activo no duplicable (cliente+dirección+ventana) | `OrderService.assertNoDuplicate` |

RN-002–005, RN-008–011 pertenecen a módulos no construidos (roadmap).

## 8. Documentación: qué actualizar cuando cambias algo

| Cambio | Docs a actualizar |
| --- | --- |
| Nuevo endpoint / campo / enum / código de error | `backend/README.md` + DOC-011 (si toca BD) + esta guía §3 |
| Nueva regla de negocio | DOC-009 + §7 de esta guía |
| Cambio de roles en un endpoint | `SecurityConfig` + DOC-008 §3.1 + `backend/README.md` + `_routeRoles` si afecta vistas |
| Nueva tabla / columna | Migración Flyway + DOC-011 §3.1 + DOC-012 §4.1 si es entidad de dominio |
| Cambio de stack o arquitectura | DOC-010 + DOC-012 (nuevo ADR, revocar el anterior) + `README.md` + DOC-002/003/004 si mencionan el stack |

Convenciones: archivos `NN. Nombre V_X_Y_Z.md`; **no renombrar archivos
versionados** (los enlaces del `README.md` dependen del nombre);
al corregir, subir versión en cabecera + fila en *Control de versiones*.
Versiones congeladas (ej. `12. Modelo C4 V_1_0_0.md`) no se editan salvo
nota de superación. Decisiones de arquitectura van como ADR en DOC-012 §7.

## 9. Entorno y comandos

| Qué | Dónde / cómo |
| --- | --- |
| BD local | PostgreSQL 16/17, puerto `5432`, BD `pathseek`, usuario `pathseek` |
| Backend dev | `backend/` → `.\mvnw.cmd spring-boot:run` → `http://localhost:8080/api/v1` |
| Frontend web | `frontend/` → `flutter run -d chrome --web-port=5173` (puerto fijo por CORS) |
| Móvil USB | `adb reverse tcp:8080 tcp:8080` + `flutter run -d <id>` (sin `<>`) |
| Variables | `JWT_SECRET` (≥32 bytes, obligatoria), `DB_*`, `CORS_ALLOWED_ORIGINS`, `APP_BOOTSTRAP_USER_*` (ver guía de ejecución) |
| Tests backend | `.\mvnw.cmd test` (H2 en memoria; 49 tests) |
| Tests frontend | `flutter analyze` (0 issues) + `flutter test` (102 tests) |
| Swagger | `http://localhost:8080/swagger-ui.html` (login → Authorize → probar) |

Detalle paso a paso en `01 Guía de ejecución local V_1_0_0.md`.

## 10. Prohibiciones

1. No commitear secretos (`.env`), logs (`boot.log`) ni credenciales reales.
2. No cambiar el contrato JSON sin actualizar backend + frontend + docs (§8).
3. No exponer entidades JPA por HTTP; no devolver stack traces.
4. No editar migraciones Flyway ya aplicadas; solo agregar `VN__*.sql`.
5. Todo cambio de código con tests (backend) o pruebas de widget/modelo
   que apliquen (frontend); verificar suites antes de pedir merge.
6. Commits estilo `feat(backend): ...` / `docs: ...`; PR hacia `main`
   (no push directo) en proyecto de equipo.

## 11. Roadmap (no implementado, no inventar)

Clientes (RF-009), Rutas/Optimizador (RF-003, RNF-001 ≤45 s), Mapa (RF-004),
Dashboard (RF-005), Reportes PDF (RF-006), Re-optimización (RF-007),
Compensación de carbono (RF-010), Redis/caché, modo conductor y logs de
auditoría. En docs figuran como *objetivo*; en código no existen.

## Control de versiones

| Versión | Fecha | Descripción | Responsable |
| --- | --- | --- | --- |
| V_1_0_0 | 2026-09-29 | Creación: contrato, patrones, RBAC, validaciones espejadas, comandos y prohibiciones | Equipo del proyecto |
