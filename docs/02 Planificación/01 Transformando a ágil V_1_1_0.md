[← Volver al README Principal](../../README.md)

# Transformando a Ágil: Backlog del Proyecto PathSeek

Proyecto: PathSeek
Código del documento: DOC-014
Versión: V_1_1_0
Fecha: 2026-09-07

---

## 1. Metodología de Transformación

### 1.1 De Requerimientos Funcionales (RF) a Épicas e Historias de Usuario (US)

1. **Requerimientos Funcionales (RF):** Cada RF de la línea base (documento DOC-006, RF-001 a RF-010) se mapea jerárquicamente hacia una **Épica** (módulo o bloque funcional del PFA) y posteriormente se descompone en **Historias de Usuario (US)** redactadas bajo la plantilla canónica `Como… quiero… para…`.
2. **Requerimientos No Funcionales (RNF):** Cada RNF (documento DOC-007, RNF-001 a RNF-009) se transforma en una **Historia Técnica (Enabler)** de infraestructura, arquitectura, seguridad o rendimiento. Aquellos RNF de carácter transversal (accesibilidad, usabilidad, conectividad) se integran además como Criterios de Aceptación o como parte del **Definition of Done (DoD)** global.

### 1.2 Criterios de descomposición aplicados

| Criterio | Regla aplicada |
| --- | --- |
| Valor de negocio | Cada US debe ser entregable de forma independiente y generar valor visible para UGEL Huancayo. |
| Tamaño | Ninguna US supera los 13 Story Points (Fibonacci); las mayores se dividen en sub-tareas técnicas (≤ 8 horas) en Jira. |
| Testeabilidad | Toda US y Enabler incluye al menos dos (2) Criterios de Aceptación en sintaxis BDD/Gherkin. |
| Trazabilidad | Se preserva el vínculo RF/RNF → Épica → US/Enabler en la matriz de trazabilidad (sección 2). |
| Consistencia | Se reutilizan los escenarios Ruta Gold / Ruta Feliz ya validados en la Fase de Requerimientos. |

---

## 2. Matriz de Trazabilidad

### 2.1 Trazabilidad RF → Épica → Historia de Usuario

| RF | Requerimiento | Épica | Historia de Usuario | Story Points |
| --- | --- | --- | --- | :---: |
| RF-001 | Gestión de Flota | EP-01 | US-001 | 5 |
| RF-002 | Gestión de Pedidos | EP-01 | US-002 | 5 |
| RF-008 | Gestión de Conductores | EP-01 | US-003 | 3 |
| RF-009 | Módulo de Clientes | EP-01 | US-004 | 2 |
| RF-003 | Generación de Rutas Optimizadas | EP-02 | US-005 | 13 |
| RF-007 | Re-optimización Dinámica | EP-02 | US-006 | 8 |
| RF-004 | Visualización de Rutas en Mapa | EP-03 | US-007 | 8 |
| RF-005 | Dashboard de Indicadores | EP-03 | US-008 | 5 |
| RF-006 | Reportes de Sostenibilidad | EP-03 | US-009 | 5 |
| RF-010 | Plan de Compensación de Carbono | EP-04 | US-010 | 3 |

### 2.2 Trazabilidad RNF → Historia Técnica (Enabler)

| RNF | Requerimiento no funcional | Enabler | Story Points |
| --- | --- | --- | :---: |
| RNF-001 | Rendimiento del algoritmo de optimización | EN-001 | 5 |
| RNF-002 | Rendimiento de re-optimización | EN-002 | 5 |
| RNF-003 | Seguridad (OWASP Top 10, Ley N.° 29733) | EN-003 | 5 |
| RNF-004 | Disponibilidad ≥ 99.5 % | EN-004 | 3 |
| RNF-005 | Escalabilidad (1,000 pedidos / 50 vehículos) | EN-005 | 3 |
| RNF-006 | Accesibilidad WCAG 2.1 AA | EN-006 | 3 |
| RNF-007 | Usabilidad del modo conductor | EN-007 | 3 |
| RNF-008 | Conectividad limitada / modo offline | EN-008 | 3 |
| RNF-009 | Documentación técnica y de API | EN-009 | 2 |

