# État de validation — 28 septembre 2026

Réussis localement : syntaxe Bash de tous les scripts ; six tests automatisés
(simulation sans écriture, sauvegarde à la réinstallation, préservation des cibles
de liens symboliques, application des douze thèmes hors ligne, rejet des arguments
invalides et absence des anciennes dépendances réseau dans les scripts).

Non exécutés : ShellCheck, compilation de Picom/Rofi, analyse graphique sous Xvfb,
installation de bout en bout dans une VM Debian 13. L’environnement local est
Ubuntu et ne dispose pas des outils graphiques ni d’un accès réseau permettant
ces installations. Le workflow `.github/workflows/validate.yml` est fourni,
mais n’a pas été lancé : GitHub a refusé la publication avec une erreur 403
« Resource not accessible by integration ».

Cette archive est une proposition de code, pas une installation validée.
Avant fusion/utilisation : publier la branche, exécuter le workflow fourni,
corriger les éventuels échecs puis tester en VM Debian 13 minimale.
