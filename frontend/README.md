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
| staging | `https://169.58.74.99` |
| prod | `https://169.58.74.99` |

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

## App movil (APK) y certificado SSL de la VPS

La VPS sirve HTTPS con un certificado **auto-firmado**. El APK lo valida con un
**pin en Dart** (`SecurityContext` con el certificado embebido), porque Flutter
(`dart:io`) **no respeta** el `network_security_config.xml` de Android para TLS:
usa su propio motor (BoringSSL).

- `assets/certs/pathseek_cert.pem` — certificado publico de la VPS (asset Flutter).
- `lib/core/network/secure_http_client.dart` — crea el `HttpClient` que confia
  **solo** en ese certificado (pin estricto); se conecta al adaptador de dio en
  `lib/core/network/api_client.dart` y en `lib/core/di/injection.dart`. En web no
  aplica (el navegador usa su propia validacion).
- `android/app/src/main/AndroidManifest.xml` — declara `INTERNET` (necesario para
  que el APK release pueda consumir la API).
- `android/app/src/main/res/xml/network_security_config.xml` y
  `android/app/src/main/res/raw/pathseek_cert.pem` — config nativa equivalente;
  no tiene efecto en `dart:io`, pero se mantiene por si se usa red nativa de
  Android en el futuro.

**Si el certificado de la VPS se renueva**, se debe:

1. Reemplazar `assets/certs/pathseek_cert.pem` (y opcionalmente el de `res/raw/`)
   con el nuevo certificado:
   ```bash
   openssl s_client -connect 169.58.74.99:443 -showcerts </dev/null 2>/dev/null \
     | openssl x509 -outform PEM > frontend/assets/certs/pathseek_cert.pem
   ```
2. Verificar que el certificado incluya la IP en `Subject Alternative Name`:
   ```bash
   openssl x509 -in frontend/assets/certs/pathseek_cert.pem -noout -text \
     | grep -A1 "Subject Alternative Name"
   # Debe mostrar: IP Address:169.58.74.99
   ```
   Si el certificado actual no la tiene (solo `CN`), regenerarlo en la VPS con SAN:
   ```bash
   openssl req -x509 -newkey rsa:2048 -nodes -days 3650 \
     -keyout ssl/pathseek.key -out ssl/pathseek.crt \
     -subj "/CN=169.58.74.99" -addext "subjectAltName=IP:169.58.74.99"
   docker compose -f docker-compose.prod.yml restart frontend
   ```
3. Reconstruir el APK (`docker compose -f docker-compose.prod.yml build frontend`).

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
