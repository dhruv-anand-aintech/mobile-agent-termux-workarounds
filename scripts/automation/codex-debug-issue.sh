#!/usr/bin/env bash
set -euo pipefail

issue_number="${ISSUE_NUMBER:?ISSUE_NUMBER is required}"
repo="${REPO:?REPO is required}"
avd_name="${ANDROID_AVD_NAME:-Pixel_8_API_35}"
workdir="${GITHUB_WORKSPACE:-$PWD}"
outdir="$workdir/.codex-issue-debug"
mkdir -p "$outdir"

log="$outdir/issue-${issue_number}.log"
report="$outdir/issue-${issue_number}-report.md"

post_comment() {
  gh issue comment "$issue_number" --repo "$repo" --body-file "$report" >/dev/null
}

find_emulator() {
  if command -v emulator >/dev/null 2>&1; then
    command -v emulator
    return 0
  fi

  for base in "${ANDROID_HOME:-}" "${ANDROID_SDK_ROOT:-}" "$HOME/Library/Android/sdk"; do
    if [ -n "$base" ] && [ -x "$base/emulator/emulator" ]; then
      printf '%s\n' "$base/emulator/emulator"
      return 0
    fi
  done

  return 1
}

{
  echo "== issue =="
  printf 'repo=%s\nissue=%s\nurl=%s\n' "$repo" "$issue_number" "${ISSUE_URL:-}"
  printf 'title=%s\n' "${ISSUE_TITLE:-}"
  echo
  echo "== tool versions =="
  command -v codex || true
  codex --version || true
  command -v adb || true
  adb version || true
  echo
  echo "== adb before =="
  adb devices -l || true
} > "$log" 2>&1

if emulator_path="$(find_emulator 2>/dev/null)"; then
  {
    echo
    echo "== emulator =="
    printf 'path=%s\navd=%s\n' "$emulator_path" "$avd_name"
    "$emulator_path" -list-avds || true
  } >> "$log" 2>&1

  if ! adb devices | awk 'NR > 1 && $2 == "device" { found=1 } END { exit !found }'; then
    nohup "$emulator_path" -avd "$avd_name" -no-snapshot-save -no-audio -no-boot-anim \
      > "$outdir/emulator-${issue_number}.log" 2>&1 &
    echo "$!" > "$outdir/emulator-${issue_number}.pid"
    adb wait-for-device || true
    timeout 180 bash -lc 'until adb shell getprop sys.boot_completed 2>/dev/null | grep -q 1; do sleep 3; done' || true
  fi
else
  {
    echo
    echo "== emulator =="
    echo "No emulator binary found on PATH or common Android SDK paths."
  } >> "$log"
fi

{
  echo
  echo "== adb after =="
  adb devices -l || true
  echo
  echo "== issue body =="
  printf '%s\n' "${ISSUE_BODY:-}"
  if [ -n "${COMMENT_BODY:-}" ]; then
    echo
    echo "== triggering comment =="
    printf '%s\n' "$COMMENT_BODY"
  fi
} >> "$log" 2>&1

prompt_file="$outdir/issue-${issue_number}-prompt.md"
cat > "$prompt_file" <<PROMPT
You are debugging an Android Termux workaround issue from GitHub.

Repository: $repo
Issue: #$issue_number
URL: ${ISSUE_URL:-}
Title: ${ISSUE_TITLE:-}

Issue body:
${ISSUE_BODY:-}

Triggering comment:
${COMMENT_BODY:-}

Local evidence is in:
$log

Task:
- Inspect the repository scripts.
- Use adb/emulator evidence if available.
- Do not make real external API calls.
- Produce a concise diagnosis and concrete patch suggestion.
- If you can safely patch files, do it.
- Write your final report to $report.
PROMPT

if codex exec --help >/dev/null 2>&1; then
  codex exec --full-auto --skip-git-repo-check "$(cat "$prompt_file")" >> "$log" 2>&1 || true
else
  codex "$(cat "$prompt_file")" >> "$log" 2>&1 || true
fi

if [ ! -s "$report" ]; then
  {
    echo "Codex debugger ran, but did not write a structured report."
    echo
    echo "Last log lines:"
    echo '```text'
    tail -80 "$log"
    echo '```'
  } > "$report"
fi

post_comment
