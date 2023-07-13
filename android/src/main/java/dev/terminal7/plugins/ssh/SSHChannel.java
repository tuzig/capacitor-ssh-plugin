package dev.terminal7.plugins.ssh;

import com.jcraft.jsch.*;

import java.io.*;
import java.io.IOException;

public class SSHChannel {

    private final SSHSession session;
    private final byte[] buffer;
    private Channel channel;
    private InputStream in;
    private OutputStream out;

    public SSHChannel(SSHSession session) throws JSchException {
        this.session = session;
        this.buffer = new byte[1024];
    }

    public void startShell() throws JSchException, IOException {
        this.channel = this.session.openChannel("shell");
        this.in = this.channel.getInputStream();
        this.out = this.channel.getOutputStream();
        this.channel.connect();
    }

    public void startExec(String command) throws JSchException, IOException {
        ChannelExec channel = (ChannelExec) this.session.openChannel("exec");
        this.channel = channel;
        channel.setCommand(command);
        channel.setPty(true);
        this.in = channel.getInputStream();
        this.out = channel.getOutputStream();
        channel.connect();
    }

    public void close() {
        this.channel.disconnect();
    }

    public void write(String message) throws JSchException, IOException {
        this.out.write(message.getBytes());
        this.out.flush();
    }

    public boolean readAvailable() throws Exception {
        if (this.channel.isEOF())
            throw new Exception("EOF");
        return this.in.available() > 0;
    }

    public String read() throws IOException {
        int i = this.in.read(this.buffer);
        if (i < 0)
            return null;
        return new String(this.buffer, 0, i);
    }

    public void resize(int width, int height) {
        if (this.channel instanceof ChannelShell)
            ((ChannelShell) this.channel).setPtySize(width, height, 0, 0);
        else
            ((ChannelExec) this.channel).setPtySize(width, height, 0, 0);
    }
}
