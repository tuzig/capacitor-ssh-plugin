package dev.terminal7.plugins.ssh;

import com.jcraft.jsch.*;

import java.io.*;
import java.io.IOException;

public class SSHChannel {

    private final SSHSession session;
    private Channel channel;
    private PipedOutputStream pin;
    private ByteArrayOutputStream out;

    public SSHChannel(SSHSession session) throws JSchException {
        this.session = session;
    }

    public void openPipes() throws IOException {
        PipedInputStream in = new PipedInputStream();
        this.pin = new PipedOutputStream(in);
        this.out = new ByteArrayOutputStream();
        this.channel.setInputStream(in);
        this.channel.setOutputStream(this.out);
    }

    public void startShell() throws JSchException, IOException {
        this.channel = this.session.openChannel("shell");
        this.openPipes();
        this.channel.connect();
    }

    public void startExec(String command) throws JSchException, IOException {
        ChannelExec channel = (ChannelExec) this.session.openChannel("exec");
        this.channel = channel;
        channel.setCommand(command);
        channel.setPty(true);
        this.openPipes();
        channel.connect();
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

    public void clear() {
        this.out.reset();
    }

    public void resize(int width, int height) {
        if (this.channel instanceof ChannelShell)
            ((ChannelShell) this.channel).setPtySize(width, height, 0, 0);
        else
            ((ChannelExec) this.channel).setPtySize(width, height, 0, 0);
    }
}
