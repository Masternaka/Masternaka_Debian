#!/usr/bin/env bash
# Compilation utilisateur : aucun sudo et aucun écrasement de /usr/bin.
set -Eeuo pipefail
root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
# shellcheck source=../packages/versions.env
source "$root/packages/versions.env"
base="$HOME/.local/share/masternaka-debian"
build_root=$(mktemp -d)
prefix="$base/releases/picom-$PICOM_VERSION-rofi-$ROFI_VERSION-$(date +%Y%m%d%H%M%S)-$$"
complete=false
cleanup() {
    rm -rf -- "$build_root"
    if ! $complete; then rm -rf -- "$prefix"; fi
}
trap cleanup EXIT
mkdir -p "$prefix"
git init -q "$build_root/picom"
git -C "$build_root/picom" remote add origin https://github.com/yshui/picom.git
git -C "$build_root/picom" fetch --depth=1 origin "$PICOM_COMMIT"
git -C "$build_root/picom" checkout --detach FETCH_HEAD
[[ $(git -C "$build_root/picom" rev-parse HEAD) == "$PICOM_COMMIT" ]]
meson setup "$build_root/picom/build" "$build_root/picom" --prefix="$prefix" --buildtype=release --wrap-mode=nodownload -Dwith_docs=false
meson compile -C "$build_root/picom/build" -j 2
meson install -C "$build_root/picom/build"
curl --fail --location --proto '=https' --tlsv1.2 --retry 3 \
    "https://github.com/davatorium/rofi/releases/download/$ROFI_VERSION/rofi-$ROFI_VERSION.tar.gz" -o "$build_root/rofi.tar.gz"
printf '%s  %s\n' "$ROFI_SHA256" "$build_root/rofi.tar.gz" | sha256sum -c -
mkdir "$build_root/rofi"
tar -xzf "$build_root/rofi.tar.gz" --strip-components=1 -C "$build_root/rofi" --no-same-owner
meson setup "$build_root/rofi/build" "$build_root/rofi" --prefix="$prefix" --buildtype=release --wrap-mode=nodownload -Dwayland=disabled -Dxcb=enabled -Dcheck=enabled
meson compile -C "$build_root/rofi/build" -j 2
meson test -C "$build_root/rofi/build" --print-errorlogs
meson install -C "$build_root/rofi/build"
"$prefix/bin/picom" --version
"$prefix/bin/rofi" -v
# Basculer vers les deux nouveaux binaires uniquement si tout a réussi.
ln -s "$prefix" "$base/.current-$$"
mv -Tf "$base/.current-$$" "$base/current"
complete=true
printf 'Binaires installés : %s\n' "$prefix"
