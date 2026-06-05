# Mobile Agent Termux Workarounds

Short Termux installers for mobile coding agents on Android.

## Codex

```sh
curl -fsSL https://raw.githubusercontent.com/dhruv-anand-aintech/mobile-agent-termux-workarounds/main/scripts/termux/install-codex.sh | bash
```

Then log in:

```sh
codex login
```

## OpenCode

```sh
curl -fsSL https://raw.githubusercontent.com/dhruv-anand-aintech/mobile-agent-termux-workarounds/main/scripts/termux/install-opencode.sh | bash
```

Check:

```sh
opencode --version
```

## Cursor Agent

```sh
curl -fsSL https://raw.githubusercontent.com/dhruv-anand-aintech/mobile-agent-termux-workarounds/main/scripts/termux/install-cursor-agent.sh | bash
```

Check:

```sh
cursor-agent --help
```

## Install All

```sh
curl -fsSL https://raw.githubusercontent.com/dhruv-anand-aintech/mobile-agent-termux-workarounds/main/scripts/termux/install-all-agents.sh | bash
```

## What These Scripts Do

- `install-codex.sh`: installs Node.js and the Termux-compatible Codex package.
- `install-opencode.sh`: installs the OpenCode Android aarch64 binary and wraps it with an Android tagged-pointer compatibility shim.
- `install-cursor-agent.sh`: runs the Cursor Agent Termux installer, patches the Merkle native binding fallback, and adds GNU-style compatibility libraries needed by native modules.

## Current Cursor Caveat

Cursor Agent can still fail on Android if its bundled `node_sqlite3.node` asks for `libgcc_s.so.1`. That native module is not consistently available in Termux. The next durable fix is to rebuild or replace sqlite3 with an Android-compatible native module.
