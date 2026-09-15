[← Volver al README Principal](../../README.md)

# Presupuesto del Proyecto PathSeek

Proyecto: PathSeek
Código del documento: DOC-017
Versión: V_1_0_0
Fecha: 2026-09-07

---

## 1. Objetivo y Alcance del Presupuesto

El presente documento modela el **costo total de desarrollo e infraestructura** del PFA para el horizonte del MVP (**14 semanas, 4 iteraciones**), desagregado en cuatro categorías: Recursos Humanos (CAPEX), Licenciamiento y Herramientas, Infraestructura Cloud (OPEX) y Reserva de Contingencia.

- **Moneda:** Soles (S/).
- **Horizonte:** 14 semanas (≈ 4 meses de uso de servicios).
- **Naturaleza:** Presupuesto **indicativo**. El equipo está compuesto por estudiantes (Equipo PIPRE) con perfil mayoritariamente junior (1 año de experiencia), por lo que las tarifas reflejan ese rango de conocimientos actual.

---

## 2. Costo de Recursos Humanos (CAPEX)

Cálculo: `Costo = Horas Asignadas × Tarifa Hora (S/)`

| Rol | Perfil del equipo | Horas/semana | Horas totales (14 semanas) | Tarifa (S//hora) | Costo (S/) |
| --- | --- | :---: | :---: | :---: | :---: |
| Project Manager | Junior académico, supervisado por el docente | 20 | 280 | 15 | 4,200 |
| Software Architect | Único perfil semi-senior del equipo | 15 | 210 | 20 | 4,200 |
| Developer Junior Backend | Junior, 1 año de experiencia | 30 | 420 | 12 | 5,040 |
| Developer Junior Frontend | Junior, 1 año de experiencia | 30 | 420 | 12 | 5,040 |
| QA Engineer | Junior | 20 | 280 | 12 | 3,360 |
| UI/UX Designer | Junior | 15 | 210 | 12 | 2,520 |
| **Total RRHH** | | **130** | **1,820** | | **24,360** |

**Notas:**

- La mayor carga horaria recae en los desarrolladores junior (840 horas combinadas), coherente con el rango de conocimientos actual del equipo.
- El Software Architect (S/ 20/hora) concentra las decisiones técnicas de mayor complejidad (metaheurísticas, arquitectura, integraciones) con dedicación parcial.
- El Project Manager (S/ 15/hora) opera con supervisión académica del Ing. Daniel Gamarra, sin costo adicional imputado al proyecto.

---

## 3. Costo de Licenciamiento y Herramientas

> **Nota importante:** el costo final de esta categoría **dependía de las decisiones de desarrollo y despliegue** que se tomarían durante las auditorías del proyecto. Por ello se presentan **tablas con opciones de costo** (mínimo / recomendado / premium); la selección definitiva ya fue tomada (**escenario mínimo: todas las herramientas en plan gratuito**, sección 3.6) y se registra mediante control de cambios (V_1_0_1).

### 3.1 Atlassian Jira Software (Cloud)

| Opción | Descripción | Costo (4 meses) |
| --- | --- | :---: |
| Mínima | Plan Free (< 10 usuarios) | S/ 0 |
| Recomendada | Plan Standard (~S/ 260/mes, hasta 35,000 usuarios) | S/ 1,040 |
| Premium | Plan Premium (~S/ 480/mes, con Advanced Roadmaps y análisis) | S/ 1,920 |

### 3.2 Herramientas de diseño (Figma)

| Opción | Descripción | Costo (4 meses) |
| --- | --- | :---: |
| Mínima | Plan Starter (1 diseñador) | S/ 0 |
| Recomendada | Professional (~S/ 45/mes × 2 usuarios) | S/ 360 |
| Premium | Organization (~S/ 150/mes × 2 usuarios) | S/ 1,200 |

### 3.3 Calidad de código (SonarQube)

| Opción | Descripción | Costo (4 meses) |
| --- | --- | :---: |
| Mínima | Community Edition (análisis básico) | S/ 0 |
| Recomendada | Developer Edition (~S/ 47/mes, hasta 1M LOC) | S/ 188 |
| Premium | Enterprise Edition | Cotización |

### 3.4 Entornos IDE

| Opción | Descripción | Costo (4 meses) |
| --- | --- | :---: |
| Mínima | Visual Studio Code | S/ 0 |
| Recomendada | Visual Studio Code + extensiones oficiales | S/ 0 |
| Premium | WebStorm (~S/ 55/mes × 2 desarrolladores) | S/ 440 |

### 3.5 Integración y despliegue continuo (GitHub / CI-CD)

| Opción | Descripción | Costo (4 meses) |
| --- | --- | :---: |
| Mínima | GitHub Free (2,000 min/mes de Actions) | S/ 0 |
| Recomendada | GitHub Team (~S/ 12/mes × 6 usuarios) | S/ 288 |
| Premium | GitHub Enterprise (~S/ 65/mes × 6 usuarios) | S/ 1,560 |

### 3.6 Resumen de la categoría (escenario mínimo – planes gratuitos)

| Herramienta | Opción seleccionada | Costo (4 meses) |
| --- | --- | :---: |
| Jira Software | Free (< 10 usuarios) | S/ 0 |
| Figma | Starter | S/ 0 |
| SonarQube | Community Edition | S/ 0 |
| IDE | Visual Studio Code | S/ 0 |
| GitHub / CI-CD | Free (2,000 min/mes de Actions) | S/ 0 |
| **Subtotal Licenciamiento** | | **S/ 0** |

> Decisión adoptada: todas las herramientas de esta categoría se usan en su **plan gratuito / edición open source** (escenario mínimo, S/ 0). Los escenarios recomendado (S/ 1,876) y premium (S/ 5,120) quedan documentados en las secciones 3.1–3.5 como alternativas si la auditoría de desarrollo y despliegue las requiere.

---

## 4. Costo de Infraestructura Cloud y Servicios (OPEX)

| Servicio | Descripción | Costo mensual | Costo (4 meses) |
| --- | --- | :---: | :---: |
| Cómputo | Instancia cloud (AWS EC2 t3.medium / GCP e2-medium) para backend y frontend | S/ 120 | S/ 480 |
| Base de datos gestionada | PostgreSQL (RDS db.t3.small / Cloud SQL) con extensión PostGIS | S/ 190 | S/ 760 |
| Caché | Redis (ElastiCache / Memorystore) para sesiones y consultas frecuentes | S/ 90 | S/ 360 |
| Almacenamiento y respaldo | S3 / Cloud Storage 50 GB + snapshots | S/ 30 | S/ 120 |
| Dominio y SSL | Dominio institucional + certificado SSL (costo anual prorrateado) | — | S/ 85 |
| Monitoreo y telemetría | Dashboards, alertas y telemetría del ambiente de Staging | S/ 80 | S/ 320 |
| **Subtotal Infraestructura (OPEX)** | | | **S/ 2,125** |

> El costo operativo anual estimado post-MVP (S/ 120,000 según el acta de constitución) no forma parte de este presupuesto de desarrollo; aquí solo se prorratean los 4 meses de ejecución del proyecto.

---

## 5. Reserva de Contingencia (Imprevistos)

Se establece una reserva del **12 %** del subtotal (dentro del rango sugerido de 10 % – 15 %), justificada por la presencia de **dos riesgos de severidad Alta** (RSK-03 complejidad del algoritmo y RSK-07 rendimiento) identificados en el documento DOC-016.

| Concepto | Cálculo | Monto |
| --- | --- | :---: |
| Subtotal (RRHH + Licencias + Cloud) | 24,360 + 0 + 2,125 | S/ 26,485 |
| Reserva de contingencia (12 %) | 26,485 × 0.12 | S/ 3,178 |

---

## 6. Tabla Resumen Financiera

| Categoría | Costo Subtotal (S/) | Porcentaje del Total |
| --- | :---: | :---: |
| 1. Recursos Humanos (CAPEX) | 24,360 | 92.0 % |
| 2. Licenciamiento de Software (escenario mínimo) | 0 | 0.0 % |
| 3. Infraestructura Cloud (OPEX) | 2,125 | 8.0 % |
| **SUBTOTAL DE PROYECTO** | **26,485** | **100.0 %** |
| 4. Reserva de Contingencia (12 %) | 3,178 | N/A |
| **PRESUPUESTO TOTAL ESTIMADO** | **29,663** | **100.0 %** |

---

## 7. Nota de Coherencia con el Acta de Constitución

El acta de constitución (DOC-002) aprobó un presupuesto máximo de **S/ 500,000** para el MVP y **S/ 120,000** anuales de operación. El presupuesto indicativo aquí calculado (**S/ 29,663**) no se fuerza a dicho techo porque:

1. Las tarifas reflejan el **rango de conocimientos actual del equipo** (estudiantes junior, 1 año de experiencia), no tarifas de mercado empresarial.
2. El acta cubre el **ciclo de vida completo** (adquisición, hardware, capacitación institucional, operación), mientras que este documento modela únicamente el **costo de desarrollo e infraestructura de las 14 semanas del MVP**.
3. La diferencia resultante constituye **margen disponible** del techo aprobado, utilizable ante escalamientos de la reserva de contingencia o si la auditoría decidiera migrar a escenarios superiores de herramientas (recomendado o premium).

---

## 8. Historial de Control de Cambios

| Versión | Fecha | Descripción | Responsable |
| --- | --- | --- | --- |
| V_1_0_0 | 2026-09-07 | Creación inicial: modelado financiero del MVP con tarifas según perfil real del equipo, opciones de licenciamiento sujetas a auditoría y contingencia del 12 % (Fase 02: Planificación). | Equipo PIPRE |
| V_1_0_1 | 2026-09-14 | Decisión de licenciamiento: todas las herramientas en planes gratuitos (escenario mínimo, S/ 0). Se actualizan 3.6, reserva de contingencia, resumen financiero y nota de coherencia (total S/ 29,663). | Equipo PIPRE |

---

## 9. Referencia

- **Consigna Fase 02:** `docs/a.html` — Consigna: Planificación del Proyecto (sección 2.5).
- **Documentos de Fase 01:** DOC-002 (Acta de Constitución, presupuesto S/ 500,000), DOC-016 (Registro de Riesgos, reserva de contingencia).
- **Marco de referencia:** PMBOK 7.ª Edición (Gestión de Costos), CMMI-DEV (PP - Planificación de Proyecto).
