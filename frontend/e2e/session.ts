import { expect, type APIRequestContext, type Locator, type Page } from '@playwright/test';

function credential(name: string): string {
  const value = process.env[name];
  if (!value) throw new Error(`Falta ${name} para el entorno E2E`);
  return value;
}

export const adminEmail = () => credential('PLAYWRIGHT_ADMIN_EMAIL');
export const operatorEmail = () => credential('PLAYWRIGHT_OPERATOR_EMAIL');
export const password = () => credential('PLAYWRIGHT_TEST_PASSWORD');

export async function signInApi(request: APIRequestContext, email: string) {
  const response = await request.post('/api/v1/auth/login', {
    data: { email, password: password() },
  });
  expect(response.status()).toBe(200);
  const { token, usuario } = await response.json();
  expect(token).toEqual(expect.any(String));
  return { headers: { Authorization: `Bearer ${token}` }, usuario };
}

export async function openLogin(page: Page) {
  const response = await page.goto('/');
  expect(response?.status()).toBe(200);
  await expect(page.getByRole('heading', { name: 'Inicia sesión' })).toBeVisible();
}

export async function fillFlutterInput(field: Locator, value: string) {
  await expect(field).toBeFocused();
  // Let Flutter attach its editor and process the DOM change before moving focus.
  const renderFrame = () => field.page().evaluate(() => new Promise<void>(resolve => {
    requestAnimationFrame(() => requestAnimationFrame(() => resolve()));
  }));
  await renderFrame();
  await field.fill(value);
  await renderFrame();
}

export async function signIn(page: Page) {
  await openLogin(page);
  const emailField = page.getByRole('textbox', { name: 'Correo electrónico', exact: true });
  const passwordField = page.getByLabel('Contraseña', { exact: true });
  await emailField.click({ force: true });
  await expect(emailField).toHaveAttribute('id', 'username');
  await fillFlutterInput(emailField, adminEmail());
  await expect(emailField).toHaveValue(adminEmail());
  await page.keyboard.press('Tab');
  await expect(passwordField).toHaveAttribute('id', 'current-password');
  await fillFlutterInput(passwordField, password());
  await expect.poll(async () => (await passwordField.inputValue()).length).toBe(password().length);
  const [response] = await Promise.all([
    page.waitForResponse(response => response.url().endsWith('/api/v1/auth/login')),
    page.keyboard.press('Enter'),
  ]);
  expect(response.status()).toBe(200);
  await expect(page.getByRole('heading', { name: 'Resumen operativo' })).toBeVisible();
}

export async function navigate(page: Page, name: string) {
  await page.getByRole('button', { name, exact: true }).click({ force: true });
}
