# Contributing

This guide provides instructions for contributing to this Capacitor plugin.

## Developing

### Local Setup

1. Fork and clone the repo.
1. Install the dependencies.

    ```shell
    npm install
    ```

1. Install SwiftLint if you're on macOS.

    ```shell
    brew install swiftlint
    ```

### Scripts

#### `npm test`

Run the offline web unit tests with Node.js 18 or later after installing the
development dependencies. The test compiler builds the actual plugin source into
the ignored `.test-build/` directory; Node's built-in test runner then imports its
public entry with the real Capacitor dependency.

The tests check plugin registration, lazy loading, and the unsupported web API's
asynchronous `UNIMPLEMENTED` errors, including callback and concurrent-call
behavior. Network and native bridge calls are blocked during the tests. No SSH
server, credentials, Appium server, or native device is required.

This is web unit coverage only. It does not validate native SSH sessions or
channels and does not replace the real iPad/Mac/Appium/XCUITest lab requested in
[issue #3](https://github.com/tuzig/capacitor-ssh-plugin/issues/3).

#### `npm run build`

Build the plugin web assets and generate plugin API documentation using [`@capacitor/docgen`](https://github.com/ionic-team/capacitor-docgen).

It will compile the TypeScript code from `src/` into ESM JavaScript in `dist/esm/`. These files are used in apps with bundlers when your plugin is imported.

Then, Rollup will bundle the code into a single file at `dist/plugin.js`. This file is used in apps without bundlers by including it as a script in `index.html`.

#### `npm run verify`

Build and validate the web and native projects.

This is useful to run in CI to verify that the plugin builds for all platforms.

#### `npm run lint` / `npm run fmt`

Check formatting and code quality, autoformat/autofix if possible.

This template is integrated with ESLint, Prettier, and SwiftLint. Using these tools is completely optional, but the [Capacitor Community](https://github.com/capacitor-community/) strives to have consistent code style and structure for easier cooperation.

## Publishing

There is a `prepublishOnly` hook in `package.json` which prepares the plugin before publishing, so all you need to do is run:

```shell
npm publish
```

> **Note**: The [`files`](https://docs.npmjs.com/cli/v7/configuring-npm/package-json#files) array in `package.json` specifies which files get published. If you rename files/directories or add files elsewhere, you may need to update it.
