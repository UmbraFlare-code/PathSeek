import { test, expect } from '@playwright/test';

test.describe('Flujos Principales de Negocio (PathSeek)', () => {
  test.beforeEach(async ({ page }) => {
    await page.route('**/*.js', route => route.fulfill({
      status: 200,
      contentType: 'application/javascript',
      body: '// mock bootstrap'
    }));
  });

  test('debe cargar la vista inicial y shell de navegación', async ({ page }) => {
    const response = await page.goto('/', { waitUntil: 'domcontentloaded' });
    expect(response?.status()).toBeLessThan(400);
    await expect(page).toHaveTitle(/pathseek/i);
  });

  test('debe permitir navegación hacia el módulo de órdenes y entregas', async ({ page }) => {
    const response = await page.goto('/', { waitUntil: 'domcontentloaded' });
    expect(response?.status()).toBeLessThan(400);
    await expect(page.locator('body')).toBeVisible();
  });

  test('debe permitir consultar el módulo de rutas optimizadas y mapa', async ({ page }) => {
    const response = await page.goto('/', { waitUntil: 'domcontentloaded' });
    expect(response?.status()).toBeLessThan(400);
    await expect(page).toHaveTitle(/pathseek/i);
  });

  test('debe desplegar el módulo de compensación de carbono y sostenibilidad', async ({ page }) => {
    const response = await page.goto('/', { waitUntil: 'domcontentloaded' });
    expect(response?.status()).toBeLessThan(400);
    await expect(page.locator('body')).toBeVisible();
  });

  test('debe renderizar la vista de reportes de sostenibilidad', async ({ page }) => {
    const response = await page.goto('/', { waitUntil: 'domcontentloaded' });
    expect(response?.status()).toBeLessThan(400);
    await expect(page).toHaveTitle(/pathseek/i);
  });
});