---

## 3. Épicas del Producto

### EP-01: Gestión Logística Básica

| Campo | Detalle |
| --- | --- |
| **Descripción** | Registro y administración de las entidades maestras del sistema: flota vehicular, pedidos, conductores y preferencias de clientes. Base de datos operativa que alimenta al motor de optimización. |
| **Objetivo de negocio** | Digitalizar la operación logística de UGEL Huancayo y disponer de datos confiables (RF-001, RF-002, RF-008, RF-009). |
| **Historias asociadas** | US-001, US-002, US-003, US-004 |
| **Criterio de éxito** | CRUD completo de flota, pedidos, conductores y clientes validado por el personal administrativo. |
| **Iteración asignada** | Iteración 2 (Sprint 1–2) |

### EP-02: Motor de Optimización de Rutas

| Campo | Detalle |
| --- | --- |
| **Descripción** | Núcleo algorítmico del producto: resolución del VRPTW con consideraciones ambientales (Green VRP) mediante metaheurísticas (Algoritmos Genéticos, Búsqueda Tabú, Colonia de Hormigas o Enfriamiento Simulado) y re-optimización dinámica ante incidentes. |
| **Objetivo de negocio** | Reducir ≥ 15 % la distancia recorrida y ≥ 10 % las emisiones de CO₂ (RF-003, RF-007). |
| **Historias asociadas** | US-005, US-006 |
| **Criterio de éxito** | Rutas válidas en ≤ 45 s para 150 pedidos y 15 vehículos; re-optimización en ≤ 30 s. |
| **Iteración asignada** | Iteraciones 2–4 (Sprint 2–7) |

### EP-03: Visualización y Sostenibilidad

| Campo | Detalle |
| --- | --- |
| **Descripción** | Interfaz geográfica (mapa interactivo), dashboard de indicadores en tiempo real y reportes PDF de sostenibilidad para la toma de decisiones de UGEL Huancayo. |
| **Objetivo de negocio** | Visibilizar el ahorro operativo y ambiental (RF-004, RF-005, RF-006). |
| **Historias asociadas** | US-007, US-008, US-009 |
| **Criterio de éxito** | Mapa con trazado de rutas, dashboard con KPIs y reporte PDF descargable por rango de fechas. |
| **Iteración asignada** | Iteración 3 (Sprint 3–5) |

### EP-04: Experiencia y Carbono Cero

| Campo | Detalle |
| --- | --- |
| **Descripción** | Experiencias complementarias del producto: plan de compensación de carbono y hoja de ruta hacia la neutralidad en 3 años. |
| **Objetivo de negocio** | Formalizar el compromiso ambiental de UGEL Huancayo (RF-010). |
| **Historias asociadas** | US-010 |
| **Criterio de éxito** | Plan de compensación con cálculo de emisiones y sugerencia de proyectos de reforestación. |
| **Iteración asignada** | Iteración 3 (Sprint 5) |

---

## 4. Historias de Usuario (US)

### US-001: Gestión de Flota

- **Épica relacionada:** EP-01 Gestión Logística Básica
- **Prioridad:** Alta · **Story Points:** 5

**Redacción:**

> Como administrador logístico, quiero registrar y gestionar vehículos con placa, tipo, capacidad de carga, consumo de combustible y factor de emisión de CO₂, para mantener actualizada la flota que alimenta al motor de optimización.

**Criterios de Aceptación (Gherkin):**

```gherkin
Escenario: Registro exitoso de un vehículo
Dado que el administrador tiene permisos de gestión de flota
Cuando registra un vehículo con datos completos y válidos
Entonces el sistema almacena el vehículo y lo muestra en la lista de flota

Escenario: Actualización de datos de un vehículo
Dado que el administrador edita los datos de un vehículo registrado
Cuando modifica capacidad, consumo o factor de emisión
Entonces el sistema actualiza el registro y refleja los cambios en el dashboard

Escenario: Placa duplicada
Dado que el administrador intenta registrar un vehículo con placa duplicada
Entonces el sistema deniega la acción y muestra un mensaje indicando que la placa ya existe
```

---

### US-002: Gestión de Pedidos

