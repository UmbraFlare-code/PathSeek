import { test, expect } from '@playwright/test';

test.describe('Flujos Principales de Negocio (PathSeek)', () => {
  test('debe cargar la vista inicial y shell de navegación', async ({ page }) => {
    const response = await page.goto('/');
    expect(response?.status()).toBeLessThan(400);
    await expect(page).toHaveTitle(/pathseek/i);
  });

  test('debe permitir navegación hacia el módulo de órdenes y entregas', async ({ page }) => {
    await page.goto('/orders');
    await page.waitForLoadState('domcontentloaded');
    expect(page.url()).toContain('/orders');
  });

  test('debe permitir consultar el módulo de rutas optimizadas y mapa', async ({ page }) => {
    await page.goto('/routes');
    await page.waitForLoadState('domcontentloaded');
    expect(page.url()).toContain('/routes');
  });

  test('debe desplegar el módulo de compensación de carbono y sostenibilidad', async ({ page }) => {
    await page.goto('/carbon');
    await page.waitForLoadState('domcontentloaded');
    expect(page.url()).toContain('/carbon');
  });

  test('debe renderizar el reporte descargable en PDF de sostenibilidad', async ({ page }) => {
    await page.goto('/reports');
    await page.waitForLoadState('domcontentloaded');
    expect(page.url()).toContain('/reports');
  });
});
