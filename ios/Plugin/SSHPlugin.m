#import <Foundation/Foundation.h>
#import <Capacitor/Capacitor.h>

// Define the plugin using the CAP_PLUGIN Macro, and
// each method the plugin supports using the CAP_PLUGIN_METHOD macro.
CAP_PLUGIN(SSHPlugin, "SSH",
           CAP_PLUGIN_METHOD(startSessionByPasswd, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(startSessionByKey, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(newChannel, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(closeChannel, CAPPluginReturnNone);
           CAP_PLUGIN_METHOD(closeSession, CAPPluginReturnNone);
           CAP_PLUGIN_METHOD(startShell, CAPPluginReturnCallback);
           CAP_PLUGIN_METHOD(writeToChannel, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(setPtySize, CAPPluginReturnPromise);
)
