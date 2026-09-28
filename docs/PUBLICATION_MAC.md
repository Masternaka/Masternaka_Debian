# Travailler depuis macOS

Le Mac peut servir à modifier les fichiers et à examiner les changements Git.
Ne pas y exécuter l’installateur : la cible reste Debian 13.

Aucun workflow GitHub Actions n’est actuellement présent dans ce dépôt. Publier
une branche ne déclenche donc pas les tests Debian décrits dans les anciennes
versions de ce guide.

Les tests complets demandent un environnement Debian 13 jetable. Le script
`tests/graphics.sh` nécessite en plus un serveur X, par exemple Xvfb, les logiciels
du bureau et une configuration déployée dans le dossier d’un utilisateur de test
dédié. Il ne remplace pas un essai complet de connexion, réseau, son et veille.

Voir [VALIDATION.md](VALIDATION.md) pour les vérifications déjà effectuées et leurs
limites. Aucun accès au dépôt d’origine n’est nécessaire pour maintenir ce projet.
