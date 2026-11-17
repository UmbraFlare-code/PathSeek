[← Volver al README principal](../../../README.md)

# Análisis de Playwright

- **Proyecto:** PathSeek, optimizador de rutas sostenibles para UGEL Huancayo
- **Revisión:** V_1_1_0 · 2026-11-17

## Resultados del corte de cierre

| Commit | Entorno | Resultado | Evidencia |
| --- | --- | --- | --- |
| `78a414d` | URL pública usada en el cierre | 33 fallos y 3 aprobados. Los navegadores registraron conexiones rechazadas. El caso de salud podía pasar al omitir las comprobaciones tras un error de red. | [Log y artefactos](https://github.com/UmbraFlare-code/PathSeek/actions/runs/44010264612) |
| `702f7e9` | Archivos fuente de `frontend/web` servidos por Python | 9 fallos y 27 aprobados en la corrida de push. Los casos navegaban por el HTML estático. | [Log del job](https://github.com/UmbraFlare-code/PathSeek/actions/runs/44010997004/job/133797699383) |

Los resultados anteriores corresponden a la configuración de cada commit. Se retiran del cierre las cifras de 36/36, LCP, latencia, uptime y consumo para las que no se conservó evidencia trazable.

## Suite corregida

| Caso | Comprobación |
| --- | --- |
| Autenticación y permisos | Error visible al enviar el formulario vacío, login por teclado hasta el panel y respuestas 401, 403 y 200 de la API según la sesión. |
| Pedidos y rutas | Petición y renderizado de pedidos de prueba. Apertura de una ruta generada y su mapa. |
| Compensación y PDF | Petición al servicio de compensación y comprobación del tipo y la cabecera del PDF solicitado por la interfaz. |
| Rendimiento y resiliencia | Login renderizado dentro del presupuesto de CI, TTFB y FCP cuando el navegador lo expone, estado `UP` de la API, 404 para una ruta inexistente y consulta de detalles en caché con la red desconectada. |
| Accesibilidad | Axe sobre el login y el panel con el árbol semántico de Flutter habilitado. El resultado acompaña a las pruebas de teclado y a la auditoría manual pendiente. |

Los proyectos de escritorio cubren Chromium, Firefox y WebKit. El presupuesto de laboratorio para el login es 15 s de carga renderizada y 1,5 s de TTFB. El informe adjunta las mediciones observadas por navegador. Los tiempos de producción y los p95 de optimización requieren su propia medición.

### Ejecución local del 17 de noviembre

La suite corregida aprobó **33 de 33 casos**, con 11 en Chromium, 11 en Firefox y 11 en WebKit, sin reintentos ni omisiones. Se ejecutó contra el build de Flutter 3.41.6 y el backend con PostgreSQL aislado. Los casos de login y filtrado pasaron además dos veces por motor en una ejecución específica. Lighthouse generó un informe de laboratorio para el login y el recorrido adicional en Chromium abrió pedidos, rutas, reportes y compensación con el teclado y completó axe sin incidencias en esas vistas.

## Reproducir con los servicios de prueba

Desde un entorno local limpio y con Docker activo, ejecutar en PowerShell desde la raíz. La base nueva usa la semilla de demostración con usuarios, vehículos, conductores y pedidos.

```powershell
$env:ROUTING_ENABLED = 'false'
docker compose up --build --wait --wait-timeout 180

cd frontend
npm ci
npx playwright install
$env:PLAYWRIGHT_BASE_URL = 'http://localhost'
$env:PLAYWRIGHT_ADMIN_EMAIL = 'admin@pathseek.pe'
$env:PLAYWRIGHT_OPERATOR_EMAIL = 'operador@pathseek.pe'
$env:PLAYWRIGHT_TEST_PASSWORD = 'Admin123!'
$env:PLAYWRIGHT_SEED_ROUTES = '1'
npm run test:e2e
npm run test:e2e:report
```

La generación de la ruta de prueba modifica únicamente la base del entorno aislado. Si el entorno ya tiene una ruta de prueba, el paso de preparación la reutiliza. CI guarda los reportes HTML y JSON, los resultados axe y las trazas de fallos. El entorno usa trazados estimados con OSRM desactivado.

## Contratos comprobados

- Salud de backend en `GET /api/v1/health`, con JSON y `status: UP`.
- OpenAPI generado en `GET /v3/api-docs` del backend. La ruta documentada para reoptimización es `POST /api/v1/rutas/reoptimizar`.
- PDF en `GET /api/v1/reportes/sostenibilidad`, con contenido `application/pdf`.

[Revisión del sprint](01%20Revisi%C3%B3n%20del%20Sprint%20V_1_0_0.md) · [← Volver al README principal](../../../README.md)
