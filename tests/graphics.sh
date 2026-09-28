#!/usr/bin/env bash
set -euo pipefail
export PATH="$HOME/.local/share/masternaka-debian/current/bin:$PATH"
dir="$HOME/.config/i3"
i3 -C -c "$dir/config"
for theme in "$dir/rofi/"*.rasi; do
    case $theme in */colors.rasi) continue ;; esac
    rofi -no-config -theme "$theme" -dump-theme >/dev/null
done
picom --config "$dir/picom/picom.conf" --diagnostics
# Vérifier un démarrage réel, puis arrêter les processus du test.
children=()
cleanup() { if ((${#children[@]})); then kill "${children[@]}" 2>/dev/null || true; fi; }
trap cleanup EXIT
i3 -c "$dir/config" > /tmp/i3-test.log 2>&1 &
children+=("$!")
sleep 3
pgrep -u "$(id -u)" -x picom >/dev/null || { cat /tmp/i3-test.log; exit 1; }
pgrep -u "$(id -u)" -x polybar >/dev/null
pgrep -u "$(id -u)" -x dunst >/dev/null
for theme in "$dir/themes/"*/; do
    "$dir/scripts/thememenu" "$(basename "$theme")"
done
