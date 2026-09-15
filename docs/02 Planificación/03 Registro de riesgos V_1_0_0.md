[← Volver al README Principal](../../README.md)

# Registro de Riesgos del Proyecto PathSeek

Proyecto: PathSeek
Código del documento: DOC-016
Versión: V_1_0_0
Fecha: 2026-09-07

---

## 1. Marco de Gestión de Riesgos

El presente registro consolida la línea base de gestión de riesgos del proyecto conforme a los estándares **PMBOK 7.ª Edición** y **CMMI-DEV (área RSKM)**, y extiende los riesgos macro identificados en el acta de constitución (DOC-002, R-01 a R-08) hacia una **Matriz de Evaluación de Riesgos** cuantitativa.

---

## 2. Metodología de Evaluación Cuantitativa

### 2.1 Fórmula de cálculo

**Severidad (Exposición) = Probabilidad (1 a 5) × Impacto (1 a 5)**

### 2.2 Escala de Probabilidad

| Nivel | Valor | Descripción |
| --- | :---: | --- |
| Muy baja | 1 | Improbable; < 10 % de ocurrencia en el proyecto. |
| Baja | 2 | Poco probable; 10 % – 30 %. |
| Media | 3 | Posible; 30 % – 50 %. |
| Alta | 4 | Probable; 50 % – 70 %. |
| Muy alta | 5 | Casi seguro; > 70 %. |

### 2.3 Escala de Impacto

| Nivel | Valor | Descripción |
| --- | :---: | --- |
| Insignificante | 1 | Afectación mínima al alcance, cronograma o costo. |
| Menor | 2 | Afectación leve, absorbible sin cambios de línea base. |
| Moderado | 3 | Afectación media; requiere replanificación parcial. |
| Mayor | 4 | Afectación significativa a objetivos o hitos del proyecto. |
| Catastrófico | 5 | Amenaza la viabilidad del proyecto. |

### 2.4 Bandas de Severidad

| Banda | Rango (P × I) | Acción requerida |
| --- | :---: | --- |
| **Low** | 1 – 6 | Monitorear periódicamente. |
| **Medium** | 8 – 12 | Plan de respuesta obligatorio y seguimiento en cada Sprint. |
| **High** | 15 – 25 | Escalar al Project Manager; mitigación inmediata y reserva de contingencia. |

---

## 3. Matriz de Evaluación de Riesgos

| ID | Descripción del Riesgo | Categoría | Prob. | Imp. | Severidad | Plan de Mitigación (Preventivo) | Plan de Contingencia (Reactivo) | Responsable |
| --- | --- | --- | :---: | :---: | :---: | --- | --- | --- |
| RSK-01 | Indisponibilidad de servicios Cloud en el proveedor por límites de cuota. | Técnica / Infraestructura | 2 | 4 | **8 (Media)** | Monitorear consumo de cuotas e implementar alertas de umbral al 70 %. | Migrar temporalmente los contenedores a una cuenta secundaria de respaldo. | DevOps Engineer |
| RSK-02 | Curva de aprendizaje elevada en el framework del frontend. | Recursos Humanos / Capacidades | 3 | 3 | **9 (Media)** | Realizar 2 jornadas de Pair Programming y pases de conocimiento al inicio del Sprint. | Reasignar las tareas de mayor complejidad al arquitecto de software. | Scrum Master |
| RSK-03 | Complejidad del algoritmo de optimización VRPTW/Green VRP. | Técnica / Algoritmo | 4 | 4 | **16 (Alta)** | Implementar versión básica de la metaheurística primero y mejorar progresivamente; pruebas de rendimiento desde la primera versión. | Reducir el alcance del Sprint (criterio de salida parcial: rutas factibles sin optimización fina) y reasignar horas de QA al desarrollo. | Software Architect |
| RSK-04 | Datos de tráfico incompletos o imprecisos. | Datos / Externos | 3 | 4 | **12 (Media)** | Permitir carga manual de datos de tráfico y definir interfaces estandarizadas con proveedores. | Activar escenario degradado: optimizar con datos históricos y ajustes manuales del operador. | Backend Developer |
| RSK-05 | Integración con APIs externas de mapas (Waze, Google, MTC). | Técnica / Integración | 3 | 4 | **12 (Media)** | Definir contratos de interfaz claros y mantener alternativas de código abierto (flutter_map/OSM) como respaldo. | Conmutar al proveedor alternativo de código abierto sin modificar el resto del sistema. | Software Architect |
| RSK-06 | Retrasos en iteraciones del cronograma (14 semanas). | Gestión / Cronograma | 3 | 4 | **12 (Media)** | Priorizar funcionalidades esenciales del MVP y revisar el avance del Sprint en reuniones diarias (Daily). | Negociar alcance con el Product Owner y diferir EP-04 a una versión posterior al MVP. | Project Manager |
| RSK-07 | Problemas de rendimiento del algoritmo (SLA ≤ 45 s / ≤ 30 s). | Técnica / Rendimiento | 4 | 4 | **16 (Alta)** | Ejecutar pruebas de rendimiento desde las primeras versiones y aplicar perfilamiento continuo. | Paralelizar el cálculo con workers, aplicar caché Redis y ajustar parámetros de la metaheurística. | Backend Developer |
| RSK-08 | Baja adopción por parte de los conductores. | Recursos Humanos / Adopción | 2 | 3 | **6 (Baja)** | Diseñar modo conductor simple y validarlo tempranamente con conductores reales. | Reforzar capacitación presencial y soporte por WhatsApp durante la primera semana de operación. | UI/UX Designer |
| RSK-09 | Cambios en requerimientos o restricciones externas (normativa vehicular). | Gestión / Alcance | 3 | 3 | **9 (Media)** | Aplicar control de cambios y priorización continua del backlog con el Product Owner. | Actualizar la versión semántica de los documentos afectados y re-planificar el Sprint afectado. | Project Manager |
| RSK-10 | Limitaciones de conectividad en campo (2G/3G o sin señal). | Infraestructura / Campo | 3 | 3 | **9 (Media)** | Diseñar para conexiones de baja velocidad y modo offline con datos cacheados (EN-008). | Activar modo offline extendido y sincronización diferida al recuperar conectividad. | Frontend Developer |

