# Dépendances de Masternaka Debian

Mis à jour le 28 septembre 2026. Cible : **Debian 13 Stable (trixie), avec i3/X11**.

## 1. Portée de l’inventaire

Ce document inventorie toutes les dépendances **explicitement déclarées par le
projet actuel**, les outils système utilisés par ses scripts et les outils de
validation. Les listes de référence sont `packages/base.txt`, `packages/build.txt`,
`packages/versions.env` et les scripts de `tests/`.

Les bibliothèques installées indirectement par APT ne sont pas figées une par une :
leur liste et leurs versions varient selon l’architecture, les mises à jour de
sécurité et les paquets déjà présents. La section 7 explique comment obtenir
l’inventaire exact d’une installation. Ce document ne prétend pas fournir un
fichier de verrouillage de toutes les dépendances transitives.

**Les commandes d’installation ci-dessous s’exécutent sur Debian 13, pas sur macOS.**
Aucun workflow GitHub Actions n’est actuellement fourni ; voir
`docs/PUBLICATION_MAC.md` pour les limites des vérifications depuis un Mac.

## 2. Debian Stable et composants externes

| Composant | Version dans Debian 13 observée lors de l’audit | Version retenue | Origine utilisée |
|---|---|---|---|
| Picom | 12.5-1 | **13** | Dépôt officiel `yshui/picom`, compilation au commit fixé |
| Rofi | 1.7.5-0.1 (révision variable selon l’architecture) | **2.0.0** | Archive officielle `davatorium/rofi`, SHA-256 fixé |
| Polybar | 3.7.2 | Version du paquet trixie | Debian Stable |
| Kitty | Version du paquet trixie et ses mises à jour | Paquet Debian | Debian Stable |
| Autres paquets des sections 3 et 4 | Versions résolues par APT | Paquets Debian | Debian Stable |
| Configurations, scripts et douze palettes | Fichiers du projet | Version du dépôt Masternaka | Inclus dans le projet |

