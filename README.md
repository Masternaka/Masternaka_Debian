# Masternaka Debian

Masternaka Debian installe un bureau personnel **i3 sous X11 sur Debian 13
(Trixie)**, à partir d’une installation sans environnement de bureau.
Le projet regroupe les paquets, les configurations et les scripts nécessaires
pour retrouver le même bureau et le faire évoluer simplement.

La base provient d’i3-setup de JustAGuyLinux, mais le projet est maintenu ici de
façon indépendante. Aucun accès à Codeberg, Butterrepo ou Butterscripts n’est
nécessaire à l’installation ou à l’utilisation. Il n’y a aucune synchronisation
automatique avec le dépôt d’origine.

**Le projet reste en validation.** La logique de gestion des versions et certaines
opérations sur les fichiers sont testées ; l’installation complète et la session
graphique ne sont pas encore validées dans une VM Debian 13.
Voir [l’état des vérifications](docs/VALIDATION.md).

## Ce que le projet installe

| Composant | Rôle | Gestion |
|---|---|---|
| Xorg, LightDM, i3 | Affichage, connexion et gestion des fenêtres | Paquets Debian |
| Polybar, Dunst, sxhkd | Barre, notifications et raccourcis | Paquets Debian |
| Kitty, Firefox ESR, Thunar, Geany | Terminal, navigateur, fichiers et éditeur | Paquets Debian |
| PipeWire, NetworkManager, agent Polkit, gestionnaire d’énergie | Son, réseau, autorisations et alimentation | Paquets Debian |
| Picom 13 | Composition, transparence et animations | Compilation depuis le dépôt officiel, commit fixé |
| Rofi 2.0.0 | Lanceur et menus | Compilation depuis une archive officielle, SHA-256 vérifié |
| Douze palettes et scripts de session | Apparence et commandes du bureau | Fichiers inclus dans ce dépôt |

Le choix est de conserver des versions récentes de Picom et Rofi, indépendantes
des versions de Debian Stable. APT gère les autres logiciels. Les versions et
références à compiler sont centralisées dans [packages/versions.env](packages/versions.env).
Aucune version « latest » ni branche distante mouvante n’est exécutée.

Les compilations sont installées dans le dossier utilisateur, sans remplacer
`/usr/bin`. Les paquets Debian Picom et Rofi restent présents, mais leur
compatibilité avec tous les effets et thèmes du projet n’est pas garantie.
L’inventaire complet est dans [docs/DEPENDANCES.md](docs/DEPENDANCES.md).

## Installer le bureau

### Prérequis

- Debian 13 minimal, avec une connexion Internet fonctionnelle.
- Un utilisateur normal autorisé à utiliser `sudo`.
- Une console locale, hors session graphique et hors SSH, pour l’installation complète.
- Plusieurs Go disponibles pour les paquets, les sources et les compilations.

Les commandes d’installation s’exécutent **sur Debian, pas sur macOS**.
Si `sudo` manque, ouvrir une session root avec `su -`, puis exécuter :

```bash
apt update
apt install sudo git ca-certificates
usermod -aG sudo TON_UTILISATEUR
```

Remplacer `TON_UTILISATEUR`, puis fermer et rouvrir sa session utilisateur.
Si `sudo` est déjà configuré, préparer le clonage avec :

```bash
sudo apt-get update
sudo apt-get install git ca-certificates
```

### Première installation

Depuis la session de l’utilisateur normal :

```bash
git clone https://github.com/Masternaka/Masternaka_Debian.git
cd Masternaka_Debian
./install.sh --dry-run
./install.sh
```

Pour une archive ZIP, extraire son contenu et se placer dans le dossier du projet.
Les scripts peuvent aussi être lancés avec `bash install.sh`, par exemple.
Ne pas lancer `sudo ./install.sh` : le script utilise lui-même `sudo` pour les
opérations système et garde les fichiers personnels sous ton identité.

L’installateur :

1. Vérifie Debian 13, les privilèges et les conditions de lancement.
2. Met à jour les index APT, simule puis installe les paquets des deux manifestes.
3. Appelle `scripts/build-desktop.sh` pour préparer Picom et Rofi si nécessaire.
4. Active LightDM et NetworkManager pour le prochain démarrage et sélectionne la cible graphique.
5. Sauvegarde l’ancienne configuration i3, puis copie celle du projet dans `~/.config/i3`.
6. Prépare les dossiers utilisateur et `~/Screenshots`.

