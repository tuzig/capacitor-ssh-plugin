/*
 * the type of a callback that's called when a new message is
 * recieved in the channel
 */
export type STDOutCallback = (message: string | null, err?: any) => void;
/**
 * Session ID
 */
export type SSHSessionID = string
/**
 * Channel ID
 */
export type SSHChannelID = number


/**
 * FFU: connecting using an public, private key
 */
export interface KeyRing {
    publicKey: string;
    privateKey: string;
    passwd: string;
}
/**
 * parameters used when opening a session by password
 */
export interface StartByPasswd {
    address: string;
    port: number;
    username: string;
    password: string;
}
/**
 * terminal type. this was copied from libssh and  can not be changed
 */
export enum TerminalType {
    PtyNone = 0,
    PtyTerminalVanilla,
    PtyTerminalVT100,
    PtyTerminalVT102,
    PtyTerminalVT220,
    PtyTerminalAnsi,
    PtyTerminalXterm
};
/*
 * A plugin to support the secure shell protocol
 */
export interface SSHPlugin {
    /**
     * connect to a host using a username & password
     */
    startSessionByPasswd(options: StartByPasswd): Promise<SSHSessionID>
    /**
     * given a connected session and an optional terminal type,
     * start a new channel
     */
    newChannel(options: { session: SSHSessionID, pty?: TerminalType}): Promise< { id: number } >
    /**
     * given a channel, start a login shell.
     *
     * The function also recieves a callback which is called when messages 
     * arrive on the channel.
     */
    startShell(options: { channel: SSHChannelID } , callback: STDOutCallback): Promise<string>
    /**
     * writes a message to an open channel
     */
    writeToChannel(options: { channel: number, s: string }): Promise<void>
    /*
     * all good things come to an end and so is the `channel`
     */
    closeChannel(options: { channel: number }): Promise<void>
    /*
     * change the pseudo tty size
     */
    setPtySize(options: { channel: number, width: number, height: number }): Promise<void>
  /* Some ideas for the future:

  startSessionByKeys(options: KeyRing): Promise<{ session: string}>;
  isConnected(options: { session: string } ): Promise< { connected: boolean} >;
  execCommand(options: CommandExecution, callback: STDOutCallback): Promise<{ channel: string} >;
  startShell(options: { pty: TerminalType} , callback: STDOutCallback): Promise< {channel:string }>;
  writeToChannel(options: { channel: string, s: string }): Promise< { error: string} >;
  rsaKeyGen(options: { password: string}): Promise< { publicKey: string, privateKey: string } >;
  */
}
