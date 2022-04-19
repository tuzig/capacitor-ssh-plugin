export type ChannelCallback = (message: string | null, err?: any) => void;
export type SSHSessionID = string
export type SSHChannelID = number


export enum KnownHostStatus {
    KnownHostStatusMatch,
    KnownHostStatusMismatch,
    KnownHostStatusNotFound,
    KnownHostStatusFailure
}
export interface SSHID {
    id: string;
}
export interface SessionByKeys {
    publicKey: string;
    privateKey: string;
    passwd: string;
}
export interface SSHSessionByPass {
    address: string;
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
export interface SSHPlugin {
  startSessionByPasswd(options: SSHSessionByPass): Promise<SSHID>
  newChannel(options: { session: SSHSessionID, pty?: TerminalType}): Promise< { id: number } >
  startShell(options: { channel: SSHChannelID } , callback: ChannelCallback): Promise<string>
  writeToChannel(options: { channel: number, s: string }): Promise<void>
  closeChannel(options: { channel: number }): Promise<void>
  setPtySize(options: { channel: number, width: number, height: number }): Promise<void>
  /*
  startSessionByKeys(options: SessionByKeys): Promise<{ session: string}>;
  isHostKnown(options: { session: string } ): Promise< KnownHostStatus >;
  isConnected(options: { session: string } ): Promise< { connected: boolean} >;
  // execCommand(options: CommandExecution, callback: ChannelCallback): Promise<{ channel: string} >;
  startShell(options: { pty: TerminalType} , callback: ChannelCallback): Promise< {channel:string }>;
  writeToChannel(options: { channel: string, s: string }): Promise< { error: string} >;
  rsaKeyGen(options: { password: string}): Promise< { publicKey: string, privateKey: string } >;
  */
}
