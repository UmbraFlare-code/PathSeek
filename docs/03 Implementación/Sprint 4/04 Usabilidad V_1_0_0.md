[← Volver al README principal](../../../README.md)

# Evaluación Cuantitativa de Usabilidad del Sistema (Escala SUS)

**Proyecto:** PathSeek — Optimizador de Rutas Sostenibles para UGEL Huancayo  
**Versión del Documento:** V_1_1_0\
**Fecha de Evaluación:** 2026-11-15  
**Entorno declarado en el levantamiento:** plataforma de producción\
**Responsable Técnico:** Francis Maxuel Urquizo Ore y Equipo PIPRE

---

## 1. Ficha Técnica de la Evaluación

El informe registra una evaluación de usabilidad percibida con el cuestionario **System Usability Scale (SUS)** de John Brooke. La matriz permite reproducir el resultado de la muestra.

| Parámetro | Detalle Metodológico |
| :--- | :--- |
| **Instrumento Aplicado** | System Usability Scale (SUS) — 10 ítems estandarizados con balance positivo/negativo. |
| **Escala de Valoración** | Tipo Likert de 5 puntos: <br>1 = Totalmente en desacuerdo &nbsp;|&nbsp; 2 = En desacuerdo &nbsp;|&nbsp; 3 = Neutral &nbsp;|&nbsp; 4 = De acuerdo &nbsp;|&nbsp; 5 = Totalmente de acuerdo |
| **Tamaño de la Muestra ($n$)** | **$n = 6$ participantes** de distintos perfiles. |
| **Perfiles de la Muestra** | • 2 Operadores Logísticos de UGEL Huancayo (planificación de despachos y asignación vehicular).<br>• 2 Conductores de Distribución Institucional (operación en ruta y modo móvil offline).<br>• 1 Administrador de Sistemas / TI (gestión de cuentas, roles y auditoría).<br>• 1 Supervisor Académico / Evaluador de Proyectos de Software. |
| **Condiciones del Test** | Entorno real de producción sobre dispositivos heterogéneos (navegador de escritorio Chrome en estación de trabajo y smartphone Android de 6.5" para conductores). |

### Tareas Previamente Asignadas a los Evaluadores
Antes de responder el cuestionario SUS, cada participante completó de forma autónoma una batería de tareas representativas del flujo diario:
1. **Tarea T1 (Autenticación y Navegación Base):** Iniciar sesión con sus credenciales asignadas y explorar el dashboard resumen de UGEL Huancayo.
2. **Tarea T2 (Gestión de Pedidos y Filtros):** Consultar la lista de pedidos pendientes, aplicar filtros por tipo de material educativo y verificar la dirección de destino.
3. **Tarea T3 (Generación y Visualización de Rutas):** Ejecutar la solicitud de optimización de rutas y examinar en el mapa interactivo el trazado por calles generado mediante OSRM.
4. **Tarea T4 (Modo Conductor y Hoja de Ruta):** Acceder a la vista simplificada de paradas, registrar una entrega completada y comprobar el estado de sincronización.
5. **Tarea T5 (Sostenibilidad y Reportes):** Consultar los indicadores de ahorro de CO₂ y generar la descarga del reporte oficial en PDF.

---

## 2. Los 10 Ítems Estandarizados del Instrumento SUS

El cuestionario alternó afirmaciones con formulación positiva (ítems impares) y negativa (ítems pares) para evitar sesgos de aquiescencia:

- **Ítem 1 (Positivo):** Creo que me gustaría utilizar este sistema con frecuencia.
- **Ítem 2 (Negativo):** Encontré el sistema innecesariamente complejo.
- **Ítem 3 (Positivo):** Pensé que el sistema era fácil de usar.
- **Ítem 4 (Negativo):** Creo que necesitaría el apoyo de una persona técnica para poder utilizar este sistema.
- **Ítem 5 (Positivo):** Encontré que las diversas funciones en este sistema estaban bien integradas.
- **Ítem 6 (Negativo):** Pensé que había demasiada inconsistencia en este sistema.
- **Ítem 7 (Positivo):** Imaginaría que la mayoría de las personas aprenderían a usar este sistema muy rápidamente.
- **Ítem 8 (Negativo):** Encontré el sistema muy engorroso de usar.
- **Ítem 9 (Positivo):** Me sentí muy seguro utilizando el sistema.
- **Ítem 10 (Negativo):** Necesité aprender muchas cosas antes de poder empezar a usar este sistema.

---

## 3. Resultados Cuantitativos

### 3.1 Matriz de Respuestas Brutas (Escala Likert 1–5)

A continuación se presentan las respuestas individuales registradas para cada uno de los 6 participantes:

| Participante | Perfil del Usuario | Q1 | Q2 | Q3 | Q4 | Q5 | Q6 | Q7 | Q8 | Q9 | Q10 |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **P1** | Operador Logístico Principal (UGEL) | 5 | 2 | 5 | 1 | 4 | 2 | 5 | 1 | 5 | 2 |
| **P2** | Operador Logístico Asistente (UGEL) | 4 | 2 | 4 | 2 | 4 | 2 | 4 | 2 | 4 | 2 |
| **P3** | Conductor 1 (Rutas Urbanas Huancayo) | 5 | 2 | 4 | 2 | 5 | 1 | 4 | 2 | 5 | 2 |
| **P4** | Conductor 2 (Rutas Rurales y Valle) | 4 | 2 | 4 | 3 | 4 | 2 | 4 | 2 | 4 | 2 |
| **P5** | Administrador de TI / Infraestructura | 5 | 1 | 5 | 1 | 5 | 1 | 5 | 1 | 4 | 2 |
| **P6** | Supervisor / Evaluador Académico | 4 | 2 | 4 | 2 | 4 | 2 | 4 | 2 | 4 | 3 |

---

### 3.2 Cálculo Matemático Paso a Paso

De acuerdo con el algoritmo formal de John Brooke:
1. Para cada **ítem impar** ($i \in \{1, 3, 5, 7, 9\}$), la puntuación de contribución es:
   $$C_i = R_i - 1$$
2. Para cada **ítem par** ($i \in \{2, 4, 6, 8, 10\}$), la puntuación de contribución es:
   $$C_i = 5 - R_i$$
3. La puntuación total del participante $k$ se obtiene multiplicando la suma de sus contribuciones por 2.5:
   $$\text{Puntaje SUS}_k = \left( \sum_{i=1}^{10} C_i \right) \times 2.5$$

#### Desarrollo Individual:

- **Participante P1:**
  - Impares ($R - 1$): $(5-1) + (5-1) + (4-1) + (5-1) + (5-1) = 4 + 4 + 3 + 4 + 4 = 19$
  - Pares ($5 - R$): $(5-2) + (5-1) + (5-2) + (5-1) + (5-2) = 3 + 4 + 3 + 4 + 3 = 17$
  - Suma = $19 + 17 = 36$
  - $\text{SUS}_{\text{P1}} = 36 \times 2.5 = \mathbf{90.0}$

- **Participante P2:**
  - Impares: $(4-1) + (4-1) + (4-1) + (4-1) + (4-1) = 3 + 3 + 3 + 3 + 3 = 15$
  - Pares: $(5-2) + (5-2) + (5-2) + (5-2) + (5-2) = 3 + 3 + 3 + 3 + 3 = 15$
  - Suma = $15 + 15 = 30$
  - $\text{SUS}_{\text{P2}} = 30 \times 2.5 = \mathbf{75.0}$

- **Participante P3:**
  - Impares: $(5-1) + (4-1) + (5-1) + (4-1) + (5-1) = 4 + 3 + 4 + 3 + 4 = 18$
  - Pares: $(5-2) + (5-2) + (5-1) + (5-2) + (5-2) = 3 + 3 + 4 + 3 + 3 = 16$
  - Suma = $18 + 16 = 34$
  - $\text{SUS}_{\text{P3}} = 34 \times 2.5 = \mathbf{85.0}$

- **Participante P4:**
  - Impares: $(4-1) + (4-1) + (4-1) + (4-1) + (4-1) = 3 + 3 + 3 + 3 + 3 = 15$
  - Pares: $(5-2) + (5-3) + (5-2) + (5-2) + (5-2) = 3 + 2 + 3 + 3 + 3 = 14$
  - Suma = $15 + 14 = 29$
  - $\text{SUS}_{\text{P4}} = 29 \times 2.5 = \mathbf{72.5}$

- **Participante P5:**
  - Impares: $(5-1) + (5-1) + (5-1) + (5-1) + (4-1) = 4 + 4 + 4 + 4 + 3 = 19$
  - Pares: $(5-1) + (5-1) + (5-1) + (5-1) + (5-2) = 4 + 4 + 4 + 4 + 3 = 19$
  - Suma = $19 + 19 = 38$
  - $\text{SUS}_{\text{P5}} = 38 \times 2.5 = \mathbf{95.0}$

- **Participante P6:**
  - Impares: $(4-1) + (4-1) + (4-1) + (4-1) + (4-1) = 3 + 3 + 3 + 3 + 3 = 15$
  - Pares: $(5-2) + (5-2) + (5-2) + (5-2) + (5-3) = 3 + 3 + 3 + 3 + 2 = 14$
  - Suma = $15 + 14 = 29$
  - $\text{SUS}_{\text{P6}} = 29 \times 2.5 = \mathbf{72.5}$

---

### 3.3 Cálculo del Puntaje Promedio Global

$$\bar{X}_{\text{SUS}} = \frac{90.0 + 75.0 + 85.0 + 72.5 + 95.0 + 72.5}{6} = \frac{490.0}{6} = \mathbf{81.67}$$

**Puntaje SUS Promedio Global de PathSeek:** **81.67 / 100 puntos**.

---

## 4. Análisis e Interpretación de Resultados

### 4.1 Comparación frente al Estándar de la Industria
- **Umbral de Aceptabilidad Básica:** La literatura científica (Sauro, 2011; Bangor et al., 2008) establece una media histórica de **68 puntos** como línea base de usabilidad aceptable para aplicaciones de software.
- **Resultado Obtenido:** Con **81.67 puntos**, PathSeek supera el promedio de la industria en **+13.67 puntos**, ubicándose en una zona de alta fidelidad y satisfacción de usuario.

```text
 0            50           68           80.3         81.67       100
 |-------------|------------|-------------|------------|----------|
 [Inaceptable]     [Marginal]       [Aceptable]    [Excelente] (PathSeek)
```

### 4.2 Alcance del resultado

El promedio se obtuvo en una muestra de seis participantes. Dos tenían perfil de conductor. Para verificar EN-007, falta documentar la prueba del APK con conductores, la ejecución de tareas sin ayuda y la satisfacción específica de **≥ 4/5**.
---

## 5. Observaciones de interfaz y mejoras reportadas

El levantamiento original registró estos puntos de fricción. La prueba de campo debe confirmar su estado en el APK que se entregue.

| Cuello de Botella Detectado | Impacto en la Tarea | Acción de Mejora Reportada en Flutter | Estado reportado |
| :--- | :--- | :--- | :---: |
| **Contraste de marcadores en el mapa bajo luz solar:** El conductor rural (P4) reportó dificultad para distinguir paradas completadas frente a pendientes. | Confusión en la secuencia de entrega durante el recorrido. | Se rediseñaron los pines de `interactive_route_map.dart` incorporando bordes gruesos de alto contraste (#1B5E20 para entregados, #C62828 para pendientes) con iconos vectoriales explícitos. | **Resuelto** |
| **Tiempo de respuesta en reoptimización:** El operador secundario (P2) consultó si el sistema se había congelado durante el cálculo de rutas de 150 pedidos. | Incertidumbre operativa durante los 25 segundos de cómputo. | Se integró una barra de progreso indeterminada con animación de estado y mensaje explicativo del progreso del algoritmo genético / simulated annealing. | **Resuelto** |
| **Feedback de guardado offline:** El conductor urbano (P3) no estaba seguro de si la firma del receptor se guardó al no tener señal en el sótano de una escuela. | Reintento innecesario de envío. | Se añadió un banner persistente (*Offline Banner*) y un indicador visual tipo "chip" verde que indica *"1 entrega encolada para sincronización automática"*. | **Resuelto** |
| **Densidad de datos en tabla de pedidos:** La vista inicial saturaba visualmente en pantallas portátiles estándar. | Sobrecarga cognitiva en operadores logísticos. | Se implementó el patrón maestro-detalle con acordeones colapsables y tarjetas simplificadas de pedidos diseñadas con la skill `frontend-uiux`. | **Resuelto** |

---

## 6. Conclusión de Usabilidad

Las seis respuestas registradas dan un promedio SUS de **81,67/100**. El resultado resume la usabilidad percibida en esta muestra. La aceptación de EN-007 requiere la evidencia de la prueba de campo del APK y su encuesta específica.

Para realizar esa validación, registrar la versión del APK, dispositivo y fecha. Cada conductor debe consultar su ruta asignada y sus entregas pendientes sin ayuda, registrar una entrega de prueba y responder la encuesta de satisfacción de 1 a 5. Conservar las respuestas anonimizadas y calcular el promedio de los conductores para contrastarlo con **≥ 4/5**.

---

[← Volver al README principal](../../../README.md)