Redémarrer manuellement, puis choisir **i3** dans LightDM. L’installateur ne lance
pas de mise à niveau générale du système ni de redémarrage automatique. En cas
d’échec, il s’arrête ; les paquets déjà installés ne sont pas annulés.

### Options de l’installateur

| Commande | Effet |
|---|---|
| `./install.sh --help` | Affiche les options |
| `./install.sh --dry-run` | Affiche le plan sans modifier de fichiers ni vérifier le réseau |
| `./install.sh --only-config` | Sauvegarde et remplace la configuration i3, sans APT, compilation ni sudo |
| `./install.sh --only-config --dry-run` | Affiche le plan de copie uniquement |
| `./install.sh --yes` | Accepte la confirmation initiale ; sudo peut encore demander un mot de passe |

`--only-config` suppose que les logiciels sont déjà installés. Il remplace tout
`~/.config/i3`, après sauvegarde, et laisse les autres dossiers de configuration
en place. Un `XDG_CONFIG_HOME` différent de `~/.config` n’est pas pris en charge.

### Réseau et matériel

Les opérations APT de l’installateur utilisent [packages/debian.sources](packages/debian.sources)
avec Trixie, Trixie-updates et Trixie-security, sans réécrire `/etc/apt`.
Les sources APT du système restent à entretenir pour les mises à jour futures.
Un système contenant déjà des paquets tiers n’est pas converti automatiquement.

`/etc/network/interfaces` est conservé : NetworkManager ne reprend pas
automatiquement les interfaces gérées par ifupdown. Une connexion peut donc
fonctionner sans apparaître dans nm-applet. Toute migration réseau se prépare
séparément, depuis une console locale.

Le projet conserve la langue et le clavier de Debian. Il ne configure pas les
pilotes NVIDIA propriétaires, les micrologiciels propres au matériel, Bluetooth
ou les imprimantes.

## Utiliser et personnaliser le bureau

