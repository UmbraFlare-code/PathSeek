# PathSeek

**Optimizador de Rutas Sostenibles para UGEL Huancayo**

## Presentación

**PathSeek** es una plataforma web de optimización de rutas de distribución de última milla para **UGEL Huancayo**, institución educativa con operaciones logísticas. El sistema resuelve el Problema de Ruteo de Vehículos con Ventanas de Tiempo (VRPTW) y consideraciones ambientales (Green VRP) mediante metaheurísticas (Algoritmos Genéticos, Búsqueda Tabú, Colonia de Hormigas o Enfriamiento Simulado).

### Datos clave del proyecto

| Campo                      | Detalle                                             |
| -------------------------- | --------------------------------------------------- |
| **Nombre del proyecto**    | PathSeek                                            |
| **Organización / Cliente** | UGEL Huancayo                                       |
| **Ubicación**              | Atalaya 1280, Huancayo 12006, Perú                  |
| **Tipo de solución**       | Plataforma web de optimización de rutas sostenibles |
| **Área**                   | Logística y distribución de última milla            |
| **Equipo**                 | Equipo PIPRE (Desarrollo)                           |
| **Supervisor / Docente**   | Ing. Daniel Gamarra                                 |
| **Duración**               | 14 semanas (4 iteraciones)                          |
| **Enfoque**                | Híbrido con dominancia ágil (iterativo-incremental) |
| **Presupuesto**            | S/ 500,000 (MVP) + S/ 120,000 anual operativo       |
| **Versión documento**      | V_1_2_0                                             |

## Índice de documentación

La documentación completa reside en `docs/01 Inicio/` (Fase 01), `docs/02 Planificación/` (Fase 02) y `docs/03 Implementación/` (Fase 03). Cada documento es accesible desde su vínculo relativo.

| Doc | Archivo                                                                                                                                   | Descripción                                                    |
| --- | ----------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------- |
| 01  | [01. Selección del enfoque del proyecto V_1_0_0.md](docs/01%20Inicio/01.%20Selecci%C3%B3n%20del%20enfoque%20del%20proyecto%20V_1_0_0.md)  | Enfoque híbrido con dominancia ágil                            |
| 02  | [02. Acta de constitución V_1_0_0.md](docs/01%20Inicio/02.%20Acta%20de%20constituci%C3%B3n%20V_1_0_0.md)                                  | Propósito, objetivos, hitos, presupuesto, riesgos              |
| 03  | [03. Declaración de la visión V_1_0_0.md](docs/01%20Inicio/03.%20Declaraci%C3%B3n%20de%20la%20visi%C3%B3n%20V_1_0_0.md)                   | Visión, KPIs, capacidades del producto                         |
| 04  | [04. Registro de supuestos y restricciones V_1_0_0.md](docs/01%20Inicio/04.%20Registro%20de%20supuestos%20y%20restricciones%20V_1_0_0.md) | Supuestos y restricciones del proyecto                         |
| 05  | [05. Registro de interesados V_1_0_0.md](docs/01%20Inicio/05.%20Registro%20de%20interesados%20V_1_0_0.md)                                 | Interesados, RBAC y comunicación                               |
| 06  | [06. Requisitos funcionales V_1_0_0.md](docs/01%20Inicio/06.%20Requisitos%20funcionales%20V_1_0_0.md)                                     | Catálogo RF-001 a RF-010                                       |
| 07  | [07. Requisitos no funcionales V_1_0_0.md](docs/01%20Inicio/07.%20Requisitos%20no%20funcionales%20V_1_0_0.md)                             | Escenarios de calidad RNF-001 a RNF-009                        |
| 08  | [08. Usuarios V_1_0_0.md](docs/01%20Inicio/08.%20Usuarios%20V_1_0_0.md)                                                                   | Roles, historias de uso, matriz RBAC                           |
| 09  | [09. Reglas de negocio V_1_0_0.md](docs/01%20Inicio/09.%20Reglas%20de%20negocio%20V_1_0_0.md)                                             | Reglas RN-001 a RN-012 y trazabilidad                          |
| 10  | [10. Stack tecnológico V_1_0_0.md](docs/01%20Inicio/10.%20Stack%20tecnol%C3%B3gico%20V_1_0_0.md)                                          | Evaluación y selección del stack                               |
| 11  | [11. Base de datos V_1_0_0.md](docs/01%20Inicio/11.%20Base%20de%20datos%20V_1_0_0.md)                                                     | Modelo conceptual, lógico, físico (DDL)                        |
| 12  | [12. Modelo C4 V_1_0_0.md](docs/01%20Inicio/12.%20Modelo%20C4%20V_1_0_0.md)                                                               | Arquitectura de software (contexto, contenedores, componentes) |
| 13  | [13. Restricciones V_1_0_0.md](docs/01%20Inicio/13.%20Restricciones%20V_1_0_0.md)                                                         | Análisis multidimensional de restricciones                     |

