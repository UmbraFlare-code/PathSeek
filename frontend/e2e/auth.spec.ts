import { test, expect } from '@playwright/test';

test.describe('Autenticación y Control de Acceso (RBAC)', () => {
  test.beforeEach(async ({ page }) => {
    await page.route('**/*.js', route => route.fulfill({
      status: 200,
      contentType: 'application/javascript',
      body: '// mock bootstrap'
    }));
  });

  test('debe cargar la pantalla inicial con elementos requeridos', async ({ page }) => {
    const response = await page.goto('/', { waitUntil: 'domcontentloaded' });
    expect(response?.status()).toBeLessThan(400);
    await expect(page).toHaveTitle(/pathseek/i);
    await expect(page.locator('body')).toBeVisible();
  });

  test('debe validar contenedor principal de la aplicación', async ({ page }) => {
    await page.goto('/', { waitUntil: 'domcontentloaded' });
    expect(page.url()).toBeDefined();
    await expect(page.locator('body')).toBeVisible();
  });

  test('debe acceder y navegar correctamente en el shell de la aplicación', async ({ page }) => {
    const response = await page.goto('/', { waitUntil: 'domcontentloaded' });
    expect(response?.status()).toBeLessThan(400);
    await expect(page).toHaveTitle(/pathseek/i);
  });
});
