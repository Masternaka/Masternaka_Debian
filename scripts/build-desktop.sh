#!/usr/bin/env bash
# Compilation utilisateur : aucun sudo et aucun écrasement de /usr/bin.

build_error() { printf 'Erreur : %s\n' "$*" >&2; exit 1; }

build_preflight() {
    ((EUID != 0)) || build_error 'Lance ce script avec ton utilisateur normal, sans sudo.'
    [[ -r /etc/os-release ]] || build_error 'Debian 13 est requis.'
    # shellcheck source=/dev/null
    source /etc/os-release
    [[ $ID == debian && ${VERSION_ID:-} == 13 ]] || build_error 'Debian 13 est requis.'
    command -v flock >/dev/null || build_error 'flock manque (paquet util-linux).'
}

build_require_tools() {
    local cmd
    for cmd in git curl sha256sum tar meson ninja pkg-config cc; do
        command -v "$cmd" >/dev/null || build_error "Commande absente : $cmd. Voir packages/build.txt et docs/DEPENDANCES.md."
    done
}

build_picom() {
    local prefix=$1 work=$2
    git init -q "$work/picom"
    git -C "$work/picom" remote add origin https://github.com/yshui/picom.git
    git -C "$work/picom" fetch --depth=1 origin "$PICOM_COMMIT"
    git -C "$work/picom" checkout --detach FETCH_HEAD
    [[ $(git -C "$work/picom" rev-parse HEAD) == "$PICOM_COMMIT" ]] || build_error 'Commit Picom inattendu.'
    meson setup "$work/picom/build" "$work/picom" --prefix="$prefix" --buildtype=release --wrap-mode=nodownload -Dwith_docs=false
    meson compile -C "$work/picom/build" -j 2
    meson install -C "$work/picom/build"
}

build_rofi() {
    local prefix=$1 work=$2
    curl --fail --location --proto '=https' --tlsv1.2 --retry 3 \
        "https://github.com/davatorium/rofi/releases/download/$ROFI_VERSION/rofi-$ROFI_VERSION.tar.gz" -o "$work/rofi.tar.gz"
    printf '%s  %s\n' "$ROFI_SHA256" "$work/rofi.tar.gz" | sha256sum -c -
    mkdir "$work/rofi"
    tar -xzf "$work/rofi.tar.gz" --strip-components=1 -C "$work/rofi" --no-same-owner
    meson setup "$work/rofi/build" "$work/rofi" --prefix="$prefix" --buildtype=release --wrap-mode=nodownload -Dwayland=disabled -Dxcb=enabled -Dcheck=enabled
    meson compile -C "$work/rofi/build" -j 2
    meson test -C "$work/rofi/build" --print-errorlogs
    meson install -C "$work/rofi/build"
}

build_check_binary() {
    local name=$1 prefix=$2
    [[ -x $prefix/bin/$name ]] || return 1
    case "$name" in
        picom) "$prefix/bin/picom" --version ;;
        rofi) "$prefix/bin/rofi" -v ;;
    esac
}

# Les fichiers source-id sont des données locales, jamais exécutées comme du shell.
build_source_id() {
    case "$1" in
        picom) printf 'picom %s %s\n' "$PICOM_VERSION" "$PICOM_COMMIT" ;;
        rofi) printf 'rofi %s %s\n' "$ROFI_VERSION" "$ROFI_SHA256" ;;
    esac
}

