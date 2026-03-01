import test from 'node:test';
import assert from 'node:assert/strict';

globalThis.window ??= {};

const { SSHWeb } = await import('../dist/esm/web.js');

const expectUnimplemented = async (fn, message = 'Not implemented on web') => {
  try {
    await fn();
    assert.fail('Expected an unimplemented error');
  } catch (err) {
    assert.match(String(err?.message ?? err), new RegExp(message));
  }
};

test('startSessionByPasswd throws unimplemented error', async () => {
  const plugin = new SSHWeb();
  await expectUnimplemented(() => plugin.startSessionByPasswd({ host: 'localhost', username: 'u', passwd: 'p' }));
});

test('startSessionByKey throws unimplemented error', async () => {
  const plugin = new SSHWeb();
  await expectUnimplemented(() => plugin.startSessionByKey({ host: 'localhost', username: 'u', privateKey: 'k' }));
});

test('channel operations throw unimplemented error', async () => {
  const plugin = new SSHWeb();
  await expectUnimplemented(() => plugin.newChannel({ session: 1 }));
  await expectUnimplemented(() => plugin.writeToChannel({ channel: 1, s: 'echo test' }));
  await expectUnimplemented(() => plugin.closeChannel({ channel: 1 }));
  await expectUnimplemented(() => plugin.setPtySize({ channel: 1, width: 80, height: 24 }));
});

test('startShell stores callback before throwing so later wiring can reuse it', async () => {
  const plugin = new SSHWeb();
  const cb = () => {};

  await expectUnimplemented(() => plugin.startShell({ channel: 1, command: 'echo hi' }, cb));

  assert.equal(plugin.CB, cb);
});
