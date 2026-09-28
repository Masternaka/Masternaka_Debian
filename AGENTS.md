# AGENTS.md — Masternaka_Debian

## Objectif du projet

Créer une installation et une personnalisation reproductibles de Debian 13 (Trixie), à partir d'une installation sans environnement de bureau, avec i3 sous X11.

Le projet appartient à Gabriel et doit pouvoir évoluer indépendamment du projet d'origine de JustAGuy Linux. Privilégier la stabilité, la lisibilité et une maintenance simple. Ne pas transformer ce projet en distribution généraliste ni ajouter d'autres environnements de bureau sans demande.

Ces instructions s'appliquent à tout le dépôt. Les instructions explicites de Gabriel priment sur les conventions décrites ici.

## Dépôts du projet

- Dépôt principal de Gabriel : https://github.com/Masternaka/Masternaka_Debian
- Dépôt de référence : https://codeberg.org/justaguylinux/i3-setup
- Effectuer les évolutions dans le dépôt principal. Le dépôt de référence sert à comprendre la base et à comparer des fonctionnalités ; il ne doit pas être nécessaire à l'installation ni à l'exécution.
- Ne pas synchroniser automatiquement les changements du dépôt de référence. Évaluer et adapter chaque changement utile à Debian 13 et aux choix de ce projet.
- L'arborescence ci-dessous provient de l'archive de référence fournie. Vérifier le contenu actuel du dépôt principal avant toute modification ; ne pas supposer que l'archive reflète ses dernières évolutions.

## Avant de modifier le code

- Lire le `README.md`, `DEPENDANCES.md` s'il existe, les instructions locales et les fichiers concernés.
- Examiner l'état Git et préserver les modifications déjà présentes. Ne pas réinitialiser le dépôt ou écraser du travail utilisateur.
- Vérifier l'arborescence réelle : les chemins ci-dessous décrivent la base importée et doivent être adaptés si le projet a évolué.
- Rechercher les appels indirects : scripts de session, raccourcis clavier, modules Polybar, thèmes et téléchargements. La liste APT de l'installateur ne suffit pas à inventorier les dépendances.
- Faire des modifications ciblées. Ne pas réécrire toute l'architecture pour corriger un problème local.

## Repères dans la base importée

| Chemin | Rôle |
| --- | --- |
| `install.sh` | Installation et copie des configurations |
| `i3/config` | Configuration principale et inclusions i3 |
| `i3/scripts/` | Démarrage de session, thèmes, volume, menus et scratchpad |
| `i3/sxhkd/sxhkdrc` | Raccourcis et commandes des applications |
| `i3/polybar/` | Configuration et lancement de la barre |
| `i3/picom/`, `i3/rofi/`, `i3/dunst/` | Compositeur, lanceur et notifications |
| `i3/themes/` | Palettes et paramètres des thèmes |
| `README.md`, `QUICKSTART.md` | Installation, utilisation et raccourcis |
| `DEPENDANCES.md` | Inventaire des dépendances et installation des composants externes ; à créer s'il manque |

## Indépendance du projet

- Éliminer les dépendances d'installation ou d'exécution à Butterrepo, Butterscripts et aux dépôts personnels de l'auteur d'origine.
- Lorsqu'un script distant fournit une fonction nécessaire, remplacer cette fonction par un script maintenu dans ce dépôt ou par une méthode officielle documentée.
- Ne pas remplacer simplement l'ancien nom de compte par celui de Gabriel dans les URL : vérifier que la ressource de destination existe.
- Les projets officiels des logiciels restent des sources acceptables. L'autonomie ne signifie pas recopier tous les logiciels tiers dans le dépôt.
- Pour les fonds d'écran, polices, icônes et thèmes, prévoir des ressources distribuables avec le projet ou une source officielle explicite, ainsi qu'un comportement de repli.
- Distinguer les références historiques et attributions des dépendances actives. Conserver les licences et mentions d'origine applicables aux éléments réutilisés.
- Mettre à jour les instructions de contribution et d'installation lorsque leurs liens pointent encore vers le projet d'origine.

## Compatibilité Debian et choix des versions

