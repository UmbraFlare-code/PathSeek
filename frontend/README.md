# PathSeek - Frontend (Flutter)

SPA Flutter de **PathSeek**: Optimizador de Rutas Sostenibles para UGEL Huancayo.
Cliente de la API REST de Spring Boot (arquitectura Cliente-Servidor, ver DOC-012).

## Stack

- **Flutter / Dart** (multi-plataforma: web + movil)
- **flutter_bloc** (estado), **go_router** (navegacion + guards RBAC)
- **dio** (HTTP + interceptores JWT/refresh), **get_it** (DI)
- **shared_preferences** (persistencia de sesion web + movil)

## Estructura (feature-first con capas)

```
lib/
├── main.dart                 # Bootstrap: DI, router, theme
├── core/                     # Transversal (sin logica de negocio)
│   ├── config/               # Entornos dev/staging/prod
│   ├── constants/            # Roles RBAC, rutas de API
│   ├── errors/               # Failures, exceptions, mapper Dio→Failure
│   ├── network/              # ApiClient (dio), TokenStorage, SessionStore
│   ├── router/               # AppRouter (go_router + redirect RBAC), HomeShell
│   ├── theme/                # Tema con contraste WCAG 2.1 AA
│   ├── utils/                # Validators, Formatters
│   └── widgets/              # Loading, Error, Empty, SnackBar
├── features/
│   ├── auth/                 # Login, sesion JWT (EN-003)
│   ├── fleet/                # US-001 Gestion de Flota
│   ├── drivers/              # US-003 Gestion de Conductores
│   └── orders/               # US-002 Gestion de Pedidos
└── l10n/                     # Strings en espanol (app_es.arb)
```

### Capas por feature

`presentation (bloc/pages/widgets) → domain (entities/repositories) ← data (datasources/models/repositories)`

- **presentation**: widgets + estado (BLoC) + eventos/estados
- **domain**: entidades puras (Dart, sin Flutter/HTTP) e interfaces de repositorio
- **data**: DTOs, datasources remotos e implementaciones de repositorio

## Ejecutar

```bash
flutter pub get

# Web (operador/dashboard)
flutter run -d chrome

# Android (modo conductor - EP-03)
flutter run -d <device-id>
```

### Backend en paralelo

La URL base por entorno esta en `lib/core/config/environment.dart`:

| Entorno | URL |
| --- | --- |
| dev | `http://localhost:8080` |
| staging | `https://staging-api.pathseek.pe` |
| prod | `https://api.pathseek.pe` |

> Web en Chrome: usa un puerto fijo para que el CORS del backend lo acepte,
> por ejemplo `flutter run -d chrome --web-port=5173` (origen permitido por defecto).

Contrato esperado de la API (prefix `/api/v1`):

| Metodo | Ruta | Sprint |
| --- | --- | --- |
| POST | `/api/v1/auth/login` | EN-003 |
| POST | `/api/v1/auth/refresh` | EN-003 |
| CRUD | `/api/v1/vehiculos` | US-001 |
| CRUD | `/api/v1/conductores` | US-003 |
| CRUD | `/api/v1/pedidos` | US-002 |

Login devuelve `{ token, refreshToken, usuario: { usuario_id, nombre, email, rol } }`.

## Calidad (DoD global)

```bash
flutter analyze          # 0 issues
flutter test             # 95 tests
flutter test --coverage  # >= 80% cobertura (requisito DoD)
flutter build web        # compilacion release
```

## Convenciones

- Codigo en ingles, UI en espanol (l10n)
- BLoC para CRUD con estados; Cubit para casos simples
- Modelos: entidades de dominio separadas de DTOs (mapeo tolerante al contrato API)
- Nombres de rutas de API centralizados en `core/constants/api_paths.dart`
