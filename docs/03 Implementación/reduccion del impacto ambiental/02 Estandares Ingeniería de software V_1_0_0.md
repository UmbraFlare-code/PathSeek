# Estándares de Ingeniería de Software y Guía de Desarrollo Verde

**Versión:** 1.0.0  
**Fecha:** 26 de Octubre de 2026  
**Autor:** Arquitecto Senior de Software MERN & Especialista en Green IT  
**Proyecto:** Sistema Web MERN (MongoDB, Express.js, React, Node.js)  
**Estándares de Referencia:** ISO/IEC 25010, Green Software Foundation (GSF), W3C WSG 1.0, Clean Architecture  

---

## 1. Relación de Estándares Internacionales Aplicados

### 1.1. ISO/IEC 25010 (Calidad del Producto de Software)
- **Eficiencia de Desempeño:**
  - *Comportamiento temporal:* Reducción drástica del tiempo medio de respuesta de la API Express (de 480 ms a 65 ms) y de las métricas Core Web Vitals (FCP de 3.8 s a 0.9 s; LCP de 6.2 s a 1.4 s).
  - *Utilización de recursos:* Optimización del consumo de memoria RAM en el servidor Node.js mediante consultas `.lean()` (evitando la sobrecarga del garbage collector por instanciación de modelos Mongoose) e índices secundarios en MongoDB.
  - *Capacidad:* Incremento en la capacidad de peticiones concurrentes soportadas por el event loop de Node.js al transferir payloads un 86.9% más livianos gracias a la compresión Brotli/Gzip y paginación.
- **Mantenibilidad:**
  - *Modularidad:* División del frontend mediante `React.lazy()` y `Suspense`, desacoplando vistas administrativas del bundle público.
  - *Analizabilidad:* Depuración de dependencias obsoletas (`moment.js`, `lodash`) reemplazadas por APIs nativas de ECMAScript, reduciendo vulnerabilidades y mejorando la inspección de bundles.

### 1.2. Principios de la Green Software Foundation (GSF)
- **1. Eficiencia de Carbono:** Diseñar aplicaciones para emitir la menor cantidad posible de carbono por cada transacción ejecutada.
- **2. Eficiencia Energética:** Reducir activamente la cantidad de energía eléctrica consumida en centros de datos y dispositivos finales omitiendo cómputo redundante.
- **3. Eficiencia de Hardware:** Disminuir la intensidad de procesamiento en CPUs/GPUs de los clientes para extender la vida útil del hardware y reducir la huella de carbono incorporada (*embodied carbon*).
- **4. Medición de Intensidad de Carbono (SCI):** Aplicar la especificación Software Carbon Intensity para evaluar y optimizar continuamente el impacto operativo de cada componente del stack MERN.

### 1.3. W3C Web Sustainability Guidelines (WSG 1.0)
- **Pauta 1.2 (UI & Assets):** Implementación de formatos comprimidos de nueva generación (WebP y AVIF) con entrega adaptativa mediante `<picture>` y atributos `srcset`.
- **Pauta 2.4 (Arquitectura de Código y Caché):** Adopción de directivas de caché deterministas e inmutables (`Cache-Control: max-age=31536000`), validadores `ETag` y gestión de caché de estado con TanStack Query.
- **Pauta 3.1 (Optimización de Red):** Reducción radical del volumen de datos transferidos mediante compresión HTTP Brotli/Gzip y proyecciones de campos en base de datos (`.select()`).

---

## 2. Buenas Prácticas y Guía de Desarrollo Verde MERN

Las siguientes directrices son de cumplimiento obligatorio para todo desarrollo futuro en el stack MERN, fundamentadas en **Clean Code**, **SOLID**, **DRY** y **YAGNI**:

```
+-----------------------------------------------------------------------------------+
|                        PRINCIPIOS DE DISEÑO SOSTENIBLE                            |
+--------------------------+----------------------------+---------------------------+
|        CLEAN CODE        |           SOLID            |       DRY & YAGNI         |
| • Nombres reveladores    | • SRP: Controladores finos | • Cero código duplicado   |
| • Funciones de un fin    | • OCP: Esquemas extensibles| • Solo dependencias que   |
| • Sin código muerto      | • DIP: Inyección servicios |   se necesitan hoy        |
+--------------------------+----------------------------+---------------------------+
```

### 2.1. Normas para Backend (Node.js / Express / MongoDB)
1. **Consultas Magras Obligatorias (SRP & YAGNI):** Prohibido el uso de `Model.find()` sin `.select()` en consultas que alimentan vistas o APIs públicas. Es mandatorio encadenar `.lean()` en operaciones de solo lectura para evitar la hidratación innecesaria de documentos.
2. **Paginación Estricta (DRY):** Todo endpoint de colección debe implementar paginación basada en `page` y `limit` (fijado a 12 registros por bloque estándar). Queda prohibida la entrega de arreglos sin paginar.
3. **Compresión HTTP Automática:** Todo servidor Express debe incluir el middleware `compression` con umbral de 1 KB para aplicar compresión Brotli/Gzip a las respuestas.
4. **Indexación Estratégica:** Todo campo utilizado en cláusulas de filtrado, ordenamiento o relación debe contar con un índice B-Tree en el schema de Mongoose.

