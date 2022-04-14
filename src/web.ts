import { WebPlugin } from '@capacitor/core';

import type { SSHPlugin, SSHSessionByPass, SSHSessionID, TerminalType, SSHChannelID, ChannelCallback, SSHID } from './definitions';

export class SSHWeb extends WebPlugin implements SSHPlugin {
  CB: ChannelCallback | undefined
  startSessionByPasswd = async (_: SSHSessionByPass): Promise<SSHID> => {
      throw this.unimplemented('Not implemented on web.');
  }
  newChannel(_: { session: SSHSessionID, pty?: TerminalType}): Promise<{ id: number }> {
      throw this.unimplemented('Not implemented on web.');
  }
  startShell(_: { channel: SSHChannelID} , callback: ChannelCallback): Promise<string> {
      this.CB = callback
      throw this.unimplemented('Not implemented on web.');
  };
  writeToChannel = async (_: { channel: number, s: string }): Promise< { error: string} > => {
      throw this.unimplemented('Not implemented on web.');
  }
  closeShell= async (_: { channel: number }): Promise<void> => {
      throw this.unimplemented('Not implemented on web.');
  }
  setPtySize(_: { channel: number, width: number, height: number }): Promise<void> {
      throw this.unimplemented('Not implemented on web.');
  };
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
