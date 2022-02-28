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
* [`startShell(...)`](#startshell)
* [`writeToChannel(...)`](#writetochannel)
* [`closeShell(...)`](#closeshell)
* [Interfaces](#interfaces)
* [Type Aliases](#type-aliases)
* [Enums](#enums)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### startSessionByPasswd(...)

```typescript
startSessionByPasswd(options: SessionByPasswd) => Promise<{ session: string; }>
```

| Param         | Type                                                        |
| ------------- | ----------------------------------------------------------- |
| **`options`** | <code><a href="#sessionbypasswd">SessionByPasswd</a></code> |

**Returns:** <code>Promise&lt;{ session: string; }&gt;</code>

--------------------


### startShell(...)

```typescript
startShell(options: { pty: TerminalType; session: string; }, callback: ChannelCallback) => Promise<{ channel: string; }>
```

| Param          | Type                                                                             |
| -------------- | -------------------------------------------------------------------------------- |
| **`options`**  | <code>{ pty: <a href="#terminaltype">TerminalType</a>; session: string; }</code> |
| **`callback`** | <code><a href="#channelcallback">ChannelCallback</a></code>                      |

**Returns:** <code>Promise&lt;{ channel: string; }&gt;</code>

--------------------


### writeToChannel(...)

```typescript
writeToChannel(options: { channel: string; s: string; }) => Promise<{ error: string; }>
```

| Param         | Type                                         |
| ------------- | -------------------------------------------- |
| **`options`** | <code>{ channel: string; s: string; }</code> |

**Returns:** <code>Promise&lt;{ error: string; }&gt;</code>

--------------------


### closeShell(...)

```typescript
closeShell(options: { channel: string; }) => Promise<void>
```

| Param         | Type                              |
| ------------- | --------------------------------- |
| **`options`** | <code>{ channel: string; }</code> |

--------------------


### Interfaces


#### SessionByPasswd

| Prop           | Type                |
| -------------- | ------------------- |
| **`hostname`** | <code>string</code> |
| **`port`**     | <code>number</code> |
| **`username`** | <code>string</code> |
| **`password`** | <code>string</code> |


### Type Aliases


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
