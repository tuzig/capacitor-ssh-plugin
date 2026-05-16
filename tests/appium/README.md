# Appium iOS SSH scenario

Issue #3 asks for automated coverage of Terminal7's SSH usage scenario on a real iPad, using Appium with XCUITest against a local ssh daemon accepting the `jrandom` user on port 22.

The script in this directory is intentionally opt-in. It exits successfully without running unless `RUN_APPIUM_SSH_E2E=1` is set, so normal CI can run `npm test` without a device lab and without pretending that the real iPad scenario was verified.

## Lab requirements

- Appium 2 server running with the XCUITest driver installed.
- A real iPad that can run the Capacitor test app. A simulator may be useful for harness smoke tests, but it is not a substitute for the lab requested in issue #3.
- A built `.app` or `.ipa` containing this plugin and a Capacitor WebView.
- An SSH server reachable from that device.
- Credentials supplied through environment variables.

## Run

```bash
export RUN_APPIUM_SSH_E2E=1
export IOS_APP=/absolute/path/to/TestApp.app
export IOS_DEVICE_NAME='iPad'
export IOS_PLATFORM_VERSION='17.0'
export IOS_UDID='optional-real-device-udid'
export SSH_HOST='localhost'
export SSH_PORT=22
export SSH_USERNAME='jrandom'
export SSH_PASSWORD='password'

npm run test:e2e:ios
```

The test creates one SSH session, opens seven channels, verifies `echo hello world` on each shell, then repeatedly closes one shell and verifies that a remaining shell can still echo.
