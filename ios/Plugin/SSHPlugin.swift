import Capacitor
import Foundation
import NMSSHT7
import os
import Security

@available(iOS 14.0, *)
let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "network")

private func generateKey(length: Int = 10) -> String {
  let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
  return String((0..<length).map{ _ in letters.randomElement()! })
}

@objc(SSHPlugin) public class SSHPlugin: CAPPlugin {
    private var sessions: [String: Session] = [:]
    private var channels: [Int: Channel] = [:]
    private var lastChannleID: Int = 0
    private var publicKey : SecKey?
    private var privateKey : SecKey?

    @objc func startSessionByPasswd(_ call: CAPPluginCall) {
        guard let host = call.getString("address") else {
            return call.reject("Must provide an address") }
        let port = call.options["port"] as? Int ?? 22
        guard let user = call.getString("username") else {
            return call.reject("Must provide a username") }
        guard let pass = call.getString("password") else {
            return call.reject("Must provide a password") }
        let session = Session(host: host, port: port, username: user)
        if session.connect(call: call, password: pass) {
            let key = generateKey()
            self.sessions[key] = session
            call.resolve(["session": key])
        } // no need for an else as the call was already rejected
    }
    @objc func newChannel(_ call: CAPPluginCall) {
        guard let sessionKey = call.getString("session") else {
            return call.reject("Missing session id")
        }
        guard let session = self.sessions[sessionKey] else {
            return call.reject("Bad session id")
        }
        let channel = Channel(call: call, session: session.session)
        let key = self.lastChannleID
        self.lastChannleID += 1
        self.channels[key] = channel
        call.resolve(["id": key])
    }
    @objc func startShell(_ call: CAPPluginCall) {
        guard let key = call.getInt("channel") else {
            return call.reject("Missing channel id")
        }
        guard let channel = self.channels[key] else {
            return call.reject("Bad channel id")
        }
        channel.startShell(call)
    }
    @objc func closeSession(_ call: CAPPluginCall) {
        guard let key = call.getString("session") else {
            return call.reject("Missing session id")
        }
        guard let session = self.sessions[key] else {
            return call.reject("Bad session id")
        }
        session.session.disconnect()
        self.sessions[key] = nil
        call.resolve()
    }
    @objc func closeChannel(_ call: CAPPluginCall) {
        guard let key = call.getInt("channel") else {
            return call.reject("Missing channel id")
        }
        guard let channel = self.channels[key] else {
            return call.reject("Bad channel id")
        }
        channel.closeChannel()
        self.channels[key] = nil
        call.resolve()
    }
    @objc func writeToChannel(_ call: CAPPluginCall) {
        guard let key = call.getInt("channel") else {
            return call.reject("Missing channel id")
        }
        guard let channel = self.channels[key] else {
            return call.reject("Bad channel id")
        }
        guard let message = call.getString("message") else {
            return call.reject("Missing message")
        }
        channel.write(message: message)
        call.resolve()
    }
    @objc func setPtySize(_ call: CAPPluginCall) {
        guard let key = call.getInt("channel") else {
            return call.reject("Missing channel id")
        }
        guard let channel = self.channels[key] else {
            return call.reject("Bad channel id")
        }
        guard let width = call.getInt("width") else {
            return call.reject("Missing width id")
        }
        guard let height = call.getInt("height") else {
            return call.reject("Missing height id")
        }
        channel.resize(width: UInt(width), height: UInt(height))
        call.resolve()
    }
    @objc func deleteKey(_ call: CAPPluginCall) {
        guard let tag = call.getString("tag") else {
            return call.reject("Must provide a tag")
        }
        let query: [String: Any] = [kSecClass as String: kSecClassKey,
           kSecAttrApplicationTag as String: tag.data(using: .utf8)!,
           kSecReturnRef as String: true]
        let status = SecItemDelete(query as CFDictionary)
        call.resolve()
    }
    @objc func getPublicKey(_ call: CAPPluginCall) {
        guard let tag = call.getString("tag") else {
            return call.reject("Must provide a tag")
        }
        let getquery: [String: Any] = [kSecClass as String: kSecClassKey,
           kSecAttrApplicationTag as String: tag.data(using: .utf8)!,
           kSecReturnRef as String: true]
		var item: CFTypeRef?
		let status = SecItemCopyMatching(getquery as CFDictionary, &item)
		guard status == errSecSuccess else {
            call.reject("Failed to get private key")
            return
        }
        let privateKey = item as! SecKey
        guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
            call.reject("Failed to copy public key")
            return
        }

        var error: Unmanaged<CFError>?
        let exportedKey = SecKeyCopyExternalRepresentation(publicKey, &error)
        var keyData = Data()
        // keyData.append(Data(sshRsaHeader))
        let data = exportedKey as Data?

        keyData.append(data!)
        let publicKeyString = keyData.base64EncodedString()

