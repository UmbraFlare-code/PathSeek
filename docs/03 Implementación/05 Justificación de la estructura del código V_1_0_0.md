[← Volver al README Principal](../../README.md)

# Justificación técnica de la organización del código fuente

**Nombre del Proyecto:** PathSeek

**Líder del Proyecto:** Francis Maxuel Urquizo Ore

Proyecto: PathSeek
Código del documento: DOC-024
Versión: V_1_0_0
Fecha: 2026-09-29

---

## 1. Objetivo

Sustentar técnicamente la decisión de organizar el código fuente de PathSeek en carpetas independientes de primer nivel (`frontend/`, `backend/` y `database/`) directamente en la raíz del repositorio, en lugar de concentrarlas bajo una carpeta `src/` (por ejemplo `src/frontend` y `src/backend`).

---

## 2. Contexto: estructura actual del repositorio

```text
PathSeek/
├── backend/            # API REST (Java 17 + Spring Boot 4.1) con su propio pom.xml y Maven Wrapper
│   ├── src/main/java/com/pathseek/backend/
│   ├── src/main/resources/db/migration/
│   ├── src/test/java/
│   ├── pom.xml
│   ├── mvnw / mvnw.cmd
│   └── .gitignore
├── frontend/           # SPA Flutter (Dart) web + móvil con su propio pubspec.yaml
│   ├── lib/            # core/, features/, l10n/
│   ├── test/
│   ├── android/ web/
│   ├── pubspec.yaml
│   └── .gitignore
├── database/           # Esquema, triggers, procedimientos almacenados y datos semilla
├── docs/               # Documentación por fases (01 Inicio, 02 Planificación, 03 Implementación)
├── .gitignore          # Reglas globales del repositorio
└── README.md
```

El repositorio es un **monorepo multi-stack**: conviven dos ecosistemas de build distintos (Maven/Java y Flutter/Dart) que no comparten código fuente entre sí.

---

## 3. Decisión

Mantener las carpetas de cada componente **en la raíz del repositorio**, con la separación `frontend/` y `backend/` como frontera de primer nivel, y `database/` como módulo de artefactos de base de datos.

---

## 4. Fundamentos técnicos

### 4.1. La estructura `src/` propuesta es un ejemplo, no un requisito

La consigna indica "por ejemplo: `src/frontend` y `src/backend`", por lo que se trata de una recomendación ilustrativa. La rúbrica evalúa que exista una **"estructura de carpetas limpia y modular (Frontend/Backend)"** con componentes "independientes y claramente identificados". La separación de primer nivel `frontend/` + `backend/` satisface ese criterio de forma más directa y visible.

### 4.2. Colisión con la convención interna de Maven

Spring Boot (Maven) impone su propio `src/` **dentro** del módulo: `src/main/java`, `src/main/resources` y `src/test/java`. Ubicar el backend bajo `src/backend/` produciría la ruta `src/backend/src/main/java`, con una duplicación de `src/` que rompe la convención estándar de Maven y confunde a las herramientas de build.

### 4.3. Autonomía de build por stack

Cada componente es un proyecto autocontenido con su propio manifiesto y ciclo de vida:

| Componente | Manifiesto | Comando de build | Herramienta |
| --- | --- | --- | --- |
| Backend | `backend/pom.xml` | `./mvnw clean package` | Maven Wrapper |
| Frontend | `frontend/pubspec.yaml` | `flutter build web` / `flutter build apk` | Flutter SDK |

No existe un `src/` compartido ni un build unificado; una carpeta contenedora artificial no aporta ningún valor y añade un nivel de indirección innecesario.

### 4.4. Compatibilidad con herramientas, scripts e IDEs

Los scripts de ejecución (`backend/run-local.ps1`, `backend/run-local.cmd`, `backend/mvnw`) y las rutas relativas de Flutter asumen que el proyecto se ejecuta desde su propio directorio. Herramientas como IntelliJ IDEA, Android Studio y VS Code detectan el módulo por la proximidad del archivo de proyecto (`pom.xml`, `pubspec.yaml`). Mover los proyectos a `src/` obligaría a reescribir rutas, actualizar configuraciones de IDE y reparar scripts de arranque, sin beneficio funcional.

### 4.5. Integración y despliegue continuo por componente

Con la separación raíz, un pipeline puede filtrar por ruta y construir cada componente de forma independiente:

```yaml
# Ejemplo de filtros por ruta en CI/CD
backend:  paths: ["backend/**"]
frontend: paths: ["frontend/**"]
```

