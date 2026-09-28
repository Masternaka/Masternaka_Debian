#!/usr/bin/env bash
# Adaptation Masternaka, 2026-09-28 : session et services locaux.
set -u
dir="$HOME/.config/i3"
export PATH="$HOME/.local/share/masternaka-debian/current/bin:$PATH"
"$dir/polybar/polybar-i3" &
lxpolkit &
xsettingsd -c "$dir/xsettingsd.conf" &
dunst -config "$dir/dunst/dunstrc" &
picom --config "$dir/picom/picom.conf" &
nm-applet &
xfce4-power-manager &
xss-lock --transfer-sleep-lock -- i3lock --nofork &
sxhkd -c "$dir/sxhkd/sxhkdrc" &
"$dir/scripts/background"
notify-send -t 10000 'Masternaka Debian' 'Super + / : raccourcis • Super + Maj + T : thèmes'
