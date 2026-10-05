const assert = require('node:assert/strict');
const { test, after } = require('node:test');

// Unit tests must never reach a native bridge, socket, or remote service.
const restorers = [];
let networkCalls = 0;
let nativeCalls = 0;

function block(object, property, counter) {
  const hadOwnProperty = Object.prototype.hasOwnProperty.call(object, property);
  const original = object[property];
  object[property] = () => {
    counter();
    throw new Error(`Unexpected ${property} call in an offline web test`);
  };
  restorers.push(() => {
    if (hadOwnProperty) object[property] = original;
    else delete object[property];
  });
}

const networkCall = () => networkCalls++;
block(globalThis, 'fetch', networkCall);
for (const protocol of ['node:http', 'node:https']) {
  block(require(protocol), 'request', networkCall);
  block(require(protocol), 'get', networkCall);
}
for (const method of ['connect', 'createConnection']) {
  block(require('node:net'), method, networkCall);
}
block(require('node:net').Socket.prototype, 'connect', networkCall);
block(require('node:dgram'), 'createSocket', networkCall);
block(require('node:tls'), 'connect', networkCall);

const { Capacitor, ExceptionCode } = require('@capacitor/core');
block(Capacitor, 'nativePromise', () => nativeCalls++);
block(Capacitor, 'nativeCallback', () => nativeCalls++);

const webPath = require.resolve('../.test-build/web');
const { SSH } = require('../.test-build/index');

after(() => {
  for (const restore of restorers.reverse()) restore();
});

test('the public entry registers SSH on the actual web platform without loading its implementation', () => {
  assert.equal(Capacitor.getPlatform(), 'web');
  assert.equal(Capacitor.isNativePlatform(), false);
  assert.equal(Capacitor.isPluginAvailable('SSH'), true);
  assert.equal(Capacitor.Plugins.SSH, SSH);
  assert.equal(require.cache[webPath], undefined);
});

const cases = [
  [
    'startSessionByPasswd',
    [
      {
        address: 'localhost',
        port: 22,
        username: 'unit-test',
        password: 'unused-fixture',
      },
    ],
  ],
  [
    'startSessionByKey',
    [
      {
        address: 'localhost',
        port: 22,
        username: 'unit-test',
        tag: 'unused-fixture',
      },
    ],
  ],
  ['newChannel', [{ session: 'unused-session', pty: 0 }]],
  ['startShell', [{ channel: 1 }]],
  ['writeToChannel', [{ channel: 1, s: 'plain text' }]],
  ['closeChannel', [{ channel: 1 }]],
  ['setPtySize', [{ channel: 1, width: 80, height: 24 }]],
];

function unsupported(error) {
  assert.ok(error instanceof Capacitor.Exception);
  assert.equal(error.code, ExceptionCode.Unimplemented);
  assert.equal(error.message, 'Not implemented on web');
  return true;
}

for (const [method, args] of cases) {
  test(`${method} rejects asynchronously with the public UNIMPLEMENTED contract`, async () => {
    let callbackCalls = 0;
    const callback = () => callbackCalls++;
    const callArgs = method === 'startShell' ? [...args, callback] : args;
    let operation;
    assert.doesNotThrow(() => {
      operation = SSH[method](...callArgs);
    });
    assert.ok(operation instanceof Promise);
    await assert.rejects(operation, unsupported);
    assert.equal(
      callbackCalls,
      0,
      'unsupported shell must not emit successful output',
    );
  });
}

test('calls use the compiled plugin web module, rather than a replacement implementation', () => {
  assert.ok(require.cache[webPath]);
  const { SSHWeb } = require.cache[webPath].exports;
  assert.equal(typeof SSHWeb, 'function');
  assert.ok(SSHWeb.prototype instanceof require('@capacitor/core').WebPlugin);
});

test('concurrent unsupported operations retain independent rejection results', async () => {
  const results = await Promise.allSettled([
    SSH.newChannel({ session: 'unused-first' }),
    SSH.newChannel({ session: 'unused-second' }),
    SSH.closeChannel({ channel: 1 }),
  ]);
  assert.equal(results.length, 3);
  for (const result of results) {
    assert.equal(result.status, 'rejected');
    unsupported(result.reason);
  }
});

test('the complete web unit suite makes no network or native bridge calls', () => {
  assert.equal(networkCalls, 0);
  assert.equal(nativeCalls, 0);
});