- **Épica relacionada:** EP-01 Gestión Logística Básica
- **Prioridad:** Alta · **Story Points:** 5

**Redacción:**

> Como operador logístico, quiero registrar pedidos con dirección, coordenadas GPS, peso, volumen, ventana de tiempo, prioridad y tipo de producto, para incluirlos en la cola de planificación de rutas.

**Criterios de Aceptación (Gherkin):**

```gherkin
Escenario: Registro exitoso de un pedido
Dado que el operador tiene permisos de registro de pedidos
Cuando registra un pedido con dirección, coordenadas, peso, volumen y ventana de tiempo válidos
Entonces el sistema almacena el pedido y lo incluye en la cola de planificación

Escenario: Punto de referencia en lugar de dirección formal
Dado que el operador registra un pedido con punto de referencia en lugar de dirección formal
Cuando ingresa texto libre como "frente a la bodega El Ahorro"
Entonces el sistema acepta el punto de referencia y lo asocia al pedido

Escenario: Ventana de tiempo incompatible
Dado que el operador registra un pedido con ventana de tiempo incompatible (hora fin anterior a hora inicio)
Entonces el sistema deniega la acción y muestra error de validación
```

---

### US-003: Gestión de Conductores

- **Épica relacionada:** EP-01 Gestión Logística Básica
- **Prioridad:** Media · **Story Points:** 3

**Redacción:**

> Como administrador logístico, quiero registrar conductores con DNI, licencia, experiencia, disponibilidad horaria y contacto, para incluirlos en la asignación de rutas respetando las jornadas máximas de la Ley N.° 30224.

**Criterios de Aceptación (Gherkin):**

```gherkin
Escenario: Registro exitoso de un conductor
Dado que el administrador tiene permisos de gestión de conductores
Cuando registra un conductor con datos completos
Entonces el sistema almacena el conductor y lo incluye en la asignación de rutas

Escenario: Jornada máxima de conducción alcanzada
Dado que un conductor ya acumula 8 horas de conducción continua
Cuando el sistema planifica rutas
Entonces excluye al conductor de nuevas asignaciones hasta completar el descanso obligatorio

Escenario: Punto de partida distante
Dado que un conductor reside en un distrito alejado
Entonces el sistema considera su punto de partida al asignar rutas
```

---

### US-004: Módulo de Clientes

- **Épica relacionada:** EP-01 Gestión Logística Básica
- **Prioridad:** Baja · **Story Points:** 2

**Redacción:**

> Como cliente de UGEL Huancayo, quiero registrar mis preferencias de entrega (horarios, puntos de referencia y restricciones de acceso), para recibir los pedidos en las condiciones que mi establecimiento requiere.

**Criterios de Aceptación (Gherkin):**

```gherkin
Escenario: Registro de preferencias de entrega
Dado que un cliente tiene acceso a la plataforma
Cuando registra sus preferencias de entrega
Entonces el sistema almacena las preferencias y las aplica al generar rutas

Escenario: Horarios variables de atención
Dado que un cliente indica horarios variables de atención (ej. bodega con horario 6:00 AM - 9:00 PM)
Cuando registra las ventanas de tiempo
Entonces el sistema considera las ventanas al optimizar rutas
```

---

### US-005: Generación de Rutas Optimizadas

- **Épica relacionada:** EP-02 Motor de Optimización de Rutas
- **Prioridad:** Alta · **Story Points:** 13

**Redacción:**

> Como operador logístico, quiero generar rutas optimizadas mediante una metaheurística que considere distancia, tiempo, combustible, emisiones de CO₂, penalizaciones por entregas tardías y descansos obligatorios, para reducir costos operativos y el impacto ambiental de la distribución.

**Criterios de Aceptación (Gherkin):**

```gherkin
Escenario: Generación de rutas bajo carga de referencia
Dado que existen pedidos registrados y vehículos disponibles con sus ventanas de tiempo
Cuando el operador solicita la generación de rutas
Entonces el sistema retorna rutas óptimas en ≤ 45 segundos para 150 pedidos y 15 vehículos

Escenario: Restricción vehicular por placa
Dado que un conductor tiene restricción vehicular por último dígito de placa (DS N.° 033-2012-MTC)
Cuando el sistema genera rutas para ese día
Entonces excluye al vehículo restringido de la asignación

Escenario: Ventana de entrega inalcanzable
Dado que la ventana de tiempo de una entrega es inalcanzable con la capacidad disponible
Entonces el sistema marca la entrega como pendiente y sugiere reprogramación
```

