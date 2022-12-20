package dev.terminal7.plugins.ssh;

import com.jcraft.jsch.*;
import java.io.*;
import java.io.IOException;
import java.nio.charset.StandardCharsets;

public class SSHChannel {

        private ChannelShell channel;
        private InputStream in;
        private PipedOutputStream pin;
        private ByteArrayOutputStream out;

        public SSHChannel(Session session) throws JSchException {
            this.channel = (ChannelShell) session.openChannel("shell");
        }

        public void startShell() throws JSchException, IOException {
            this.in = new PipedInputStream();
            this.pin = new PipedOutputStream((PipedInputStream) this.in);
            this.out = new ByteArrayOutputStream();
            this.channel.setInputStream(this.in);
            this.channel.setOutputStream(this.out);
            this.channel.connect();
        }

        public void disconnect() {
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
