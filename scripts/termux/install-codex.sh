#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

mkdir -p "$PREFIX/etc/apt"
printf 'deb https://packages.termux.dev/apt/termux-main stable main\n' > "$PREFIX/etc/apt/sources.list"

pkg update -y
pkg install -y nodejs-lts git ripgrep
npm install -g @mmmbuto/codex-cli-termux@latest

echo
codex --version
echo "Run: codex login"
