r# TODO: Correction de la gestion des tokens et session utilisateur

## Problème
L'utilisateur rencontre des erreurs "Missing user data or token" lors du chargement de la session, avec savedUserJson présent mais savedToken null. Cela conduit à une redirection forcée vers la page de connexion.

## Cause racine
- ApiClient récupère les tokens directement depuis SharedPreferences sans validation
- Pas de gestion automatique du rafraîchissement des tokens expirés dans ApiClient
- Gestion d'erreur insuffisante dans UserService.loadUser()
- Pas de nettoyage automatique des tokens invalides

## Plan de solution
1. [x] Ajouter des logs détaillés dans UserService.getValidToken() pour tracer les tokens
2. [x] Améliorer la gestion d'erreur dans UserService.loadUser()
3. [x] Modifier ApiClient pour utiliser UserService.getValidToken()
4. [x] Ajouter méthode de nettoyage forcé des tokens invalides
5. [x] Améliorer la gestion de session dans main.dart
6. [x] Tester les changements et vérifier les logs

## Fichiers à modifier
- `lib/core/features/Agrobloc/data/dataSources/userService.dart`
- `lib/core/utils/api_token.dart`
- `lib/main.dart`

## Étapes détaillées
1. **UserService.getValidToken()** : Ajouter logs détaillés pour chaque étape
2. **UserService.loadUser()** : Améliorer gestion d'erreur et nettoyage automatique
3. **ApiClient** : Remplacer récupération directe par UserService.getValidToken()
4. **UserService** : Ajouter méthode clearInvalidTokens()
5. **main.dart** : Améliorer gestion du chargement utilisateur au démarrage

## Tests
- Vérifier que les tokens sont correctement sauvegardés lors de la connexion
- Tester le rafraîchissement automatique des tokens expirés
- Vérifier le nettoyage automatique des sessions invalides
- Tester la robustesse du chargement utilisateur au démarrage

## Changements apportés

### UserService.getValidToken()
- ✅ Logs détaillés pour tracer la présence des tokens (longueur incluse)
- ✅ Vérification améliorée des tokens vides ou null
- ✅ Nettoyage automatique des tokens invalides avec clearInvalidTokens()
- ✅ Gestion d'erreur améliorée pour le rafraîchissement

### UserService.loadUser()
- ✅ Séparation des vérifications pour données utilisateur et token
- ✅ Nettoyage automatique des tokens invalides si données utilisateur présentes
- ✅ Logs détaillés pour chaque étape du processus
- ✅ Gestion d'erreur améliorée avec nettoyage automatique

### UserService.clearInvalidTokens()
- ✅ Nouvelle méthode pour nettoyer seulement les tokens sans supprimer les données utilisateur
- ✅ Préserve les données utilisateur tout en supprimant les tokens expirés

### ApiClient._getHeaders()
- ✅ Remplacement de la récupération directe par UserService.getValidToken()
- ✅ Rafraîchissement automatique des tokens lors des appels API
- ✅ Gestion d'erreur améliorée pour les tokens manquants

### main.dart
- ✅ Logs détaillés pour l'initialisation UserService
- ✅ Nettoyage automatique en cas d'erreur lors de l'initialisation
- ✅ Meilleure traçabilité du processus de chargement utilisateur

## Comportement attendu après corrections
1. **Au démarrage**: L'app vérifie automatiquement les tokens et les rafraîchit si nécessaire
2. **Tokens expirés**: Rafraîchissement automatique transparent pour l'utilisateur
3. **Tokens invalides**: Nettoyage automatique avec préservation des données utilisateur
4. **Erreurs API**: Gestion robuste avec logs détaillés pour le débogage
5. **Sessions corrompues**: Nettoyage automatique et redirection vers la connexion

## Comportement attendu
- Tokens valides automatiquement rafraîchis si expirés
- Sessions invalides automatiquement nettoyées
- Redirection propre vers la connexion si authentification échoue
- Logs détaillés pour faciliter le débogage