Esto evita acoplar el build del frontend al del backend y es coherente con el criterio del Definition of Done global que exige despliegue automatizado por componente.

### 4.6. `.gitignore` resueltos por proximidad

Cada componente conserva sus reglas de exclusión relativas: `backend/.gitignore` (por ejemplo `target/`, `.env`) y `frontend/.gitignore` (por ejemplo `build/`, `.dart_tool/`). Git las resuelve por la ubicación del archivo, sin necesidad de prefijos. El `.gitignore` de la raíz concentra las reglas globales (`.env`, `*.log`, archivos de IDE y del sistema operativo). Una reorganización bajo `src/` obligaría a reescribir todos esos patrones relativos.

### 4.7. Costo/beneficio desfavorable de una reorganización retroactiva

El proyecto ya cuenta con historial Git, Pull Requests fusionados (#4 y #5), ramas de funcionalidad, scripts, wrappers y documentación con rutas relativas. Mover el código a `src/` en una etapa avanzada generaría:

- Ruptura de rutas en scripts, CI y documentación (enlaces relativos).
- Pérdida de trazabilidad si el movimiento no se realiza con `git mv`.
- Ruido en el historial (`churn`) y riesgo de conflictos con ramas abiertas.
- Ningún beneficio funcional, dado que la estructura actual ya es modular.

### 4.8. Visibilidad arquitectónica para los stakeholders

La separación de primer nivel evidencia de inmediato la **arquitectura Cliente-Servidor** adoptada (documento `12. Modelo C4`): un cliente Flutter y un servidor Spring Boot. Esta claridad favorece la evaluación del proyecto, la incorporación de nuevos integrantes y la comunicación con el cliente UGEL Huancayo.

---

## 5. Comparativa de alternativas

| Criterio | `frontend/` + `backend/` (raíz) | `src/frontend` + `src/backend` |
| --- | :---: | :---: |
| Convención de Maven (`src/main/java`) | ✔ Sin colisión | ✘ Doble `src/` |
| Convención de Flutter (`lib/`, `pubspec.yaml`) | ✔ Respetada | ✘ Ruta no estándar |
| Scripts y wrappers (`mvnw`, `run-local.*`) | ✔ Sin cambios | ✘ Requieren reescritura |
| Detección por IDEs | ✔ Inmediata | ✘ Configuración manual |
| CI/CD por ruta | ✔ Directo | ~ Requiere rutas anidadas |
| `.gitignore` relativos | ✔ Por proximidad | ✘ Reescribir patrones |
| Visibilidad Cliente-Servidor | ✔ Alta | ~ Menor |
| Costo de reorganización retroactiva | ✔ Nulo | ✘ Alto |
| Cumplimiento de la rúbrica | ✔ Excelente | ✔ (equivalente) |

---

## 6. Riesgos asumidos

| Riesgo | Mitigación |
| --- | --- |
| Ambientes sin `node_modules`/`vendor` compartido entre carpetas. | No aplica: cada componente gestiona sus propias dependencias (Maven local / `flutter pub`). |
| Dificultad para compartir tipos o contratos entre frontend y backend. | El contrato se centraliza en OpenAPI/Swagger, no en código compartido. |
| Crecimiento futuro hacia más servicios. | Se podrá adoptar un patrón de monorepo (`apps/`, `services/`) de forma incremental sin romper la separación actual. |

---

## 7. Conclusión

La organización con `frontend/` y `backend/` en la raíz es la opción técnicamente superior para PathSeek: respeta las convenciones de Maven y Flutter, preserva scripts, IDEs y pipelines, mantiene un historial Git limpio y evidencia la arquitectura Cliente-Servidor. La propuesta `src/frontend` + `src/backend` era un ejemplo orientativo y habría introducido costos sin beneficios.

---

## 8. Control de versiones

| Versión | Fecha | Descripción | Responsable |
| --- | --- | --- | --- |
| V_1_0_0 | 2026-09-29 | Creación inicial: fundamento técnico de la organización del código (Fase 03: Implementación). | Equipo PIPRE |

---

## 9. Referencia

- **Documentos relacionados:** `01 Informe de estado del proyecto V_1_0_0.md`, `02 Registro de Impedimentos V_1_0_0.md`, `03 Revisión del Sprint V_1_0_0.md`, `04 Retrospectiva del Sprint V_1_0_0.md`.
- **Arquitectura:** `docs/01 Inicio/12. Modelo C4 V_1_1_0.md`.
- **Stack tecnológico:** `docs/01 Inicio/10. Stack tecnológico V_1_0_0.md`.