## Fase 02: Planificación del Proyecto

La documentación de la Fase 02 reside en `docs/02 Planificación/`. Cada documento es accesible desde su vínculo relativo.

| Doc | Archivo                                                                                                               | Descripción                                                                            |
| --- | --------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------- |
| 14  | [01 Transformando a ágil V_1_1_0.md](docs/02%20Planificaci%C3%B3n/01%20Transformando%20a%20%C3%A1gil%20V_1_1_0.md)    | Transformación de RF/RNF a Épicas, Historias de Usuario, Enablers y Definition of Done |
| 15  | [02 Artefactos Jira V_1_1_0.md](docs/02%20Planificaci%C3%B3n/02%20Artefactos%20Jira%20V_1_1_0.md)                     | Configuración de Jira Software: jerarquía, backlog, roadmap, sprint y releases         |
| 16  | [03 Registro de riesgos V_1_0_0.md](docs/02%20Planificaci%C3%B3n/03%20Registro%20de%20riesgos%20V_1_0_0.md)           | Matriz de riesgos con severidad P × I y planes de mitigación/contingencia              |
| 17  | [04 Presupuesto del proyecto V_1_0_0.md](docs/02%20Planificaci%C3%B3n/04%20Presupuesto%20del%20proyecto%20V_1_0_0.md) | CAPEX RRHH, licenciamiento, OPEX Cloud y reserva de contingencia                       |

## Fase 03: Implementación del Proyecto (Organizada por Sprints)

La documentación de la Fase 03 reside en `docs/03 Implementación/` y se encuentra estructurada modularmente en carpetas por cada sprint e incluye la justificación arquitectural:

### Sprint 1: Núcleo Logístico y Seguridad (18 SP - Done)

| Doc | Archivo | Descripción |
| --- | --- | --- |
| S1-01 | [01 Planificación del Sprint 1 V_1_0_0.md](docs/03%20Implementaci%C3%B3n/Sprint%201/01%20Planificaci%C3%B3n%20del%20Sprint%201%20V_1_0_0.md) | Sprint Goal, US-001, US-002, US-003, EN-003 y DoD |
| S1-02 | [02 Informe de estado del proyecto V_1_0_0.md](docs/03%20Implementaci%C3%B3n/Sprint%201/02%20Informe%20de%20estado%20del%20proyecto%20V_1_0_0.md) | DOC-018: Cierre Sprint 1 (18/18 SP), métricas y PRs #4 y #5 |
| S1-03 | [03 Registro de Impedimentos V_1_0_0.md](docs/03%20Implementaci%C3%B3n/Sprint%201/03%20Registro%20de%20Impedimentos%20V_1_0_0.md) | DOC-019: Obstáculos identificados y resueltos al 100% |
| S1-04 | [04 Revisión del Sprint V_1_0_0.md](docs/03%20Implementaci%C3%B3n/Sprint%201/04%20Revisi%C3%B3n%20del%20Sprint%20V_1_0_0.md) | Demostración a UGEL Huancayo de Login JWT y CRUDs |
| S1-05 | [05 Retrospectiva del Sprint V_1_0_0.md](docs/03%20Implementaci%C3%B3n/Sprint%201/05%20Retrospectiva%20del%20Sprint%20V_1_0_0.md) | Aprendizajes en 4 ejes y compromisos para Sprint 2 |

### Sprint 2: Dashboard, Visualización de Rutas y Producción VPS (26 SP - Done)

