# Exposición Frontend — Sprint 1 + Sprint 2

**Proyecto:** PathSeek — Optimizador de Rutas Sostenibles para UGEL Huancayo
**Alcance:** Sprint 1 (login, flota, pedidos, conductores) + Sprint 2 (rutas optimizadas, dashboard)
**Stack:** Flutter/Dart + flutter_bloc + go_router + dio + get_it + shared_preferences

---

## 1. Flujo de navegación del usuario

```
Abre la app (web o APK)
      │
      ▼
/login ──► AuthBloc verifica sesión guardada
      │  sin token ──► se queda en login
      │  con token ──► entra al sistema
      ▼
/ (Dashboard de indicadores - US-008)
      │
      ├─ Inicio (Dashboard KPI)        ──► métricas en tiempo real
      ├─ Flota          ──► lista + formulario CRUD (US-001)
      ├─ Conductores    ──► lista + formulario CRUD (US-003)
      ├─ Pedidos        ──► lista + formulario CRUD (US-002)
      └─ Rutas          ──► generar rutas (US-005) + detalle con entregas
```

### Navegación según el rol (DOC-008 RBAC)

| Rol | Módulos visibles | Permisos |
| --- | --- | --- |
| ADMIN / OPERADOR | Todo | CRUD completo |
| AUDITOR | Todo | Solo lectura (sin botones de crear/editar/eliminar) |
| CLIENTE | Inicio, Pedidos | Crea y lee pedidos (sin editar/eliminar) |
| CONDUCTOR | Solo Inicio | Hasta el modo conductor (EP-03) |

Los guards del router (`app_router.dart`) redirigen al `/` si el rol no tiene permiso
para la ruta **o la acción** (`/new`, `/:id/edit`). La matriz de permisos vive en
`core/constants/permissions.dart`.

---

## 2. Cómo se aplicaron los documentos en el front

| Documento | Cómo se aplicó en el código |
| --- | --- |
| **DOC-010 Stack tecnológico** | Flutter/Dart, estado con flutter_bloc, go_router, dio; código abierto (RES-07) |
| **DOC-012 ADR-06** | Cliente-Servidor: el front solo consume REST/JSON; jamás accede a PostgreSQL |
| **DOC-012 Capas internas** | Cada feature: `presentation → domain ← data` |
| **DOC-008 RBAC** | 5 roles en `app_roles.dart`; guards por ruta y acción; botones y menús por permiso |
| **DOC-009 RN-001** | Mensaje de bloqueo tras 3 intentos fallidos mostrado en login |
| **DOC-009 RN-006** | Validación de ventana de tiempo en formulario de pedidos |
| **RNF-001 (US-005/EN-001)** | Timeout extendido (90 s) solo en `POST /rutas/generar`; SLA ≤ 45 s con banner de progreso |
| **DOC-014 DoD** | 171 tests, cobertura 82.9 % (≥ 80 %), analyze 0 issues |
| **Convención de docs** | Código en inglés, UI en español (l10n); endpoints centralizados en `api_paths.dart` |

---

## 3. Responsive: web + móvil (breakpoint 600dp)

| Pantalla | Escritorio (≥600dp) | Teléfono (<600dp) |
| --- | --- | --- |
| Navegación | `NavigationRail` lateral + botón APK | `NavigationBar` inferior (sin botón APK) |
| Listas | `DataTable` con todas las columnas | Tarjetas con datos clave + acciones ≥48px |
| Formularios | Campos en pares (fila) | Campos apilados (`ResponsiveFieldRow`) |
| Dashboard | Grid de 3 columnas | Grid de 2 columnas, padding reducido |

---

## 4. Accesibilidad y colores

- Colores con contraste WCAG 2.1 AA: primario `#1B6D29`, appbar `#0D4715`, error `#BA1A1A`
- Widgets semánticos Material (`DataTable`, `ListTile`, `Tooltip`, `SnackBar`)
- Iconos siempre con etiqueta/texto; toques ≥48px en móvil
- **Honestidad:** EN-006 (auditoría axe, teclado completo) sigue en backlog

---

## 5. Seguridad en el frontend

