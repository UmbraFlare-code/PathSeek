import { test, expect } from '@playwright/test';
import { adminEmail, navigate, openLogin, signIn, signInApi } from './session';

test('mide la carga del login renderizado', async ({ page }, testInfo) => {
  const started = Date.now();
  await openLogin(page);
  const navigation = await page.evaluate(() => {
    const [entry] = performance.getEntriesByType('navigation') as PerformanceNavigationTiming[];
    const fcp = performance.getEntriesByName('first-contentful-paint')[0]?.startTime;
    return { ttfbMs: entry.responseStart - entry.requestStart, fcpMs: fcp ?? null };
  });
  const renderedMs = Date.now() - started;
  await testInfo.attach('navigation', {
    body: JSON.stringify({ ...navigation, renderedMs }),
    contentType: 'application/json',
  });
  expect(navigation.ttfbMs).toBeGreaterThanOrEqual(0);
  expect(navigation.ttfbMs).toBeLessThan(1500);
  expect(renderedMs).toBeLessThan(15_000);
});

test('el backend devuelve salud UP y 404 para una ruta inexistente', async ({ request }) => {
  const response = await request.get('/api/v1/health');
  expect(response.status()).toBe(200);
  expect(await response.json()).toMatchObject({ status: 'UP' });
  const { headers } = await signInApi(request, adminEmail());
  const missing = await request.get('/api/v1/rutas/00000000-0000-0000-0000-000000000000', { headers });
  expect(missing.status()).toBe(404);
});

test('conserva el detalle de la ruta al desconectar y recuperar la red', async ({ page, context }) => {
  await signIn(page);
  await navigate(page, 'Rutas');
  const route = page.getByRole('button', { name: 'Ver ruta y mapa' }).first();
  await route.click({ force: true });
  const detail = page.getByRole('heading', { name: 'Detalle de ruta' });
  await expect(detail).toBeVisible();
  await expect(page.getByRole('button', { name: 'Ver ruta completa' })).toBeVisible();
  await page.getByRole('button', { name: 'Volver a rutas' }).click({ force: true });
  await context.setOffline(true);
  await expect(page.getByText(/Sin conexión: se muestran datos guardados/)).toBeVisible();
  await route.click({ force: true });
  await expect(detail).toBeVisible();
  await expect(page.getByRole('button', { name: 'Ver ruta completa' })).toBeVisible();
  await context.setOffline(false);
  await expect(page.getByText(/Sin conexión: se muestran datos guardados/)).toBeHidden();
});
