package dev.terminal7.plugins.ssh;

import android.util.Log;

public class SSH {

    public String echo(String value) {
        Log.i("Echo", value);
        return value;
    }
}
