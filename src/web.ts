import { WebPlugin } from '@capacitor/core';

import type { SSHPlugin } from './definitions';

export class SSHWeb extends WebPlugin implements SSHPlugin {
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }
}