        call.resolve(["publickey": "\(publicKeyString)"])
    }
    @objc func startSessionByKey(_ call: CAPPluginCall) {
        guard let host = call.getString("address") else {
            return call.reject("Must provide an address") }
        let port = call.options["port"] as? Int ?? 22
        guard let user = call.getString("username") else {
            return call.reject("Must provide a username") }
        guard let tag = call.getString("tag") else {
            return call.reject("Must provide a tag") }
        let getquery: [String: Any] = [kSecClass as String: kSecClassKey,
                                       kSecAttrApplicationTag as String: tag.data(using: .utf8)!,
                                       kSecReturnRef as String: true]
		var privateKey: SecKey
		var item: CFTypeRef?
		let status = SecItemCopyMatching(getquery as CFDictionary, &item)
		if status == errSecSuccess { 
		    privateKey = item as! SecKey
        } else {
            // no key. generate it and return
			let attributes: [String: Any] =
				[kSecAttrKeyType as String:            kSecAttrKeyTypeRSA,
                 kSecAttrKeySizeInBits as String:      2048,
				 kSecPrivateKeyAttrs as String:
					 [kSecAttrIsPermanent as String:    true,
                      kSecClass: kSecClassKey,
					  kSecAttrApplicationTag as String: tag.data(using: .utf8)!]
				]
			var error: Unmanaged<CFError>?
			guard let key = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
				// throw error!.takeRetainedValue() as Error
				call.reject("Failed to generate Key")
                return
			}
            call.reject("New key generated")
            return
		} 
        let publicKey = SecKeyCopyPublicKey(privateKey)
        let session = Session(host: host, port: port, username: user)
        if session.connect(call: call, privateKey: privateKey) {
            let key = generateKey()
            self.sessions[key] = session
            call.resolve(["session": key])
        } // no need for an else as the call was already rejected
    }
    
}
@objc private class Session: NSObject, NMSSHSessionDelegate {
    var call: CAPPluginCall?
    var session: NMSSHSession
    var password: String?
    init(host: String, port: Int, username: String) {
        self.session = NMSSHSession(host: host, configs: [], withDefaultPort: port,
                                    defaultUsername: username)
    }
    func connect(call: CAPPluginCall, password: String) -> Bool {
        self.call = call
        self.password = password
        let session = self.session
        session.delegate = self
        session.connect()
        if session.isConnected {
            session.authenticate(byPassword: password)
            if session.isAuthorized {
                call.keepAlive = true
            } else {
                call.reject("Wrong password")
                return false
            }
        } else {
            call.reject("Failed to connect")
            return false
        }
        return true
    }
    func connect(call: CAPPluginCall, privateKey: SecKey) -> Bool {
        self.call = call
        let session = self.session
        session.delegate = self
        session.connect()
        if session.isConnected {
            guard let privateKeyEx = SecKeyCopyExternalRepresentation(privateKey, nil),
                  let privateData = privateKeyEx as? Data else {
                call.reject("Failed to convert private key")
                return false
            }
            guard let publicKey = SecKeyCopyPublicKey(privateKey),
                  let publicKeyEx = SecKeyCopyExternalRepresentation(publicKey, nil) else { //2
                call.reject("Failed to get public key")
                return false
            }
            guard let publicData = publicKeyEx as? Data else {
                call.reject("Failed to get public key")
                return false
            }
            session.authenticateBy(inMemoryPublicKey: publicData.base64EncodedString(),
                                 privateKey: privateData.base64EncodedString(),
                                 andPassword: nil)
            if session.isAuthorized {
                call.keepAlive = true
            } else {
                call.reject("UNAUTHORIZED")
                return false
            }
        } else {
            call.reject("Failed to connect")
            return false
        }
        return true
    }
    @objc public func session(_ session: NMSSHSession, keyboardInteractiveRequest request: String) -> String {
        if let pass = self.password {
            return pass
        } else {
            return ""
        }
    }
    @objc public func session(_ session: NMSSHSession, didDisconnectWithError error: Error) {
        print("SSH Session disconnect with error", error)
        if let call = self.call {
            call.reject(error.localizedDescription)
            call.keepAlive = false
        }
    }
    @objc public func session(_ session: NMSSHSession, shouldConnectToHostWithFingerprint msg: String) -> Bool {
        return true
    }
}
@objc private class Channel: NSObject, NMSSHChannelDelegate {
    var call: CAPPluginCall
    var channel: NMSSHChannel
    init(call: CAPPluginCall, session: NMSSHSession) {
        self.channel = NMSSHChannel(session: session)
        self.channel.requestPty = true
        self.call = call
    }
    func startShell(_ call: CAPPluginCall) {
        self.call = call
        self.channel.requestPty = true
        self.channel.ptyTerminalType = NMSSHChannelPtyTerminal.xterm
        self.channel.delegate = self
        self.call.keepAlive = true
        guard let command = call.getString("command") else {
            do {
                try self.channel.startShell()
            } catch { self.call.reject("Failed to start shell") }
            return
        }
        do {
            try self.channel.startCommand(nil, command: command)
        } catch { self.call.reject("Failed to start command") }
    }
    // TODO: rename to `close`
    func closeChannel() {
        self.channel.closeShell()
        self.call.keepAlive = false
    }
    func write(message: String) {
        do {
            try self.channel.write(message)
        } catch {
            self.call.reject("Failed writing data to channel")
        }
    }
    func resize(width: UInt, height: UInt) {
        self.channel.requestSizeWidth(width, height: height)
    }
    // channel delegates - we can only use resolve() 
    @objc public func channel(_ channel: NMSSHChannel, didReadRawData message: Data)  {
        self.call.resolve(["data": String(decoding: message, as: UTF8.self)])
    }
    @objc public func channel(_ channel: NMSSHChannel, didReadError error: String) {
        self.call.resolve(["error": error])
        self.call.keepAlive = false
    }
    @objc public func channelShellDidClose(_ channel: NMSSHChannel) {
        self.call.resolve(["error": "EOF"])
        self.call.keepAlive = false
    }
}
