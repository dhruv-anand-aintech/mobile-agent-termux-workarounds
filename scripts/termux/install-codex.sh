#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

pkg update -y
pkg install -y nodejs-lts git ripgrep
npm install -g @mmmbuto/codex-cli-termux@latest

echo
codex --version
echo "Run: codex login"