Versions Debian de Picom et Rofi revérifiées le 28 septembre 2026 sur les
[fiches Picom](https://packages.debian.org/trixie/picom) et
[Rofi](https://packages.debian.org/trixie/rofi). Cette vérification établit leur
disponibilité, pas la compatibilité de la configuration. Les versions des autres
paquets n’ont pas été revérifiées lors de ce contrôle.

**Picom et Rofi existent dans Debian Stable : ce sont les versions retenues ici
qui sont externes aux suites Stable utilisées.** On ne dit donc pas que ces deux
logiciels sont entièrement absents de Debian. Le projet n’utilise ni Testing/Sid
ni les backports pour les obtenir. Les versions de Stable peuvent évoluer ; les
valeurs ci-dessus décrivent l’audit, pas une garantie permanente.

Le projet conserve Picom 13 et Rofi 2.0.0 par choix de maintenance de versions
récentes, indépendantes de Debian Stable. Picom conserve les animations et les
règles du bureau. Les animations existent déjà en Picom 12 :
Picom 13 n’est pas présenté comme un minimum prouvé pour chaque option.
De même, l’archive d’origine ne déclare pas de minimum Rofi ; 2.0.0 est la version
fixée pour cette adaptation, pas un minimum technique démontré.

### Références exactes des composants externes

Source de vérité : `packages/versions.env`.

```text
PICOM_VERSION=13
PICOM_COMMIT=d87a5ba3af7a9ee3c4e040ee29b2dea7e9e46317
ROFI_VERSION=2.0.0
ROFI_SHA256=f81659b175306ff487e35d88d6b36128e85a793bfb56b64fa22c62eb54c4abd0
```

- Picom : https://github.com/yshui/picom ; récupération du commit complet, puis
  comparaison avec `git rev-parse HEAD` avant compilation.
- Rofi : https://github.com/davatorium/rofi/releases/tag/2.0.0 ; téléchargement de
  `rofi-2.0.0.tar.gz`, puis vérification SHA-256 avant extraction.
- Archive Rofi utilisée :
  https://github.com/davatorium/rofi/releases/download/2.0.0/rofi-2.0.0.tar.gz

Le commit Git fixé identifie les sources Picom ; il n’est pas une vérification
de signature de l’auteur. Le SHA-256 Rofi provient des métadonnées de sa publication
GitHub et détecte un changement du fichier attendu. Aucun script d’installation
distant n’est exécuté. Les systèmes de compilation contenus dans ces sources sont,
eux, exécutés localement sans privilèges administrateur.

## 3. Dépendances Debian du bureau

**51 paquets explicitement demandés** dans `packages/base.txt`. Tous sont
installés par APT ; Picom et Rofi Debian restent présents comme solutions de secours.

| Paquet Debian | Utilisation dans le projet |
|---|---|
| `xorg` | Serveur et environnement X11 (métapaquet). |
| `xinit` | Démarrage manuel d’une session X avec startx. |
| `dbus-x11` | Intégration D-Bus des sessions X11. |
| `lightdm` | Gestionnaire de connexion graphique. |
| `lightdm-gtk-greeter` | Écran de connexion GTK de LightDM. |
| `i3-wm` | Gestionnaire de fenêtres i3 et commande i3-msg. |
| `sxhkd` | Gestion des raccourcis clavier. |
| `xdotool` | Recherche des fenêtres des terminaux escamotables. |
| `x11-xserver-utils` | Utilitaires X11, dont xsetroot pour le fond uni. |
| `xss-lock` | Déclenchement du verrouillage, notamment avant la veille. |
| `i3lock` | Verrouillage de l’écran. |
| `picom` | Version Debian de secours ; la session privilégie Picom 13 compilé. |
| `polybar` | Barre d’état et zone de notification. |
| `rofi` | Version Debian de secours ; la session privilégie Rofi 2.0.0 compilé. |
| `dunst` | Notifications du bureau et du volume. |
| `libnotify-bin` | Commande notify-send utilisée par les scripts. |
| `feh` | Affichage du fond d’écran personnel facultatif. |
| `xsettingsd` | Application des paramètres GTK, des icônes et des polices. |
| `lxpolkit` | Agent d’authentification graphique PolicyKit. |
| `network-manager` | Gestion des connexions réseau. |
| `network-manager-gnome` | Applet réseau nm-applet. |
| `xfce4-power-manager` | Gestion de l’énergie dans la session i3. |
| `brightnessctl` | Réglage de la luminosité sur le matériel compatible. |
| `thunar` | Gestionnaire de fichiers. |
| `thunar-archive-plugin` | Actions d’archivage dans Thunar. |
| `thunar-volman` | Intégration des supports amovibles. |
| `file-roller` | Gestionnaire d’archives utilisé par Thunar. |
| `gvfs-backends` | Accès aux emplacements et protocoles distants. |
| `gvfs-fuse` | Accès aux montages GVfs depuis les applications classiques. |
| `xdg-user-dirs` | Création des dossiers utilisateur standards. |
| `xdg-utils` | Intégration des applications et ouverture des fichiers/URL. |
| `unzip` | Extraction d’archives ZIP. |
| `kitty` | Terminal principal et terminaux escamotables. |
| `firefox-esr` | Navigateur Web. |
| `geany` | Éditeur de texte graphique. |
| `flameshot` | Captures d’écran. |
| `qimgv` | Visionneuse d’images. |
| `gsimplecal` | Calendrier ouvert depuis Polybar. |
| `pipewire-audio` | Ensemble audio PipeWire (métapaquet). |
| `pavucontrol` | Réglage graphique du son. |
| `pulsemixer` | Mixeur audio dans le terminal. |
| `pamixer` | Réglage du volume par les raccourcis. |
| `fonts-dejavu-core` | Polices utilisées par les configurations adaptées. |
| `fonts-font-awesome` | Police d’icônes déclarée dans Polybar. |
| `fonts-noto-color-emoji` | Prise en charge des émojis. |
| `gnome-themes-extra` | Thème GTK Adwaita, dont la variante sombre. |
| `papirus-icon-theme` | Icônes Papirus/Papirus-Dark. |
| `procps` | Commandes pgrep et pkill utilisées par les scripts. |
| `psmisc` | Utilitaires de gestion des processus ; paquet conservé dans le manifeste. |
| `util-linux` | `flock`, verrou obligatoire de `scripts/build-desktop.sh` ; version du paquet non vérifiée. Également `runuser` pour les tests Linux. |
| `ca-certificates` | Certificats racines pour les connexions HTTPS. |

Les métapaquets regroupent plusieurs composants : `pipewire-audio` apporte
notamment les composants audio PipeWire, la compatibilité PulseAudio et le
gestionnaire de session audio via ses dépendances. APT choisit et installe ces
sous-paquets ; ils ne sont pas téléchargés depuis les dépôts de JustAGuyLinux.
`xorg` apporte également des outils et composants X11 supplémentaires.

## 4. Dépendances Debian de compilation

**45 paquets explicitement demandés** dans `packages/build.txt`.
Ils servent à construire les versions externes de Picom et Rofi sur Debian 13.
Les bibliothèques nécessaires à l’exécution sont installées par les dépendances
APT correspondantes. Ne pas supprimer manuellement leurs paquets d’exécution
après compilation.

| Paquet Debian | Utilisation dans le projet |
|---|---|
| `build-essential` | Compilateur C/C++, make et outillage de compilation de base (métapaquet). |
| `git` | Récupération de Picom au commit fixé. |
| `curl` | Téléchargement de l’archive officielle Rofi. |
| `meson` | Configuration, compilation, installation et tests des projets. |
| `ninja-build` | Moteur de compilation utilisé par Meson. |
| `pkg-config` | Détection des bibliothèques de développement. |
| `flex` | Génération d’analyseurs lexicaux pour Rofi. |
| `bison` | Génération d’analyseurs syntaxiques pour Rofi. |
| `check` | Bibliothèque de tests activée pour Rofi. |
| `libconfig-dev` | Lecture de la configuration Picom. |
| `libdbus-1-dev` | Intégration D-Bus de Picom. |
| `libegl-dev` | Interface graphique EGL de Picom. |
| `libev-dev` | Boucle d’événements de Picom. |
| `libgl-dev` | Interface OpenGL de Picom. |
| `libepoxy-dev` | Chargement des fonctions graphiques GL/EGL de Picom. |
| `libpcre2-dev` | Expressions régulières des règles Picom. |
| `libpixman-1-dev` | Manipulation des pixels et régions dans Picom. |
| `libx11-xcb-dev` | Interconnexion Xlib/XCB pour Picom. |
| `libxcb1-dev` | Bibliothèque XCB de base (Picom et Rofi). |
| `libxcb-composite0-dev` | Extension Composite utilisée par Picom. |
| `libxcb-damage0-dev` | Détection des régions modifiées, Picom. |
| `libxcb-glx0-dev` | Extension GLX, Picom. |
| `libxcb-image0-dev` | Gestion des images XCB, Picom. |
| `libxcb-present-dev` | Présentation des images, Picom. |
| `libxcb-randr0-dev` | Gestion des écrans et de leurs dimensions. |
| `libxcb-render0-dev` | Extension Render de X11, Picom. |
| `libxcb-render-util0-dev` | Utilitaires de rendu XCB, Picom. |
| `libxcb-shape0-dev` | Formes des fenêtres X11, Picom. |
| `libxcb-util-dev` | Utilitaires XCB communs. |
| `libxcb-xfixes0-dev` | Extension XFixes, Picom. |
| `uthash-dev` | Structures de hachage utilisées par Picom. |
| `libpango1.0-dev` | Rendu du texte dans Rofi. |
| `libcairo2-dev` | Rendu graphique de Rofi. |
| `libglib2.0-dev` | GLib, GIO, modules et compilation des ressources de Rofi. |
| `libgdk-pixbuf-2.0-dev` | Chargement des images et icônes dans Rofi. |
| `libstartup-notification0-dev` | Notifications de lancement des applications, Rofi. |
| `libxkbcommon-dev` | Traitement du clavier dans Rofi. |
| `libxkbcommon-x11-dev` | Intégration X11 du clavier, Rofi. |
| `libxcb-xkb-dev` | Extension clavier XCB pour Rofi. |
| `libxcb-ewmh-dev` | Propriétés et conventions des gestionnaires de fenêtres, Rofi. |
| `libxcb-icccm4-dev` | Conventions de communication entre clients X11, Rofi. |
| `libxcb-cursor-dev` | Gestion des curseurs, Rofi. |
| `libxcb-xinerama0-dev` | Informations multi-écrans Xinerama, Rofi. |
| `libxcb-keysyms1-dev` | Symboles de touches X11, Rofi. |
| `libxcb-imdkit-dev` | Prise en charge des méthodes de saisie X11 de Rofi. |

Meson utilise `--wrap-mode=nodownload` : une bibliothèque manquante provoque un
échec au lieu d’un téléchargement implicite. Les composants embarqués dans les
sources officielles, tels que les sous-projets de Rofi, sont ceux de l’archive
fixée ; ils ne constituent pas des téléchargements indépendants du projet.
Rofi est construit avec X11 activé, Wayland désactivé et ses tests `check` activés.
Picom est compilé sans génération de documentation (`-Dwith_docs=false`).
La compilation est limitée à deux tâches parallèles (`-j 2`).

## 5. Prérequis système et dépendances de validation

### Outils déjà fournis par Debian ou à préparer

Ces composants complètent les manifestes ; l’installateur ne constitue pas un
système Linux autonome et suppose une installation Debian fonctionnelle.

| Paquet ou composant | Usage |
|---|---|
| `bash` | Exécution des scripts et utilisation des tableaux Bash |
| `coreutils` | `cp`, `mv`, `mkdir`, `rm`, `chmod`, `date`, `mktemp`, `sha256sum`, `id`, `ln`, `head`, `sort`, `cut`, etc. |
| `findutils` | Recherche des palettes locales avec `find` |
| `grep`, `sed` | Analyse et modification de texte |
| `mawk` ou `gawk` | Fourniture de `awk`, utilisé pour les palettes, les menus et les écrans |
| `tar`, `gzip` | Extraction de l’archive `.tar.gz` Rofi |
| `apt`, `dpkg` | Installation des paquets et comparaison des versions |
| `debian-archive-keyring` | Vérification des dépôts Debian via leur trousseau de clés |
| `sudo` | Installation des paquets et configuration des services système |
| `systemd`, `systemd-sysv` | Gestion des services et démarrage standard Debian ; `systemctl`, `loginctl` |
| `libpam-systemd` | Intégration des sessions utilisateur avec systemd-logind |
| `dbus`, `dbus-user-session` | Communication entre les applications, services utilisateur et session audio |
| `passwd` | Commandes de gestion de comptes comme `usermod` et `useradd` |
| Connexion Internet, DNS et heure système correcte | Récupération des paquets, accès GitHub et validation HTTPS |

`git` et `ca-certificates`, déjà présents dans les manifestes, doivent être
installés **avant le clonage HTTPS** si le projet est récupéré avec Git.
Pour préparer un utilisateur sans sudo, suivre les prérequis du README depuis
une session root, puis se reconnecter après l’ajout au groupe `sudo`.

### Outils réservés aux tests

| Dépendance | Origine | Utilisation |
|---|---|---|
| `python3` | Debian | Tests de déploiement, sauvegardes et gestion des versions avec compilation simulée |
| `shellcheck` | Debian | Analyse statique des scripts shell |
| `xvfb` | Debian | Serveur X virtuel pour les tests graphiques |
| `xauth` | Debian | Authentification X pour `xvfb-run` |
| `sudo`, `util-linux`, `passwd` | Debian | Préparation et exécution des tests avec un utilisateur dédié |

Aucun workflow GitHub Actions ni image de conteneur n’est déclaré dans le dépôt
actuel. Ces outils ne sont pas des dépendances de l’installation.

## 6. Installer les dépendances externes

### Méthode A — installation complète du projet

Sur **Debian 13 minimal**, se placer dans le dossier extrait ou cloné du projet,
avec l’utilisateur normal disposant de sudo :

```bash
cd /chemin/vers/Masternaka_Debian
bash install.sh --dry-run
bash install.sh
```

Remplacer le chemin par l’emplacement réel. Le script installe les paquets des
deux manifestes, puis appelle `scripts/build-desktop.sh` pour Picom et Rofi.
Il déploie également i3 et configure les services. Ne pas utiliser `sudo bash
install.sh` : seul le travail système interne passe par sudo.
La compilation elle-même ne demande pas de privilèges administrateur.

### Méthode B — compiler seulement Picom 13 et Rofi 2.0.0

Cette méthode ne déploie pas i3 et n’active pas LightDM. Elle est utile pour
préparer ou reconstruire les composants externes.

**1. Ouvrir Bash et se placer dans le projet.** Les commandes suivantes utilisent
des tableaux Bash ; ne pas les exécuter directement dans Fish.

```bash
bash
cd /chemin/vers/Masternaka_Debian
```

**2. Installer les dépendances de compilation depuis Debian Stable.**

```bash
project_dir=$(pwd -P)
apt_options=(
  -o "Dir::Etc::sourcelist=$project_dir/packages/debian.sources"
  -o 'Dir::Etc::sourceparts=-'
)
mapfile -t build_packages < <(
  sed 's/#.*//; /^[[:space:]]*$/d' packages/build.txt
)
sudo apt-get "${apt_options[@]}" update
sudo apt-get "${apt_options[@]}" --simulate install ca-certificates "${build_packages[@]}"
sudo apt-get "${apt_options[@]}" install ca-certificates "${build_packages[@]}"
```

Ces options utilisent les suites `trixie`, `trixie-updates` et `trixie-security`
de `packages/debian.sources`, sans modifier `/etc/apt`. Elles ne convertissent
pas automatiquement un système contenant déjà des paquets tiers.

**3. Lancer le script local de compilation, sans sudo.**

```bash
bash scripts/build-desktop.sh
```

Le script vérifie Debian 13, refuse root et prend un verrou utilisateur avec
`flock` (paquet `util-linux`, déjà présent dans `base.txt`). Il compare chaque
référence demandée avec le fichier local `source-id` et exécute la commande de
version du binaire. Si ces contrôles réussissent, il réutilise ce composant sans
réseau ni compilation. Cette vérification n’est pas un audit d’intégrité de tous
les fichiers ni de compatibilité avec les bibliothèques système.

Pour un composant à reconstruire :

1. Vérifie la présence des outils, puis crée un ensemble sous `releases/`.
2. Pour Picom, récupère le commit officiel fixé et vérifie son identifiant.
3. Pour Rofi, télécharge l’archive officielle, vérifie son SHA-256 et l’extrait.
4. Configure et compile le composant avec Meson ; exécute également les tests Rofi.
5. Installe le composant dans son propre préfixe au sein du nouvel ensemble,
   vérifie que son binaire démarre et écrit sa référence dans `source-id`.
6. Relie les composants réutilisés à leurs préfixes existants, sans recopier les
   binaires ni leurs ressources.
7. Active le nouvel ensemble seulement après réussite de toute la sélection et
   conserve le précédent dans `previous`.

En cas d’échec, le nouvel ensemble incomplet et le répertoire temporaire sont
supprimés ; `current` reste inchangé. Les sources temporaires sont également
supprimées après réussite. Les anciens ensembles ne sont pas purgés.

Après l’installation initiale des deux logiciels, on peut sélectionner un seul
composant ou forcer sa reconstruction :

```bash
bash scripts/build-desktop.sh picom
bash scripts/build-desktop.sh rofi
bash scripts/build-desktop.sh rofi --force
bash scripts/build-desktop.sh --help
```

`--force` ignore la réutilisation pour la sélection. Le script ne détecte pas les
changements d’options de compilation ou de bibliothèques système : utiliser cette
option si une reconstruction à référence identique est nécessaire.
Une ancienne installation sans `source-id` est reconstruite une première fois
pour chaque composant sélectionné. Elle reste disponible pour un retour arrière.

**4. Vérifier les versions installées.**

```bash
"$HOME/.local/share/masternaka-debian/current/bin/picom" --version
"$HOME/.local/share/masternaka-debian/current/bin/rofi" -v
```

Résultats attendus : Picom **v13** (éventuellement suivi d’une référence Git)
et Rofi **2.0.0**. Les chemins complets évitent de vérifier par erreur les binaires
Debian de `/usr/bin`.

**5. Sélectionner les binaires dans un terminal, si nécessaire.**

```bash
export PATH="$HOME/.local/share/masternaka-debian/current/bin:$PATH"
command -v picom
command -v rofi
```

Cet export ne modifie que le shell courant et ses programmes enfants. Le script
`i3/scripts/autostart.sh` prépare déjà ce PATH pour les programmes de la session
qu’il lance, notamment sxhkd et les menus. Pour une session déjà ouverte après
mise à jour, se déconnecter et se reconnecter pour relancer les composants.
Si toute la configuration et tous les logiciels sont installés, vérifier aussi :

```bash
bash scripts/check-session.sh
```

Ce dernier contrôle exige l’ensemble du bureau, pas seulement Picom et Rofi.

### Emplacements, mises à jour et retour arrière

| Chemin | Contenu |
|---|---|
| `~/.local/share/masternaka-debian/releases/` | Ensembles `desktop.ID`, avec préfixes séparés `picom/`, `rofi/` et liens vers les composants réutilisés |
| `~/.local/share/masternaka-debian/current` | Lien vers l’ensemble sélectionné |
| `~/.local/share/masternaka-debian/previous` | Lien vers l’ensemble précédent |
| `~/.local/share/masternaka-debian/current/bin/` | Binaires Picom et Rofi sélectionnés |
| `/usr/bin/picom`, `/usr/bin/rofi` | Versions Debian, si installées ; non écrasées |

APT ne met **pas** à jour les copies compilées. Pour changer de version : modifier
les références dans `packages/versions.env`, vérifier la documentation amont et
les dépendances de construction, puis relancer le script. Pour Rofi, actualiser
le SHA-256 à partir d’une référence vérifiée ; ne jamais désactiver ce contrôle
simplement pour faire passer un téléchargement différent.

Les anciens ensembles restent dans `releases/`. Le retour arrière habituel est :

```bash
bash scripts/build-desktop.sh --rollback
```

Cette commande vérifie les binaires de l’ensemble précédent et échange les liens
`current` et `previous`, sans compilation ni accès réseau. Une seconde exécution
revient à l’autre ensemble. Elle ne modifie pas `packages/versions.env` : une
installation normale réappliquera les références de ce fichier. Se reconnecter
pour relancer les composants après chaque basculement.

Pour revenir manuellement à un ensemble plus ancien, hors compilation en cours :

```bash
ls -1 "$HOME/.local/share/masternaka-debian/releases"
# Remplacer NOM_ENSEMBLE par le nom exact choisi dans la liste.
previous_release="$HOME/.local/share/masternaka-debian/releases/NOM_ENSEMBLE"
if [ -x "$previous_release/bin/picom" ] && [ -x "$previous_release/bin/rofi" ]; then
  ln -sfnT "$previous_release" "$HOME/.local/share/masternaka-debian/current"
fi
```

Cette méthode manuelle ne met pas à jour le lien `previous`. Ne pas effacer les
ensembles anciens individuellement sans examiner les liens : un ensemble actif
peut réutiliser un composant compilé dans un autre dossier.

### Désactiver les versions compilées

Depuis une console, hors session i3 et sans compilation en cours, archiver tout
le dossier utilisateur du projet pour retirer les compilations du PATH habituel :

```bash
archive=$(mktemp -d "$HOME/.local/share/masternaka-debian-disabled.XXXXXXXX")
mv -- "$HOME/.local/share/masternaka-debian" "$archive/"
printf 'Archive : %s/masternaka-debian\n' "$archive"
```

Les paquets Debian et la configuration i3 restent en place. Les liens internes
absolus de l’archive ne fonctionnent plus à cet emplacement ; ils refonctionnent
une fois le dossier remis exactement à sa place. Pour annuler, conserver le
chemin affiché et, si aucun nouveau dossier actif n’a été créé :

```bash
# Définir archive avec le chemin affiché si le shell a été fermé.
if [ ! -e "$HOME/.local/share/masternaka-debian" ] && [ ! -L "$HOME/.local/share/masternaka-debian" ]; then
  mv -- "$archive/masternaka-debian" "$HOME/.local/share/"
fi
```

Pour désinstaller définitivement les compilations, supprimer uniquement cette
archive identifiée après avoir vérifié le retour aux paquets Debian. Ne pas
supprimer les bibliothèques d’exécution via APT sans examiner les dépendances.
Les versions `/usr/bin/picom` et `/usr/bin/rofi` ne garantissent pas les mêmes
effets : adapter et valider la configuration avant de les utiliser en session.

### En cas d’échec

| Symptôme | Marche à suivre |
|---|---|
| Paquet introuvable | Vérifier Debian 13, les sources du projet et le résultat de `apt-get update`. Ne pas ajouter Sid pour contourner l’erreur. |
| Échec de vérification SHA-256 | Arrêter ; contrôler la version, l’URL et la référence attendue. Ne pas exécuter le contenu non vérifié. |
| Bibliothèque manquante dans Meson | Lire son nom dans l’erreur et vérifier `packages/build.txt`. Le téléchargement implicite est volontairement désactivé. |
| Échec des tests Rofi | La nouvelle installation n’est pas activée ; conserver les logs de sortie pour diagnostic. |
| Ancienne version affichée | Vérifier `command -v`, le PATH et le lien `current`, puis utiliser les chemins complets. |
| Fonctionnement sous Xvfb mais problème sur le PC | Vérifier le pilote et le backend graphique ; les tests virtuels ne reproduisent pas le matériel. |

## 7. Inventaire des dépendances transitives et versions réellement installées

APT installe automatiquement les bibliothèques nécessaires aux paquets déclarés,
et éventuellement des recommandations suivant sa configuration. Il faut une
résolution sur Debian 13 pour en connaître la liste exacte.

Pour afficher le plan APT complet avant installation, depuis Bash dans le projet :

```bash
mapfile -t project_packages < <(
  sed 's/#.*//; /^[[:space:]]*$/d' packages/base.txt packages/build.txt
)
sudo apt-get \
  -o "Dir::Etc::sourcelist=$(pwd -P)/packages/debian.sources" \
  -o 'Dir::Etc::sourceparts=-' \
  --simulate install "${project_packages[@]}"
```

Exécuter d’abord la mise à jour des index décrite en section 6. La simulation
montre les changements requis sur la machine considérée, pas tous ses paquets
préexistants. Pour enregistrer l’état complet des paquets installés :

```bash
dpkg-query -W -f='${binary:Package}\t${Version}\t${db:Status-Status}\n' \
  | awk -F '\t' '$3 == "installed" { print $1 "\t" $2 }' \
  > paquets-installes.tsv
"$HOME/.local/share/masternaka-debian/current/bin/picom" --version
"$HOME/.local/share/masternaka-debian/current/bin/rofi" -v
```

Le fichier TSV inclut tous les paquets de la machine, y compris ceux sans rapport
avec ce projet. Les logiciels compilés localement ne figurent pas dans dpkg :
leurs versions doivent être relevées séparément comme ci-dessus.

## 8. Ressources d’origine remplacées ou non incluses

| Dépendance dans l’archive | Remplacement |
|---|---|
| butterscripts/setup/add_butterrepo.sh | Sources Debian pour les bibliothèques, compilation autonome de Picom/Rofi |
| butterscripts/kitty/install_kitty.sh | Paquet Kitty Debian |
| butterscripts/theming/install_nerdfonts.sh | DejaVu Sans Mono et Font Awesome Debian |
| butterscripts/theming/install_theme.sh | Palettes locales, Adwaita-dark, Papirus-Dark |
| drewgrif/wallpapers | Fond uni et image personnelle facultative |
| butterscripts/system/install_lightdm.sh | LightDM Debian et activation explicite |
| butterscripts/setup/optional_tools.sh | Liste de paquets locale modifiable |
| kitty +kitten themes | Fichiers de couleurs inclus, aucun catalogue distant |

Les scripts butterscripts ne figurent pas dans l’archive : leur contenu et leurs
versions exactes n’ont pas été audités. Cette adaptation remplace leurs fonctions
visibles ; elle ne prétend pas reproduire tous leurs choix cachés.

Les anciens fonds d’écran, Nerd Fonts et thèmes GTK Orchis/Colloid ne sont **pas**
des dépendances externes à installer pour cette version : ils ont été remplacés.
Les douze palettes locales restent incluses ; elles ne reproduisent pas à elles
seules tous les thèmes GTK, icônes et fonds de l’installation originale.
Discord, OBS et GIMP ne sont pas requis par la configuration actuelle.
Les micrologiciels propres au matériel, pilotes propriétaires, Bluetooth et
imprimantes ne sont pas configurés automatiquement par le projet.

## 9. Sources et état de validation

Sources utilisées pour le choix des versions et les étapes de construction :

- [Picom dans Debian 13](https://packages.debian.org/trixie/picom)
- [Rofi dans Debian 13](https://packages.debian.org/trixie/rofi)
- [Polybar dans Debian 13](https://packages.debian.org/trixie/polybar)
- [Kitty dans Debian 13](https://packages.debian.org/trixie/kitty)
- [Picom 13 : publication](https://github.com/yshui/picom/releases/tag/v13)
- [Picom 13 : compilation](https://github.com/yshui/picom/blob/v13/README.md)
- [Rofi 2.0.0 : publication](https://github.com/davatorium/rofi/releases/tag/2.0.0)
- [Rofi 2.0.0 : compilation](https://github.com/davatorium/rofi/blob/2.0.0/INSTALL.md)

La liste des paquets de ce document correspond aux manifestes actuels. La
résolution APT, les compilations et la compatibilité graphique ne sont pas
validées par cet inventaire. Voir [VALIDATION.md](VALIDATION.md) pour les contrôles
réellement exécutés et les limites restantes.
