#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

BASE_URL="${MOBILE_AGENTS_BASE_URL:-https://raw.githubusercontent.com/dhruv-anand-aintech/mobile-agent-termux-workarounds/main}"

setup_termux() {
  mkdir -p "$HOME/.termux" "$HOME/tmp" "$HOME/.local/bin"
  chmod 700 "$HOME/tmp" 2>/dev/null || true

  if [ -f "$HOME/.termux/termux.properties" ]; then
    sed -i 's/^# *allow-external-apps *= *true/allow-external-apps = true/' "$HOME/.termux/termux.properties"
  fi
  grep -q '^allow-external-apps *= *true' "$HOME/.termux/termux.properties" 2>/dev/null || \
    printf '\nallow-external-apps = true\n' >> "$HOME/.termux/termux.properties"
  termux-reload-settings >/dev/null 2>&1 || true

  export TMPDIR="${TMPDIR:-$HOME/tmp}"
  export TMP_DIR="${TMP_DIR:-$HOME/tmp}"
  export TEMP_DIR="${TEMP_DIR:-$HOME/tmp}"
  export PATH="$HOME/.local/bin:$PREFIX/bin:$PATH"
}

install_script() {
  case "$1" in
    claude) printf 'install-claude-code.sh' ;;
    codex) printf 'install-codex.sh' ;;
    opencode) printf 'install-opencode.sh' ;;
    cursor) printf 'install-cursor-agent.sh' ;;
    *) return 1 ;;
  esac
}

agent_label() {
  case "$1" in
    claude) printf 'Claude Code' ;;
    codex) printf 'Codex' ;;
    opencode) printf 'OpenCode' ;;
    cursor) printf 'Cursor Agent' ;;
    *) printf '%s' "$1" ;;
  esac
}

next_command() {
  case "$1" in
    claude) printf 'claude' ;;
    codex) printf 'codex login' ;;
    opencode) printf 'opencode auth login' ;;
    cursor) printf 'cursor-agent login' ;;
  esac
}

run_installer() {
  agent="$1"
  script="$(install_script "$agent")"
  label="$(agent_label "$agent")"

  printf '\n==> Installing %s\n\n' "$label"
  if [ -f "$HOME/mobile-agent-termux-workarounds/scripts/termux/$script" ]; then
    bash "$HOME/mobile-agent-termux-workarounds/scripts/termux/$script"
  else
    curl -fsSL "$BASE_URL/scripts/termux/$script" | bash
  fi

  printf '\n==> %s install step finished.\n' "$label"
  printf 'Next auth command: %s\n' "$(next_command "$agent")"
}

choose_agents() {
  SELECTED_AGENTS=""
  clear || true
  cat <<'EOF'
Mobile Agent Termux Setup

Choose the agents to install. Each selected agent runs one at a time.

Press Enter for the default shown in brackets.

EOF

  for agent in claude codex opencode cursor; do
    label="$(agent_label "$agent")"
    while true; do
      printf 'Install %s? [y/N] ' "$label"
      IFS= read -r answer || answer=n
      answer="${answer:-n}"
      case "$answer" in
        y|Y|yes|YES|y*|Y*)
          SELECTED_AGENTS="${SELECTED_AGENTS:+$SELECTED_AGENTS }$agent"
          break
          ;;
        n|N|no|NO|n*|N*)
          break
          ;;
        *)
          break
          ;;
      esac
    done
  done

  if [ -z "$SELECTED_AGENTS" ]; then
    printf '\nNo agents selected. Exiting.\n'
    exit 0
  fi

  printf '\nSelected:'
  for agent in $SELECTED_AGENTS; do
    printf ' %s' "$(agent_label "$agent")"
  done
  printf '\n\nPress Enter to start installing.'
  IFS= read -r _ || true
}

setup_termux

cat <<EOF
Mobile Agent Termux Setup

This script installs agent CLIs into this Termux app data directory:

  PREFIX=$PREFIX
  HOME=$HOME

It uses the latest workaround scripts from:

  $BASE_URL
EOF

printf '\nPress Enter to choose agents.'
IFS= read -r _ || true

choose_agents
for agent in $SELECTED_AGENTS; do
  run_installer "$agent"
  printf '\n'
  case "$SELECTED_AGENTS" in
    *" "*)
      printf 'Press Enter to continue to the next selected agent.'
      IFS= read -r _ || true
      ;;
  esac
done

cat <<'EOF'

Install flow finished.

Authenticate one agent at a time:

  claude
  codex login
  opencode auth login
  cursor-agent login
EOF