---

## 4. Análisis Cuantitativo de la Matriz

### 4.1 Distribución por banda de severidad

| Banda | Riesgos | Cantidad |
| --- | --- | :---: |
| **Low (1-6)** | RSK-08 | 1 |
| **Medium (8-12)** | RSK-01, RSK-02, RSK-04, RSK-05, RSK-06, RSK-09, RSK-10 | 7 |
| **High (15-25)** | RSK-03, RSK-07 | 2 |

### 4.2 Interpretación

- Los dos (2) riesgos de severidad **Alta** concentran el mayor esfuerzo de gestión: ambos están ligados al **motor de optimización** (complejidad y rendimiento), que constituye el núcleo técnico del proyecto. Su mitigación se incorporó al backlog como Enablers EN-001 y EN-002 y como criterio del DoD global.
- Los siete (7) riesgos de severidad **Media** se gestionan con planes preventivos incorporados al trabajo del Sprint y se revisan en cada revisión de Sprint.
- El riesgo **Baja** (adopción de conductores) se monitorea mediante validación temprana del modo conductor (EN-007).
- La exposición global justifica una **reserva de contingencia del 12 %** del presupuesto (documento DOC-017).

### 4.3 Trazabilidad con el acta de constitución

| Riesgo del acta (DOC-002) | Riesgo de la matriz |
| --- | --- |
| R-01 Complejidad del algoritmo | RSK-03 |
| R-02 Datos de tráfico incompletos | RSK-04 |
| R-03 Integración con APIs externas | RSK-05 |
| R-04 Retrasos en iteraciones | RSK-06 |
| R-05 Problemas de rendimiento | RSK-07 |
| R-06 Baja adopción de conductores | RSK-08 |
| R-07 Cambios en requerimientos | RSK-09 |
| R-08 Limitaciones de conectividad | RSK-10 |

---

## 5. Historial de Control de Cambios

| Versión | Fecha | Descripción | Responsable |
| --- | --- | --- | --- |
| V_1_0_0 | 2026-09-07 | Creación inicial: matriz de evaluación de riesgos con severidad P × I y planes de respuesta (Fase 02: Planificación). | Equipo PIPRE |
| V_1_0_1 | 2026-09-14 | Actualización por cambio de stack frontend: Leaflet → flutter_map (Flutter/Dart) en RSK-05. | Equipo PIPRE |

---

## 6. Referencia

- **Consigna Fase 02:** `docs/a.html` — Consigna: Planificación del Proyecto (sección 2.4).
- **Documentos de Fase 01:** DOC-002 (Acta de Constitución, riesgos macro R-01 a R-08), DOC-004 (Supuestos y Restricciones).
- **Marco de referencia:** PMBOK 7.ª Edición (Gestión de Riesgos), CMMI-DEV (RSKM), ISO 31000.