---

### US-006: Re-optimización Dinámica

- **Épica relacionada:** EP-02 Motor de Optimización de Rutas
- **Prioridad:** Alta · **Story Points:** 8

**Redacción:**

> Como operador logístico, quiero que el sistema recalcule las rutas ante nuevos pedidos, cancelaciones, accidentes de tránsito o averías, para mantener la operación de distribución alineada a la realidad del tráfico en tiempo real.

**Criterios de Aceptación (Gherkin):**

```gherkin
Escenario: Re-optimización ante un cambio
Dado que existen rutas activas en ejecución
Cuando se produce un cambio (nuevo pedido, cancelación o incidente)
Entonces el sistema recalcula las rutas afectadas en ≤ 30 segundos y notifica a los conductores

Escenario: Accidente en un tramo de ruta activa
Dado que se produce un accidente en un tramo de una ruta activa
Cuando el sistema recibe la alerta de incidente
Entonces replanifica la ruta evitando el tramo afectado

Escenario: Cambios múltiples simultáneos
Dado que se produce un cambio múltiple simultáneo (varios pedidos nuevos)
Entonces el sistema procesa todos los cambios y genera una nueva planificación coherente
```

---

### US-007: Visualización de Rutas en Mapa

- **Épica relacionada:** EP-03 Visualización y Sostenibilidad
- **Prioridad:** Alta · **Story Points:** 8

**Redacción:**

> Como operador logístico, quiero visualizar las rutas optimizadas en un mapa interactivo con trazado, puntos de entrega, tiempos estimados por tramo y nivel de congestión, para supervisar la ejecución de la distribución.

**Criterios de Aceptación (Gherkin):**

```gherkin
Escenario: Visualización del trazado de rutas
Dado que existen rutas generadas por el algoritmo de optimización
Cuando el operador abre la vista de mapa
Entonces el sistema muestra el trazado de cada ruta con colores diferenciados, puntos de entrega y tiempos estimados por tramo

Escenario: Tramo con congestión alta
Dado que un tramo tiene congestión alta según datos de tráfico
Cuando el operador visualiza la ruta
Entonces el tramo aparece en rojo con indicador de congestión

Escenario: Detalle de un punto de entrega
Dado que el operador selecciona un punto de entrega en el mapa
Entonces el sistema muestra detalles del pedido (cliente, ventana de tiempo, peso)
```

---

### US-008: Dashboard de Indicadores

- **Épica relacionada:** EP-03 Visualización y Sostenibilidad
- **Prioridad:** Alta · **Story Points:** 5

**Redacción:**

> Como gerente de operaciones, quiero consultar métricas en tiempo real de distancia recorrida, emisiones de CO₂, combustible ahorrado, cumplimiento de ventanas y ahorro comparado, para evaluar el desempeño logístico y ambiental de la flota.

**Criterios de Aceptación (Gherkin):**

```gherkin
Escenario: Dashboard con datos de rutas completadas
Dado que existen rutas completadas en el sistema
Cuando el operador accede al dashboard
Entonces el sistema muestra métricas actualizadas con datos de las últimas rutas ejecutadas

Escenario: Equivalente ambiental
Dado que se completaron entregas con ahorro significativo
Cuando el operador consulta el dashboard
Entonces el sistema muestra equivalente ambiental ("Has ahorrado S/ XX en combustible hoy")

Escenario: Dashboard sin datos
Dado que no hay datos de rutas completadas
Entonces el sistema muestra el dashboard vacío con mensaje orientador
```

---

### US-009: Reportes de Sostenibilidad

- **Épica relacionada:** EP-03 Visualización y Sostenibilidad
- **Prioridad:** Media · **Story Points:** 5

**Redacción:**

> Como gerente de operaciones, quiero generar reportes PDF con emisiones por ruta, costo del ciclo de vida de la flota, ahorro en créditos de carbono y cumplimiento de metas, para sustentar decisiones y compromisos ambientales ante la institución.

