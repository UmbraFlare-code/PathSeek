import AxeBuilder from '@axe-core/playwright';
import { test, expect } from '@playwright/test';
import { openLogin, signIn } from './session';

test('audita con axe el login y el panel renderizados', async ({ page }, testInfo) => {
  await openLogin(page);
  for (const view of ['login', 'panel']) {
    if (view === 'panel') await signIn(page);
    const result = await new AxeBuilder({ page })
      .withTags(['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa', 'wcag22aa'])
      .analyze();
    await testInfo.attach(`axe-${view}`, {
      body: JSON.stringify(result, null, 2),
      contentType: 'application/json',
    });
    expect.soft(result.violations, `Incidencias en ${view}`).toEqual([]);
  }
});
