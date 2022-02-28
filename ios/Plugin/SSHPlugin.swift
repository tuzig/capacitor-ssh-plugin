import Capacitor
import Foundation
import NMSSH_riden

@objc(SSHPlugin) public class SSHPlugin: CAPPlugin {
    // to remove a session: sessions[hash] = nil
    private var sessions: [String: NMSSHSession] = [:]
    private var channels: [String: Channel] = [:]
    private let keyLen = 8
    func generateKey() -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<keyLen).map{ _ in letters.randomElement()! })
    }
    @objc func startSessionByPasswd(_ call: CAPPluginCall) {
        guard let host = call.getString("hostname") else {
            return call.reject("Must provide a hostname") }
        let port = call.options["port"] as? Int ?? 22

        guard let user = call.getString("username") else {
            return call.reject("Must provide a username") }
        guard let pass = call.getString("password") else {
            return call.reject("Must provide a password") }
        let session = NMSSHSession(host: host, configs: [], withDefaultPort: port, defaultUsername: user)
        session.connect()
        if session.isConnected {
            session.authenticate(byPassword: pass)
            if session.isAuthorized {
                let key = generateKey()
                sessions[key] = session
                call.resolve(["session": key])
            } else {
                call.reject("Wrong password")
            }
        } else {
            call.reject("Failed to connect")
        }
    }
    @objc func newChannel(_ call: CAPPluginCall) {
        guard let sessionKey = call.getString("session") else {
            return call.reject("Missing session id")
        }
        guard let session = sessions[sessionKey] else {
            return call.reject("Bad session id")
        }
        let channel = Channel(call: call, session: session)
        let key = generateKey()
        channels[key] = channel
        call.resolve(["channel": key])
    }
    @objc func startShell(_ call: CAPPluginCall) {
        guard let key = call.getString("channel") else {
            return call.reject("Missing channel id")
        }
        guard let channel = channels[key] else {
            return call.reject("Bad channel id")
        }
        channel.startShell()
    }
    @objc func closeChannel(_ call: CAPPluginCall) {
        guard let key = call.getString("channel") else {
            return call.reject("Missing channel id")
        }
        guard let channel = channels[key] else {
            return call.reject("Bad channel id")
        }
        channel.closeChannel()
        channels[key] = nil
    }
    @objc func writeToChannel(_ call: CAPPluginCall) {
        guard let key = call.getString("channel") else {
            return call.reject("Missing channel id")
        }
        guard let channel = channels[key] else {
            return call.reject("Bad channel id")
        }
        guard let message = call.getString("message") else {
            return call.reject("Missing channel id")
        }
        channel.write(message: message)
    }

}
@objc public class Channel: NSObject, NMSSHChannelDelegate {
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
    // channel delegates
    @objc public func channel(_ channel: NMSSHChannel, didReadRawData message: Data)  {
        self.call.resolve(["data": message])
    }
    @objc public func channel(_ channel: NMSSHChannel, didReadError error: String) {
        self.call.reject(error)
    }
    @objc public func channelShellDidClose(_ channel: NMSSHChannel) {
        self.call.reject("Shell Did Close")
        // TODO: remove channel from channels
    }
}
