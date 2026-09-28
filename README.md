# Masternaka Debian

Installation et personnalisation de **Debian 13 (trixie) minimal avec i3/X11**.
Projet maintenu dans ce dépôt, dérivé d’i3-setup de JustAGuyLinux.

**Première version en validation. Tester dans une VM Debian 13 avant un poste principal.**
La compilation et les tests graphiques automatisés ne remplacent pas un essai de
connexion LightDM, du réseau, du son et de la veille sur une installation réelle.

## Indépendance et versions

Aucun accès à butterrepo, butterscripts, Codeberg ou justaguy.dev n’est nécessaire
pour installer ou utiliser cette version. Les configurations et scripts sont dans
ce dépôt. Les références à l’auteur dans CREDITS.md servent à l’attribution.

L’autonomie ne signifie pas imposer les anciennes versions de Debian :

| Logiciel | Source retenue | Gestion |
|---|---|---|
| Picom | yshui/picom, version 13 | Commit fixé, compilation locale |
| Rofi | davatorium/rofi, version 2.0.0 | Archive officielle, SHA-256 vérifié |
| i3, Polybar, Dunst, Kitty, PipeWire | Debian 13 | Paquets APT |
| Palettes i3, Rofi, Polybar, Dunst, Kitty | Ce dépôt | Fichiers locaux |

Les versions choisies ne sont pas présentées comme les versions minimales prouvées
pour chaque option. Voir [l’audit](docs/DEPENDANCES.md).
Les sources de Picom et Rofi restent nécessaires au moment de la compilation ;
aucun script d’installation distant n’est exécuté.
Les installations compilées vivent dans
`~/.local/share/masternaka-debian/releases/` ; `current` désigne la version active.
L’installateur ne remplace pas les binaires de `/usr/bin`.
Le PATH des composants lancés par la session i3 privilégie ces versions.
Les paquets Debian Picom et Rofi restent installés comme solutions de secours.

## Prérequis

- Debian 13 fraîchement installée, sans environnement de bureau ni gestionnaire
  de connexion ; installation complète depuis une console locale.
- Connexion Internet fonctionnelle et utilisateur normal autorisé à utiliser sudo.
- Dépôts Debian configurés pour l’entretien ultérieur du système.
- Assez d’espace pour les paquets et la compilation (prévoir plusieurs Go).

Si sudo manque, ouvrir une session root avec `su -`, puis :

```bash
apt update
apt install sudo git ca-certificates
usermod -aG sudo TON_UTILISATEUR
```

Remplacer `TON_UTILISATEUR` par son identifiant, puis fermer et rouvrir sa session.

## Installation

```bash
git clone https://github.com/Masternaka/Masternaka_Debian.git
cd Masternaka_Debian
./install.sh --dry-run
./install.sh
```

Pour cette livraison en archive : extraire le ZIP, ouvrir un terminal dans
`Masternaka_Debian`, puis lancer `bash install.sh --dry-run`.
La publication GitHub a été bloquée par les permissions de la connexion ;
aucune branche ni demande de fusion n’a été créée. Les commandes de clonage
ci-dessus ne seront utilisables qu’après ajout des fichiers au dépôt.

L’installation complète vérifie Debian 13, installe les paquets, compile les
versions fixées, sauvegarde l’ancienne configuration et configure i3.
Elle active LightDM et NetworkManager pour le prochain démarrage et sélectionne
la cible graphique. Redémarrer manuellement, puis choisir **i3** dans LightDM.
Elle ne lance ni mise à niveau générale ni redémarrage automatique.
Si une étape échoue, elle s’arrête ; les paquets déjà installés ne sont pas annulés.

Les commandes APT de l’installateur utilisent `packages/debian.sources`, sans
réécrire `/etc/apt`. Un système déjà modifié avec des paquets tiers n’est pas
converti automatiquement en système Debian officiel.

### Options

```bash
./install.sh --only-config       # aucun paquet, aucune compilation, aucun sudo
./install.sh --dry-run           # simulation ; ne vérifie pas la disponibilité réseau
./install.sh --yes               # accepte la confirmation de l’installateur
```

