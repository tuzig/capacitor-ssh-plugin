package dev.terminal7.plugins.ssh;

import com.jcraft.jsch.*;

public class SSHSession {

    private JSch jsch;
    private Session session;
    private String password;

    public SSHSession(String host, int port, String username) throws JSchException {
        this.jsch = new JSch();
        this.session = jsch.getSession(username, host, port);
    }

    public Session getSession() {
        return this.session;
    }

    public boolean connect(String password) throws JSchException {
        this.password = password;
        this.session.setPassword(password);
        this.session.connect();
        return true;
    }

    public boolean disconnect() {
        this.session.disconnect();
        return true;
    }
}
