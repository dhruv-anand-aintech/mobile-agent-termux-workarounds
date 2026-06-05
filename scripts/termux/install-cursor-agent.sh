#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

pkg update -y
pkg install -y curl git nodejs-lts ripgrep python make clang pkg-config binutils openssl-tool

installer="$(mktemp)"
trap 'rm -f "$installer"' EXIT

curl -fL https://gist.githubusercontent.com/wallentx/33c51158a044daf9a8548807a2d023c8/raw -o "$installer"
bash "$installer"

version_dir="$(find "$HOME/.local/share/cursor-agent/versions" -mindepth 1 -maxdepth 1 -type d | sort | tail -n 1)"
index_js="$version_dir/index.js"

mkdir -p "$PREFIX/etc/tls"
if [ ! -e "$PREFIX/etc/tls/certs" ] && [ -d "$PREFIX/etc/tls/cert.pem" ]; then
  rm -rf "$PREFIX/etc/tls/certs"
fi
if [ ! -e "$PREFIX/etc/tls/certs" ] && [ -d "$PREFIX/etc/ssl/certs" ]; then
  ln -s "$PREFIX/etc/ssl/certs" "$PREFIX/etc/tls/certs"
fi

ln -sf "$PREFIX/lib/libc++_shared.so" "$PREFIX/lib/libstdc++.so.6"
ln -sf "$PREFIX/lib/libc++_shared.so" "$PREFIX/lib/libstdc++.so"
cat > "$HOME/empty-gnu-compat.c" <<'C'
void __termux_gnu_compat_stub(void) {}
C
clang -shared -fPIC -Wl,-soname,libm.so.6 "$HOME/empty-gnu-compat.c" -o "$PREFIX/lib/libm.so.6"
clang -shared -fPIC -Wl,-soname,libc.so.6 "$HOME/empty-gnu-compat.c" -o "$PREFIX/lib/libc.so.6"
clang -shared -fPIC -Wl,-soname,libpthread.so.0 "$HOME/empty-gnu-compat.c" -o "$PREFIX/lib/libpthread.so.0"
clang -shared -fPIC -Wl,-soname,libdl.so.2 "$HOME/empty-gnu-compat.c" -o "$PREFIX/lib/libdl.so.2"
rm -f "$HOME/empty-gnu-compat.c"

if [ -e "$PREFIX/glibc/lib/libgcc_s.so.1" ]; then
  ln -sf "$PREFIX/glibc/lib/libgcc_s.so.1" "$PREFIX/lib/libgcc_s.so.1"
  ln -sf "$PREFIX/glibc/lib/libgcc_s.so" "$PREFIX/lib/libgcc_s.so"
fi

if ! find "$PREFIX" -name 'libgcc_s.so.1' -print -quit | grep -q .; then
  echo "warning: libgcc_s.so.1 is not present in this Termux prefix."
  echo "Cursor may still fail while loading node_sqlite3.node."
fi

node - "$index_js" <<'NODE'
const fs = require("fs");
const path = process.argv[2];
let src = fs.readFileSync(path, "utf8");
if (!src.includes("MerkleClient:class{constructor(){}}")) {
  const pattern = /if\(!c\)\{let n="Failed to load native binding for ".+?throw new Error\(n\)\}/s;
  const replacement = 'if(!c){c={MerkleClient:class{constructor(){}async build(){}async getTreeStructure(){return null}async getSimhash(){return[]}async getNumEmbeddableFiles(){return 0}},getParentProcessInfo:()=>null,MULTI_ROOT_ABSOLUTE_PATH:""};}';
  if (pattern.test(src)) {
    fs.copyFileSync(path, `${path}.orig`);
    src = src.replace(pattern, replacement);
    fs.writeFileSync(path, src);
  }
}
NODE

echo
LD_LIBRARY_PATH="$PREFIX/lib:${LD_LIBRARY_PATH:-}" cursor-agent --help
