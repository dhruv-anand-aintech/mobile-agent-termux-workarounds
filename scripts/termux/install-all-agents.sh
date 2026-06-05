#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

base_url="${MOBILE_AGENTS_BASE_URL:-https://raw.githubusercontent.com/dhruv-anand-aintech/mobile-agent-termux-workarounds/main}"

curl -fsSL "$base_url/scripts/termux/install-claude-code.sh" | bash
curl -fsSL "$base_url/scripts/termux/install-codex.sh" | bash
curl -fsSL "$base_url/scripts/termux/install-opencode.sh" | bash
curl -fsSL "$base_url/scripts/termux/install-cursor-agent.sh" | bash
