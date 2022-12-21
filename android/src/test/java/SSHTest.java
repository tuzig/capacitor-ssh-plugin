import com.jcraft.jsch.*;

import dev.terminal7.plugins.ssh.*;

import java.io.IOException;

public class SSHTest {
    public static void main(String[] args) {
        try {
            SSHSession session = new SSHSession("localhost", 22, "user");
            session.connect("password");
            SSHChannel channel = new SSHChannel(session);
            channel.startShell();
            System.out.println("Running command");
            channel.write("ls\n");
            Thread.sleep(2000);
            System.out.println("Output:");
            System.out.println(channel.read());
            System.out.println("Running command");
            channel.write("echo hello world\n");
            Thread.sleep(2000);
            System.out.println("Output:");
            System.out.println(channel.read());
            channel.close();
            session.disconnect();
        } catch (JSchException | IOException | InterruptedException e) {
            e.printStackTrace();
        }
    }
}
