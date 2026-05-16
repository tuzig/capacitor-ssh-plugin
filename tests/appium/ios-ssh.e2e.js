const assert = require('assert/strict');

const shouldRun = process.env.RUN_APPIUM_SSH_E2E === '1';

if (!shouldRun) {
  console.log('skipped - set RUN_APPIUM_SSH_E2E=1 to run the Appium/XCUITest SSH scenario');
  process.exit(0);
}

const APPIUM_SERVER_URL = process.env.APPIUM_SERVER_URL || 'http://127.0.0.1:4723';
const IOS_APP = requiredEnv('IOS_APP');
const SSH_PASSWORD = requiredEnv('SSH_PASSWORD');

const sshOptions = {
  address: process.env.SSH_HOST || 'localhost',
  port: Number(process.env.SSH_PORT || 22),
  username: process.env.SSH_USERNAME || 'jrandom',
  password: SSH_PASSWORD,
};

const desiredCapabilities = {
  platformName: 'iOS',
  'appium:automationName': 'XCUITest',
  'appium:app': IOS_APP,
  'appium:autoWebview': true,
  'appium:autoWebviewTimeout': Number(process.env.APPIUM_AUTOWEBVIEW_TIMEOUT || 15000),
  'appium:newCommandTimeout': Number(process.env.APPIUM_NEW_COMMAND_TIMEOUT || 120),
};

optionalCapability('IOS_DEVICE_NAME', 'appium:deviceName');
optionalCapability('IOS_PLATFORM_VERSION', 'appium:platformVersion');
optionalCapability('IOS_UDID', 'appium:udid');

async function main() {
  const session = await createSession();

  try {
    await switchToWebView(session.sessionId);
    const result = await executeAsync(session.sessionId, sshScenarioScript(), [sshOptions]);
    assert.equal(result.ok, true, result.error || 'SSH scenario failed');
    console.log(`ok - ${result.message}`);
  } finally {
    await deleteSession(session.sessionId);
  }
}

function requiredEnv(name) {
  const value = process.env[name];
  if (!value) {
    throw new Error(`${name} is required when RUN_APPIUM_SSH_E2E=1`);
  }
  return value;
}

function optionalCapability(envName, capabilityName) {
  if (process.env[envName]) {
    desiredCapabilities[capabilityName] = process.env[envName];
  }
}

async function createSession() {
  const response = await appiumRequest('POST', '/session', {
    capabilities: {
      alwaysMatch: desiredCapabilities,
      firstMatch: [{}],
    },
  });

  const sessionId = response.sessionId || (response.value && response.value.sessionId);
  if (!sessionId) {
    throw new Error('Appium did not return a session id');
  }

  return {
    sessionId,
    capabilities: response.capabilities || (response.value && response.value.capabilities),
  };
}

async function deleteSession(sessionId) {
  if (!sessionId) {
    return;
  }
  await appiumRequest('DELETE', `/session/${sessionId}`);
}

async function switchToWebView(sessionId) {
  const deadline = Date.now() + Number(process.env.APPIUM_WEBVIEW_TIMEOUT || 15000);

  while (Date.now() < deadline) {
    const contexts = await appiumRequest('GET', `/session/${sessionId}/contexts`);
    const names = contexts.value || contexts;
    const webview = names.find(name => String(name).startsWith('WEBVIEW'));

    if (webview) {
      await appiumRequest('POST', `/session/${sessionId}/context`, { name: webview });
      return;
    }

    await sleep(500);
  }

  throw new Error('Timed out waiting for a WEBVIEW context');
}

async function executeAsync(sessionId, script, args) {
  const response = await appiumRequest('POST', `/session/${sessionId}/execute/async`, {
    script,
    args,
  });

  return response.value;
}

async function appiumRequest(method, path, body) {
  const response = await fetch(appiumUrl(path), {
    method,
    headers: body ? { 'content-type': 'application/json' } : undefined,
    body: body ? JSON.stringify(body) : undefined,
  });
  const payload = await response.json().catch(() => ({}));

  if (!response.ok) {
    const message = payload.value && payload.value.message ? payload.value.message : response.statusText;
    throw new Error(`${method} ${path} failed: ${message}`);
  }

  return payload;
}

function appiumUrl(path) {
  const base = new URL(APPIUM_SERVER_URL.endsWith('/') ? APPIUM_SERVER_URL : `${APPIUM_SERVER_URL}/`);
  return new URL(path.replace(/^\/+/, ''), base);
}

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

function sshScenarioScript() {
  return `
    const done = arguments[arguments.length - 1];
    const options = arguments[0];

    (async () => {
      const SSH = window.Capacitor && window.Capacitor.Plugins && window.Capacitor.Plugins.SSH;
      if (!SSH) {
        throw new Error('Capacitor SSH plugin is not available in the WebView');
      }

      const sessionResult = await SSH.startSessionByPasswd(options);
      const session = typeof sessionResult === 'string' ? sessionResult : sessionResult.session;
      if (!session) {
        throw new Error('startSessionByPasswd did not return a session id');
      }

      const channels = [];

      async function openShell(index) {
        const channelResult = await SSH.newChannel({ session });
        const channel = channelResult.id;
        const state = { channel, buffer: '' };
        channels.push(state);

        await SSH.startShell({ channel }, event => {
          if (!event) return;
          if (typeof event === 'string') {
            state.buffer += event;
          } else if (event.data) {
            state.buffer += event.data;
          } else if (event.error) {
            state.buffer += event.error;
          }
        });

        await verifyEcho(state, 'hello world ' + index);
      }

      async function verifyEcho(state, message) {
        const marker = 'ssh-e2e-' + Date.now() + '-' + Math.random().toString(16).slice(2);
        const command = 'echo ' + marker + ' ' + message + '\\n';
        const previousLength = state.buffer.length;
        await SSH.writeToChannel({ channel: state.channel, message: command });

        await waitFor(() => state.buffer.slice(previousLength).includes(marker), 5000);
      }

      async function waitFor(predicate, timeoutMs) {
        const deadline = Date.now() + timeoutMs;
        while (Date.now() < deadline) {
          if (predicate()) return;
          await new Promise(resolve => setTimeout(resolve, 100));
        }
        throw new Error('Timed out waiting for shell output');
      }

      for (let i = 0; i < 7; i += 1) {
        await openShell(i);
      }

      for (let i = 0; i < 6; i += 1) {
        const closed = channels.shift();
        await SSH.closeChannel({ channel: closed.channel });
        const remaining = channels[i % channels.length];
        await verifyEcho(remaining, 'remaining shell ' + i);
      }

      if (typeof SSH.closeSession === 'function') {
        await SSH.closeSession({ session });
      }

      return { ok: true, message: 'verified seven shells and remaining-shell echo checks' };
    })().then(done).catch(error => done({ ok: false, error: error.message || String(error) }));
  `;
}

main().catch(error => {
  console.error(error);
  process.exit(1);
});
