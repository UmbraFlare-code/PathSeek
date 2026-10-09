[← Volver al README Principal](../../../README.md)

# Registro de Impedimentos (Sprint 3)

**Nombre del Proyecto:** PathSeek  
**Líder del Proyecto:** Francis Maxuel Urquizo Ore  
**Código del documento:** DOC-026  
**Versión:** V_1_0_0  
**Fecha:** 2026-10-23  

---

## 1. Registro de Obstáculos e Impedimentos

| ID | Fecha | Descripción del Obstáculo | Impacto | Estado | Resolución / Acción Tomada |
| :---: | :---: | --- | :---: | :---: | --- |
| IMP-07 | 2026-10-14 | Necesidad de mantener compatibilidad con clientes sin modificar rutas REST ya probadas. | Alto | **Resuelto** | Se respetaron todas las rutas base y se extendió la API con nuevos endpoints no destructivos. |
| IMP-08 | 2026-10-16 | Complejidad en la serialización del reporte PDF en ambientes headless Docker. | Medio | **Resuelto** | Implementación de generador liviano iText/PDF con plantillas estilizadas compatibles con Java 17. |
| IMP-09 | 2026-10-19 | Registro concurrente de logs de auditoría sin degradar la latencia de la API. | Medio | **Resuelto** | Servicio de auditoría desacoplado con persistencia transaccional optimizada. |

---

## 2. Resumen de Estado

- **Total de impedimentos en Sprint 3:** 3
- **Total resueltos satisfactoriamente:** 3 (100 %)
- **Bloqueos pendientes:** 0
