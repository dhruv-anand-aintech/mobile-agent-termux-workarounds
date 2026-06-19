#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

version="${OPENCODE_VERSION:-1.15.13}"
release_tag="${OPENCODE_TERMUX_RELEASE:-Push260522}"
repo="${OPENCODE_TERMUX_REPO:-Hope2333/opencode-termux}"
asset="opencode_${version}_aarch64.deb"
url="https://github.com/${repo}/releases/download/${release_tag}/${asset}"
mirror_base="${AINTECH_MIRROR_BASE:-https://mirror.aintech.link}"
mirror_url="${mirror_base%/}/github/${repo}/releases/download/${release_tag}/${asset}"

mkdir -p "$PREFIX/etc/apt"
printf 'deb https://packages.termux.dev/apt/termux-main stable main\n' > "$PREFIX/etc/apt/sources.list"

workdir="$(mktemp -d)"
trap 'rm -rf "$workdir"' EXIT

pkg update -y
pkg install -y curl dpkg openssl python ripgrep

cd "$workdir"
curl -fL -o "$asset" "$mirror_url" || curl -fL -o "$asset" "$url"
dpkg -i "$asset" || apt-get install -f -y

echo
opencode --version
opencode auth list || true
opencode models | head -40 || true