| Mecanismo | Dónde |
| --- | --- |
| JWT + refresh persistidos | `shared_preferences` (localStorage en web) |
| Bearer automático | Interceptor `_AuthInterceptor` (`api_client.dart`) |
| Refresh sin bucles | Una sola petición de refresh concurrente + un reintento; nunca sobre endpoints de auth |
| RBAC doble capa | Guards del router + ocultamiento de botones/menús |
| **Pin TLS del APK** | `secure_http_client.dart` + `assets/certs/pathseek_cert.pem`: Flutter (dart:io) NO respeta el `network_security_config.xml` de Android, por eso el certificado auto-firmado de la VPS se valida con `SecurityContext` dentro de Dart |
| Sin secretos en código | Entornos por `--dart-define` (`environment.dart`) |

---

## 6. CORS y comunicación con la base de datos

- El frontend **nunca se conecta a PostgreSQL**: UI → BLoC → Repository → DataSource (dio) → API REST → (backend) → PostgreSQL
- **CORS**: lo aplica el backend; la web usa el proxy nginx del mismo origen; el APK nativo no envía Origin
- Contrato API Sprint 2 documentado como fuente de verdad en `frontend/README.md` (endpoints de rutas y dashboard, campos snake_case, estados, códigos de error)

---

## 7. Qué mostrar en la exposición

1. **Login** con credenciales demo; error real del backend (credenciales/bloqueo RN-001)
2. **Dashboard**: KPIs desde `/api/v1/dashboard/resumen` (vehículos, conductores, pedidos por estado, rutas, CO₂, combustible); mensaje orientador cuando está vacío
3. **Flota/Conductores/Pedidos**: CRUD con validaciones (placa duplicada, DNI, ventana de tiempo)
4. **Rutas (US-005)**: botón "Generar rutas" con banner de progreso (SLA ≤45s), lista con métricas (distancia, CO₂, combustible), detalle con entregas ordenadas
5. **Diferenciación por roles**: entrar como AUDITOR (sin botones), CLIENTE (solo pedidos, solo crear), CONDUCTOR (solo inicio)
6. **Responsive**: misma app en ventana de escritorio y tamaño de teléfono (nav inferior, tarjetas, formularios apilados)
7. **Pin TLS en el APK**: instalar el APK desde `https://169.58.74.99/downloads/pathseek.apk` y hacer login (certificado auto-firmado validado por Dart)

---

## 8. Qué mostrar en modo inspección (DevTools)

- **Network**: `POST /auth/login` → `{token, refreshToken, usuario}`; header `Authorization: Bearer`; flujo 401→refresh→retry; `POST /rutas/generar` con su timeout extendido; errores `{code, message, errors}`
- **Application → Local Storage**: `pathseek.accessToken`, `pathseek.refreshToken`, `pathseek.currentUser`
- **Flutter DevTools**: árbol de widgets y cambio de layout al reducir el ancho (<600dp)

---

## 9. Código clave para proyectar

| Tema | Archivo |
| --- | --- |
| Interceptores JWT/refresh | `frontend/lib/core/network/api_client.dart` |
| Pin TLS del APK | `frontend/lib/core/network/secure_http_client.dart` |
| Guards RBAC por acción | `frontend/lib/core/router/app_router.dart` |
| Matriz de permisos | `frontend/lib/core/constants/permissions.dart` |
| Responsive helper | `frontend/lib/core/utils/responsive.dart` |
| Nav inferior/rail por rol | `frontend/lib/core/router/home_shell.dart` |
| Generación de rutas | `frontend/lib/features/routes/presentation/bloc/route_bloc.dart` |
| Dashboard KPIs | `frontend/lib/features/dashboard/presentation/pages/dashboard_page.dart` |
| Test representativo | `frontend/test/features/routes/bloc/route_bloc_test.dart` |

---

## 10. Métricas de calidad (DoD)

```powershell
flutter analyze          # 0 issues
flutter test             # 171 tests, todos pasan
flutter test --coverage  # 82.9 % de cobertura (DoD >= 80 %)
flutter build web        # compilacion release
flutter build apk --release --dart-define=APP_ENV=prod   # APK movil
```
