[← Volver al README Principal](../../../README.md)

# Planificación del Sprint 2

**Nombre del Proyecto:** PathSeek  
**Líder del Proyecto:** Francis Maxuel Urquizo Ore  
**Código del documento:** DOC-019-S2  
**Versión:** V_1_0_0  
**Fecha:** 2026-09-28  

---

## 1. Datos del Sprint

| Campo | Detalle |
| --- | --- |
| **Sprint** | Sprint 2 |
| **Duración** | 2 semanas (2026-09-28 al 2026-10-09) |
| **Capacidad del equipo** | 28 Story Points |
| **Story Points comprometidos** | 26 SP |
| **Meta del Sprint (Sprint Goal)** | Implementar el dashboard de indicadores de sostenibilidad y la visualización de rutas optimizadas en tarjetas web y modo móvil adaptativo, desplegando la arquitectura integral en ambiente de producción seguro (HTTPS/Docker) con descarga directa del APK para conductores de UGEL Huancayo. |

---

## 2. Historias de Usuario e Incidencias Seleccionadas

| Clave | Resumen | Épica | Story Points | Responsable | Criterios BDD Clave |
| :---: | --- | :---: | :---: | --- | --- |
| PATHSEEK-10 | **US-008** Dashboard de Indicadores | EP-03 | 5 | Dev Junior Frontend | KPIs de CO₂ evitado, combustible ahorrado, resumen de pedidos |
| PATHSEEK-7 | **US-007** Visualización de Rutas en Mapa/Tarjetas | EP-03 | 8 | Dev Junior Frontend | Módulo `/routes`, secuencia ordenada de paradas, detalle `/routes/:id` |
| PATHSEEK-4 | **US-005** Núcleo de Gestión de Rutas Optimizadas | EP-02 | 5 | Dev Junior Backend | Metaheurística Green VRPTW con contexto vial OSM de Huancayo |
| PATHSEEK-15/16 | **EN-007 / EN-008** Modo Móvil Conductor y APK | EP-03 | 3 | UI/UX & Flutter Dev | Layout adaptativo móvil y descarga directa de APK Android |
| PATHSEEK-11 | **EN-004** Alta Disponibilidad y VPS | EP-03 | 5 | Software Architect / DevOps | `docker-compose.prod.yml`, Nginx HTTPS SSL, VPS Contabo |

---

## 3. Criterios de Aceptación del Sprint y Definition of Done (DoD)

1. Dashboard interactivo con datos reactivos consumiendo servicios agregados.
2. Catálogo de rutas en tarjetas responsivas y vista de detalle con secuencia cronológica.
3. Despliegue productivo en VPS Contabo (`https://169.58.74.99`) con terminación SSL en puerto 443.
4. Generación y descarga directa del instalador móvil Android `pathseek.apk`.
5. 170 pruebas frontend y 49 pruebas backend automatizadas aprobadas.
