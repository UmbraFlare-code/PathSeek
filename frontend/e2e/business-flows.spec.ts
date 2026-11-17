import { test, expect } from '@playwright/test';
import { fillFlutterInput, navigate, signIn } from './session';

test.beforeEach(async ({ page }) => {
  await signIn(page);
});

test('carga y filtra los pedidos del entorno de prueba', async ({ page }) => {
  const [response] = await Promise.all([
    page.waitForResponse(response => new URL(response.url()).pathname === '/api/v1/pedidos'),
    navigate(page, 'Pedidos'),
  ]);
  expect(response.ok()).toBeTruthy();
  await expect(page.getByRole('heading', { name: 'Pedidos de distribución' })).toBeVisible();
  const sanCarlos = page.getByRole('group', { name: /Av\. Ferrocarril 450, Huancayo/ });
  const mariscalCastilla = page.getByRole('group', { name: /Jr\. Real 1250, El Tambo/ });
  await expect(sanCarlos).toBeVisible();
  await expect(mariscalCastilla).toBeVisible();
  const search = page.getByRole('textbox', { name: 'Buscar' });
  await search.click({ force: true });
  await fillFlutterInput(search, 'IE-SAN-CARLOS');
  await expect(sanCarlos).toBeVisible();
  await expect(mariscalCastilla).toBeHidden();
});

test('abre una ruta generada y muestra el detalle del mapa', async ({ page }) => {
  await navigate(page, 'Rutas');
  await expect(page.getByRole('heading', { name: 'Rutas de distribución' })).toBeVisible();
  await page.getByRole('button', { name: 'Ver ruta y mapa' }).first().click({ force: true });
  await expect(page.getByRole('heading', { name: 'Detalle de ruta' })).toBeVisible();
  await expect(page.getByRole('button', { name: 'Ver ruta completa' })).toBeVisible();
});

test('obtiene el plan de compensación del backend', async ({ page }) => {
  const [response] = await Promise.all([
    page.waitForResponse(response => response.url().endsWith('/api/v1/compensacion/plan')),
    navigate(page, 'Compensación'),
  ]);
  expect(response.ok()).toBeTruthy();
  await expect(page.getByRole('heading', { name: 'Compensación de carbono' })).toBeVisible();
});

test('genera un PDF de sostenibilidad desde la interfaz', async ({ page }) => {
  await navigate(page, 'Reportes');
  const [response] = await Promise.all([
    page.waitForResponse(response => new URL(response.url()).pathname === '/api/v1/reportes/sostenibilidad'),
    page.getByRole('button', { name: 'Descargar PDF' }).click({ force: true }),
  ]);
  expect(response.ok()).toBeTruthy();
  expect(response.headers()['content-type']).toContain('application/pdf');
  expect((await response.body()).subarray(0, 5).toString()).toBe('%PDF-');
});
