[← Volver al README Principal](../../../README.md)

# Registro de Impedimentos (Sprint 1)

**Nombre del Proyecto:** PathSeek  
**Líder del Proyecto:** Francis Maxuel Urquizo Ore  
**Código del documento:** DOC-019  
**Versión:** V_1_0_0  
**Fecha:** 2026-09-25  

---

## 1. Registro de Obstáculos e Impedimentos Identificados

| ID | Fecha Detección | Descripción del Impedimento | Impacto | Estado | Plan de Mitigación / Resolución |
| :---: | :---: | --- | :---: | :---: | --- |
| IMP-01 | 2026-09-16 | Diferencias en el formateo de horas (`HH:mm` vs `ISO-8601`) entre frontend y backend para pedidos. | Medio | **Resuelto** | Se estandarizó el uso de formato `HH:mm` con validadores `@Pattern` en DTOs y formateadores en Dart. |
| IMP-02 | 2026-09-18 | Manejo de CORS restrictivo que bloqueaba solicitudes desde el entorno local de Flutter Web. | Alto | **Resuelto** | Se parametrizó `SecurityProperties` con soporte dinámico de `corsAllowedOrigins`. |
| IMP-03 | 2026-09-22 | Restricción de unicidad en BD que arrojaba excepción genérica 500 en lugar de 409 Conflict. | Medio | **Resuelto** | Se creó `BusinessConflictException` y su mapeador en `GlobalExceptionHandler`. |

---

## 2. Resumen de Estado

- **Total de impedimentos registrados:** 3
- **Total resueltos en el Sprint:** 3 (100 %)
- **Impedimentos bloqueantes al cierre:** 0
