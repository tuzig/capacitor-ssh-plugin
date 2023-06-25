package dev.terminal7.plugins.ssh;

import com.jcraft.jsch.*;

import java.util.UUID;

public class SSHSession {

    private final JSch jsch;
    private final Session session;

    public SSHSession(String host, int port, String username) throws JSchException {
        this.jsch = new JSch();
        this.session = jsch.getSession(username, host, port);
        this.session.setConfig("StrictHostKeyChecking", "no");
    }

    public Channel openChannel(String type) throws JSchException {
        return this.session.openChannel(type);
    }

    public void connect(String password) throws JSchException {
        this.session.setPassword(password);
        this.session.connect();
    }

    public void connect(String publicKey, String privateKey, String passphrase) throws JSchException {
        this.jsch.addIdentity(UUID.randomUUID().toString(), privateKey.getBytes(), publicKey.getBytes(), passphrase.getBytes());
        this.session.connect();
    }

    public void disconnect() {
        this.session.disconnect();
    }
}
