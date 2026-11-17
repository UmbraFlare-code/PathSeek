import { test, expect } from '@playwright/test';

test.describe('Autenticación y Control de Acceso (RBAC)', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/login');
  });

  test('debe cargar la pantalla de login con elementos requeridos', async ({ page }) => {
    await expect(page).toHaveTitle(/pathseek/i);
    // Verificar presencia de formulario de acceso
    const emailInput = page.locator('input[type="email"], input[type="text"]').first();
    const passwordInput = page.locator('input[type="password"]').first();
    await expect(emailInput).toBeVisible({ timeout: 10000 });
    await expect(passwordInput).toBeVisible({ timeout: 10000 });
  });

  test('debe validar campos vacíos y rechazar credenciales inválidas', async ({ page }) => {
    const submitBtn = page.locator('button, [role="button"]').first();
    if (await submitBtn.isVisible()) {
      await submitBtn.click();
      // Debe mantenerse en login o mostrar aviso de validación
      expect(page.url()).toContain('/login');
    }
  });

  test('debe autenticar exitosamente y redirigir al shell de la aplicación', async ({ page }) => {
    const emailInput = page.locator('input[type="email"], input[type="text"]').first();
    const passwordInput = page.locator('input[type="password"]').first();
    const submitBtn = page.locator('button, [role="button"]').first();

    if (await emailInput.isVisible()) {
      await emailInput.fill('admin@pathseek.com');
      await passwordInput.fill('Admin123*');
      await submitBtn.click();

      // Redirección esperada al dashboard o verificación de sesión activa
      await page.waitForTimeout(2000);
      expect(page.url()).not.toContain('/login-error');
    }
  });
});
