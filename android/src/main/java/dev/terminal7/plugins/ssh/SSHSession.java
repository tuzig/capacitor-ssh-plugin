package dev.terminal7.plugins.ssh;

import com.jcraft.jsch.*;

public class SSHSession {

    private final JSch jsch;
    private final Session session;

    public SSHSession(String host, int port, String username) throws JSchException {
        this.jsch = new JSch();
        this.session = jsch.getSession(username, host, port);
        this.session.setConfig("StrictHostKeyChecking", "no");
    }

    public ChannelShell openChannel(String type) throws JSchException {
        return (ChannelShell) this.session.openChannel(type);
    }

    public void connect(String password) throws JSchException {
        this.session.setPassword(password);
        this.session.connect();
    }

    public void connect(String publicKey, String privateKey, String passphrase) throws JSchException {
        this.jsch.addIdentity(privateKey, publicKey, passphrase.getBytes());
        this.session.connect();
    }

    public void disconnect() {
        this.session.disconnect();
    }
}
