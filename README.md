# capacitor-ssh-plugin

Supporting libssh2 sessions and channels

## Install

```bash
npm install capacitor-ssh-plugin
npx cap sync
```

## API

<docgen-index>

* [`startSessionByPasswd(...)`](#startsessionbypasswd)
* [`newChannel(...)`](#newchannel)
* [`startShell(...)`](#startshell)
* [`writeToChannel(...)`](#writetochannel)
* [`closeShell(...)`](#closeshell)
* [`setPtySize(...)`](#setptysize)
* [Interfaces](#interfaces)
* [Type Aliases](#type-aliases)
* [Enums](#enums)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### startSessionByPasswd(...)

```typescript
startSessionByPasswd(options: SSHSessionByPass) => Promise<SSHID>
```

| Param         | Type                                                          |
| ------------- | ------------------------------------------------------------- |
| **`options`** | <code><a href="#sshsessionbypass">SSHSessionByPass</a></code> |

**Returns:** <code>Promise&lt;<a href="#sshid">SSHID</a>&gt;</code>

--------------------


### newChannel(...)

```typescript
newChannel(options: { pty?: TerminalType; session: SSHSessionID; }) => Promise<{ id: number; }>
```

| Param         | Type                                                                              |
| ------------- | --------------------------------------------------------------------------------- |
| **`options`** | <code>{ pty?: <a href="#terminaltype">TerminalType</a>; session: string; }</code> |

**Returns:** <code>Promise&lt;{ id: number; }&gt;</code>

--------------------


### startShell(...)

```typescript
startShell(options: { channel: SSHChannelID; }, callback: ChannelCallback) => Promise<string>
```

| Param          | Type                                                        |
| -------------- | ----------------------------------------------------------- |
| **`options`**  | <code>{ channel: number; }</code>                           |
| **`callback`** | <code><a href="#channelcallback">ChannelCallback</a></code> |

**Returns:** <code>Promise&lt;string&gt;</code>

--------------------


### writeToChannel(...)

```typescript
writeToChannel(options: { channel: number; s: string; }) => Promise<{ error: string; }>
```

| Param         | Type                                         |
| ------------- | -------------------------------------------- |
| **`options`** | <code>{ channel: number; s: string; }</code> |

**Returns:** <code>Promise&lt;{ error: string; }&gt;</code>

--------------------


### closeShell(...)

```typescript
closeShell(options: { channel: number; }) => Promise<void>
```

| Param         | Type                              |
| ------------- | --------------------------------- |
| **`options`** | <code>{ channel: number; }</code> |

--------------------


### setPtySize(...)

```typescript
setPtySize(options: { channel: number; width: number; height: number; }) => Promise<void>
```

| Param         | Type                                                             |
| ------------- | ---------------------------------------------------------------- |
| **`options`** | <code>{ channel: number; width: number; height: number; }</code> |

--------------------


### Interfaces


#### SSHID

| Prop     | Type                |
| -------- | ------------------- |
| **`id`** | <code>string</code> |


#### SSHSessionByPass

| Prop           | Type                |
| -------------- | ------------------- |
| **`address`**  | <code>string</code> |
| **`port`**     | <code>number</code> |
| **`username`** | <code>string</code> |
| **`password`** | <code>string</code> |


### Type Aliases


#### SSHSessionID

<code>string</code>


#### SSHChannelID

<code>number</code>


#### ChannelCallback

<code>(message: string | null, err?: any): void</code>


### Enums


#### TerminalType

| Members                  | Value          |
| ------------------------ | -------------- |
| **`PtyNone`**            | <code>0</code> |
| **`PtyTerminalVanilla`** |                |
| **`PtyTerminalVT100`**   |                |
| **`PtyTerminalVT102`**   |                |
| **`PtyTerminalVT220`**   |                |
| **`PtyTerminalAnsi`**    |                |
| **`PtyTerminalXterm`**   |                |

</docgen-api>
