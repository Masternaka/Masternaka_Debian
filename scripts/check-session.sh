#!/usr/bin/env bash
set -euo pipefail
root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
# shellcheck source=../packages/versions.env
source "$root/packages/versions.env"
export PATH="$HOME/.local/share/masternaka-debian/current/bin:$PATH"
for cmd in i3 sxhkd picom polybar rofi dunst kitty thunar firefox-esr pamixer xss-lock i3lock; do
    command -v "$cmd" >/dev/null || { printf 'Commande absente : %s\n' "$cmd" >&2; exit 1; }
done
picom_version=$(picom --version | sed -nE 's/^v?([0-9]+(\.[0-9]+)*).*/\1/p')
rofi_version=$(rofi -v | sed -nE 's/^Version: ([0-9]+(\.[0-9]+)*).*/\1/p')
[[ -n $picom_version && -n $rofi_version ]]
dpkg --compare-versions "$picom_version" ge "$PICOM_VERSION" || { printf 'Picom attendu : %s ou supérieur.\n' "$PICOM_VERSION" >&2; exit 1; }
dpkg --compare-versions "$rofi_version" ge "$ROFI_VERSION" || { printf 'Rofi attendu : %s ou supérieur.\n' "$ROFI_VERSION" >&2; exit 1; }
printf 'Picom %s ; Rofi %s\n' "$picom_version" "$rofi_version"
polybar --version | head -n 1
i3 -C -c "$HOME/.config/i3/config"
printf 'Commandes et syntaxe i3 vérifiées.\n'
