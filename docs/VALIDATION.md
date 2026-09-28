# État de validation — 28 septembre 2026

## Autonomie et maintenance

L’installation et la session ne font aucun appel au projet i3-setup, à Butterrepo
ou à Butterscripts. Les sources réseau actives sont Debian pour APT et les dépôts
officiels de Picom et Rofi pour leur compilation. Les scripts, les douze palettes
et le fond uni sont locaux. Aucun sous-module ni mécanisme de synchronisation
avec le projet d’origine n’a été trouvé.

Le contrôle automatisé d’indépendance couvre `install.sh`, `lib/`, `packages/`,
`scripts/` et `i3/`. Les références historiques et les attributions ne constituent
pas des dépendances d’exécution.

Les versions récentes de Picom et Rofi sont conservées par choix du projet.
Le script de compilation réutilise maintenant les références déjà installées,
permet la reconstruction d’un seul composant et garde un ensemble précédent
pour le retour arrière. APT continue de gérer les autres logiciels.
La compatibilité graphique des versions choisies reste à valider.

## Contrôles effectués sur macOS

- Analyse des scripts d’installation, appels de session, raccourcis, modules
  Polybar, ressources locales et adresses de téléchargement.
- Vérification de syntaxe avec `bash -n` des scripts shell, y compris ceux sans
  extension. Cette vérification ne valide pas les commandes Linux.
- Trois tests Python exécutés et réussis dans des dossiers personnels temporaires :
  sauvegarde à la réinstallation, préservation de la cible d’un lien symbolique,
  absence des anciennes dépendances réseau dans les chemins contrôlés.

Neuf tests supplémentaires de gestion des versions ont réussi sur macOS :
réutilisation sans compilation, reconstruction sélective, échange des ensembles
lors du retour arrière, échec de compilation sans changement de version active,
changement de référence, binaire défaillant, installation initiale incomplète,
migration d’un ancien ensemble et contrôle des options. Les téléchargements,
compilateurs, contrôle Debian, verrou `flock` et remplacement GNU `mv -Tf` sont
simulés dans ces tests ; ils n’établissent pas la réussite d’une compilation réelle
ni la fiabilité du verrouillage sur Debian.

L’installateur n’a pas été exécuté sur le Mac. La suite complète n’a pas été
relancée : elle utilise notamment `mapfile` et `sed -i` selon les conventions
Linux, absentes du Bash et du sed fournis par défaut sur macOS.

ShellCheck, Docker et Podman ne sont pas disponibles dans l’environnement
contrôlé. Aucun test en conteneur ni en VM n’a été effectué. La compilation,
les thèmes Rofi, les règles et animations Picom, LightDM, le son, le réseau,
le verrouillage et la veille restent non testés sous Debian 13.

## Points restants

- `--only-config` ne signale pas encore les logiciels absents. Le contrôle manuel
  `scripts/check-session.sh` existe, mais impose les versions du manifeste
  sans établir leur minimum technique.
- `autostart.sh` repose sur le lancement initial par i3 (`exec`, sans
  `exec_always`). Son exécution manuelle répétée peut dupliquer des composants.
- `tests/graphics.sh` doit rester réservé à un environnement jetable et à un
  utilisateur dédié ; il lance les composants de session et ne garantit pas
  leur nettoyage complet à la sortie.
- Aucun fichier `.github/workflows/validate.yml` n’est présent. Les anciennes
  affirmations de validation automatique et de publication refusée ont été
  retirées de la documentation actuelle.
- `LICENSE` et `CREDITS.md` sont marqués supprimés dans les modifications locales
  antérieures à cet audit. Ces suppressions ont été préservées. Le README et les
  configurations y font encore référence ; conserver les textes de licence et
  d’attribution de la base réutilisée lors de la préparation de la publication.

Ces résultats établissent l’autonomie du code inspecté ; ils ne constituent pas
une validation de l’installation complète sur Debian 13.
