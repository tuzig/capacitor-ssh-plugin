import { registerPlugin } from '@capacitor/core';

import type { SSHPlugin } from './definitions';

const SSH = registerPlugin<SSHPlugin>('SSH', {
  web: () => import('./web').then(m => new m.SSHWeb()),
});

export * from './definitions';
export { SSH };
