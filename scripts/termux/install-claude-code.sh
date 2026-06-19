#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

mkdir -p "$HOME/tmp" "$HOME/.local/bin" "$PREFIX/etc/apt"
printf 'deb https://packages.termux.dev/apt/termux-main stable main\n' > "$PREFIX/etc/apt/sources.list"

pkg update -y
pkg install -y nodejs-lts git ripgrep

existing_claude=""
if [ -x "$PREFIX/bin/claude" ]; then
  existing_claude="$PREFIX/bin/claude"
elif command -v claude >/dev/null 2>&1; then
  candidate="$(command -v claude)"
  if [ "$candidate" != "$HOME/.local/bin/claude" ]; then
    existing_claude="$candidate"
  fi
fi

if [ -n "$existing_claude" ] && "$existing_claude" --version >/dev/null 2>&1; then
  claude_path="$existing_claude"
else
  npm install -g --allow-scripts=@anthropic-ai/claude-code @anthropic-ai/claude-code
fi

if [ -z "${claude_path:-}" ] && [ -x "$PREFIX/bin/claude" ]; then
  claude_path="$PREFIX/bin/claude"
elif [ -z "${claude_path:-}" ] && command -v claude >/dev/null 2>&1; then
  candidate="$(command -v claude)"
  if [ "$candidate" != "$HOME/.local/bin/claude" ]; then
    claude_path="$candidate"
  fi
fi

if [ -z "${claude_path:-}" ]; then
  echo "Claude Code installed, but no claude executable was found on PATH." >&2
  exit 1
fi

if ! "$claude_path" --version >/dev/null 2>&1; then
  claude_root="$(npm root -g)/@anthropic-ai/claude-code"
  if [ -f "$claude_root/install.cjs" ]; then
    (cd "$claude_root" && node install.cjs)
  fi
fi

cat > "$HOME/.local/bin/claude" <<SH
#!/data/data/com.termux/files/usr/bin/sh
export TMPDIR="\${TMPDIR:-\$HOME/tmp}"
export TMP_DIR="\${TMP_DIR:-\$HOME/tmp}"
export TEMP_DIR="\${TEMP_DIR:-\$HOME/tmp}"
exec "$claude_path" "\$@"
SH
chmod 0755 "$HOME/.local/bin/claude"

case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *)
    if [ -f "$HOME/.zshrc" ] && ! grep -q 'HOME/.local/bin' "$HOME/.zshrc"; then
      printf '\nexport PATH="$HOME/.local/bin:$PATH"\n' >> "$HOME/.zshrc"
    fi
    if [ -f "$HOME/.bashrc" ] && ! grep -q 'HOME/.local/bin' "$HOME/.bashrc"; then
      printf '\nexport PATH="$HOME/.local/bin:$PATH"\n' >> "$HOME/.bashrc"
    fi
    export PATH="$HOME/.local/bin:$PATH"
    ;;
esac

echo
"$HOME/.local/bin/claude" --version
echo "Run: claude"
