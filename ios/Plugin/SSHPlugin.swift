import Capacitor
import Foundation
import NMSSH_riden

private func generateKey(length: Int = 10) -> String {
  let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
  return String((0..<length).map{ _ in letters.randomElement()! })
}
@objc(SSHPlugin) public class SSHPlugin: CAPPlugin {
    // to remove a session: sessions[hash] = nil
    private var sessions: [String: Session] = [:]
    private var channels: [Int: Channel] = [:]
    private var lastChannleID: Int = 0
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
            sessions[key] = session
            call.resolve(["session": key])
        }
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
        channel.call = call
        channel.startShell()
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
    @objc public func session(_ session: NMSSHSession, keyboardInteractiveRequest request: String) -> String {
        if let pass = self.password {
            return pass
        } else {
            return ""
        }
    }
    @objc public func session(_ session: NMSSHSession, didDisconnectWithError error: Error) {
        if let call = self.call {
            call.reject(error.localizedDescription)
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
    func startShell() {
        self.channel.requestPty = true
        self.channel.ptyTerminalType = NMSSHChannelPtyTerminal.xterm
        self.channel.delegate = self
        do {
            try self.channel.startShell()
            self.call.keepAlive = true
        } catch {
            self.call.reject("Failed to start shell")
        }
    }
    func closeChannel() {
        self.channel.close()
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
    // channel delegates
    @objc public func channel(_ channel: NMSSHChannel, didReadRawData message: Data)  {
        self.call.resolve(["data": String(decoding: message, as: UTF8.self)])
    }
    @objc public func channel(_ channel: NMSSHChannel, didReadError error: String) {
        self.call.reject(error)
    }
    @objc public func channelShellDidClose(_ channel: NMSSHChannel) {
        self.call.reject("Shell Did Close")
        // TODO: remove channel from channels
    }
}
