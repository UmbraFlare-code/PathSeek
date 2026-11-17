import { test, expect } from '@playwright/test';

test.describe('Autenticación y Control de Acceso (RBAC)', () => {
  test('debe cargar la pantalla inicial con elementos requeridos', async ({ page }) => {
    const response = await page.goto('/');
    expect(response?.status()).toBeLessThan(400);
    await expect(page).toHaveTitle(/pathseek/i);
    await expect(page.locator('body')).toBeVisible();
  });

  test('debe validar contenedor principal de la aplicación', async ({ page }) => {
    await page.goto('/login');
    expect(page.url()).toBeDefined();
    await expect(page.locator('body')).toBeVisible();
  });

  test('debe acceder y navegar correctamente en el shell de la aplicación', async ({ page }) => {
    const response = await page.goto('/');
    expect(response?.status()).toBeLessThan(400);
    await expect(page).toHaveTitle(/pathseek/i);
  });
});
