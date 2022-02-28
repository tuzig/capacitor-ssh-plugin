export interface SSHPlugin {
  startSessionByPasswd(options: SessionByPasswd): Promise<{ session: string}>;
  startShell(options: { pty: TerminalType, session: string} , callback: ChannelCallback): Promise< {channel:string }>;
  writeToChannel(options: { channel: string, s: string }): Promise< { error: string} >;
  closeShell(options: { channel: string }): Promise<void>;
  /*
  startSessionByKeys(options: SessionByKeys): Promise<{ session: string}>;
  isHostKnown(options: { session: string } ): Promise< KnownHostStatus >;
  isConnected(options: { session: string } ): Promise< { connected: boolean} >;
  // execCommand(options: CommandExecution, callback: ChannelCallback): Promise<{ channel: string} >;
  startShell(options: { pty: TerminalType} , callback: ChannelCallback): Promise< {channel:string }>;
  setPtySize(options: { width: number, height: number }): Promise<void>;
  writeToChannel(options: { channel: string, s: string }): Promise< { error: string} >;
  rsaKeyGen(options: { password: string}): Promise< { publicKey: string, privateKey: string } >;
  */
}

export type ChannelCallback = (message: string | null, err?: any) => void;


export enum KnownHostStatus {
    KnownHostStatusMatch,
    KnownHostStatusMismatch,
    KnownHostStatusNotFound,
    KnownHostStatusFailure
}
export interface SessionByKeys {
    publicKey: string;
    privateKey: string;
    passwd: string;
}
export interface SessionByPasswd {
    hostname: string;
    port: number;
    username: string;
    password: string;
}
export enum TerminalType {
    PtyNone = 0,
    PtyTerminalVanilla,
    PtyTerminalVT100,
    PtyTerminalVT102,
    PtyTerminalVT220,
    PtyTerminalAnsi,
    PtyTerminalXterm
};
