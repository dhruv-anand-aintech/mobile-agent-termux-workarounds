# Mobile Agent Termux Workarounds

Short Termux installers for mobile coding agents on Android.

Shortlinks are served by the separate `aintech-link-shortlinks` Worker repo.

## Fragility Note

These workarounds are fragile and were written by Codex against real Android/Termux failures. Agent CLIs, native modules, Termux packages, and Android linker behavior change often. If a script stops working, please file an issue with the command output and device details; a bot will look at it and try to fix the workaround.

Issue debugging is push-based through GitHub Actions, not polling. New issues and `/codex-debug` comments can trigger a Codex workflow on a self-hosted Mac runner with `adb` and an optional Android emulator.

## Claude Code

```sh
curl -fsSL https://aintech.link/claude | bash
```

Check:

```sh
claude --version
```

## Codex

```sh
curl -fsSL https://aintech.link/codex | bash
```

Then log in:

```sh
codex login
```

## OpenCode

```sh
curl -fsSL https://aintech.link/opencode | bash
```

Check:

```sh
opencode --version
```

## Cursor Agent

```sh
curl -fsSL https://aintech.link/cursor | bash
```

Check:

```sh
cursor-agent --help
```

## Install All

```sh
curl -fsSL https://aintech.link/all | bash
```

## What These Scripts Do

- `install-claude-code.sh`: installs Node.js, installs `@anthropic-ai/claude-code`, and wraps `claude` with Termux-safe temp directories.
- `install-codex.sh`: installs Node.js and the Termux-compatible Codex package.
- `install-opencode.sh`: installs the OpenCode 1.15.13 Android aarch64 Termux package.
- `install-cursor-agent.sh`: runs the Cursor Agent Termux installer, patches the Merkle native binding fallback, fixes Termux TLS cert lookup, and replaces the bundled Linux `node_sqlite3.node` with the Android-built sqlite3 module that the installer already compiles.

## Current Cursor Status

On the tested phone, `cursor-agent --help` works after the sqlite replacement. After authenticating with `cursor-agent login`, `cursor-agent status`, `cursor-agent models`, and this headless smoke test also worked:

```sh
cursor-agent --print --trust --mode ask --model auto "Reply with exactly: CURSOR_ANDROID_OK"
```