La touche **Super** désigne la touche Windows. Les principaux raccourcis sont
**Super + Entrée** pour Kitty, **Super + Espace** pour Rofi, **Super + F** pour
Thunar et **Super + B** pour Firefox. **Super + /** affiche l’aide complète.
Voir [QUICKSTART.md](QUICKSTART.md) pour les autres raccourcis.

**Super + Maj + T** choisit l’une des douze palettes locales. GTK utilise
Adwaita-dark et les icônes Papirus-Dark. Le fond est uni par défaut. Pour utiliser
une image personnelle, la copier dans `~/.config/i3/wallpaper.jpg`, puis lancer :

```bash
~/.config/i3/scripts/background
```

Les anciens ensembles Orchis/Colloid, Nerd Fonts et fonds d’écran distants ne sont
pas fournis. Les palettes de ce dépôt coordonnent i3, Polybar, Rofi, Dunst et Kitty.

### Où modifier les fichiers

| Fichier ou dossier | Utilisation |
|---|---|
| `install.sh` | Point d’entrée de l’installation et du déploiement des configurations |
| `lib/install.sh` | Fonctions internes de lecture des paquets, sauvegarde et copie ; ne pas lancer directement |
| `packages/base.txt` | Paquets du bureau, un nom par ligne ; commentaires possibles avec `#` |
| `packages/build.txt` | Paquets nécessaires pour compiler Picom et Rofi |
| `packages/debian.sources` | Sources APT utilisées uniquement par les commandes qui les indiquent explicitement |
| `packages/versions.env` | Versions, commit Picom et SHA-256 Rofi ; lu par les scripts de compilation et de contrôle |
| `scripts/build-desktop.sh` | Installation, reconstruction et retour arrière de Picom/Rofi |
| `scripts/check-session.sh` | Contrôle des commandes, versions attendues et syntaxe i3 installée |
| `i3/config` | Configuration principale, inclusions et lancement de la session |
| `i3/workspaces.conf`, `i3/rules.conf` | Espaces de travail et règles des fenêtres |
| `i3/sxhkd/sxhkdrc` | Raccourcis clavier ; adapter aussi `QUICKSTART.md` après modification |
| `i3/scripts/autostart.sh` | Composants lancés à l’ouverture de session ; éviter les lancements manuels répétés |
| `i3/polybar/` | Barre, modules et lanceur multi-écrans `polybar-i3` |
| `i3/picom/picom.conf` | Animations, ombres, transparence et règles du compositeur |
| `i3/rofi/`, `i3/dunst/`, `i3/kitty/` | Menus, notifications et terminal |
| `i3/xsettingsd.conf` | Réglages GTK et icônes |
| `i3/themes/` | Sources des douze palettes ; les fichiers de couleurs actifs sont remplacés lors d’un changement de palette |
| `tests/` | Tests de fichiers, gestion des versions et contrôles graphiques |
| `docs/DEPENDANCES.md` | Dépendances, sources, compilation et procédures détaillées |
| `docs/VALIDATION.md` | Résultats des vérifications et limites connues |
| `docs/PUBLICATION_MAC.md` | Travail depuis un Mac et limites des tests locaux |
| `AGENTS.md` | Consignes pour les assistants de développement, si présent ; aucun rôle dans l’installation |

Les fichiers du dépôt sont les sources ; ceux de `~/.config/i3` sont la copie
utilisée par la session. Pour conserver une personnalisation, la reporter dans
le dépôt avant le prochain `--only-config`. Cela concerne aussi ton fond d’écran
et la palette active si tu souhaites les conserver après un déploiement.

### Scripts utilisables dans la session

Les chemins suivants sont relatifs à `~/.config/i3/scripts/` :

| Commande | Action |
|---|---|
| `help` | Affiche les raccourcis à partir de sxhkdrc |
| `thememenu` | Ouvre le choix de palette |
| `thememenu nord` | Applique directement une palette par son nom de dossier |
| `background` | Applique l’image personnelle ou le fond uni de la palette |
| `changevolume up`, `down` ou `mute` | Change le volume avec notification |
| `scratchpad` | Affiche ou lance le terminal escamotable |
| `scratchpad pulsemixer pulsemixer` | Affiche ou lance le mixeur audio escamotable |
| `power` | Ouvre le menu de déconnexion, redémarrage et arrêt |

Après une modification des services ou un déploiement complet des fichiers,
se déconnecter puis se reconnecter. Pour les réglages courants, **Super + Maj + R**
recharge i3 et **Super + Échap** recharge les raccourcis sxhkd.

## Entretenir le projet

### Paquets Debian et configurations

APT entretient les paquets Debian avec les sources du système. Les logiciels
compilés dans le dossier utilisateur ne sont pas mis à jour par APT.
Modifier `base.txt` seul n’installe et ne désinstalle aucun paquet ;
`--only-config` ne traite pas les manifestes.

Pour récupérer les changements de ton dépôt, préserver d’abord tes modifications
locales, puis :

```bash
git pull --ff-only
./install.sh --only-config
```

Cette opération n’applique pas une éventuelle nouvelle version de Picom ou Rofi.
Pour ces logiciels, utiliser la procédure suivante.

### Picom et Rofi

Depuis le dossier du projet, avec l’utilisateur normal :

```bash
./scripts/build-desktop.sh               # prépare les deux logiciels si nécessaire
./scripts/build-desktop.sh picom         # traite seulement Picom
./scripts/build-desktop.sh rofi          # traite seulement Rofi
./scripts/build-desktop.sh rofi --force  # reconstruit Rofi, même à référence identique
./scripts/build-desktop.sh --rollback    # revient à l’ensemble précédent
```

L’installation initiale prépare les deux logiciels. Ensuite, la sélection d’un
seul logiciel conserve l’autre. Le script ne déploie aucune configuration, ne
modifie aucun service et n’installe aucun paquet. Si les outils de compilation
manquent, suivre la [préparation des dépendances](docs/DEPENDANCES.md#6-installer-les-dépendances-externes).

Pour chaque logiciel sélectionné, le script compare la version et la référence
source avec le fichier local `source-id`, puis vérifie que le binaire répond à
sa commande de version. Si ces contrôles passent, il n’effectue aucun téléchargement
ni compilation pour ce logiciel. `--force` sert notamment après un changement
d’options de compilation ou pour réparer une installation ; le cache ne compare
pas toutes les bibliothèques système ni tous les fichiers installés.

Pour changer de version, modifier `packages/versions.env` : conserver un commit
Picom complet et vérifier le SHA-256 de l’archive Rofi à partir d’une source
fiable. Contrôler les instructions officielles de compilation, adapter
`packages/build.txt` au besoin, puis lancer le script pour le logiciel concerné.
Documenter le changement dans `docs/DEPENDANCES.md`. Le script ne cherche pas
les nouvelles versions automatiquement.

L’ensemble courant n’est remplacé qu’après réussite de toutes les compilations
sélectionnées et de leurs contrôles. En cas d’échec, il reste actif. L’ensemble
précédent est conservé ; `--rollback` échange les deux ensembles, sans réseau ni
compilation. Se reconnecter pour relancer les composants avec les bons binaires.
Un retour arrière ne modifie pas `versions.env` : une nouvelle exécution normale
réappliquera les références demandées par ce fichier.

Les installations issues de l’ancien script restent conservées. Comme elles
n’ont pas de fichier `source-id`, chaque logiciel sélectionné est reconstruit
une première fois pour bénéficier ensuite de la réutilisation.

### Emplacements et retour arrière

| Chemin | Contenu |
|---|---|
| `~/.config/i3` | Configuration active |
| `~/.local/state/masternaka-debian/backups/DATE.ID/i3` | Sauvegarde avant chaque déploiement |
| `~/.local/share/masternaka-debian/releases/desktop.ID` | Ensemble de versions, avec composants compilés ou liens vers des composants conservés |
| `~/.local/share/masternaka-debian/current` | Lien vers l’ensemble actif |
| `~/.local/share/masternaka-debian/previous` | Lien vers l’ensemble précédent |
| `~/.local/share/masternaka-debian/current/bin` | Picom et Rofi utilisés par les composants lancés depuis l’autostart |

Les ensembles peuvent partager des composants via des liens symboliques : ne pas
supprimer un ancien dossier de `releases/` en se basant seulement sur son âge.
Aucune purge automatique n’est effectuée.

Pour vérifier les binaires exacts :

```bash
"$HOME/.local/share/masternaka-debian/current/bin/picom" --version
"$HOME/.local/share/masternaka-debian/current/bin/rofi" -v
```

Le PATH de ton terminal n’est pas modifié globalement. Pour utiliser ces binaires
dans le shell courant :

```bash
export PATH="$HOME/.local/share/masternaka-debian/current/bin:$PATH"
```

Pour restaurer une configuration i3, quitter la session graphique, déplacer la
configuration actuelle vers un nom libre et recopier le dossier `i3` de la
sauvegarde choisie dans `~/.config/`. Un lien symbolique préexistant est sauvegardé
comme lien, sans modifier sa cible. Cette restauration ne change ni les paquets,
ni les services, ni les versions compilées.

La désactivation des compilations et leur restauration manuelle sont décrites
dans [DEPENDANCES.md](docs/DEPENDANCES.md#désactiver-les-versions-compilées).

## Vérifier et diagnostiquer

Sur Debian 13, depuis le projet :

```bash
python3 -m unittest discover -s tests -v
./scripts/check-session.sh
```

Les tests Python utilisent des dossiers temporaires. Les tests de gestion des
versions simulent les téléchargements et les compilateurs : ils ne prouvent pas
que les sources externes compilent. `check-session.sh` contrôle les commandes,
les versions au moins égales à celles du manifeste et la syntaxe de la
configuration installée ; il ne valide pas le son ou le matériel.

`tests/graphics.sh` est réservé à un environnement Debian jetable, avec Xvfb,
les dépendances graphiques et un utilisateur dédié dont la configuration est
installée. Le lancer avec `bash tests/graphics.sh` dans cet environnement.
Il peut laisser des processus de session actifs. Aucun workflow GitHub Actions
n’est actuellement fourni.

| Problème | Vérification |
|---|---|
| Commande de compilation absente | Préparer les paquets de `packages/build.txt` avec la procédure documentée |
| SHA-256 incorrect | Arrêter et vérifier l’archive et la référence attendue ; ne pas désactiver la vérification |
| Compilation ou test Rofi en échec | Lire l’erreur ; l’ensemble actif est conservé |
| Ancienne version affichée | Vérifier le chemin complet ci-dessus et se reconnecter |
| Problème après mise à jour | Utiliser `--rollback` pour les binaires ou restaurer la sauvegarde i3 pour les fichiers |
| Commande graphique absente après `--only-config` | Ce mode n’installe aucun logiciel ; lancer `check-session.sh` pour un premier diagnostic |

## Origine et licences

Le projet réutilise une base i3-setup distribuée sous GPL v2. Les textes de licence
et les mentions d’origine doivent accompagner les éléments réutilisés ; ils ne
créent aucune dépendance technique au dépôt d’origine. Dans l’état local audité,
`LICENSE` et `CREDITS.md` sont supprimés : ce point reste signalé dans
[VALIDATION.md](docs/VALIDATION.md). Les logiciels et ressources tiers conservent
leurs propres licences.