| Doc | Archivo | Descripción |
| --- | --- | --- |
| S2-01 | [01 Planificación del Sprint 2 V_1_0_0.md](docs/03%20Implementaci%C3%B3n/Sprint%202/01%20Planificaci%C3%B3n%20del%20Sprint%202%20V_1_0_0.md) | Sprint Goal, US-008, US-007, US-005, EN-007/008, EN-004 |
| S2-02 | [02 Informe de estado del proyecto V_1_0_0.md](docs/03%20Implementaci%C3%B3n/Sprint%202/02%20Informe%20de%20estado%20del%20proyecto%20V_1_0_0.md) | DOC-020: Cierre Sprint 2 (26/26 SP), VPS Contabo SSL |
| S2-03 | [03 Registro de Impedimentos V_1_0_0.md](docs/03%20Implementaci%C3%B3n/Sprint%202/03%20Registro%20de%20Impedimentos%20V_1_0_0.md) | DOC-021: Obstáculos superados en despliegue y CORS |
| S2-04 | [04 Revisión del Sprint V_1_0_0.md](docs/03%20Implementaci%C3%B3n/Sprint%202/04%20Revisi%C3%B3n%20del%20Sprint%20V_1_0_0.md) | DOC-022: Demostración Dashboard, tarjetas de rutas y APK |
| S2-05 | [05 Retrospectiva del Sprint V_1_0_0.md](docs/03%20Implementaci%C3%B3n/Sprint%202/05%20Retrospectiva%20del%20Sprint%20V_1_0_0.md) | DOC-023: Acciones de mejora A-08 a A-12 para Sprint 3 |

### Sprint 3: Re-optimización Dinámica, Reportes Sostenibilidad, Clientes y Auditoría (23 SP - Objetivo)

| Doc | Archivo | Descripción |
| --- | --- | --- |
| S3-01 | [01 Planificación del Sprint 3 V_1_0_0.md](docs/03%20Implementaci%C3%B3n/Sprint%203/01%20Planificaci%C3%B3n%20del%20Sprint%203%20V_1_0_0.md) | Sprint Goal, US-006, EN-002, US-009, US-004, US-010 |
| S3-02 | [02 Especificación de Contratos API y Trazabilidad V_1_0_0.md](docs/03%20Implementaci%C3%B3n/Sprint%203/02%20Especificaci%C3%B3n%20de%20Contratos%20API%20y%20Trazabilidad%20V_1_0_0.md) | Contratos REST, OpenAPI Schemas y DTOs tipados |
| S3-03 | [03 Matriz de Seguimiento y Criterios Gherkin V_1_0_0.md](docs/03%20Implementaci%C3%B3n/Sprint%203/03%20Matriz%20de%20Seguimiento%20y%20Criterios%20Gherkin%20V_1_0_0.md) | Trazabilidad RF/RNF a criterios BDD Gherkin y tests |
| S3-04 | [04 Informe de estado del proyecto V_1_0_0.md](docs/03%20Implementaci%C3%B3n/Sprint%203/04%20Informe%20de%20estado%20del%20proyecto%20V_1_0_0.md) | DOC-025: Avance 23/23 SP, avance general 67/89 SP |
| S3-05 | [05 Registro de Impedimentos V_1_0_0.md](docs/03%20Implementaci%C3%B3n/Sprint%203/05%20Registro%20de%20Impedimentos%20V_1_0_0.md) | DOC-026: Registro y control de riesgos del Sprint 3 |
| S3-06 | [06 Revisión del Sprint V_1_0_0.md](docs/03%20Implementaci%C3%B3n/Sprint%203/06%20Revisi%C3%B3n%20del%20Sprint%20V_1_0_0.md) | DOC-027: Demostración de re-optimización, PDF y clientes |
| S3-07 | [07 Retrospectiva del Sprint V_1_0_0.md](docs/03%20Implementaci%C3%B3n/Sprint%203/07%20Retrospectiva%20del%20Sprint%20V_1_0_0.md) | DOC-028: Lecciones aprendidas y plan de transferencia |

### Entregables Transversales de Arquitectura y Diseño

| Doc | Archivo | Descripción |
| --- | --- | --- |
| 24  | [05 Justificación de la estructura del código V_1_0_0.md](docs/03%20Implementaci%C3%B3n/05%20Justificaci%C3%B3n%20de%20la%20estructura%20del%20c%C3%B3digo%20V_1_0_0.md) | DOC-024: Fundamento de la organización `frontend/`, `backend/` y `database/` en la raíz |
| 25  | [DESIGN.md](DESIGN.md) | Guía del Sistema de Diseño UI/UX: Enfoque Mobile-First, Minimalista, Flat y Tipografía Ligera |


## Resumen de objetivos y KPIs

Diagrama Mermaid con el resumen de los objetivos y KPIs recurrentes en la documentación:

