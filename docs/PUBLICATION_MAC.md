# Publier et tester depuis macOS

Aucun Linux local n’est nécessaire pour les tests automatisés. GitHub Actions
utilise un conteneur Debian 13 sur un serveur GitHub.

## Avec GitHub Desktop

1. Extraire l’archive de cette livraison.
2. Dans GitHub Desktop, cloner `Masternaka/Masternaka_Debian`.
3. Créer la branche `feat/debian13-autonome`.
4. Copier le contenu extrait dans le dossier du dépôt, y compris le dossier
   `.github` et le fichier `.gitignore` (Cmd + Maj + point dans Finder pour les voir).
   Ne pas copier de dossier `.git` : l’archive fournie n’en contient pas.
5. Vérifier les changements, créer un commit, puis publier la branche.
6. Dans l’onglet Actions de GitHub, ouvrir le workflow « Debian 13 ».
   S’il est désactivé pour le dépôt, l’activer. Une publication de branche le lance.
7. Transmettre le lien de la branche ou du workflow à l’assistant pour examiner
   les résultats et corriger les problèmes.

Le workflow installe les dépendances, compile et teste sans installer Linux sur
le Mac. Il ne remplace pas l’essai final d’une session Debian complète.
Ne pas exécuter `install.sh` sur macOS.
