CONSIGNA DE PROYECTO

“EcoLogística Lima" - Optimizador de Rutas Sostenibles para "DistriRápido S.A.C."
1. Contexto del Proyecto
La empresa ficticia "DistriRápido S.A.C." es un operador logístico con sede en el distrito de San Juan de
Lurigancho, Lima, una de las zonas con mayor densidad poblacional, congestión vehicular y actividad
comercial de la capital. La empresa realiza más de 250 entregas diarias en los distritos de San Juan de
Lurigancho, El Agustino, Santa Anita y Ate, atendiendo a pequeños comerciantes, bodegas y
mercados locales.
La empresa enfrenta los siguientes desafíos operativos:
a. Alta congestión vehicular: Especialmente en la Av. Próceres de la Independencia y la Av. Fernando
Belaúnde Terry en horas punta.
b. Altos costos operativos: El combustible y el mantenimiento de la flota representan el 35% de los
costos totales.
c. Impacto ambiental: La flota de 15 camionetas (mayormente diésel) genera aproximadamente 3.5
toneladas de CO2 mensuales.
d. Incumplimiento de ventanas de tiempo: El 22% de las entregas se realizan fuera del horario
acordado, generando penalidades y pérdida de clientes.
El proyecto "EcoLogística Lima" tiene como objetivo diseñar, desarrollar e implementar una plataforma
web moderna que optimice las rutas de reparto de última milla, aplicando metaheurísticas (Algoritmos
Genéticos, Búsqueda Tabú u Optimización por Colonia de Hormigas) para resolver el Problema de
Ruteo de Vehículos con Ventanas de Tiempo (VRPTW) y consideraciones ambientales (Green VRP).
2. Objetivo general
Desarrollar una plataforma web funcional que:
a. Permita la gestión de pedidos, flota de vehículos y conductores.
b. Calcule rutas optimizadas que minimicen la distancia recorrida, el consumo de combustible, las
emisiones de CO2 y las penalizaciones por incumplimiento de ventanas de tiempo.
c. Visualice las rutas generadas en un mapa interactivo.
d. Muestre un dashboard con indicadores clave de sostenibilidad (CO2 ahorrado, ahorro económico,
equivalentes ambientales).
Genere reportes descargables que evidencien el impacto ambiental y económico.
3. Requerimientos del proyecto
Los estudiantes deben completar y ampliar los siguientes requerimientos, adaptándolos a la realidad
geográfica y operativa de Lima Metropolitana.
a. Requerimientos Funcionales (RF) - Mínimos a Desarrollar
Código Descripción Condiciones Locales a Considerar
RF-01 Gestión de Flota: Registrar vehículos con: placa, tipo
(camioneta, furgón, moto), capacidad de carga (kg),
consumo de combustible (km/L), factor de emisión de
CO2 (kg CO2/km) y año de fabricación.

Considerar que en Lima circulan
vehículos de más de 15 años con alto
factor de emisión. Incluir restricciones
del Sistema de Control de Emisiones
(ej. vehículos diésel con restricción en
el Centro Histórico).

RF-02 Gestión de Pedidos: Registrar pedidos con: ID de
cliente, dirección de entrega, coordenadas GPS,
peso (kg), volumen (m3), ventana de tiempo de
entrega (hora inicio-fin), prioridad (express, estándar,
económico) y tipo de producto (perecedero, no
perecedero).