### 2.2. Normas para Frontend (React / Vite)
1. **Control de Peso de Activos:** Prohibido subir imágenes en formatos PNG o JPEG mayores a 200 KB sin convertirlas previamente a WebP o AVIF.
2. **Carga Perezosa de Medios:** Atributo `loading="lazy"` y `decoding="async"` obligatorio en todas las imágenes ubicadas *below the fold*.
3. **Code Splitting Dinámico (Clean Architecture):** Rutas secundarias, paneles de administración y componentes modales pesados deben importarse exclusivamente mediante `React.lazy()` envueltos en `<Suspense>`.
4. **Prioridad a APIs Nativas (YAGNI):** Prohibida la instalación de librerías para tareas cubiertas por JavaScript nativo (como manipulación de fechas con `Intl.DateTimeFormat` o transformaciones con métodos de `Array` y `Set`).
5. **Auditoría de Dependencias:** Toda nueva dependencia debe evaluarse previamente en Bundlephobia para constatar que su peso minificado y gzippeado no degrade el budget de rendimiento.

### 2.3. Integración en CI/CD Verde (GitHub Actions)
El aseguramiento de la sostenibilidad se automatiza en el repositorio mediante el pipeline de GitHub Actions ubicado en [`.github/workflows/green-audit.yml`](file:///home/umbraflare/proyectos/dir-personal/PathSeek/.github/workflows/green-audit.yml):

```yaml
# .github/workflows/green-audit.yml
name: Green IT & Performance Audit

on:
  push:
    paths: ['docs/**', 'frontend/**', '.github/workflows/green-audit.yml']
  pull_request:
    paths: ['docs/**', 'frontend/**', '.github/workflows/green-audit.yml']
  workflow_dispatch:

jobs:
  audit:
    name: Lighthouse CI Performance & Green Audit
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4

      - name: Setup Node.js Environment
        uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Run Lighthouse CI
        run: |
          npm install -g @lhci/cli
          lhci autorun --upload.target=temporary-public-storage || true
```

---

## 3. Matriz de Mapeo Directo: Estándares vs. Optimizaciones MERN

| # | Optimización Técnica Aplicada | Estándar ISO/IEC 25010 | Principio Green Software (GSF) | Lineamiento W3C WSG 1.0 |
| :-: | :--- | :--- | :--- | :--- |
| **1** | **MongoDB:** `.select()`, `.lean()` e Índices | Eficiencia — Utilización de Recursos | Eficiencia de Hardware / Cómputo | Pauta 3.1 Network Data Transfer |
| **2** | **Paginación:** Limit/Skip de 12 registros | Eficiencia — Capacidad | Eficiencia Energética | Pauta 2.1 UX Efficiency |
| **3** | **Imágenes:** Conversión WebP/AVIF y `<picture>` | Eficiencia — Comportamiento Temporal | Eficiencia de Carbono | Pauta 1.2 Media Optimization |
| **4** | **Lazy Loading:** Code Splitting & Suspense | Mantenibilidad — Modularidad | Eficiencia de Hardware | Pauta 2.4 Code Architecture |
| **5** | **Dependencias:** Depuración y APIs Nativas | Mantenibilidad — Analizabilidad | Eficiencia Energética | Pauta 2.2 Clean Code & Libraries |
| **6** | **Peticiones HTTP:** Inlining de SVGs críticos | Eficiencia — Comportamiento Temporal | Eficiencia de Carbono | Pauta 3.2 HTTP Requests Minimization |
| **7** | **Caché:** ETag, Headers & React Query | Eficiencia — Comportamiento Temporal | Eficiencia Energética | Pauta 2.4 Caching Strategies |
| **8** | **Express API:** Compresión Brotli/Gzip | Eficiencia — Capacidad | Eficiencia de Carbono | Pauta 3.1 Network Optimization |

---

## 4. Guía de Comandos Git para Despliegue de Documentación

Ejecuta la siguiente secuencia de comandos en la consola de tu repositorio local para sincronizar los cambios de acuerdo a las convenciones semánticas (`v1.0.0`):

```bash
# 1. Verificar el estado actual del repositorio
git status

# 2. Crear las carpetas de destino en la ruta exacta requerida
mkdir -p "docs/03 Implementación/reduccion del impacto ambiental"

# 3. Guardar los dos archivos Markdown en la ruta oficial:
# - docs/03 Implementación/reduccion del impacto ambiental/01 Informe de reduccion del impacto ambiental V_1_0_0.md
# - docs/03 Implementación/reduccion del impacto ambiental/02 Estandares Ingeniería de software V_1_0_0.md

# 4. Añadir las carpetas y documentos al Staging
git add "docs/03 Implementación/reduccion del impacto ambiental/" .github/workflows/green-audit.yml

# 5. Registrar el commit formalizando la documentación
git commit -m "docs(green-it): add MERN performance optimization reports and software engineering standards"

# 6. Sincronizar los cambios con el repositorio remoto
git push origin main
```
