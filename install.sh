#!/usr/bin/env bash
# Masternaka Debian — installation autonome, 2026-09-28.
set -Eeuo pipefail
ROOT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=lib/install.sh
source "$ROOT_DIR/lib/install.sh"
only_config=false
dry_run=false
assume_yes=false
while (($#)); do
    case "$1" in
        --only-config) only_config=true ;;
        --dry-run) dry_run=true ;;
        --yes) assume_yes=true ;;
        --help|-h)
            printf '%s\n' 'Usage : ./install.sh [--only-config] [--dry-run] [--yes]' \
                'Installation : Debian 13 minimal, utilisateur normal avec sudo.' \
                '--only-config : configurations uniquement, sans sudo ni réseau.' \
                '--dry-run : afficher les actions sans rien modifier.' \
                '--yes : accepter la confirmation initiale.'
            exit 0 ;;
        *) die "Option inconnue : $1" ;;
    esac
    shift
done
mapfile -t packages < <(read_packages "$ROOT_DIR/packages/base.txt"; read_packages "$ROOT_DIR/packages/build.txt")
if $dry_run; then
    printf 'Mode simulation — aucun changement.\nDestination : %s/.config/i3\n' "$HOME"
    printf 'Les configurations existantes seront sauvegardées automatiquement.\n'
    if ! $only_config; then
        printf 'Paquets (sources officielles trixie, trixie-updates et trixie-security) :\n%s\n' "${packages[*]}"
        printf 'Services activés pour le prochain démarrage : LightDM et NetworkManager.\n'
        printf 'Picom et Rofi : références de packages/versions.env, compilation seulement si nécessaire.\n'
    fi
    exit 0
fi
((EUID != 0)) || die 'Lance ce script avec ton utilisateur normal, sans sudo devant ./install.sh.'
[[ -z ${XDG_CONFIG_HOME:-} || $XDG_CONFIG_HOME == "$HOME/.config" ]] || die 'Cette configuration utilise ~/.config ; XDG_CONFIG_HOME personnalisé non pris en charge.'
if ! $only_config; then
    # shellcheck source=/dev/null
    source /etc/os-release
    [[ $ID == debian && ${VERSION_ID:-} == 13 ]] || die 'Seule Debian 13 (trixie) est prise en charge.'
    [[ -z ${SSH_CONNECTION:-} && -z ${DISPLAY:-} && -z ${WAYLAND_DISPLAY:-} ]] || die 'Lance l’installation complète depuis une console locale, hors session graphique.'
    command -v sudo >/dev/null || die 'sudo est requis. Voir les prérequis du README.'
    if [[ -s /etc/X11/default-display-manager ]]; then
        [[ $(cat /etc/X11/default-display-manager) == /usr/sbin/lightdm ]] || die 'Un autre gestionnaire de connexion existe. Utilise --only-config.'
    fi
    if systemctl is-active --quiet lightdm.service; then
        die 'LightDM est actif. Arrête la session graphique avant une installation complète.'
    fi
fi
if ! $assume_yes; then
    read -r -p 'Installer Masternaka Debian et sauvegarder les configurations existantes ? [o/N] ' answer
    [[ $answer =~ ^[oOyY]$ ]] || exit 0
fi
if ! $only_config; then
    sudo -v
    # Sources limitées à Debian pour ces commandes, sans réécrire /etc/apt.
    apt_options=(-o "Dir::Etc::sourcelist=$ROOT_DIR/packages/debian.sources" -o 'Dir::Etc::sourceparts=-')
    sudo apt-get "${apt_options[@]}" update
    sudo apt-get "${apt_options[@]}" --simulate install "${packages[@]}"
    case $(systemctl is-enabled lightdm.service 2>/dev/null || true) in
        masked*) die 'LightDM est déjà masqué ; résoudre cette configuration avant installation.' ;;
    esac
    sudo systemctl mask --runtime lightdm.service
    trap 'sudo systemctl unmask --runtime lightdm.service' EXIT
    sudo apt-get "${apt_options[@]}" install -y "${packages[@]}"
    "$ROOT_DIR/scripts/build-desktop.sh"
    sudo systemctl unmask --runtime lightdm.service
    trap - EXIT
    # Ne pas basculer le réseau ni démarrer LightDM au milieu de l’installation.
    sudo systemctl enable NetworkManager.service lightdm.service
    sudo systemctl set-default graphical.target
fi
deploy_config "$ROOT_DIR"
if command -v xdg-user-dirs-update >/dev/null; then xdg-user-dirs-update; fi
mkdir -p "$HOME/Screenshots"
printf '\nConfiguration installée dans %s/.config/i3\n' "$HOME"
printf 'Guide : %s/QUICKSTART.md\n' "$ROOT_DIR"
if ! $only_config; then
    printf 'Redémarre quand tu es prêt, puis sélectionne i3 dans LightDM.\n'
    printf 'Une interface déclarée dans /etc/network/interfaces reste gérée par ifupdown. Voir README.\n'
fi