```mermaid
graph TD
    subgraph Eficiencia Operativa
        A[Distancia recorrida >= 15%% de reducción]
        B[Combustible >= 12%% de ahorro]
    end
    subgraph Sostenibilidad
        C[Emisiones CO2 >= 10%% de reducción]
        D[Avance carbono neutral en 3 años]
    end
    subgraph Cumplimiento y Tiempo
        E[Cumplimiento ventanas >= 90%%]
        F[Algoritmo <= 45 s / 150 pedidos]
        G[Re-optimización <= 30 s]
    end
    subgraph Calidad del servicio
        H[Disponibilidad >= 99.5%%]
        I[MVP >= 70%% de RF-01 a RF-07]
    end

    PathSeek[PathSeek / UGEL Huancayo] --> A
    PathSeek --> B
    PathSeek --> C
    PathSeek --> D
    PathSeek --> E
    PathSeek --> F
    PathSeek --> G
    PathSeek --> H
    PathSeek --> I
```

## Puntos comunes en todos los documentos

Los siguientes elementos se repiten de forma consistente en todos los documentos:

### Nombre y código del proyecto

- **Proyecto:** PathSeek
- **Código de documento:** DOC-001 a DOC-013 (secuencial por documento)
- **Versión:** V_1_0_0 (versión inicial)
- **Fecha:** 2026-08-25
- **Responsable:** Equipo del proyecto

### Organización y actores

- **Cliente:** UGEL Huancayo
- **Equipo de desarrollo:** Equipo PIPRE
- **Supervisor académico:** Ing. Daniel Gamarra

### Problema que resuelve

- Congestión vehicular en horas punta.
- Costos de combustible y mantenimiento (35% de costos totales).
- Emisiones de ~3.5 toneladas de CO₂ mensuales (flota de 15 camionetas).
- 22% de incumplimiento de ventanas de tiempo.

### Objetivos y KPIs (recurrentes)

- Reducción de distancia recorrida ≥ 15%.
- Reducción de emisiones CO₂ ≥ 10%.
- Cumplimiento de ventanas ≥ 90%.
- Algoritmo en ≤ 45 s para 150 pedidos / 15 vehículos.
- Re-optimización en ≤ 30 s.
- Disponibilidad ≥ 99.5%.
- MVP con ≥ 70% de RF-01 a RF-07.

### Stack tecnológico

**Backend:** Java 17 + Spring Boot 4.1 · **Frontend:** Flutter (Dart) · **Base de datos:** PostgreSQL · **Mapas:** flutter_map / OpenStreetMap

**Arquitectura:** **Cliente-Servidor** — el frontend SPA Flutter (web para operador/dashboard y modo móvil para conductor, con caché offline) es el cliente, y consume la API REST de Spring Boot (servidor único) mediante HTTPS/JSON. El servidor centraliza la lógica de negocio, la persistencia (PostgreSQL, migraciones Flyway) y albergará el módulo de optimización. El caché distribuido (Redis) es arquitectura objetivo, no parte del MVP.

Ver la [lista de justificaciones](docs/01%20Inicio/10.%20Stack%20tecnol%C3%B3gico%20V_1_0_0.md) completa en el documento 10 y las decisiones en [ADR-07](docs/01%20Inicio/12.%20Modelo%20C4%20V_1_1_0.md).

#### Justificaciones de la elección (Flutter + Spring Boot)

1. **Frontend multi-plataforma (Flutter/Dart):** Flutter usa Dart (tipado estático, hot reload, compilación nativa). Una sola base de código cubre web (operador/dashboard) y móvil (conductor), acelerando el MVP.
2. **Spring Boot como backend maduro:** Framework Java consolidado con seguridad (Spring Security), validación (Bean Validation), persistencia (Spring Data JPA), migraciones (Flyway) y OpenAPI integrados.
3. **Tipado estático en todo el stack:** Frontend en Dart (null safety) y backend en Java (records, validación declarativa); mantenibilidad y calidad en toda la solución.
4. **Flutter como framework empresarial:** UI declarativa por widgets, gestión de estado con Provider/BLoC, navegación con Navigator/go_router, formularios con validación y clientes HTTP (http/dio) para dashboard, mapas y reportes.
5. **Concurrencia y rendimiento (HikariCP + JPA):** Atiende el dashboard en tiempo real y el volumen de 1,000 pedidos / 50 vehículos; el cómputo de la metaheurística (≤ 45 s) se aislará en hilos dedicados.
6. **Optimización en JVM:** Metaheurísticas para VRPTW/Green VRP implementadas en Java dentro del mismo backend (objetivo RF-003).
7. **Costo de infraestructura moderado:** MVP monoinstancia (API + PostgreSQL), alineado al presupuesto y criterios eco-diseño; escalado horizontal como objetivo.
8. **Código abierto:** Spring Boot, Flutter y PostgreSQL cumplen RES-07.
9. **PostgreSQL:** Soporte geográfico (PostGIS) para rutas y coordenadas.
10. **Componentes reutilizables:** Widgets reutilizables de Flutter aceleran RF-004, RF-005 y RF-010.
11. **Arquitectura cliente-servidor:** Frontend Flutter (cliente, web + móvil con offline) ↔ API REST Spring Boot (servidor único) por HTTPS, con separación de responsabilidades y escalamiento independiente del servidor.