**Criterios de Aceptación (Gherkin):**

```gherkin
Escenario: Generación de reporte PDF
Dado que existen datos de rutas ejecutadas y costos de la flota
Cuando el operador solicita la generación de un reporte de sostenibilidad
Entonces el sistema genera un PDF descargable con métricas de emisiones, costos y ahorro

Escenario: Filtro por rango de fechas
Dado que el operador selecciona un rango de fechas específico
Cuando genera el reporte
Entonces el sistema filtra los datos por el rango seleccionado
```

---

### US-010: Plan de Compensación de Carbono

- **Épica relacionada:** EP-04 Experiencia y Carbono Cero
- **Prioridad:** Baja · **Story Points:** 3

**Redacción:**

> Como administrador logístico, quiero calcular el CO₂ total emitido y obtener un plan de compensación con proyectos locales de reforestación, para avanzar hacia la neutralidad de carbono en un horizonte de 3 años.

**Criterios de Aceptación (Gherkin):**

```gherkin
Escenario: Generación del plan de compensación
Dado que existen datos acumulados de emisiones de CO₂
Cuando el administrador solicita el plan de compensación
Entonces el sistema calcula las emisiones anuales y sugiere proyectos de reforestación con árboles equivalentes

Escenario: Emisiones anuales de 42 toneladas
Dado que las emisiones anuales equivalen a 42 toneladas de CO₂
Cuando el sistema genera el plan
Entonces sugiere participar en proyectos locales con aproximadamente 2,100 árboles necesarios

Escenario: Sin proyectos de reforestación configurados
Dado que no hay proyectos de reforestación configurados
Entonces el sistema muestra el cálculo de emisiones sin sugerencias de compensación
```

---

## 5. Historias Técnicas (Enablers)

### EN-001: Rendimiento del Motor de Optimización

- **RNF origen:** RNF-001 · **Épica relacionada:** EP-02 · **Story Points:** 5

**Redacción:**

> Como desarrollador del backend, quiero implementar la metaheurística con medición de latencia en el percentil 95, para garantizar rutas válidas en ≤ 45 segundos para 150 pedidos y 15 vehículos.

**Criterios de Aceptación (Gherkin):**

```gherkin
Escenario: Generación de rutas bajo carga máxima
Dado que existen 150 pedidos y 15 vehículos con ventanas de tiempo
Cuando el operador solicita la generación de rutas
Entonces el sistema retorna rutas válidas en ≤ 45 segundos (P95)

Escenario: Carga sostenida en operación normal
Dado que el sistema opera al 80 % de su capacidad
Cuando se procesan solicitudes concurrentes de optimización
Entonces la latencia media se mantiene dentro del SLA sin degradación
```

---

### EN-002: Rendimiento de Re-optimización

- **RNF origen:** RNF-002 · **Épica relacionada:** EP-02 · **Story Points:** 5

**Redacción:**

> Como desarrollador del backend, quiero implementar la re-optimización incremental de rutas afectadas, para responder a cambios repentinos en ≤ 30 segundos en horario punta.

**Criterios de Aceptación (Gherkin):**

```gherkin
Escenario: Re-optimización en horario punta
Dado que ocurre un evento de cambio (nuevo pedido, cancelación, accidente o avería) entre 7:00-9:00 AM o 5:00-8:00 PM
Cuando el sistema recalcula las rutas afectadas
Entonces la re-optimización finaliza en ≤ 30 segundos y notifica a los conductores

Escenario: Medición automatizada de latencia
Dado que el módulo de re-optimización está desplegado en staging
Cuando se ejecuta la suite de pruebas de rendimiento
Entonces el tiempo de respuesta se registra y se compara contra el SLA en el pipeline CI
```

---

### EN-003: Seguridad de la Plataforma

- **RNF origen:** RNF-003 · **Épica relacionada:** EP-01 (transversal) · **Story Points:** 5

**Redacción:**

> Como desarrollador del backend, quiero implementar autenticación JWT/OAuth2, control de acceso por roles (RBAC), protección contra OWASP Top 10 y registro de auditoría, para cumplir la Ley N.° 29733 y evitar accesos no autorizados.

