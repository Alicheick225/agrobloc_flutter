# TODO - Modifications apportées à homeProducteur.dart

## Tâches terminées ✅

1. **Icône favorie ajoutée** : L'icône favorie (favorite_border) a été ajoutée sur la même ligne que la quantité, à droite, juste en dessous du montant (prix unitaire).

2. **Annonces cliquables** : Les cartes d'annonces sont maintenant enveloppées dans un InkWell pour les rendre cliquables et naviguer vers les détails dans detailoffrevente.

3. **Navigation vers détails** : La navigation utilise Navigator.pushNamed avec la route '/detailOffreVente' et passe l'annonce en arguments.

4. **Mise à jour de DetailOffreVente** : Le widget DetailOffreVente a été modifié pour accepter un objet dynamique (AnnonceAchat ou AnnonceVente) et afficher les détails appropriés.

5. **Route mise à jour** : La route '/detailOffreVente' dans main.dart a été modifiée pour accepter un objet dynamique au lieu d'un AnnonceAchat spécifique.

## Modifications apportées

### homeProducteur.dart
- Modifié `_buildAnnonceCard` pour :
  - Envelopper le Container dans un InkWell avec onTap pour la navigation
  - Restructurer la mise en page : quantité et icône favorie sur une Row avec Expanded pour la quantité
  - Ajouter IconButton avec Icons.favorite_border

### detailOffreVente.dart
- Changé le paramètre `annonce` de `AnnonceAchat` à `dynamic`
- Ajouté la logique pour détecter le type d'annonce (AnnonceAchat ou AnnonceVente)
- Affichage conditionnel des détails selon le type

### main.dart
- Modifié la route '/detailOffreVente' pour accepter un objet dynamique

## Fonctionnalités à implémenter plus tard
- Implémentation de la fonctionnalité de favoris (actuellement juste l'icône sans action)
- Gestion des erreurs de navigation si la route n'existe pas

## Test à effectuer
- Vérifier que les cartes sont cliquables et naviguent vers les détails
- Vérifier la position de l'icône favorie
- Tester avec différentes tailles d'écran
