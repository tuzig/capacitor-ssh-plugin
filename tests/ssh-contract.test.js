const assert = require('assert/strict');
const fs = require('fs');
const path = require('path');

const root = path.resolve(__dirname, '..');

function read(file) {
  return fs.readFileSync(path.join(root, file), 'utf8');
}

function test(name, fn) {
  try {
    fn();
    console.log(`ok - ${name}`);
  } catch (error) {
    console.error(`not ok - ${name}`);
    throw error;
  }
}

const requiredScenarioMethods = [
  'startSessionByPasswd',
  'newChannel',
  'startShell',
  'writeToChannel',
  'closeChannel',
  'setPtySize',
];

test('native plugins expose the SSH scenario methods from issue #3', () => {
  const iosBridge = read('ios/Plugin/SSHPlugin.m');
  const androidPlugin = read('android/src/main/java/dev/terminal7/plugins/ssh/SSHPlugin.java');

  for (const method of requiredScenarioMethods) {
    assert.match(iosBridge, new RegExp(`CAP_PLUGIN_METHOD\\(${method},`), `iOS bridge is missing ${method}`);
    assert.match(androidPlugin, new RegExp(`public void ${method}\\(PluginCall call\\)`), `Android plugin is missing ${method}`);
  }
});

test('startShell is registered as a callback-returning plugin method', () => {
  const iosBridge = read('ios/Plugin/SSHPlugin.m');
  const androidPlugin = read('android/src/main/java/dev/terminal7/plugins/ssh/SSHPlugin.java');

  assert.match(iosBridge, /CAP_PLUGIN_METHOD\(startShell,\s*CAPPluginReturnCallback\)/);
  assert.match(androidPlugin, /@PluginMethod\(returnType\s*=\s*PluginMethod\.RETURN_CALLBACK\)\s*public void startShell/);
});

test('writeToChannel uses the same payload key in TypeScript, iOS, and Android', () => {
  const definitions = read('src/definitions.ts');
  const web = read('src/web.ts');
  const readme = read('README.md');
  const iosPlugin = read('ios/Plugin/SSHPlugin.swift');
  const androidPlugin = read('android/src/main/java/dev/terminal7/plugins/ssh/SSHPlugin.java');

  assert.match(definitions, /writeToChannel\(options:\s*\{\s*channel:\s*number,\s*message:\s*string\s*\}\):\s*Promise<void>/);
  assert.match(web, /writeToChannel\s*=\s*async\s*\(_:\s*\{\s*channel:\s*number,\s*message:\s*string\s*\}/);
  assert.match(readme, /writeToChannel\(options:\s*\{\s*channel:\s*number;\s*message:\s*string;\s*\}\)\s*=>\s*Promise<void>/);
  assert.match(iosPlugin, /call\.getString\("message"\)/);
  assert.match(androidPlugin, /call\.getString\("message"\)/);
  assert.doesNotMatch(definitions, /writeToChannel\(options:\s*\{\s*channel:\s*number,\s*s:\s*string\s*\}/);
});
