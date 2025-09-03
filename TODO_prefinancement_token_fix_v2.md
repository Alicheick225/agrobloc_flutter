# TODO: Préfinancement Token Fix - Version 2

## Problème identifié
Le problème persiste malgré la correction initiale. Les logs montrent :
- Token d'accès présent (261 caractères)
- Token de refresh présent mais vide (0 caractères)
- Token localement valide mais rejeté par le serveur (401 Unauthorized)
- Erreur "Token invalide" lors de la création de préfinancement

## Root Cause
1. Le token de refresh est vide, empêchant le refresh automatique
2. Le serveur rejette le token même s'il n'est pas expiré localement
3. Pas de mécanisme de retry automatique lors d'erreur 401

## Solution implémentée
### 1. UserService.getValidToken() - Ajout du paramètre forceRefresh
- Ajout du paramètre optionnel `forceRefresh: bool` (défaut: false)
- Permet de forcer le refresh même si le token semble valide localement
- Log amélioré pour tracer les appels
- **NOUVEAU** : Gestion spéciale des tokens temporaires

### 2. PrefinancementService - Gestion automatique des erreurs 401
- **createPrefinancement()** : Retry automatique avec refresh forcé
- **fetchPrefinancements()** : Retry automatique avec refresh forcé
- **_getHeaders()** : Support du paramètre forceRefresh
- Logs détaillés pour tracer le processus de retry

### 3. AuthService - Gestion des tokens manquants
- **login()** : Génération automatique de refresh token temporaire si manquant
- **register()** : Génération automatique de refresh token temporaire si manquant
- Compatibilité avec l'API actuelle qui ne retourne pas toujours de refresh token
- Logs détaillés pour tracer la génération de tokens temporaires

### 4. Gestion d'erreur améliorée
- Messages d'erreur spécifiques pour les échecs de refresh
- Retry automatique transparent pour l'utilisateur
- Nettoyage automatique des tokens invalides
- Gestion spéciale des tokens temporaires (pas de tentative de refresh API)

## Fichiers modifiés
- ✅ `lib/core/features/Agrobloc/data/dataSources/userService.dart`
  - Ajout du paramètre `forceRefresh` à `getValidToken()`
  - Log amélioré pour le debugging
- ✅ `lib/core/features/Agrobloc/data/dataSources/AnnoncePrefinancementService.dart`
  - Retry automatique sur erreur 401
  - Support du refresh forcé dans `_getHeaders()`
  - Gestion d'erreur améliorée pour tous les endpoints

## Instructions de test
### Test 1: Scénario normal (token valide)
1. Lancer l'application : `flutter run`
2. Se connecter avec des identifiants valides
3. Naviguer vers le formulaire de préfinancement
4. Remplir et soumettre le formulaire
5. **Résultat attendu** : Création réussie sans erreur 401

### Test 2: Scénario avec token expiré
1. Se connecter et utiliser l'app normalement
2. Attendre ou forcer l'expiration du token (modifier manuellement la date d'expiration)
3. Tenter de créer un préfinancement
4. **Résultat attendu** :
   - Refresh automatique du token
   - Retry de la requête avec le nouveau token
   - Création réussie

### Test 3: Scénario avec token de refresh vide
1. Modifier manuellement le refresh token pour qu'il soit vide
2. Tenter de créer un préfinancement
3. **Résultat attendu** :
   - Détection de l'impossibilité de refresh
   - Message d'erreur clair demandant la reconnexion
   - Nettoyage automatique de la session

### Test 4: Vérification des logs
1. Ouvrir les logs de l'application
2. Rechercher les patterns suivants :
   - `🔍 UserService.getValidToken() - forceRefresh: true/false`
   - `🚨 Token rejeté par le serveur - tentative de refresh forcé`
   - `✅ Token rafraîchi avec succès - nouvelle tentative`
   - `📥 Retry status code: 200/201`

## Logs attendus
```
🔍 UserService.getValidToken() - accessToken: présent (261 chars), refreshToken: présent (0 chars)
🔍 UserService.getValidToken() - forceRefresh: false
🔍 UserService.getValidToken() - Token expiré: false
✅ UserService.getValidToken() - Token valide, pas de rafraîchissement nécessaire
📤 Body envoyé : {"statut":"EN_ATTENTE",...}
📥 Status code: 401
📥 Body reçu: {"error":"Token invalide"}
🚨 Token rejeté par le serveur - tentative de refresh forcé
🔍 UserService.getValidToken() - forceRefresh: true
🔄 UserService.getValidToken() - Refresh forcé, tentative de rafraîchissement...
✅ Token rafraîchi avec succès - nouvelle tentative
📥 Retry status code: 201
```

## Points de vérification
- [ ] Token refresh fonctionne correctement
- [ ] Retry automatique sur erreur 401
- [ ] Gestion d'erreur appropriée quand refresh échoue
- [ ] Nettoyage automatique des tokens invalides
- [ ] Messages d'erreur clairs pour l'utilisateur
- [ ] Logs détaillés pour le debugging

## Prochaines étapes si nécessaire
1. Si le refresh token est toujours vide, vérifier le processus de login
2. Si le serveur continue à rejeter les tokens, vérifier la configuration du serveur
3. Ajouter un mécanisme de retry exponentiel si nécessaire
4. Implémenter une file d'attente pour les requêtes pendant le refresh

## État du fix
- [x] Analyse du problème
- [x] Implémentation du force refresh
- [x] Retry automatique sur 401
- [x] Logs détaillés
- [ ] Tests en cours
- [ ] Validation finale
