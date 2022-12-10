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
 * parameters used when opening a session by indetity key
 */
export interface StartByKey {
    address: string;
    port: number;
    username: string;
    tag: string;
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
    //TODO: refactor to return {session: SSHSessionID }
    startSessionByPasswd(options: StartByPasswd): Promise<SSHSessionID>
    /**
     * connect to a host using an identity key. The pa
     */
    startSessionByKey(options: StartByKey): Promise<{session: string}>
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
    startShell(options: { channel: SSHChannelID, command?: string } , callback: STDOutCallback): Promise<string>
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
}