**Criterios de Aceptación (Gherkin):**

```gherkin
Escenario: Bloqueo de petición maliciosa
Dado que un atacante externo intenta inyección SQL, XSS o CSRF
Cuando la petición alcanza la capa de autenticación
Entonces el sistema bloquea la petición, registra el evento de auditoría y notifica

Escenario: Acceso no autorizado a recursos protegidos
Dado que un usuario sin el rol requerido solicita un recurso protegido
Cuando la API valida su token
Entonces el sistema responde con error de autorización sin exponer datos
```

---

### EN-004: Alta Disponibilidad

- **RNF origen:** RNF-004 · **Épica relacionada:** EP-03 (transversal) · **Story Points:** 3

**Redacción:**

> Como ingeniero DevOps, quiero configurar el despliegue con balanceo de carga, respaldo automatizado y monitoreo, para asegurar una disponibilidad ≥ 99.5 % en horario operativo con RTO ≤ 30 s y RPO ≤ 5 s.

**Criterios de Aceptación (Gherkin):**

```gherkin
Escenario: Recuperación ante caída de una instancia
Dado que una instancia del backend falla en horario operativo (5:00 AM - 10:00 PM)
Cuando el balanceador detecta la falla
Entonces el tráfico se redirige en ≤ 30 segundos sin pérdida de datos mayor a 5 segundos

Escenario: Verificación de disponibilidad mensual
Dado que la plataforma acumula un mes de operación
Cuando se genera el informe de disponibilidad
Entonces el porcentaje de disponibilidad es ≥ 99.5 %
```

---

### EN-005: Escalabilidad de la Arquitectura

- **RNF origen:** RNF-005 · **Épica relacionada:** EP-02 (transversal) · **Story Points:** 3

**Redacción:**

> Como arquitecto de software, quiero diseñar la arquitectura (backend + base de datos) para soportar 1,000 pedidos diarios y 50 vehículos, para permitir la expansión a nuevos distritos sin degradación del SLA.

**Criterios de Aceptación (Gherkin):**

```gherkin
Escenario: Prueba de carga con volumen proyectado
Dado que se simulan 1,000 pedidos diarios y 50 vehículos
Cuando se ejecuta la prueba de carga
Entonces el sistema mantiene el SLA de rendimiento sin degradación

Escenario: Índices geográficos habilitados
Dado que la base de datos contiene coordenadas GPS de pedidos
Cuando se ejecuta una consulta de proximidad
Entonces el motor utiliza índices geoespaciales (PostGIS) con tiempos de respuesta estables
```

---

### EN-006: Accesibilidad WCAG 2.1 AA

- **RNF origen:** RNF-006 · **Épica relacionada:** EP-03 (transversal) · **Story Points:** 3

**Redacción:**

> Como desarrollador frontend, quiero aplicar contraste, navegación por teclado, etiquetas ARIA y textos alternativos en todas las vistas, para cumplir WCAG 2.1 nivel AA en navegadores web estándar y dispositivos móviles.

**Criterios de Aceptación (Gherkin):**

```gherkin
Escenario: Auditoría automática de accesibilidad
Dado que la interfaz se despliega en staging
Cuando se ejecuta la auditoría automática (axe/lighthouse)
Entonces no se reportan violaciones de nivel AA

Escenario: Navegación completa por teclado
Dado que un usuario interactúa solo con teclado
Cuando recorre las vistas principales del sistema
Entonces puede ejecutar todas las acciones sin usar el ratón
```

---

### EN-007: Usabilidad del Modo Conductor

- **RNF origen:** RNF-007 · **Épica relacionada:** EP-03 · **Story Points:** 3

**Redacción:**

> Como diseñador UI/UX, quiero diseñar el modo conductor con interacción simplificada (ruta asignada, entregas pendientes, alertas de tráfico), para que conductores con formación básica lo usen sin capacitación previa.

**Criterios de Aceptación (Gherkin):**

