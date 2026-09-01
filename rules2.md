# Rules part 2
1. Directrices Generales y Estándar de Trabajo
En el marco del Proyecto Final de Asignatura (PFA), esta consigna formaliza las especificaciones técnicas para la elaboración de los 9 documentos de arquitectura, ingeniería de requisitos e impacto multidimensional del sistema.

📋 Normas Generales de Entrega
Formato Estricto: Markdown (.md) nativo, estructurado con encabezados (#, ##, ###), tablas, diagramas en bloques de código mermaid y fragmentos sql.
Nomenclatura y Versionamiento: Los archivos deberán guardarse exactamente con el nombre especificado en la ruta /docs/01 Inicio/. La versión inicial de todo documento debe ser V_1_0_0.md. Cualquier modificación sustancial posterior exigirá el incremento semántico del archivo (ej. V_1_1_0.md para cambios menores, V_2_0_0.md para revisiones estructurales), preservando el archivo previo en el historial de versiones Git.
Calidad de Requisitos: Ningún requisito funcional puede contener términos ambiguos ("fácil", "eficiente", "adecuado") ni especificaciones de diseño técnico prematuro en su descripción atómica.
2. Estructura Completa de los 9 Entregables
Documento 01: Requisitos Funcionales y Elicitación Holística
📁 Nombre de archivo: docs/01 Inicio/06. Requisitos funcionales V_1_0_0.md

Contenido Exigido:

Marco de Elicitación Holística y Ética: Explicación detallada del proceso de recolección de necesidades considerando grupos de usuarios diversos, contexto local (glocal) y perspectiva ética.
Especificación Atómica de Requisitos Funcionales: Catálogo estructurado donde cada requisito responde strictly al QUÉ realiza el sistema.
### Estructura de Ficha por Requisito Funcional:
### RF-[00X]: [Nombre del Requisito]

- **Descripción Atómica:** El sistema debe [Acción concreta e inconfundible] cuando [Detonante/Condición].

- **Prioridad:** [Alta / Media / Baja]

- **Criterios de Aceptación (Gherkin / BDD):**

#### Ruta Gold (Camino Ideal Principal)

DADO [Contexto previo válido y usuario autenticado con permisos]

CUANDO [El usuario realiza la acción principal con datos válidos]

ENTONCES [El sistema procesa y confirma la transacción correctamente]

#### Ruta Feliz (Flujos Alternativos Válidos)

DADO [Contexto alternativo válido]

CUANDO [El usuario opta por una vía secundaria permitida]

ENTONCES [El sistema completa la operación satisfaciendo el objetivo]


DADO [Contexto de fallo o datos inválidos]

  
ENTONCES [El sistema deniega la acción, mantiene el estado consistente y despliega un mensaje de error explícito]

Documento 02: Requisitos No Funcionales (RNF)
📁 Nombre de archivo: docs/01 Inicio/07. Requisitos no funcionales V_1_0_0.md

Contenido Exigido: Definición de atributos de calidad del sistema mediante el uso de Escenarios de Calidad (ISO/IEC 25010 / arc42) y métricas SMART. Queda prohibido el uso de adjetivos calificativos sin umbral cuantitativo explícito.

ID	Categoría ISO 25010	Escenario de Calidad (Fuente -> Estímulo -> Entorno -> Artefacto -> Respuesta -> Medida SLA)
RNF-001	Rendimiento	Fuente: Usuario concurrente. Estímulo: Petición de generación de reporte mensual. Entorno: Operación normal con carga máxima (80% capacidad). Artefacto: Módulo de Reportes. Respuesta: Procesar la solicitud y retornar el payload. Medida: Latencia ≤ 1.5 segundos en el percentil 95 (P95).
RNF-002	Seguridad	Fuente: Atacante externo. Estímulo: Intento de inyección SQL en endpoint de autenticación. Entorno: Producción. Artefacto: API Gateway / WAF. Respuesta: Bloquear petición, registrar evento de auditoría y notificar al SOC. Medida: 0% de vulnerabilidades críticas OWASP Top 10 ejecutables.
RNF-003	Disponibilidad	Fuente: Infraestructura cloud. Estímulo: Caída de un nodo en la zona de disponibilidad primaria. Entorno: Operación 24/7. Artefacto: Cluster K8s / Base de Datos. Respuesta: Failover automático hacia la zona secundaria. Medida: RTO ≤ 30 segundos, RPO ≤ 5 segundos, SLA global ≥ 99.9% anual.
Documento 03: Identificación y Perfiles de Usuarios
📁 Nombre de archivo: docs/01 Inicio/08. Usuarios V_1_0_0.md

Contenido Exigido:

Matriz de Roles y Actores: Descripción detallada de los perfiles que interactúan de forma directa e indirecta con el sistema.
Historias de Uso Resumidas: Mapa sintético de interacciones por perfil.
Matriz de Control de Acceso (RBAC / ABAC):
Módulo / Capacidad	Rol: Administrador	Rol: Operador / Técnico	Rol: Usuario Final	Rol: Auditor Externo
Configuración de Parámetros	CRUD	Lectura	Sin Acceso	Lectura
Registro de Datos Transaccionales	CRUD	CRUD	Crear / Lectura	Lectura
Depuración / Eliminación Física	D	Sin Acceso	Sin Acceso	Sin Acceso
Exportación de Logs de Auditoría	Lectura	Sin Acceso	Sin Acceso	Lectura (Solo Lectura)
Documento 04: Reglas de Negocio y Trazabilidad
📁 Nombre de archivo: docs/01 Inicio/09. Reglas de negocio V_1_0_0.md

Contenido Exigido:

Codificación de Reglas de Negocio: Formulación explícita de las políticas, restricciones y algoritmos de negocio (RN-001, RN-002, etc.).
Matriz de Trazabilidad Cruzada:
Código RN	Descripción de la Regla de Negocio	Requisito Funcional Asociado	Requisito No Funcional Asociado
RN-001	Un usuario que acumule 3 intentos fallidos de inicio de sesión debe ser bloqueado por 15 minutos.	RF-001 (Autenticación)	RNF-002 (Seguridad)
RN-002	Todo cálculo de impuestos debe aplicar la tasa fija del 18% IGV vigente sobre el subtotal neto.	RF-005 (Facturación)	RNF-004 (Precisión Funcional)
Documento 05: Evaluación e Identificación del Stack Tecnológico
📁 Nombre de archivo: docs/01 Inicio/10. Stack tecnológico V_1_0_0.md

Contenido Exigido: Evaluación rigurosa de al menos 3 alternativas de stack tecnológico mediante criterios multidimensionales.

Criterio de Evaluación	Alternativa 1: MERN (Node/Express + React + MongoDB)	Alternativa 2: Python / FastAPI + React + PostgreSQL	Alternativa 3: Java Spring Boot + Angular + PostgreSQL
Curva de Aprendizaje	Baja (JavaScript unificado)	Media (Python backend, JS frontend)	Alta (Verboso, Fuertemente tipado)
Costo de Infraestructura	Moderado (Node async I/O)	Bajo (FastAPI asíncrono, bajo consumo RAM)	Alto (Mayor consumo de memoria JVM)
Soporte Comunitario	Masivo / Muy Alto	Alto / Crecimiento acelerado	Masivo / Corporativo consolidado
Eficiencia Energética / Eco-Design	Media	Alta (Métricas de cómputo eficientes)	Media-Baja (Warm-up JVM prolongado)
Justificación Técnica Formal: El equipo debe incluir la declaración formal sustentada de la combinación de tecnologías seleccionada, alineando la decisión técnica con la capacidad de escalabilidad, perfil del equipo y criterios de bajo consumo energético en la nube.

Documento 06: Diseño e Ingeniería de Base de Datos
📁 Nombre de archivo: docs/01 Inicio/11. Base de datos V_1_0_0.md

Contenido Exigido:

Modelo Conceptual: Diagrama Entidad-Relación conceptual.
Modelo Lógico: Especificación de entidades, atributos, claves primarias (PK), claves foráneas (FK) y nivel de normalización (3FN).
Modelo Físico (DDL SQL / NoSQL) e Índices:
-- Ejemplo de Estructura de Script DDL Requerida
CREATE TABLE usuarios (

usuario_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

email VARCHAR(255) NOT NULL UNIQUE,

password_hash VARCHAR(255) NOT NULL,

estado VARCHAR(20) NOT NULL DEFAULT 'ACTIVO',

creado_en TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP

);

CREATE INDEX idx_usuarios_email ON usuarios(email);

Documento 07: Arquitectura de Software - Modelo C4
📁 Nombre de archivo: docs/01 Inicio/12. Modelo C4 V_1_0_0.md

Contenido Exigido: Inclusión de diagramas generados en código mermaid para los niveles requeridos.

Nivel 1: Diagrama de Contexto
graph TD
    User[Usuario del Sistema] -->|Utiliza via HTTPS| System[Sistema PFA - TP2]
    System -->|Consulta/Autentica| ExtAuth[Servicio Externo OAuth2]
    System -->|Envía notificaciones| ExtMail[Servicio SMTP Cloud]
Nivel 2: Diagrama de Contenedores
graph TD
    subgraph Sistema PFA
        WA[Single Page Application - React] -->|REST / JSON| API[API Backend - FastAPI / Node]
        API -->|Lectura / Escritura| DB[(Base de Datos Relacional)]
        API -->|Caché de Sesión| Cache[(Redis Cache)]
    end
Nivel 3: Diagrama de Componentes
Estructuración interna de los módulos que componen el contenedor de la API (Controladores, Servicios, Repositorios, Middleware de Seguridad).

Documento 08: Análisis Multidimensional de Restricciones
📁 Nombre de archivo: docs/01 Inicio/13. Restricciones V_1_0_0.md

Contenido Exigido: Matriz de Análisis de Impacto, Mitigación y Cumplimiento Normativo a través de las siguientes dimensiones:

Dimensión	Descripción de la Restricción	Estrategia de Mitigación / Diseño
Salud y Seguridad Pública	Riesgo de exposición no autorizada de datos sensibles de usuarios.	Implementación de cifrado AES-256 en reposo y TLS 1.3 en tránsito. Anonimización de logs.
Análisis de Costo del Ciclo de Vida (LCC)	Presupuesto acotado para mantenimiento y hosting cloud a 3 años.	Arquitectura serverless/containers con auto-scaling para tarificación por demanda real.
Cero Carbono Neto y Sostenibilidad	Huella de carbono generada por procesamiento en servidores cloud.	Selección de proveedores cloud con centros de datos alimentados por energía 100% renovable y optimización de consultas SQL para reducir CPU cycles.
Aspectos Culturales, Sociales y Económicos	Barreras de accesibilidad digital y brecha idiomática o regional.	Diseño UX/UI bajo estándar WCAG 2.1 AA e internacionalización (i18n) para contexto local (glocal).

