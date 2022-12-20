import com.jcraft.jsch.*;
import dev.terminal7.plugins.ssh.*;
import org.junit.Test;
import org.junit.Assert.*;
import java.io.IOException;

public class SSHTest {
    public static void main(String[] args) {
        try {
            SSHSession session = new SSHSession("localhost", 22, "user");
            session.getSession().setConfig("StrictHostKeyChecking", "no");
            session.connect("password");
            SSHChannel channel = new SSHChannel(session.getSession());
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
            channel.disconnect();
            session.disconnect();
        } catch (JSchException | IOException | InterruptedException e) {
            e.printStackTrace();
        }
    }
}
