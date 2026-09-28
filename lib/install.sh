#!/usr/bin/env bash
die() { printf 'Erreur : %s\n' "$*" >&2; exit 1; }
read_packages() {
    sed 's/#.*//; /^[[:space:]]*$/d; s/^[[:space:]]*//; s/[[:space:]]*$//' "$1"
}
deploy_config() {
    local root=$1 target="$HOME/.config/i3" staged backup
    mkdir -p "$HOME/.config"
    staged=$(mktemp -d "$HOME/.config/.masternaka-i3.XXXXXXXX")
    if ! cp -a "$root/i3/." "$staged/"; then
        rm -rf -- "$staged"
        die 'Copie impossible ; la configuration existante est intacte.'
    fi
    chmod +x "$staged/scripts/"* "$staged/polybar/polybar-i3"
    if [[ -e $target || -L $target ]]; then
        mkdir -p "$HOME/.local/state/masternaka-debian/backups"
        backup=$(mktemp -d "$HOME/.local/state/masternaka-debian/backups/$(date +%Y%m%d-%H%M%S).XXXXXXXX")
        mv -- "$target" "$backup/i3"
        printf 'Sauvegarde : %s/i3\n' "$backup"
    fi
    if ! mv -- "$staged" "$target"; then
        if [[ -n ${backup:-} ]]; then mv -- "$backup/i3" "$target"; fi
        rm -rf -- "$staged"
        die 'Déploiement impossible ; ancienne configuration restaurée.'
    fi
}
