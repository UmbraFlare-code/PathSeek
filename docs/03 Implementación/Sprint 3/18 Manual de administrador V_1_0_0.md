[← Volver al README Principal](../../../README.md)

# Manual de Administrador — PathSeek V_1_0_0

**Proyecto:** PathSeek · **Código del documento:** DOC-035 · **Fecha:** 2026-10-25 · **Responsable:** Equipo PIPRE

Guía operativa y técnica para administrar la plataforma (EN-009).

Versión efectiva: V_1_1_0 (2026-10-27). El [corte QA](../Sprint%203/03%20Calidad%20de%20c%C3%B3digo%20V_1_0_0.md)
documenta cobertura, límites de Sonar y las dos incidencias; los resultados históricos de despliegue
no acreditan este árbol local. No se ejecutó despliegue ni migración durante el cierre documental.

---

## 1. Arquitectura

- **Backend:** Java 17 + Spring Boot 4.1.1, API REST en `/api/v1`, Swagger en `/swagger-ui.html`.
- **Frontend:** Flutter (web + APK Android).
- **Base de datos:** PostgreSQL 16, migraciones Flyway (`backend/src/main/resources/db/migration/`, V1–V3 y V5–V9). Flyway se ejecuta automáticamente al iniciar el backend; no requiere pasos manuales en bases nuevas ni existentes.
- **Despliegue:** Docker Compose (local: `docker-compose.yml`; producción: `docker-compose.prod.yml` en la VPS).

---

## 2. Variables de entorno clave

| Variable | Uso |
| --- | --- |
| `DB_HOST` / `DB_PORT` / `DB_NAME` / `DB_USER` / `DB_PASSWORD` | Conexión PostgreSQL |
| `JWT_SECRET` | Obligatoria, ≥ 32 bytes |
| `JWT_ACCESS_EXPIRATION_MINUTES` | 15 (por defecto) |
| `JWT_REFRESH_EXPIRATION_DAYS` | 7 (por defecto) |
| `CORS_ALLOWED_ORIGINS` | Orígenes permitidos separados por coma |
| `ROUTING_ENABLED` / `ROUTING_BASE_URL` | Trazado vial OSRM |
| `REOPTIMIZATION_BUDGET_MS` | Presupuesto de reoptimización (25 000 por defecto, 100–27 000) |
| `APP_BOOTSTRAP_USER_*` | Cuenta admin inicial (solo primer arranque) |

No subas `.env` al repositorio; usa `.env.example` como plantilla.

---

## 3. Gestión de usuarios y roles

- **Configuración → Usuarios:** crear/editar cuentas, asignar rol (`ADMIN`, `OPERADOR`, `CONDUCTOR`, `CLIENTE`, `AUDITOR`) y activar/desactivar.
- Cambiar correo, rol o estado revoca las sesiones de esa cuenta (JWT `ver` + refresh).
- Siempre queda al menos un ADMIN activo; la cuenta actual no puede desactivarse ni cambiarse el rol a sí misma.
- Los conductores se vinculan por DNI (migración 07); los clientes por `usuario_id` (esquema inicial V1) y sus preferencias de entrega viven en la migración 09.

---

## 4. Base de datos

| Migración | Contenido |
| --- | --- |
| V1–V3 | Esquema base, triggers y procedimientos (V4 reservada, no se ejecuta) |
| V5 | Reoptimización: eventos, incidentes, averías, progreso y avisos |
| V6 | Administración de usuarios (`token_version`) |
| V7 | Vinculación conductor por DNI |
| V8 | Catálogo de proyectos de compensación + seed |
| V9 | Preferencias de clientes (horarios, restricciones) |

Todas son aditivas e idempotentes. Espejos en `database/` (01–09) para instalaciones manuales.

---

## 5. Endpoints nuevos del Sprint 3

| Área | Endpoint |
| --- | --- |
| Clientes | `GET/POST /api/v1/clientes`, `GET/PUT/DELETE /api/v1/clientes/{id}` |
| Ejecución | `POST /api/v1/rutas/{id}/posicion`, `POST /api/v1/rutas/{id}/entregas/{pedidoId}/completar` |
| Reportes | `GET /api/v1/reportes/sostenibilidad?desde=&hasta=` |
| Compensación | `GET /api/v1/compensacion/plan` |
| Avisos | `GET /api/v1/rutas/notificaciones`, `POST /api/v1/rutas/notificaciones/{id}/leida` |

---

## 6. Calidad y verificación

```powershell
# Backend (H2)
cd backend
.\mvnw.cmd test

# Herramientas de benchmark
python -m unittest discover -s tools -p 'test_*.py'
python tools/benchmark_generation.py --base-url https://staging.example.test --runs 20
python tools/benchmark_reoptimization.py --base-url https://staging.example.test --events target/eventos-prueba.json

# Frontend
cd frontend
flutter analyze
flutter test
flutter build web --release
```

- **CI:** `reoptimization-check.yml` (backend H2 + PostgreSQL) y `frontend-checks.yml` (analyze + test) se ejecutan en PRs y pushes que afectan las rutas de archivos correspondientes.
- **Carga opt-in:** `PATHSEEK_LOAD_TEST=true` habilita la prueba 1000/50 (EN-005).

---

## 7. Seguridad y auditoría

- JWT stateless con validación de firma, rol, estado y versión de sesión en cada petición.
- RBAC por rol en el servidor; la UI nunca es la única barrera.
- Triggers registran cambios en `auditoria`; no existe aún pantalla de auditoría global (no se anuncia como disponible).
- Las respuestas no deben exponer hashes ni stack traces. Login y refresh sí devuelven los tokens previstos por contrato en JSON; no son cookies autenticadoras ni deben registrarse en logs o evidencias.

---

## 8. Respaldos y despliegue

1. Respalda la base antes de actualizar la VPS.
2. `git pull` y reconstruye con `docker compose -f docker-compose.prod.yml up -d --build`.
3. Flyway aplica las migraciones pendientes al iniciar el backend.
4. Verifica `GET /api/v1/health` y la web en `https://<IP>/`.

---

## Control de versiones

| Versión | Fecha | Descripción | Responsable |
| --- | --- | --- | --- |
| V_1_0_0 | 2026-10-25 | Creación del manual de administrador (EN-009). | Equipo PIPRE |
| V_1_1_0 | 2026-10-27 | Corrige afirmación sobre tokens en respuestas y enlaza QA; sin cambios de configuración o despliegue. | Auditoría documental QA |