build_main() (
    set -Eeuo pipefail
    local root base selection=all selected=false force=false rollback=false arg
    root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
    # shellcheck source=../packages/versions.env
    source "$root/packages/versions.env"
    for arg in "$@"; do
        case "$arg" in
            picom|rofi|all)
                $selected && build_error 'Choisis une seule sélection : picom, rofi ou all.'
                selection=$arg
                selected=true ;;
            --force) force=true ;;
            --rollback) rollback=true ;;
            --help|-h)
                printf '%s\n' 'Usage : ./scripts/build-desktop.sh [picom|rofi|all] [--force]' \
                    '        ./scripts/build-desktop.sh --rollback' \
                    'Sans argument : installer les deux versions fixées si nécessaire.' \
                    '--force : reconstruire la sélection, même si elle est déjà installée.' \
                    '--rollback : échanger les ensembles actuel et précédent, sans compiler.'
                return 0 ;;
            *) build_error "Option inconnue : $arg" ;;
        esac
    done
    if $rollback && { $force || $selected; }; then
        build_error '--rollback ne se combine pas avec une sélection ou --force.'
    fi
    build_preflight
    base="$HOME/.local/share/masternaka-debian"
    mkdir -p "$base/releases"
    # Une seule modification des liens et compilations à la fois par utilisateur.
    exec 9>"$base/.build.lock"
    flock -n 9 || build_error 'Une autre compilation ou restauration est en cours.'
    for arg in current previous; do
        [[ ! -e $base/$arg || -L $base/$arg ]] || build_error "$base/$arg doit être un lien symbolique."
    done
    # Variables du sous-shell : accessibles au trap EXIT même après une erreur.
    release=''
    complete=false
    local old='' previous='' name prefix source_id
    work=$(mktemp -d "$base/.build.XXXXXXXX")
    trap 'rm -rf -- "$work"; if ! $complete && [[ -n $release ]]; then rm -rf -- "$release"; fi' EXIT
    trap 'exit 130' INT
    trap 'exit 143' TERM
    if [[ -d $base/current ]]; then old=$(cd -- "$base/current" && pwd -P); fi
    if $rollback; then
        [[ -n $old && -d $base/previous ]] || build_error 'Aucun ensemble précédent disponible.'
        previous=$(cd -- "$base/previous" && pwd -P)
        for name in picom rofi; do
            build_check_binary "$name" "$previous" || build_error "Version précédente inutilisable : $name."
        done
        ln -s "$old" "$work/previous"
        ln -s "$previous" "$work/current"
        mv -Tf "$work/previous" "$base/previous"
        mv -Tf "$work/current" "$base/current"
        printf 'Ensemble restauré : %s\nReconnecte-toi pour relancer les composants.\n' "$previous"
        return 0
    fi
    [[ $PICOM_VERSION =~ ^[0-9]+([.][0-9]+)*$ && $PICOM_COMMIT =~ ^[0-9a-f]{40}$ &&
       $ROFI_VERSION =~ ^[0-9]+([.][0-9]+)*$ && $ROFI_SHA256 =~ ^[0-9a-f]{64}$ ]] || build_error 'Références invalides dans packages/versions.env.'
    local names=(picom rofi) prefixes=() rebuild=() needed=false i
    for name in "${names[@]}"; do
        prefix=''
        if [[ -n $old ]]; then
            # Migration : l’ancien installateur plaçait les deux binaires à la racine.
            if [[ -d $old/$name ]]; then prefix=$(cd -- "$old/$name" && pwd -P); else prefix=$old; fi
        fi
        prefixes+=("$prefix")
        source_id=$(build_source_id "$name")
        if [[ $selection != all && $selection != "$name" ]]; then
            [[ -n $prefix ]] && build_check_binary "$name" "$prefix" || build_error "Installe d’abord les deux logiciels sans argument ; $name manque."
            rebuild+=(false)
        elif ! $force && [[ -n $prefix && -r $prefix/source-id && $(cat "$prefix/source-id") == "$source_id" ]] && build_check_binary "$name" "$prefix"; then
            printf '%s : référence déjà installée, compilation évitée.\n' "$name"
            rebuild+=(false)
        else
            rebuild+=(true)
            needed=true
        fi
    done
    $needed || return 0
    build_require_tools
    release=$(mktemp -d "$base/releases/desktop.XXXXXXXX")
    mkdir "$release/bin"
    for i in 0 1; do
        name=${names[$i]}
        if ${rebuild[$i]}; then
            mkdir "$release/$name"
            "build_$name" "$release/$name" "$work"
            build_check_binary "$name" "$release/$name" || build_error "Binaire inutilisable après compilation : $name."
            build_source_id "$name" > "$release/$name/source-id"
        else
            ln -s "${prefixes[$i]}" "$release/$name"
        fi
        ln -s "../$name/bin/$name" "$release/bin/$name"
    done
    # Activation seulement quand toute la sélection a réussi ; les anciens dossiers restent.
    if [[ -n $old ]]; then
        ln -s "$old" "$work/previous"
        mv -Tf "$work/previous" "$base/previous"
    fi
    ln -s "$release" "$work/current"
    # Ne plus supprimer cet ensemble complet si un signal arrive pendant l’activation.
    complete=true
    mv -Tf "$work/current" "$base/current"
    printf 'Ensemble activé : %s\nReconnecte-toi pour relancer les composants.\n' "$release"
)

if [[ ${BASH_SOURCE[0]} == "$0" ]]; then build_main "$@"; fi
