package dev.terminal7.plugins.ssh;

import com.getcapacitor.*;
import com.getcapacitor.annotation.CapacitorPlugin;
import com.jcraft.jsch.JSchException;

import java.util.*;

@CapacitorPlugin(name = "SSH")
public class SSHPlugin extends Plugin {

    private Map<String, SSHSession> sessions = new HashMap<String, SSHSession>();
    private Map<Integer, SSHChannel> channels = new HashMap<Integer, SSHChannel>();
    private int lastChannelId = 0;

    private String generateKey() {
        return generateKey(10);
    }

    private String generateKey(int length) {
        String letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
        StringBuilder key = new StringBuilder();
        for (int i = 0; i < length; i++) {
            int index = (int) (Math.random() * letters.length());
            key.append(letters.charAt(index));
        }
        return key.toString();
    }

    @PluginMethod
    public void startSessionByPasswd(PluginCall call) {
        String host = call.getString("address");
        if (host == null) {
            call.reject("Must provide an address");
            return;
        }
        int port = call.getInt("port", 22);
        String username = call.getString("username");
        if (username == null) {
            call.reject("Must provide a username");
            return;
        }
        String password = call.getString("password");
        if (password == null) {
            call.reject("Must provide a password");
            return;
        }
        try {
            SSHSession session = new SSHSession(host, port, username);
            session.connect(password);
            String key = generateKey();
            this.sessions.put(key, session);
            JSObject ret = new JSObject();
            ret.put("session", key);
            call.resolve(ret);
        } catch (JSchException e) {
            call.reject("Failed to connect: " + e.getMessage());
        }
    }

    @PluginMethod
    public void startSessionByKey(PluginCall call) {
        String host = call.getString("address");
        if (host == null) {
            call.reject("Must provide an address");
            return;
        }
        int port = call.getInt("port", 22);
        String username = call.getString("username");
        if (username == null) {
            call.reject("Must provide a username");
            return;
        }
        String publicKey = call.getString("publicKey");
        if (publicKey == null) {
            call.reject("Must provide a public key");
            return;
        }
        String privateKey = call.getString("privateKey");
        if (privateKey == null) {
            call.reject("Must provide a private key");
            return;
        }
        String passphrase = call.getString("passphrase", "");
        try {
            SSHSession session = new SSHSession(host, port, username);
            session.connect(publicKey, privateKey, passphrase);
            String key = generateKey();
            this.sessions.put(key, session);
            JSObject ret = new JSObject();
            ret.put("session", key);
            call.resolve(ret);
        } catch (JSchException e) {
            call.reject("Failed to connect: " + e.getMessage());
        }
    }

    @PluginMethod
    public void newChannel(PluginCall call) {
        String sessionKey = call.getString("session");
        if (sessionKey == null) {
            call.reject("Missing session id");
            return;
        }
        SSHSession session = this.sessions.get(sessionKey);
        if (session == null) {
            call.reject("Bad session id");
            return;
        }
        try {
            SSHChannel channel = new SSHChannel(session);
            int channelId = this.lastChannelId++;
            this.channels.put(channelId, channel);
            JSObject ret = new JSObject();
            ret.put("id", channelId);
            call.resolve(ret);
        } catch (Exception e) {
            call.reject("Failed to create channel: " + e.getMessage());
        }
    }

    @PluginMethod(returnType = PluginMethod.RETURN_CALLBACK)
    public void startShell(PluginCall call) {
        int channelId = call.getInt("channel", -1);
        if (channelId == -1) {
            call.reject("Missing channel id");
            return;
        }
        SSHChannel channel = this.channels.get(channelId);
        if (channel == null) {
            call.reject("Bad channel id");
            return;
        }
        String command = call.getString("command", "");
        try {
            call.setKeepAlive(true);
            channel.startShell();
            if (command.length() > 0) {
                channel.write(command + "\n");
            }
            Thread.sleep(2000);
            new Thread(() -> {
                while (true) {
                    try {
                        String data = channel.read();
                        if (data.length() > 0) {
                            JSObject ret = new JSObject();
                            ret.put("data", data);
                            call.resolve(ret);
                        }
                        Thread.sleep(100);
                    } catch (Exception e) {
                        JSObject ret = new JSObject();
                        ret.put("error", e.getMessage());
                        call.resolve(ret);
                        break;
                    }
                }
            }).start();
        } catch (Exception e) {
            call.reject("Failed to start shell: " + e.getMessage());
        }
    }

    @PluginMethod
    public void closeSession(PluginCall call) {
        String sessionKey = call.getString("session");
        if (sessionKey == null) {
            call.reject("Missing session id");
            return;
        }
        SSHSession session = this.sessions.get(sessionKey);
        if (session == null) {
            call.reject("Bad session id");
            return;
        }
        session.disconnect();
        this.sessions.remove(sessionKey);
        call.resolve();
    }

    @PluginMethod
    public void closeChannel(PluginCall call) {
        int channelId = call.getInt("channel", -1);
        if (channelId == -1) {
            call.reject("Missing channel id");
            return;
        }
        SSHChannel channel = this.channels.get(channelId);
        if (channel == null) {
            call.reject("Bad channel id");
            return;
        }
        channel.close();
        this.channels.remove(channelId);
        call.resolve();
    }

    @PluginMethod
    public void writeToChannel(PluginCall call) {
        int channelId = call.getInt("channel", -1);
        if (channelId == -1) {
            call.reject("Missing channel id");
            return;
        }
        SSHChannel channel = this.channels.get(channelId);
        if (channel == null) {
            call.reject("Bad channel id");
            return;
        }
        String message = call.getString("message");
        if (message == null) {
            call.reject("Missing message");
            return;
        }
        try {
            channel.write(message);
            call.resolve();
        } catch (Exception e) {
            call.reject("Failed to write: " + e.getMessage());
        }
    }

    @PluginMethod
    public void setPtySize(PluginCall call) {
        int channelId = call.getInt("channel", -1);
        if (channelId == -1) {
            call.reject("Missing channel id");
            return;
        }
        SSHChannel channel = this.channels.get(channelId);
        if (channel == null) {
            call.reject("Bad channel id");
            return;
        }
        int width = call.getInt("width", -1);
        if (width == -1) {
            call.reject("Missing width");
            return;
        }
        int height = call.getInt("height", -1);
        if (height == -1) {
            call.reject("Missing height");
            return;
        }
        try {
            channel.resize(width, height);
            call.resolve();
        } catch (Exception e) {
            call.reject("Failed to set pty size: " + e.getMessage());
        }
    }
}