`--only-config` remplace toute la configuration i3 du projet après sauvegarde ;
les autres dossiers de configuration restent en place. Ce mode suppose que les
logiciels sont déjà installés. Il utilise `~/.config`, pas un XDG_CONFIG_HOME alternatif.

### Réseau, pilotes et matériel

NetworkManager ne reprend pas automatiquement les interfaces gérées dans
`/etc/network/interfaces`. L’installateur conserve ce fichier pour ne pas couper
la connexion utilisée pour les téléchargements. Une interface existante peut
continuer à fonctionner avec ifupdown même si elle n’apparaît pas dans nm-applet.
Pour transférer une interface, le faire depuis une console locale après avoir
sauvegardé la configuration et préparé sa connexion NetworkManager.

Les pilotes NVIDIA propriétaires, les micrologiciels propres au matériel,
Bluetooth et l’impression ne sont pas configurés automatiquement.
Le clavier et la langue de l’installation Debian sont conservés.

## Personnalisation

| Besoin | Fichier |
|---|---|
| Paquets | `packages/base.txt`, `packages/build.txt` |
| Versions compilées | `packages/versions.env` |
| Raccourcis | `i3/sxhkd/sxhkdrc` |
| Fenêtres, espaces, animations | `i3/rules.conf`, `i3/workspaces.conf`, `i3/picom/picom.conf` |
| Barre | `i3/polybar/config.ini` |
| Terminal | `i3/kitty/kitty.conf` |
| Services de session | `i3/scripts/autostart.sh` |
| Palettes | `i3/themes/` |

**Super + Maj + T** choisit une des douze palettes locales. Les applications GTK
utilisent Adwaita-dark et les icônes Papirus-Dark. Les anciens ensembles
Orchis/Colloid, les Nerd Fonts et les fonds d’écran externes ne sont pas fournis.
Le fond est uni ; déposer une image personnelle dans `~/.config/i3/wallpaper.jpg`
et exécuter `~/.config/i3/scripts/background` pour l’afficher.
Les couleurs de base de Kitty suivent la palette ; ce ne sont pas les collections
complètes de thèmes Kitty de l’auteur original.

Les raccourcis d’applications non installées (Discord, OBS, GIMP) ont été retirés.
Geany est inclus. Voir [QUICKSTART.md](QUICKSTART.md).

## Sauvegarde et restauration

À chaque déploiement, l’ancien `~/.config/i3` est déplacé dans un dossier unique :
`~/.local/state/masternaka-debian/backups/DATE.ID/i3`.
Un lien symbolique préexistant est sauvegardé comme lien, sans modifier sa cible.

Pour restaurer, quitter i3, déplacer la configuration actuelle vers un autre nom,
puis recopier le dossier `i3` de la sauvegarde souhaitée dans `~/.config/`.
Cela restaure les fichiers de configuration, pas les paquets ni les services système.

## Mises à jour

Les paquets Debian suivent APT. Les logiciels compilés ne sont pas mis à jour par
APT : changer explicitement les références dans `packages/versions.env`, vérifier
les sources et relancer `./scripts/build-desktop.sh`. Le basculement du lien
`current` se fait seulement si les deux compilations réussissent ; les anciennes
versions sont conservées pour un retour arrière manuel.

Pour mettre à jour la configuration : `git pull`, puis `./install.sh --only-config`.
Reporter d’abord ses personnalisations dans le dépôt ; chaque déploiement remplace
la configuration active, après sauvegarde.

## Vérification

```bash
python3 -m unittest discover -s tests -v
./scripts/check-session.sh
```

Le workflow Debian 13 installe les dépendances, compile Picom et Rofi, vérifie les
scripts et analyse les configurations sous Xvfb. Il ne teste pas le démarrage
LightDM, le matériel audio, la veille ou la connectivité réelle.

## Licence

La licence GPL v2 de l’archive est conservée dans [LICENSE](LICENSE).
L’origine et les modifications figurent dans [CREDITS.md](CREDITS.md).
Les logiciels et thèmes installés comme paquets conservent leurs propres licences.