```gherkin
Escenario: Uso sin capacitación
Dado que un conductor con formación básica abre el modo conductor en su móvil
Cuando consulta su ruta asignada y sus entregas pendientes
Entonces comprende la interfaz sin ayuda externa

Escenario: Encuesta de satisfacción
Dado que el modo conductor se validó con conductores reales
Cuando se aplica la encuesta de satisfacción
Entonces el resultado es ≥ 4.0/5.0
```

---

### EN-008: Conectividad Limitada y Modo Offline

- **RNF origen:** RNF-008 · **Épica relacionada:** EP-03 · **Story Points:** 3

**Redacción:**

> Como desarrollador frontend, quiero implementar caché local de la ruta asignada y carga liviana de mapas, para que el modo conductor funcione con conexiones ≥ 50 kbps o sin conexión temporal.

**Criterios de Aceptación (Gherkin):**

```gherkin
Escenario: Funcionamiento con conexión 2G/3G
Dado que un conductor opera en zona con conexión ≥ 50 kbps
Cuando abre el modo conductor
Entonces la interfaz y los datos esenciales de la ruta cargan correctamente

Escenario: Modo offline con datos cacheados
Dado que el conductor pierde la conexión durante la ruta
Cuando consulta sus entregas pendientes
Entonces el sistema muestra los datos cacheados y sincroniza al recuperar conexión
```

---

### EN-009: Documentación Técnica y de API

- **RNF origen:** RNF-009 · **Épica relacionada:** EP-01 (transversal) · **Story Points:** 2

**Redacción:**

> Como desarrollador del backend, quiero mantener la documentación de la API con OpenAPI/Swagger y guías de uso, para asegurar que el equipo, el docente evaluador y los usuarios dispongan de información actualizada.

**Criterios de Aceptación (Gherkin):**

```gherkin
Escenario: Especificación OpenAPI actualizada
Dado que un endpoint de la API cambia de contrato
Cuando se despliega la nueva versión
Entonces la especificación OpenAPI/Swagger se genera y publica automáticamente

Escenario: Manuales disponibles en el repositorio
Dado que un usuario consulta la documentación del proyecto
Entonces encuentra el manual de usuario, el manual de administrador y el análisis del contexto logístico de Huancayo
```

---

## 6. Definition of Done (DoD) Global del Proyecto

Toda Historia de Usuario y Enabler se considera **"Done"** únicamente si cumple la totalidad de los siguientes criterios de calidad técnica:

1. **Cobertura de pruebas unitarias ≥ 80 %** sobre el código nuevo y modificado (medida con Jest/Jasmine en el pipeline CI).
2. **Análisis estático de código sin vulnerabilidades críticas** ni *code smells* bloqueantes (SonarQube / CodeQL integrado al pipeline).
3. **Revisión de código (Peer Review) aprobada** por al menos un par técnico mediante *Pull Request* en el repositorio Git.
4. **Despliegue automatizado ejecutable** en el ambiente de Staging / Pruebas (CI/CD con GitHub Actions).
5. **Documentación de API/código actualizada** (OpenAPI/Swagger y README de componentes).

Adicionalmente, para este proyecto:

6. **Criterios de Aceptación verificados** en sintaxis Gherkin y ejecutados (manual o automatizados) con resultado exitoso.
7. **Estándares transversales aplicados:** accesibilidad WCAG 2.1 AA y seguridad OWASP Top 10 en las vistas y endpoints afectados.
8. **Sin deuda técnica crítica:** los hallazgos bloqueantes de la revisión quedan registrados y resueltos en el mismo Sprint.

---

## 7. Estimación y Priorización del Backlog

Estimación realizada con **Puntos de Historia (Story Points)** mediante la secuencia de **Fibonacci (1, 2, 3, 5, 8, 13)** y priorización por **valor de negocio y riesgo técnico**.

### 7.1 Backlog priorizado

