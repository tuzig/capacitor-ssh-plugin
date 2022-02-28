import { WebPlugin } from '@capacitor/core';

import type { SSHPlugin, SessionByPasswd, TerminalType, ChannelCallback } from './definitions';

export class SSHWeb extends WebPlugin implements SSHPlugin {
  public startSessionByPasswd = async (_: SessionByPasswd): Promise<{ session: string}> => {
      throw this.unimplemented('Not implemented on web.');
  }
  public startShell = async (_: { pty: TerminalType } , __: ChannelCallback): Promise< {channel:string }> => {
      throw this.unimplemented('Not implemented on web.');
  }
  public writeToChannel = async (_: { channel: string, s: string }): Promise< { error: string} > => {
      throw this.unimplemented('Not implemented on web.');
  }
  public closeShell= async (_: { channel: string }): Promise<void> => {
      throw this.unimplemented('Not implemented on web.');
  }
  /*
  startSessionByKeys(options: SessionByKeys): Promise<{ session: string}>;
  isHostKnown(options: { session: string } ): Promise< KnownHostStatus >;
  isConnected(options: { session: string } ): Promise< { connected: boolean} >;
  // execCommand(options: CommandExecution, callback: ChannelCallback): Promise<{ channel: string} >;
  closeShell(options: { channel: string }): Promise<void>;
  setPtySize(options: { width: number, height: number }): Promise<void>;
  rsaKeyGen(options: { password: string}): Promise< { publicKey: string, privateKey: string } >;
  throw this.unimplemented('Not implemented on web.');
  */

}
