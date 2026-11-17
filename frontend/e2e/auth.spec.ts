import { test, expect } from '@playwright/test';
import { openLogin, operatorEmail, signIn, signInApi } from './session';

test('muestra la validación al enviar el formulario vacío', async ({ page }) => {
  await openLogin(page);
  await page.getByRole('button', { name: 'Iniciar sesión', exact: true }).click({ force: true });
  await expect(page.getByText('El correo es obligatorio')).toBeVisible();
});

test('inicia sesión con el teclado y muestra el panel autenticado', async ({ page }) => {
  await signIn(page);
});

test('el backend autoriza pedidos y deniega administración al operador', async ({ request }) => {
  expect((await request.get('/api/v1/pedidos')).status()).toBe(401);
  const { headers, usuario } = await signInApi(request, operatorEmail());
  expect(usuario.rol).toBe('OPERADOR');
  expect((await request.get('/api/v1/pedidos', { headers })).status()).toBe(200);
  expect((await request.get('/api/v1/usuarios', { headers })).status()).toBe(403);
});
