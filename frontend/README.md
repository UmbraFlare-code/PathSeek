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
│   ├── utils/                # Validators, Formatters, Responsive (600dp)
│   └── widgets/              # Loading, Error, Empty, SnackBar, ResponsiveFieldRow, SearchSortControls
├── features/
│   ├── auth/                 # Login, sesion JWT (EN-003)
│   ├── fleet/                # US-001 Gestion de Flota
│   ├── drivers/              # US-003 Gestion de Conductores
│   ├── orders/               # US-002 Gestion de Pedidos
│   ├── routes/               # US-005 Generacion de Rutas Optimizadas
│   └── dashboard/            # US-008 Dashboard de Indicadores
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
| POST | `/api/v1/auth/logout` | EN-003 |
| CRUD | `/api/v1/vehiculos` | US-001 |
| CRUD | `/api/v1/conductores` | US-003 |
| CRUD | `/api/v1/pedidos` | US-002 |
| GET | `/api/v1/rutas?fecha=YYYY-MM-DD` | US-005 |
| GET | `/api/v1/rutas/{id}` | US-005 |
| POST | `/api/v1/rutas/generar` | US-005 |
| DELETE | `/api/v1/rutas/{id}` | US-005 |
| GET | `/api/v1/dashboard/resumen` | US-008 |

Login devuelve `{ token, refreshToken, usuario: { usuario_id, nombre, email, rol } }`.

### Contrato Sprint 2 (fuente de verdad para el backend)

**`POST /api/v1/rutas/generar`** (roles ADMIN/OPERADOR · SLA ≤ 45 s):

```json
{
  "rutas": [
    {
      "ruta_id": "uuid",
      "fecha": "YYYY-MM-DD",
      "conductor_id": "uuid",
      "conductor_nombre": "Carlos Gomez",
      "vehiculo_id": "uuid",
      "placa": "ABC123",
      "distancia_km": 45.2,
      "co2_kg": 11.3,
      "combustible_l": 8.5,
      "estado": "PLANIFICADA",
      "pedidos": [
        {
          "pedido_id": "uuid",
          "orden": 1,
          "hora_estimada": "HH:mm",
          "direccion": "Av. Real 123",
          "gps_lat": -12.0678,
          "gps_lon": -75.2132,
          "peso": 20,
          "ventana_inicio": "HH:mm",
          "ventana_fin": "HH:mm"
        }
      ]
    }
  ],
  "pedidos_no_asignados": ["uuid"]
}
```

- `GET /api/v1/rutas` devuelve la lista con los mismos campos (puede omitir `pedidos`).
- `GET /api/v1/rutas/{id}` devuelve la ruta completa con `pedidos`.
- `DELETE /api/v1/rutas/{id}` → 204.
- Estados de ruta: `PLANIFICADA`, `EN_PROGRESO`, `COMPLETADA`, `CANCELADA`.

**`GET /api/v1/dashboard/resumen`** (roles ADMIN/OPERADOR/AUDITOR/**CONDUCTOR**) —
retorno directo del `sp_obtener_resumen_dashboard`:

```json
{
  "total_vehiculos": 15,
  "conductores_disponibles": 8,
  "pedidos_pendientes": 22,
  "pedidos_en_ruta": 5,
  "pedidos_entregados": 40,
  "pedidos_cancelados": 2,
  "rutas_planificadas": 6,
  "co2_total_kg": 125.5,
  "combustible_total_l": 300.25
}
```

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

## Responsive y RBAC

- **Responsive** (breakpoint 600dp en `core/utils/responsive.dart`): en telefono la
  navegacion usa `NavigationBar` inferior y los formularios apilan sus campos
  (`core/widgets/responsive_field_row.dart`).
- **Listas en tarjetas** (flota, conductores y pedidos): grid responsive
  (1-4 columnas segun ancho) con **busqueda y ordenamiento** client-side
  (`SearchSortControls` + funciones puras `*_filters.dart` por feature); la misma
  tarjeta sirve para web y movil.
- **RBAC** (DOC-008): la matriz de permisos por rol y modulo vive en
  `core/constants/permissions.dart`. El router aplica guards por ruta **y accion**
  (`/new`, `/:id/edit`) y la UI oculta botones y modulos segun el rol:
  - ADMIN/OPERADOR: escritura total (flota, conductores, pedidos, rutas)
  - AUDITOR: solo lectura en todos los modulos
  - CLIENTE: crea y lee pedidos (sin editar/eliminar); su pantalla inicial es Pedidos
  - CONDUCTOR: dashboard basico (lectura) hasta el modo conductor (EP-03)

## Calidad (DoD global)

```bash
flutter analyze          # 0 issues
flutter test             # 136 tests
flutter test --coverage  # >= 80% cobertura (requisito DoD)
flutter build web        # compilacion release
```

## Convenciones

- Codigo en ingles, UI en espanol (l10n)
- BLoC para CRUD con estados; Cubit para casos simples
- Modelos: entidades de dominio separadas de DTOs (mapeo tolerante al contrato API)
- Nombres de rutas de API centralizados en `core/constants/api_paths.dart`
