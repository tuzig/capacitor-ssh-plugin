package dev.terminal7.plugins.ssh;

import com.getcapacitor.Plugin;
import com.getcapacitor.annotation.CapacitorPlugin;

@CapacitorPlugin(name = "SSH")
public class SSHPlugin extends Plugin {

    private SSHSession[] sessions;

//    @PluginMethod
//    public void echo(PluginCall call) {
//        String value = call.getString("value");
//
//        JSObject ret = new JSObject();
//        ret.put("value", implementation.echo(value));
//        call.resolve(ret);
//    }
}
