[← Volver al README Principal](../../../README.md)

# Especificación de Contratos API y Trazabilidad (Sprint 3)

**Nombre del Proyecto:** PathSeek  
**Líder del Proyecto:** Francis Maxuel Urquizo Ore  
**Código del documento:** DOC-024-CONTRATOS  
**Versión:** V_1_0_0  
**Fecha:** 2026-10-12  

---

## 1. Principios de Diseño de Contratos

1. **Preservación Inmutable:** Todas las rutas preexistentes mantienen su firma, códigos de estado HTTP y estructura DTO.
2. **Fuertemente Tipado y Validado:** Validación estricta con Jakarta Bean Validation (`@NotNull`, `@NotBlank`, `@DecimalMin`, `@Pattern`, `@Size`).
3. **Manejo Estandarizado de Errores:** Esquema canónico `ApiErrorResponse` con lista de `ApiFieldError` para validaciones de formulario.
4. **OpenAPI 3.0 / Swagger:** Anotaciones `@Operation`, `@ApiResponse`, `@Schema` en controladores y modelos.

---

## 2. Catálogo Consolidado de Endpoints

### 2.1 Módulos Preexistentes (Preservados al 100%)

| Módulo | Método | Ruta | Rol Autorizado | Descripción |
| --- | :---: | --- | --- | --- |
| Autenticación | `POST` | `/api/v1/auth/login` | Público | Autenticación y obtención de JWT + Refresh Token |
| Autenticación | `POST` | `/api/v1/auth/refresh` | Público | Rotación y renovación de tokens de sesión |
| Autenticación | `POST` | `/api/v1/auth/logout` | Público | Invalida el refresh token activo |
| Vehículos | `GET` | `/api/v1/vehiculos` | `ADMIN`, `OPERADOR`, `AUDITOR` | Listar catálogo de flota |
| Vehículos | `POST` | `/api/v1/vehiculos` | `ADMIN`, `OPERADOR` | Registrar vehículo |
| Conductores | `GET` | `/api/v1/conductores` | `ADMIN`, `OPERADOR`, `AUDITOR` | Listar conductores |
| Conductores | `POST` | `/api/v1/conductores` | `ADMIN`, `OPERADOR` | Registrar conductor |
| Pedidos | `GET` | `/api/v1/pedidos` | `ADMIN`, `OPERADOR`, `AUDITOR`, `CLIENTE` | Listar pedidos |
| Pedidos | `POST` | `/api/v1/pedidos` | `ADMIN`, `OPERADOR`, `CLIENTE` | Registrar pedido escolar |
| Rutas | `GET` | `/api/v1/rutas` | `ADMIN`, `OPERADOR`, `AUDITOR`, `CONDUCTOR` | Catálogo de rutas planificadas |
| Rutas | `GET` | `/api/v1/rutas/{id}` | `ADMIN`, `OPERADOR`, `AUDITOR`, `CONDUCTOR` | Detalle y paradas de ruta |
| Rutas | `POST` | `/api/v1/rutas/generar` | `ADMIN`, `OPERADOR` | Ejecutar metaheurística VRPTW |
| Rutas | `GET` | `/api/v1/rutas/{id}/geometria`| `ADMIN`, `OPERADOR`, `AUDITOR`, `CONDUCTOR` | Polilínea y perfil altimétrico |
| Rutas | `POST` | `/api/v1/rutas/{id}/incidentes`| `ADMIN`, `OPERADOR` | Registrar reporte de incidente vial |
| Salud | `GET` | `/api/v1/health` | Público | Healthcheck para Docker y balanceador |

### 2.2 Nuevos Endpoints Implementados en el Sprint 3

| Módulo | Método | Ruta | Rol Autorizado | Contrato Request / Response |
| --- | :---: | --- | --- | --- |
| **Re-optimización** | `POST` | `/api/v1/rutas/{id}/reoptimizar` | `ADMIN`, `OPERADOR` | `ReoptimizeRouteRequest` $\to$ `ReoptimizeRouteResponse` |
| **Sostenibilidad** | `GET` | `/api/v1/reportes/sostenibilidad` | `ADMIN`, `OPERADOR`, `AUDITOR` | Params: `fechaInicio`, `fechaFin` $\to$ `SustainabilityReportResponse` |
| **PDF Sostenibilidad**| `GET` | `/api/v1/reportes/sostenibilidad/pdf`| `ADMIN`, `OPERADOR`, `AUDITOR` | Params: `fechaInicio`, `fechaFin` $\to$ `application/pdf` |
| **Compensación** | `GET` | `/api/v1/compensacion` | `ADMIN`, `OPERADOR`, `AUDITOR` | Retorna `CarbonCompensationResponse` |
| **Clientes** | `GET` | `/api/v1/clientes` | `ADMIN`, `OPERADOR`, `AUDITOR` | Retorna `List<ClientResponse>` |
| **Clientes** | `POST` | `/api/v1/clientes` | `ADMIN`, `OPERADOR` | `ClientRequest` $\to$ `ClientResponse` |
| **Dashboard Resumen**| `GET` | `/api/v1/dashboard/resumen` | `ADMIN`, `OPERADOR`, `AUDITOR` | Retorna `DashboardSummaryDto` |
| **Auditoría** | `GET` | `/api/v1/auditoria` | `ADMIN`, `AUDITOR` | Params: `entidad`, `usuario`, `fecha` $\to$ `List<AuditLogResponse>` |

---

## 3. Esquemas y Contratos de Datos (JSON)

### 3.1 `ReoptimizeRouteRequest`
```json
{
  "motivo": "ACCIDENTE",
  "descripcion": "Cierre temporal en Jr. Real intersección Av. Huancavelica por obras",
  "latitudIncidente": -12.0685,
  "longitudIncidente": -75.2103,
  "radioBloqueoMetros": 300,
  "pedidosCancelados": []
}
```

### 3.2 `ReoptimizeRouteResponse`
```json
{
  "rutaId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "estado": "REOPTIMIZADA",
  "distanciaKm": 14.85,
  "combustibleL": 1.75,
  "co2Kg": 4.11,
  "tiempoRecalculoMs": 145,
  "mensaje": "Ruta re-optimizada exitosamente esquivando el incidente vial",
  "pedidosReordenados": 6,
  "pedidos": [ ... ]
}
```

### 3.3 `SustainabilityReportResponse`
```json
{
  "fechaInicio": "2026-10-01",
  "fechaFin": "2026-10-15",
  "totalRutasEjecutadas": 12,
  "totalPedidosEntregados": 84,
  "distanciaTotalKm": 185.40,
  "combustibleTotalL": 21.80,
  "emisionesCo2TotalKg": 51.23,
  "combustibleAhorradoL": 45.60,
  "co2EvitadoKg": 106.80,
  "ahorroEconomicoSoles": 798.00,
  "porcentajeCumplimientoVentanas": 96.4,
  "resumenPorVehiculo": [ ... ]
}
```
