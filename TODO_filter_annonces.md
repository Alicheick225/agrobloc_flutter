# TODO: Filtrer les annonces pour l'utilisateur connecté

## Objectif
Implémenter le filtrage des annonces pour n'afficher que celles de l'utilisateur connecté.

## Étapes à compléter

### [ ] 1. Vérifier le fonctionnement actuel du filtre
- Examiner le code existant dans `annonce_achat_page.dart`
- Confirmer que le toggle `_showOnlyMyAnnonces` fonctionne correctement
- Vérifier que `fetchAnnoncesByUser()` est correctement appelé

### [ ] 2. Tester la fonctionnalité existante
- S'assurer que l'API endpoint `/user/$currentUserId` fonctionne
- Vérifier que le UserService retourne correctement l'ID utilisateur

### [ ] 3. Améliorer l'interface utilisateur
- Ajouter un indicateur visuel clair quand le filtre "mes annonces" est activé
- Améliorer les messages d'état (chargement, erreurs, annonces vides)

### [ ] 4. Documentation et tests
- Documenter le fonctionnement du filtre
- Tester les différents scénarios (utilisateur connecté/déconnecté, annonces existantes/inexistantes)

## Fichiers concernés
- `lib/core/features/Agrobloc/presentations/pagesAcheteurs/annonce_achat_page.dart`
- `lib/core/features/Agrobloc/data/dataSources/AnnonceAchat.dart` (déjà fonctionnel)
- `lib/core/features/Agrobloc/data/dataSources/userService.dart` (déjà fonctionnel)

## Statut actuel
Le code semble déjà implémenter cette fonctionnalité via:
- La variable `_showOnlyMyAnnonces`
- La méthode `_toggleFilter()` qui bascule le filtre
- La méthode `_loadAnnonces()` qui appelle `fetchAnnoncesByUser()` quand le filtre est activé

## Prochaines actions
Vérifier le fonctionnement actuel et apporter des améliorations si nécessaire.