### Estándares y normativa (aplicados en todos)

- ISO/IEC 25010 (calidad de software)
- OWASP Top 10 (seguridad)
- WCAG 2.1 AA (accesibilidad)
- ISO 14083 (huella de carbono logística)
- Ley N.° 29733 (Protección de Datos Personales)
- Ley N.° 30224 (Ley de Tránsito)
- Decreto Supremo N.° 033-2012-MTC (restricción vehicular)
- W3C (validación de código)

## Convenciones de archivos

- **Formato:** Markdown (`.md`) nativo con encabezados, tablas, diagramas Mermaid y fragmentos SQL.
- **Nomenclatura:** `NN. Nombre del documento V_1_0_0.md` en `docs/01 Inicio/`; en `docs/02 Planificación/` y `docs/03 Implementación/` los artefactos usan `NN Nombre del documento V_1_0_0.md`.
- **Versionamiento:** La versión inicial es `V_1_0_0.md`; cambios menores `V_1_1_0`; revisiones estructurales `V_2_0_0`. Se preserva el historial en Git.
- **Calidad de requisitos:** Prohibidos términos ambiguos ("fácil", "eficiente", "adecuado") y diseño técnico prematuro en descripciones atómicas.

## Despliegue y Actualización en Producción (VPS)

Para actualizar el sistema completo (Frontend Web + APK Móvil, Backend Java y Base de Datos PostgreSQL) en la VPS (`169.58.74.99`), ejecuta los siguientes comandos en el servidor desde la carpeta del proyecto (`~/pathseek`):

```bash
# 1. Obtener la última versión del código fuente desde Git
git pull origin main

# 2. Reconstruir la imagen de Frontend (compila la web y genera el APK de Android)
docker compose -f docker-compose.prod.yml build frontend

# 3. (Opcional) Actualizar/Sembrar datos en la base de datos PostgreSQL
docker exec -i pathseek-postgres psql -U pathseek_prod -d pathseek_prod < database/05_seed_demo_data.sql

# 4. Levantar / Reiniciar los servicios en segundo plano
docker compose -f docker-compose.prod.yml up -d
```

### URLs de Producción y Recursos
- **Plataforma Web (Dashboard / Operador):** `https://169.58.74.99/`
- **Descarga Directa de App Móvil (APK Conductor):** `https://169.58.74.99/downloads/pathseek.apk`
- **API Health Check:** `https://169.58.74.99/api/v1/health`
- **Credenciales de Acceso Demo:**
  - **Administrador:** `admin@pathseek.pe` / `Admin123!`
  - **Operador:** `operador@pathseek.pe` / `Admin123!`
  - **Conductor:** `conductor.juan@pathseek.pe` / `Admin123!`

## Fuentes de verdad

La documentación se genera a partir de la consigna del proyecto "PathSeek" – Optimizador de Rutas Sostenibles para UGEL Huancayo, y de los documentos existentes en `docs/01 Inicio/` (01-05). Los archivos referenciales originales (`requirements.md`, `rules2.md`) fueron solo de referencia y ya no forman parte del repositorio.

## Cómo leer

1. Revisa `docs/01 Inicio/` en orden numérico (01 → 13) para una lectura secuencial.
2. Continúa con `docs/02 Planificación/` (01 → 04) y `docs/03 Implementación/` (01 → 05).
3. Cada documento incluye su propio "Control de versiones" y "Referencia" al final.

## Control de versiones

| Versión | Fecha | Descripción | Responsable |
| --- | --- | --- | --- |
| V_1_0_0 | 2026-09-07 | Creación inicial del README con el índice de las fases 01 y 02. | Equipo PIPRE |
| V_1_1_0 | 2026-09-29 | Sincronización con el Sprint 1: se agrega la Fase 03 (Implementación) con enlaces a los entregables, se retiran referencias a documentos eliminados y se actualiza el versionamiento. | Equipo PIPRE |
| V_1_2_0 | 2026-10-06 | Sincronización con los entregables del Sprint 2: actualización de la Fase 03 (Implementación), enlaces relativos de ida y vuelta y despliegue en producción. | Equipo PIPRE |

