import { expect, request, type FullConfig } from '@playwright/test';
import { adminEmail, operatorEmail, signInApi } from './session';

export default async function setup(config: FullConfig) {
  const baseURL = config.projects[0].use.baseURL!;
  const api = await request.newContext({ baseURL });
  try {
    const health = await api.get('/api/v1/health');
    expect(health.status()).toBe(200);
    expect(await health.json()).toMatchObject({ status: 'UP' });

    const { headers, usuario } = await signInApi(api, adminEmail());
    expect(usuario.rol).toBe('ADMIN');
    expect((await signInApi(api, operatorEmail())).usuario.rol).toBe('OPERADOR');
    const routes = await api.get('/api/v1/rutas', { headers });
    expect(routes.status()).toBe(200);
    if ((await routes.json()).length === 0 && process.env.PLAYWRIGHT_SEED_ROUTES === '1') {
      if (!['localhost', '127.0.0.1'].includes(new URL(baseURL).hostname)) {
        throw new Error('La generación de datos E2E requiere un entorno local aislado');
      }
      const generated = await api.post('/api/v1/rutas/generar', { headers });
      expect(generated.status()).toBe(201);
      expect((await generated.json()).rutas.length).toBeGreaterThan(0);
    }
  } finally {
    await api.dispose();
  }
}
