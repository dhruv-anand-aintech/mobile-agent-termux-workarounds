#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

workdir="$(mktemp -d)"
trap 'rm -rf "$workdir"' EXIT

pkg update -y
pkg install -y curl unzip ripgrep clang

cd "$workdir"
curl -fL -o opencode-aarch64.zip \
  https://github.com/guysoft/opencode-termux/releases/latest/download/opencode-aarch64.zip
unzip -o opencode-aarch64.zip
install -m 0755 opencode "$PREFIX/bin/opencode.real"

cat > "$HOME/disable-tagged-pointer.c" <<'C'
#include <stddef.h>
extern int mallopt(int param, int value);
__attribute__((constructor)) static void disable_tagged_pointer_hook(void) {
  mallopt(-204, 0);
}
C
clang -shared -fPIC "$HOME/disable-tagged-pointer.c" -o "$HOME/libdisable-tagged-pointer.so"
rm -f "$HOME/disable-tagged-pointer.c"

cat > "$PREFIX/bin/opencode" <<'SH'
#!/data/data/com.termux/files/usr/bin/sh
export LD_PRELOAD="$HOME/libdisable-tagged-pointer.so${LD_PRELOAD:+:$LD_PRELOAD}"
exec "$PREFIX/bin/opencode.real" "$@"
SH
chmod 0755 "$PREFIX/bin/opencode"

echo
opencode --version
