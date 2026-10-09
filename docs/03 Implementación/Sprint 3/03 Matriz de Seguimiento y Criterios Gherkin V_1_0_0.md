[← Volver al README Principal](../../../README.md)

# Matriz de Seguimiento y Criterios de Aceptación BDD (Sprint 3)

**Nombre del Proyecto:** PathSeek  
**Líder del Proyecto:** Francis Maxuel Urquizo Ore  
**Código del documento:** DOC-024-MATRIZ  
**Versión:** V_1_0_0  
**Fecha:** 2026-10-12  

---

## 1. Matriz de Trazabilidad End-to-End

| RF / RNF | Historia / Enabler | SP | Endpoint REST | Casos de Prueba Automatizados |
| :---: | :---: | :---: | --- | --- |
| RF-007 | **US-006** Re-optimización Dinámica | 8 | `POST /api/v1/rutas/{id}/reoptimizar` | `ReoptimizeRouteIntegrationTests` |
| RNF-002 | **EN-002** Rendimiento de Re-optimización | 5 | `POST /api/v1/rutas/{id}/reoptimizar` | `reoptimizationLatencyUnderThreshold()` |
| RF-006 | **US-009** Reportes de Sostenibilidad | 5 | `GET /api/v1/reportes/sostenibilidad` | `ReportIntegrationTests` |
| RF-009 | **US-004** Módulo de Clientes | 2 | `GET, POST, PUT /api/v1/clientes` | `ClientIntegrationTests` |
| RF-010 | **US-010** Compensación de Carbono | 3 | `GET /api/v1/compensacion` | `CarbonCompensationTests` |
| RNF-003 | **Auditoría y Trazabilidad** | Transv. | `GET /api/v1/auditoria` | `AuditIntegrationTests` |

---

## 2. Criterios de Aceptación en Sintaxis Gherkin

### US-006: Re-optimización Dinámica ante Incidentes

```gherkin
Escenario: Re-optimización exitosa tras bloqueo vial
  Dado que existe una ruta en ejecución con 6 entregas planificadas en Huancayo
  Cuando el operador reporta un incidente por obras en el tramo central
  Y solicita la re-optimización dinámica mediante POST /api/v1/rutas/{id}/reoptimizar
  Entonces el sistema recalcula el itinerario en menos de 30 segundos
  Y actualiza la secuencia de paradas evitando el polígono afectado
  Y genera un registro de auditoría con la acción REOPTIMIZACION_RUTA
```

### US-009: Generación de Reporte de Sostenibilidad

```gherkin
Escenario: Consulta de métricas ecológicas por rango de fechas
  Dado que existen 12 rutas completadas en el mes de octubre
  Cuando el administrador consulta GET /api/v1/reportes/sostenibilidad?fechaInicio=2026-10-01&fechaFin=2026-10-15
  Entonces el sistema calcula el CO2 total evitado (106.8 kg) y el ahorro en Soles (S/ 798.00)
  Y permite la descarga del reporte estructurado en formato PDF
```

### US-004: Registro de Preferencias de Cliente

```gherkin
Escenario: Registro de cliente con ventana de atención estricta
  Dado que un administrador registra una nueva institución educativa cliente
  Cuando envía los datos con ventana horaria 08:00 a 11:30 y punto de referencia
  Entonces el sistema valida la ventana y retorna código 201 Created
```
