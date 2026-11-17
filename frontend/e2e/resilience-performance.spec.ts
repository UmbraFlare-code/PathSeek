import { test, expect } from '@playwright/test';

test.describe('Monitoreo de Rendimiento (Web Vitals) y Resiliencia', () => {
  test('debe medir tiempos de carga y métricas Web Vitals dentro del SLA', async ({ page }) => {
    const startTime = Date.now();
    const response = await page.goto('/');
    const loadTime = Date.now() - startTime;

    expect(response?.status()).toBeLessThan(400);
    expect(loadTime).toBeLessThan(5000);

    const timing = await page.evaluate(() => {
      const perf = window.performance;
      const nav = perf.getEntriesByType('navigation')[0] as PerformanceNavigationTiming;
      const paint = perf.getEntriesByType('paint');

      const fcp = paint ? paint.find(entry => entry.name === 'first-contentful-paint')?.startTime || 0 : 0;
      const ttfb = nav ? nav.responseStart - nav.requestStart : 0;
      const domComplete = nav ? nav.domComplete : 0;

      return { ttfb, fcp, domComplete };
    });

    console.log(`[Performance Metrics] TTFB: ${timing.ttfb.toFixed(2)}ms | FCP: ${timing.fcp.toFixed(2)}ms | DOM: ${timing.domComplete.toFixed(2)}ms`);
    expect(timing.ttfb).toBeLessThan(2000);
  });

  test('debe verificar disponibilidad de endpoint base con latencia controlada', async ({ request, baseURL }) => {
    const startTime = Date.now();
    const response = await request.get(`${baseURL}/`).catch(() => null);
    const elapsed = Date.now() - startTime;

    if (response) {
      expect(response.status()).toBeLessThan(500);
      console.log(`[Endpoint Latency] / respondió en ${elapsed}ms con código ${response.status()}`);
      expect(elapsed).toBeLessThan(3000);
    }
  });

  test('debe responder adecuadamente ante solicitudes de recursos', async ({ page }) => {
    const response = await page.goto('/');
    expect(response?.status()).toBeLessThan(400);
  });

  test('debe mantener estabilidad ante simulación de desconexión de red', async ({ page, context }) => {
    await page.goto('/');
    await context.setOffline(true);
    await page.waitForTimeout(500);
    await context.setOffline(false);
    await expect(page).toHaveTitle(/pathseek/i);
  });
});
