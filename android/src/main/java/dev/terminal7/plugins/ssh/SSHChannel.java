package dev.terminal7.plugins.ssh;

import com.jcraft.jsch.*;

import java.io.*;
import java.io.IOException;

public class SSHChannel {

    private final ChannelShell channel;
    private PipedOutputStream pin;
    private ByteArrayOutputStream out;

    public SSHChannel(SSHSession session) throws JSchException {
        this.channel = session.openChannel("shell");
    }

    public void startShell() throws JSchException, IOException {
        PipedInputStream in = new PipedInputStream();
        this.pin = new PipedOutputStream(in);
        this.out = new ByteArrayOutputStream();
        this.channel.setInputStream(in);
        this.channel.setOutputStream(this.out);
        this.channel.connect();
    }

    public void close() {
        this.channel.disconnect();
    }

    public void write(String message) throws JSchException, IOException {
        this.pin.write(message.getBytes());
    }

    public String read() throws JSchException, IOException {
        return this.out.toString();
    }

    public void resize(int width, int height) throws JSchException {
        this.channel.setPtySize(width, height, 0, 0);
    }
}