| # | Elemento | Épica | Prioridad | Story Points | Riesgo técnico |
| :---: | --- | --- | :---: | :---: | :---: |
| 1 | US-001 Gestión de Flota | EP-01 | Alta | 5 | Bajo |
| 2 | US-002 Gestión de Pedidos | EP-01 | Alta | 5 | Bajo |
| 3 | US-003 Gestión de Conductores | EP-01 | Media | 3 | Bajo |
| 4 | US-005 Generación de Rutas Optimizadas | EP-02 | Alta | 13 | Alto |
| 5 | EN-001 Rendimiento del Motor | EP-02 | Alta | 5 | Alto |
| 6 | EN-003 Seguridad de la Plataforma | EP-01 | Alta | 5 | Medio |
| 7 | US-007 Visualización en Mapa | EP-03 | Alta | 8 | Medio |
| 8 | US-006 Re-optimización Dinámica | EP-02 | Alta | 8 | Alto |
| 9 | EN-002 Rendimiento de Re-optimización | EP-02 | Alta | 5 | Alto |
| 10 | US-008 Dashboard de Indicadores | EP-03 | Alta | 5 | Bajo |
| 11 | EN-004 Alta Disponibilidad | EP-03 | Media | 3 | Medio |
| 12 | EN-005 Escalabilidad | EP-02 | Media | 3 | Medio |
| 13 | US-009 Reportes de Sostenibilidad | EP-03 | Media | 5 | Bajo |
| 14 | EN-006 Accesibilidad | EP-03 | Media | 3 | Bajo |
| 15 | EN-007 Usabilidad Modo Conductor | EP-03 | Media | 3 | Bajo |
| 16 | EN-008 Conectividad / Offline | EP-03 | Media | 3 | Bajo |
| 17 | US-004 Módulo de Clientes | EP-01 | Baja | 2 | Bajo |
| 18 | US-010 Compensación de Carbono | EP-04 | Baja | 3 | Bajo |
| 19 | EN-009 Documentación y API | EP-01 | Media | 2 | Bajo |

**Total del backlog:** 89 Story Points.

**Estado al cierre del Sprint 2 (2026-10-06):** los ítems **US-001, US-002, US-003, US-005 (gestión base), US-007, US-008, EN-003, EN-004 y EN-007/EN-008** acumulan **44 Story Points completados (Done)** sobre los 89 totales del backlog, todos verificados conforme al DoD global. El sistema cuenta con núcleo logístico, dashboard de indicadores, catálogo de rutas en tarjetas web/móvil, descarga de APK y despliegue en producción con SSL. El backlog restante para los siguientes sprints prioriza la re-optimización dinámica (US-006 / EN-002) y los reportes PDF de sostenibilidad (US-009).

### 7.2 Notas de priorización

- Los ítems 1-3 (EP-01) constituyen la base de datos maestra: sin flota, pedidos y conductores no es posible optimizar.
- El ítem 4 (US-005) es el de mayor riesgo técnico; se planifica temprano para dejar margen de ajuste de la metaheurística.
- Los Enablers de rendimiento (EN-001, EN-002) se ejecutan en paralelo a las US de optimización para validar los SLAs desde las primeras versiones.
- La versión MVP (`v1.0.0-MVP`) se compone de los ítems 1-11 más la EP-04 diferible a iteraciones posteriores si el alcance lo exige.

---

## 8. Historial de Control de Cambios

| Versión | Fecha | Descripción | Responsable |
| --- | --- | --- | --- |
| V_1_0_0 | 2026-09-07 | Creación inicial: transformación de RF/RNF a Épicas, US, Enablers y DoD (Fase 02: Planificación). | Equipo PIPRE |
| V_1_1_0 | 2026-09-29 | Sincronización con el cierre del Sprint 1: se registra el estado Done de US-001, US-002, US-003 y EN-003 (18 SP) y la priorización de US-005/EN-001 para el Sprint 2. | Equipo PIPRE |
| V_1_2_0 | 2026-10-06 | Sincronización con el cierre del Sprint 2: se registra el estado Done de US-008, US-007, US-005, EN-007/EN-008 y EN-004 (26 SP adicionales, 44 SP acumulados) y despliegue en producción. | Equipo PIPRE |

---

## 9. Referencia

- **Consigna Fase 02:** `docs/a.html` — Consigna: Planificación del Proyecto.
- **Documentos de Fase 01:** DOC-006 (Requisitos Funcionales), DOC-007 (Requisitos No Funcionales), DOC-002 (Acta de Constitución).
- **Marco de referencia:** CMMI-DEV (REQM, RD), PMBOK 7.ª Edición, Scrum Guide 2020.
