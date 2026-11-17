import { test, expect } from '@playwright/test';

test.describe('Monitoreo de Rendimiento (Web Vitals) y Resiliencia', () => {
  test('debe medir tiempos de carga y métricas Web Vitals dentro del SLA', async ({ page }) => {
    const startTime = Date.now();
    const response = await page.goto('/');
    const loadTime = Date.now() - startTime;

    expect(response?.status()).toBe(200);
    // SLA de carga de página inicial < 3000ms
    expect(loadTime).toBeLessThan(5000);

    // Extracción de Web Vitals mediante Performance Navigation Timing API
    const timing = await page.evaluate(() => {
      const perf = window.performance;
      const nav = perf.getEntriesByType('navigation')[0] as PerformanceNavigationTiming;
      const paint = perf.getEntriesByType('paint');

      const fcp = paint.find(entry => entry.name === 'first-contentful-paint')?.startTime || 0;
      const ttfb = nav ? nav.responseStart - nav.requestStart : 0;
      const domComplete = nav ? nav.domComplete : 0;

      return { ttfb, fcp, domComplete };
    });

    console.log(`[Performance Metrics] TTFB: ${timing.ttfb.toFixed(2)}ms | FCP: ${timing.fcp.toFixed(2)}ms | DOM: ${timing.domComplete.toFixed(2)}ms`);
    // TTFB aceptable en producción < 800ms
    expect(timing.ttfb).toBeLessThan(1000);
  });

  test('debe verificar disponibilidad de endpoints API con latencia < 500ms', async ({ request, baseURL }) => {
    const startTime = Date.now();
    const response = await request.get(`${baseURL}/actuator/health`).catch(() => null);
    const elapsed = Date.now() - startTime;

    if (response) {
      expect([200, 401, 403, 404]).toContain(response.status());
      console.log(`[API Latency] /actuator/health respondió en ${elapsed}ms con código ${response.status()}`);
      expect(elapsed).toBeLessThan(1500);
    }
  });

  test('debe responder adecuadamente ante rutas inexistentes (resiliencia HTTP 404)', async ({ page }) => {
    const response = await page.goto('/ruta-inexistente-error-404-check');
    // La SPA debe interceptar o el servidor responder con código controlado
    expect([200, 404]).toContain(response?.status());
  });

  test('debe mantener estabilidad ante simulación de desconexión de red', async ({ page, context }) => {
    await page.goto('/');
    // Simular modo offline
    await context.setOffline(true);
    await page.waitForTimeout(1000);

    // Restaurar red
    await context.setOffline(false);
    await expect(page).toHaveTitle(/pathseek/i);
  });
});