- La cible est Debian 13 Trixie. Ne pas déduire la distribution cible du système sur lequel l'agent travaille.
- Préférer les dépôts officiels de Debian 13 lorsque les versions proposées prennent en charge la configuration utilisée.
- Ne jamais assimiler « paquet disponible » à « version compatible ». Vérifier les options réellement utilisées, notamment les animations et règles de Picom, les thèmes Rofi et les commandes Kitty.
- Pour chaque besoin de version plus récente, identifier la fonctionnalité nécessaire, la version minimale justifiée et la source utilisée pour cette vérification.
- Vérifier les disponibilités et versions dans les sources officielles Debian et les documentations ou publications officielles des logiciels. Indiquer la date de vérification. Ne pas inventer de version ou de résultat.
- Un paquet officiel Trixie-backports constitue une source distincte du dépôt Trixie de base : vérifier sa présence avant de le proposer et documenter explicitement son utilisation.
- Ne pas mélanger automatiquement les dépôts Stable, Testing, Sid ou Ubuntu pour obtenir un logiciel plus récent.
- Si la version adéquate manque, comparer une configuration compatible avec Stable, un paquet officiel adapté et une compilation reproductible depuis les sources officielles.
- Ne pas supprimer silencieusement une fonctionnalité visuelle pour contourner une incompatibilité. Expliquer le compromis ; demander un choix seulement si son impact le justifie.
- Vérifier l'architecture pour les binaires téléchargés. Ne pas annoncer la prise en charge d'une architecture non vérifiée.

## Documentation obligatoire des dépendances

Toute modification d'une dépendance doit être répercutée dans `DEPENDANCES.md`.

L'inventaire doit couvrir les dépendances directes explicitement nécessaires : installation, exécution, compilation, outils de téléchargement, programmes appelés par les raccourcis, polices, thèmes et ressources graphiques. Les dépendances transitives résolues automatiquement par APT n'ont pas à être recopiées intégralement ; préciser cette portée.

Pour chaque élément, indiquer :

- son nom et son rôle ;
- le paquet qui fournit la commande, lorsque les noms diffèrent ;
- les scripts ou configurations qui l'utilisent ;
- son caractère obligatoire, optionnel ou réservé à la compilation ;
- sa provenance : Trixie, mises à jour/sécurité, Trixie-backports ou source externe ;
- sa version minimale si nécessaire, avec justification ;
- la version vérifiée, la date et la source de vérification, ou la mention « non vérifié ».

Pour toute dépendance externe ou plus récente que celle de Trixie de base, fournir une procédure autonome comprenant :

1. La raison de ce choix et les prérequis.
2. La source officielle et la version, le tag ou le commit retenu.
3. Le téléchargement et la vérification de l'intégrité ou de la signature lorsque disponibles.
4. Les commandes de compilation éventuelles et d'installation.
5. L'emplacement installé et l'ordre de résolution du `PATH`.
6. Une commande de contrôle de version et un contrôle fonctionnel pertinent.
7. La mise à jour, la désinstallation et le retour à la solution précédente.

Une application facultative appelée par un raccourci doit être identifiée comme telle et son absence gérée clairement. Ne pas présenter une dépendance installée uniquement par un ancien script distant comme déjà prise en charge.

## Règles pour les scripts

- Respecter le shell déclaré. Pour les nouveaux scripts nécessitant Bash, utiliser `#!/usr/bin/env bash`, citer les expansions et employer des tableaux pour les listes d'arguments.
- Gérer explicitement les erreurs importantes. Ne pas ajouter mécaniquement `set -euo pipefail` sans vérifier les branches, pipelines et erreurs attendues.
- Vérifier les prérequis avant les mutations : système cible, architecture si pertinente, accès réseau nécessaire et privilèges.
- Garder les opérations utilisateur sous l'identité de l'utilisateur cible. Réserver `sudo` aux opérations système ; ne pas créer des configurations appartenant à root dans son dossier personnel.
- Sur une installation minimale, traiter explicitement le cas où `sudo` n'est pas installé ou configuré. Ne pas supposer que tous les outils de téléchargement sont présents.
- Résoudre les chemins depuis l'emplacement du script et respecter les variables XDG lorsqu'elles sont prises en charge de façon cohérente.
- Utiliser un répertoire temporaire unique créé avec `mktemp -d`, avec nettoyage limité à ce répertoire.
- Rendre la réexécution sûre : pas de lignes, de dépôts APT, de services de session ou de liens dupliqués.
- Sauvegarder les fichiers existants avant leur remplacement et documenter leur restauration. Ne pas supprimer globalement `~/.config`.
- Conserver le mode `--only-config` s'il existe : aucune installation de paquet, compilation, activation de service système ou installation d'outil distant dans ce mode. Signaler les prérequis manquants.
- Ne pas effectuer de mise à niveau générale du système, de redémarrage ou de changement du gestionnaire de connexion comme effet secondaire non annoncé.
- Un échec essentiel doit arrêter l'étape concernée avec un message utile. Un composant optionnel peut échouer sans bloquer, mais doit apparaître dans le bilan.
- Éviter les téléchargements exécutés directement par `curl | bash` ou équivalent. Utiliser des versions identifiées et des fichiers vérifiés ; ne pas exécuter une branche distante mouvante comme composant de l'installation.
- Pour un dépôt APT tiers indispensable, utiliser une clé dédiée et `signed-by`. Ne pas désactiver la vérification des signatures.
- Ne pas écraser manuellement les fichiers gérés par APT dans `/usr`. Documenter les composants installés dans `/usr/local` ou dans le dossier utilisateur.