Considerar que en San Juan de
Lurigancho muchas direcciones no
tienen nomenclatura estándar (ej.
"Altura de la cuadra 20, Mz. C, Lote
5"). Incluir la posibilidad de usar puntos

Código Descripción Condiciones Locales a Considerar
de referencia (ej. "frente a la bodega
'El Ahorro'").

RF-03 Generación de Rutas Optimizadas: Implementar una
metaheurística (GA, SA, ACO o Tabú) que calcule
rutas óptimas considerando: distancia total, tiempo
total, consumo de combustible, emisiones de CO2,
penalizaciones por entregas tardías, y descanso
obligatorio de conductores (Ley de Tránsito del Perú).

Incorporar restricciones de restricción
vehicular (Decreto Supremo N° 033-
2012-MTC) según el último dígito de la
placa. Incorporar datos de tráfico en
tiempo real (API de Waze o Google
Maps) para los tramos más
congestionados (Av. Próceres, Av.
Fernando Belaúnde, Panamericana
Norte).

RF-04 Visualización de Rutas en Mapa: Mostrar las rutas
optimizadas en un mapa interactivo
(Leaflet/OpenStreetMap o Google Maps API) con:
trazado de ruta, puntos de entrega, tiempo estimado
por tramo, y nivel de congestión del tráfico
(verde/amarillo/rojo).

Utilizar un mapa base que incluya los
límites distritales de Lima. Señalar
zonas con alta incidencia de robos
(ej. Ciudades Satélite de Santa Anita)
para que el sistema sugiera rutas
alternas más seguras.

RF-05 Dashboard de Indicadores: Mostrar métricas en
tiempo real: distancia recorrida total (km), emisiones
de CO2 (kg), combustible ahorrado (L), cumplimiento
de ventanas de tiempo (%), ahorro comparado con
ruta secuencial (%), y equivalente ambiental (ej. "Este
ahorro equivale a plantar XX árboles en el Parque
Zonal Huáscar").

Los indicadores deben expresarse en
un lenguaje accesible para los
conductores y administrativos (ej. "Has
ahorrado S/ XX en combustible hoy").

RF-06 Reportes de Sostenibilidad: Generar reportes
descargables (PDF) con: resumen de emisiones de
CO2 por ruta, costo del ciclo de vida de la flota
(combustible + mantenimiento + depreciación +
seguros), ahorro en créditos de carbono y
cumplimiento de metas de cero carbono neto.

Incluir información sobre el costo del
combustible en Lima (S/ 17.50 por
galón de diésel al 2026) y el costo de
mantenimiento promedio (S/ 1.20 por
km recorrido).

RF-07 Re-optimización Dinámica: Permitir re-calcular rutas
ante: nuevos pedidos, cancelaciones, accidentes de
tránsito, o averías de vehículos.

Incorporar datos del Sistema de
Gestión de Tránsito de Lima (SIMAT) o
del aplicativo Waze CCP para
conocer incidentes en tiempo real.

RF-08 Gestión de Conductores: Registrar conductores con:
nombre, DNI, licencia de conducir (categoría), años
de experiencia, disponibilidad horaria y número de
contacto.

Incorporar restricciones de la Ley N°
30224 (Ley de Tránsito) que establece
jornadas máximas de 8 horas y
descansos obligatorios. Considerar
que muchos conductores viven en
distritos alejados (ej. Villa El Salvador),
por lo que la asignación de rutas
debe considerar su punto de partida.

RF-09 Módulo de Clientes: Permitir a los clientes registrar sus
preferencias de entrega (horarios preferidos, puntos
de referencia, restricciones de acceso).

Considerar que en Lima muchos
clientes son bodegas que abren
desde las 6:00 AM hasta las 9:00 PM,
con horarios de atención variables.

RF-10 Plan de Compensación de Carbono: El sistema debe
calcular el CO2 total emitido y proponer un plan de
compensación, sugiriendo alianzas con proyectos
locales de reforestación (ej. Lomas de Lima o Parque
Zonal Huáscar).

Incluir información sobre proyectos de
reforestación en Lima Metropolitana
(ej. Programa "Árboles para Lima" de
la Municipalidad) y calcular cuántos
árboles se necesitan plantar para
compensar las emisiones anuales.

b. Requerimientos No Funcionales (RNF) - Mínimos a Desarrollar
Código Descripción Condiciones Locales a Considerar
RNF-01 Rendimiento: El algoritmo de optimización debe
generar una solución válida en un tiempo
máximo de 45 segundos para un problema de
hasta 150 pedidos y 15 vehículos.

Considerar que en Lima el tráfico cambia
drásticamente en horas punta (7:00-9:00
AM y 5:00-8:00 PM), por lo que el sistema
debe poder re-optimizar rápidamente
(menos de 30 segundos) ante cambios
repentinos.

Código Descripción Condiciones Locales a Considerar
RNF-02 Seguridad: Implementar las medidas de
seguridad del estándar OWASP Top 10 (inyección
SQL, XSS, CSRF, autenticación robusta).

Cumplir con la Ley N° 29733 (Ley de
Protección de Datos Personales del Perú)
para el manejo de datos de clientes y
conductores.

RNF-03 Accesibilidad: Cumplir con las directrices WCAG
2.1 nivel AA.

Considerar que algunos conductores y
clientes pueden tener limitaciones en el
uso de tecnología (ej. no saben usar
mapas digitales). La interfaz debe ser
intuitiva, con iconos grandes y colores de
alto contraste.

RNF-04 Escalabilidad: Arquitectura escalable
horizontalmente para manejar hasta 1,000
pedidos diarios y 50 vehículos.

Considerar el crecimiento proyectado de
la empresa (expansión a distritos como Los
Olivos, Comas e Independencia).

RNF-05 Usabilidad: La interfaz debe ser de fácil uso para
conductores con niveles básicos de educación
formal.

El dashboard debe tener una versión
simplificada para conductores (ej. "modo
conductor") que solo muestre la ruta
asignada, las entregas pendientes y las
alertas de tráfico.

RNF-06 Disponibilidad: 99.5% de disponibilidad en horario
operativo (5:00 AM - 10:00 PM).

Considerar que en Lima hay frecuentes
cortes de electricidad en algunas zonas
(ej. San Juan de Lurigancho). El sistema
debe tener un plan de contingencia (ej.
respaldo local en dispositivos móviles).

RNF-07 Documentación: Documentar el proceso de
desarrollo, la arquitectura del sistema, el manual
de usuario, el manual de administrador y la API.

La documentación debe incluir un análisis
del contexto logístico de Lima
(características de las vías, horas punta,
normativa de tránsito).

c. Restricciones del Proyecto
Los estudiantes deben completar y ampliar las siguientes restricciones, adaptándolas a la realidad
geográfica, económica, social y ambiental de Lima Metropolitana.
Código Descripción Condiciones Locales a Considerar
RES-01 Costo del Ciclo de Vida: Optimizar el TCO de la
flota, incluyendo: adquisición, combustible (S/
17.50/galón diésel), mantenimiento (S/ 1.20/km),
seguros (SOAT + Seguro Vehicular), depreciación
(20% anual) y costos de operación (sueldos de
conductores S/ 1,500 mensuales).

Considerar que el Gas Natural Vehicular
(GNV) es una alternativa más económica
(S/ 12.50 por metro cúbico) pero implica
conversión de vehículos (costo de S/ 5,000
por vehículo). Evaluar el ROI de migrar a
GNV en un plazo de 3 años.

RES-02 Cero Carbono Neto: Establecer un plan para que
la operación sea carbono neutral en un plazo de
3 años, mediante: optimización de rutas,
migración a vehículos eléctricos o GNV, y
compensación de carbono con proyectos de
reforestación en Lima.

Investigar proyectos locales de
reforestación como "Lomas de Lima"
(lomas de Lachay, lomas de Villa María) o
el programa "Árboles para Lima" de la
Municipalidad Metropolitana. Calcular
cuántos árboles se necesitan plantar por
tonelada de CO2 emitida.

RES-03 Restricciones Ambientales: Evitar rutas que
atraviesen áreas de reserva ecológica (ej.
Pantanos de Villa, Lomas de Lachay) y minimizar
el impacto acústico en zonas residenciales.

Incorporar un mapa de zonas sensibles (ej.
colegios, hospitales, parques zonales)
donde la circulación de vehículos debe
ser restringida en ciertos horarios.

RES-04 Restricciones Sociales: Respetar los horarios de
descanso de los conductores (8 horas máximas
de conducción continua, descanso de 1 hora por
cada 4 horas) y las normativas de tránsito de la
Municipalidad de Lima.

Incorporar la restricción vehicular según el
Decreto Supremo N° 033-2012-MTC
(vehículos no pueden circular en ciertos
días según el último dígito de la placa) y
las restricciones en el Centro Histórico de
Lima.
RES-05 Restricciones Económicas: El presupuesto inicial
de desarrollo es de S/ 500,000 (aproximadamente
USD 135,000) para el MVP, con un costo operativo
anual de S/ 120,000 para mantenimiento y
soporte.

Considerar que el costo de desarrollo en
Perú puede ser más bajo que en otros
países (tarifas de desarrolladores: S/ 25-
50/hora), pero la infraestructura de
servidores en la nube (AWS, Azure, Google

Código Descripción Condiciones Locales a Considerar
Cloud) tiene costos en dólares (ej. USD
500/mes por servidores).

RES-06 Restricciones Tecnológicas: Tecnologías de
código abierto: Python (FastAPI/Django) para
backend, React.js o Vue.js para frontend,
PostgreSQL para base de datos,
Leaflet/OpenStreetMap para mapas (o Google
Maps API con costo).

Considerar que en Perú el acceso a
internet es limitado en algunas zonas (ej.
San Juan de Lurigancho tiene cobertura
de fibra óptica limitada). El sistema debe
ser responsive y funcionar con conexiones
de baja velocidad (2G/3G).

RES-07 Restricciones Culturales: La interfaz debe estar en
español peruano (ej. usar "jato" para casa,
"chamba" para trabajo, "vamos a la ruta" para
iniciar el recorrido) y debe considerar que los
conductores pueden tener educación primaria o
secundaria incompleta.

El sistema debe usar iconos universales (ej.
sobre para entrega, camión para
vehículo, semáforo para tráfico) y colores
de advertencia (rojo para urgencia, verde
para completado).

RES-08 Restricciones Normativas: Cumplir con la Ley N°
29733 (Protección de Datos Personales), la Ley N°
30224 (Ley de Tránsito) y las normas del Ministerio
de Transportes y Comunicaciones (MTC) para la
operación de vehículos de carga.

Asegurar que el sistema no almacene
datos sensibles de conductores (ej. historial
médico) sin su consentimiento.
Implementar un sistema de autorización
para que los conductores accedan solo a
la información necesaria para su ruta.

RES-09 Restricciones de Datos: El sistema debe trabajar
con datos georreferenciados de Lima
(coordenadas GPS, direcciones, puntos de
referencia) y datos de tráfico en tiempo real.

Considerar que los datos de Waze y
Google Maps en Lima tienen una precisión
variable (ej. zonas sin cobertura de tráfico
en tiempo real). El sistema debe permitir la
carga manual de datos de tráfico (ej.
reportes de conductores).

RES-10 Restricciones de Seguridad Vial: Las rutas deben
priorizar vías seguras, evitando zonas con alta
incidencia de robos (ej. Ciudades Satélite de
Santa Anita, Cerros de San Juan de Lurigancho) y
zonas de alto riesgo de accidentes (ej. Curva del
Diablo en la Panamericana Norte).

Incorporar datos de la Policía Nacional del
Perú sobre zonas de alto riesgo y permitir
que los conductores reporten incidentes
de seguridad en tiempo real.

RES-11 Restricciones Climáticas: Lima tiene un clima
desértico con alta humedad y neblina en invierno
(junio-setiembre), lo que reduce la visibilidad y
afecta la conducción.

El sistema debe considerar que en invierno
la visibilidad es baja en horas de la
mañana (6:00-8:00 AM), por lo que debe
sugerir rutas con mejor iluminación y evitar
zonas de alta neblina.

RES-12 Restricciones de Infraestructura: Lima tiene una
infraestructura vial limitada, con calles no
pavimentadas en zonas periféricas (ej. Cerros de
San Juan de Lurigancho, Laderas de Villa El
Salvador).

El sistema debe permitir clasificar las vías
(pavimentada, no pavimentada) y evitar
que vehículos pesados circulen por calles
de tierra (riesgo de atascos y daños a la
flota).

d. Estándares y normas a aplicar
Los estudiantes deben aplicar los siguientes estándares y normas en el desarrollo del proyecto,
justificando su implementación en el contexto de Lima.
Estándar/Norma Aplicación en el Proyecto Justificación Local
W3C Validación del código HTML, CSS y

JavaScript.

Garantizar la interoperabilidad en
diferentes navegadores, considerando
que en Lima muchos usuarios usan
versiones antiguas de navegadores en
dispositivos de bajo costo.

ISO/IEC 25010 Evaluar la calidad del software en 8
características: adecuación funcional,
eficiencia, compatibilidad, usabilidad,
fiabilidad, seguridad, mantenibilidad y
portabilidad.

Asegurar que el sistema sea robusto y
confiable en un entorno operativo con
conexiones de internet inestables.

OWASP Top 10 Mitigar las vulnerabilidades web más
críticas (inyección SQL, XSS, CSRF, etc.).

Proteger los datos de clientes y
conductores, cumpliendo con la Ley de

Protección de Datos Personales del Perú
(Ley N° 29733).

Green Software Diseñar un sistema energéticamente
eficiente (optimización de consultas SQL,
reducción de transferencia de datos, uso
de servidores de bajo consumo).

Reducir la huella de carbono del propio
sistema, alineado con los objetivos de
sostenibilidad del proyecto.

WCAG 2.1 Asegurar la accesibilidad para personas

con discapacidad.

Considerar que algunos conductores
pueden tener discapacidades visuales o
motrices, y que la interfaz debe ser usable
para todos.

ISO 14083 Medición y reporte de la huella de

carbono de la logística.

Calcular el CO2 de la flota y establecer
metas de reducción alineadas con los
compromisos climáticos del Perú (ej.
Contribuciones Determinadas a Nivel
Nacional - NDC).

4. Entregables
Los estudiantes deben entregar los siguientes productos como parte del proyecto:
a. Documento de Análisis de Requerimientos: Incluyendo todos los requerimientos funcionales y no
funcionales completos, las restricciones adaptadas a Lima y el análisis de factibilidad.
b. Diseño de la Solución: Arquitectura del sistema, diagramas UML (casos de uso, clases, secuencia),
diseño de la base de datos y diseño de la interfaz de usuario (mockups en Figma o similar).
c. Implementación del MVP: Desarrollo de un prototipo funcional con al menos el 70% de los
requerimientos funcionales (RF-01 al RF-07) y el cumplimiento de los estándares de calidad.
d. Documentación Técnica: Manual de usuario, manual de administrador, documentación de la API
(Swagger/OpenAPI) y documentación del código.
e. Pruebas: Plan de pruebas, casos de prueba, resultados de pruebas de aceptación y pruebas de
rendimiento (tiempo de respuesta del algoritmo).
f. Presentación Final: Exposición del proyecto ante el docente y los compañeros, demostrando el
funcionamiento del sistema y justificando las decisiones de diseño en el contexto de Lima.
5. Cronograma Sugerido (Adaptativo)
El proyecto se desarrolla en 4 iteraciones (semanas 1-14), con entregables al final de cada iteración:
Iteración Semanas Entregables
Iteración 1 1-3 Análisis de requerimientos, investigación de campo en Lima (entrevistas a
conductores, recopilación de datos de tráfico), diseño de la base de datos y
mockups de interfaz.

Iteración 2 4-7 Implementación de la gestión de flota, gestión de pedidos y generación de
rutas con una metaheurística básica (Algoritmo Genético simple). Pruebas
de rendimiento iniciales.

Iteración 3 8-11 Implementación de la visualización de rutas en mapa, dashboard de
indicadores y reportes de sostenibilidad. Integración con API de tráfico
(Waze/Google Maps).

Iteración 4 12-14 Optimización del algoritmo (metaheurística avanzada), re-optimización
dinámica, pruebas de aceptación, documentación final y preparación de la
presentación.

6. Recursos Sugeridos
a. Datos de Tráfico: API de Waze (Waze CCP), Google Maps API, datos del MTC.
b. Datos Geográficos: OpenStreetMap, datos del Instituto Geográfico Nacional (IGN) del Perú.
c. Normativa: Decreto Supremo N° 033-2012-MTC (restricción vehicular), Ley N° 29733 (protección
de datos), Ley N° 30224 (Ley de Tránsito).

d. Proyectos de Reforestación: Programa "Árboles para Lima" (Municipalidad de Lima), Lomas de
Lachay, Pantanos de Villa.
e. Metaheurísticas: Bibliografía sobre Algoritmos Genéticos, Búsqueda Tabú, Optimización por
Colonia de Hormigas y Enfriamiento Simulado aplicados a Green VRP.:
