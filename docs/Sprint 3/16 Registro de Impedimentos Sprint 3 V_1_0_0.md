[← Volver al README Principal](../../README.md)

# Registro de Impedimentos — Sprint 3

**Nombre del Proyecto:** PathSeek

**Líder del Proyecto:** Francis Maxuel Urquizo Ore

Proyecto: PathSeek
Código del documento: DOC-028
Versión: V_1_0_0
Fecha: 2026-10-25

---

## 1. Resumen

La iteración 3 transcurrió sin impedimentos bloqueantes. Se registraron tres hallazgos menores, todos resueltos o acotados dentro del sprint, y una limitación de alcance asumida (proveedor de tráfico real).

---

## 2. Tabla de impedimentos

| ID | Descripción | Impacto | Estado |
| --- | --- | --- | --- |
| IMP-08 | El daemon de Docker Desktop no estaba activo para la verificación local de las imágenes | Medio | Resuelto (arranque manual y verificación exitosa) |
| IMP-09 | Los tests de widgets del shell fallaban al agregar servicios (conectividad/avisos) no registrados en el arnés de pruebas | Medio | Resuelto (resolución perezosa con guardas de registro) |
| IMP-10 | `cliente_id` histórico de pedidos es texto libre; el módulo de Clientes (US-004) vincula cuentas sin migrar esos códigos | Bajo | Acotado (se conserva compatibilidad; la vinculación explícita está documentada) |

---

## 3. Estado de resolución

| ID | Acción tomada | Verificación |
| --- | --- | --- |
| IMP-08 | Se inició Docker Desktop y se construyeron las imágenes `pathseek-backend` y `pathseek-frontend` | Build local correcto |
| IMP-09 | `HomeShell` resuelve `ConnectivityService` y `NotificationsBloc` solo si están registrados | Suite completa en verde (292 pruebas) |
| IMP-10 | El backend conserva `cliente_id` libre para ADMIN/OPERADOR y usa el UUID de cuenta para CLIENTE | `Sprint3ModulesIntegrationTests` (clientes, reportes, compensación y ejecución) aprobada |

---

## 4. Limitaciones de alcance (no son impedimentos)

- **Tráfico real:** no se contrató proveedor; la congestión por tramo continúa como estimación documentada (US-007).
- **Encuesta de campo (EN-007):** requiere conductores reales de UGEL Huancayo; queda programada como A-13.
- **Medición p95 en staging:** requiere un entorno de pruebas dedicado; queda programada como A-15.
- **Restricción por placa:** permanece pospuesta por instrucción del usuario.

---

## 5. Control de versiones

| Versión | Fecha | Descripción | Responsable |
| --- | --- | --- | --- |
| V_1_0_0 | 2026-10-25 | Creación inicial: registro de impedimentos del Sprint 3. | Equipo PIPRE |

---

## 6. Referencia

- **Informe de estado:** `13 Informe de estado del proyecto Sprint 3 V_1_0_0.md`.
- **Revisión:** `14 Revisión del Sprint 3 V_1_0_0.md`.
- **Retrospectiva:** `15 Retrospectiva del Sprint 3 V_1_0_0.md`.