## Cohérence de la session graphique

- Conserver une session utilisable après une installation minimale : serveur X, i3, terminal, lanceur, connexion de session et composants nécessaires.
- Vérifier les dépendances de démarrage : notifications, agent Polkit, réseau, audio et alimentation selon les fonctions retenues.
- Après modification d'un raccourci, synchroniser l'aide et `QUICKSTART.md`.
- Préserver la cohérence entre i3, Polybar, Rofi, Dunst, Kitty et les thèmes GTK.
- Prévoir un repli lorsque le fond d'écran, la police, le thème ou une application optionnelle manque.
- Éviter les chemins de périphériques et noms d'écrans codés en dur sans configuration ou détection.
- Vérifier les relancements de session et les rechargements i3 afin d'éviter plusieurs instances des mêmes composants.

## Vérification et limites des tests

Gabriel ne dispose pas actuellement d'un ordinateur Linux pour tester. Effectuer les vérifications accessibles sans lui transférer systématiquement cette charge.

- Ne jamais exécuter l'installateur sur la machine de travail pour une simple analyse.
- Vérifier la syntaxe des scripts Bash modifiés avec `bash -n`, y compris les scripts sans extension. Utiliser `sh -n` pour les scripts POSIX.
- Exécuter ShellCheck si disponible avec le dialecte approprié. Corriger les avertissements pertinents ; justifier les exclusions.
- Contrôler les chemins, inclusions, permissions exécutables, commandes appelées et ressources nécessaires.
- Rechercher les références actives restantes à l'infrastructure de l'auteur d'origine, sans supprimer les crédits.
- Utiliser les validateurs propres aux logiciels lorsqu'ils sont disponibles et compatibles. Ne pas appliquer un validateur générique à une syntaxe différente.
- Pour une validation i3, fournir un dossier personnel temporaire avec les inclusions attendues ; ne pas valider involontairement la configuration personnelle de l'environnement.
- Un conteneur Debian 13 peut servir à vérifier les paquets et compilations. Il ne prouve pas qu'une session graphique, systemd, le son ou le matériel fonctionnent.
- Réserver les essais d'installation complète à une VM jetable Debian 13, si disponible : installation initiale, seconde exécution, sauvegarde/restauration et ouverture de session i3.
- Ne pas introduire une infrastructure de tests disproportionnée. Ajouter des tests ciblés lorsque des erreurs de logique ou des régressions le justifient.
- Distinguer dans le bilan : vérifié statiquement, exécuté en conteneur, testé en VM et non testé. Ne jamais annoncer « fonctionne sous Debian 13 » sur la seule base d'une analyse syntaxique.

## Livraison attendue

- Rédiger les explications et la documentation nouvelle en français clair. Conserver les noms techniques et commandes exacts.
- Mettre à jour le code et sa documentation dans la même modification.
- Ne pas ajouter de secrets, de données personnelles ou de chemins propres à une machine.
- Fournir un bilan concis : ce qui change, pourquoi, vérifications effectuées et limites restantes.
- Si un accès ou un environnement manque, avancer sur ce qui peut être vérifié et nommer précisément ce qui reste incertain.
- Ne pas publier, pousser ou modifier les réglages d'un dépôt distant sans autorisation correspondante.
