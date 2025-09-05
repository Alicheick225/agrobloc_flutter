import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/authentificationModel.dart';
import 'authService.dart';

class UserService {
  static final UserService _instance = UserService._internal();

  AuthentificationModel? _currentUser;
  String? _userId;
  String? _token;
  bool _isLoading = false;
  bool? _cachedAuthState;
  DateTime? _lastAuthCheck;

  // Grace period in seconds before considering token expired (to handle clock skew)
  static const int _tokenGracePeriodSeconds = 120;

  factory UserService() => _instance;
  UserService._internal();

  AuthentificationModel? get currentUser => _currentUser;
  String? get userId {
    print('🔍 UserService.userId getter - Valeur actuelle: ${_userId ?? "null"}');
    return _userId;
  }
  String? get token => _token;
  bool get isLoggedIn => _currentUser != null && _token != null && _token!.isNotEmpty;
  bool get isLoading => _isLoading;

  /// Callback pour gérer la reconnexion forcée
  Function? _onForceReLogin;

  /// Définit le callback pour la reconnexion forcée
  void setForceReLoginCallback(Function callback) {
    _onForceReLogin = callback;
  }

  /// Valide le format du token JWT
  bool _isValidTokenFormat(String token) {
    try {
      // Vérifier la structure de base du JWT (header.payload.signature)
      final parts = token.split('.');
      if (parts.length != 3) {
        print('❌ UserService._isValidTokenFormat() - Token invalide: doit contenir 3 parties séparées par des points');
        return false;
      }

      // Vérifier que chaque partie est en base64url
      for (final part in parts) {
        if (part.isEmpty) {
          print('❌ UserService._isValidTokenFormat() - Token invalide: une partie est vide');
          return false;
        }
        // Vérifier les caractères base64url valides
        final base64Pattern = RegExp(r'^[A-Za-z0-9_-]+$');
        if (!base64Pattern.hasMatch(part)) {
          print('❌ UserService._isValidTokenFormat() - Token invalide: caractères non base64url détectés');
          return false;
        }
      }

      print('✅ UserService._isValidTokenFormat() - Format du token valide');
      return true;
    } catch (e) {
      print('❌ UserService._isValidTokenFormat() - Erreur lors de la validation du format: $e');
      return false;
    }
  }

  /// Sauvegarde utilisateur + tokens avec validation et atomicité
  Future<void> setCurrentUser(AuthentificationModel user, String token, String refreshToken) async {
    print('🔄 UserService.setCurrentUser() - Début de sauvegarde avec validation...');
    print('🔍 UserService.setCurrentUser() - User ID: ${user.id}, Token length: ${token.length}, Refresh length: ${refreshToken.length}');

    // Validation des tokens avant sauvegarde
    if (!_isValidTokenFormat(token)) {
      throw Exception('Format du token d\'accès invalide');
    }

    if (refreshToken.isNotEmpty && !refreshToken.startsWith('temp_refresh_') && !_isValidTokenFormat(refreshToken)) {
      throw Exception('Format du token de rafraîchissement invalide');
    }

    // Validation des données utilisateur
    if (user.id.isEmpty || user.nom.isEmpty) {
      throw Exception('Données utilisateur incomplètes: ID ou nom manquant');
    }

    _currentUser = user;
    _userId = user.id;
    _token = token;

    // Clear authentication cache to force re-evaluation
    _cachedAuthState = null;
    _lastAuthCheck = null;

    SharedPreferences? prefs;
    try {
      prefs = await SharedPreferences.getInstance();

      // Sauvegarde atomique avec rollback en cas d'échec
      final backupData = await _createBackupBeforeSave(prefs);

      // Sauvegarde avec vérification
      await prefs.setString('user', jsonEncode(user.toJson()));
      await prefs.setString('userId', user.id);
      await prefs.setString('token', token);
      await prefs.setString('refresh_token', refreshToken);

      // Créer un backup du token pour la récupération
      await _createTokenBackup(token);

      // Vérification immédiate de la sauvegarde
      final savedToken = prefs.getString('token');
      final savedRefreshToken = prefs.getString('refresh_token');
      final savedUserId = prefs.getString('userId');
      final savedUser = prefs.getString('user');

      print('✅ UserService.setCurrentUser() - Sauvegarde terminée');
      print('🔍 UserService.setCurrentUser() - Vérification - Token saved: ${savedToken != null}, Refresh saved: ${savedRefreshToken != null}, UserId saved: ${savedUserId != null}, User saved: ${savedUser != null}');

      // Vérifications de persistance détaillées
      if (savedToken != null && savedToken == token) {
        print('✅ UserService.setCurrentUser() - Token d\'accès persistant vérifié');
      } else {
        print('❌ UserService.setCurrentUser() - ERREUR: Token d\'accès non persistant correctement!');
        print('🔍 UserService.setCurrentUser() - Attendu: ${token.substring(0, min(20, token.length))}...');
        print('🔍 UserService.setCurrentUser() - Sauvegardé: ${savedToken?.substring(0, min(20, savedToken.length)) ?? "null"}...');
        await _rollbackSave(prefs, backupData);
        throw Exception('Échec de la persistance du token d\'accès');
      }

      if (savedRefreshToken != null && savedRefreshToken == refreshToken) {
        print('✅ UserService.setCurrentUser() - Token de rafraîchissement persistant vérifié');
      } else {
        print('⚠️ UserService.setCurrentUser() - Token de rafraîchissement non persistant, mais poursuite...');
      }

      if (savedUserId != null && savedUserId == user.id) {
        print('✅ UserService.setCurrentUser() - UserId persistant vérifié');
      } else {
        print('❌ UserService.setCurrentUser() - ERREUR: UserId non persistant correctement!');
        await _rollbackSave(prefs, backupData);
        throw Exception('Échec de la persistance du UserId');
      }

      if (savedUser != null) {
        print('✅ UserService.setCurrentUser() - Données utilisateur persistantes vérifiées');
      } else {
        print('❌ UserService.setCurrentUser() - ERREUR: Données utilisateur non persistantes!');
        await _rollbackSave(prefs, backupData);
        throw Exception('Échec de la persistance des données utilisateur');
      }

      print('✅ UserService.setCurrentUser() - Toutes les vérifications de persistance réussies');

    } catch (e, stackTrace) {
      print('❌ UserService.setCurrentUser() - ERREUR lors de la sauvegarde: $e');
      print('❌ UserService.setCurrentUser() - Stack trace: $stackTrace');

      // Tentative de rollback en cas d'échec
      if (prefs != null) {
        try {
          await _rollbackSave(prefs, await _createBackupBeforeSave(prefs));
          print('✅ UserService.setCurrentUser() - Rollback effectué suite à l\'erreur');
        } catch (rollbackError) {
          print('❌ UserService.setCurrentUser() - Échec du rollback: $rollbackError');
        }
      }

      rethrow;
    }
  }

  /// Récupère un token valide (refresh si nécessaire)
  Future<String?> getValidToken({bool forceRefresh = false, bool allowTempRefresh = false}) async {
    print('🔄 UserService.getValidToken() - Début de récupération du token valide...');

    SharedPreferences? prefs;
    String? accessToken;
    String? refreshToken;

    try {
      prefs = await SharedPreferences.getInstance();

      // Vérifier d'abord si SharedPreferences fonctionne
      try {
        final testKey = 'test_key_for_debugging_${DateTime.now().millisecondsSinceEpoch}';
        await prefs.setString(testKey, 'test_value');
        final testValue = prefs.getString(testKey);
        await prefs.remove(testKey);

        if (testValue != 'test_value') {
          print('❌ UserService.getValidToken() - ERREUR: SharedPreferences ne fonctionne pas correctement! Valeur attendue: "test_value", valeur obtenue: "$testValue"');
          return null;
        }
        print('✅ UserService.getValidToken() - SharedPreferences fonctionne correctement');
      } catch (e) {
        print('❌ UserService.getValidToken() - ERREUR lors du test SharedPreferences: $e');
        // Continue without returning null - the test failure doesn't necessarily mean SharedPreferences is completely broken
        print('⚠️ UserService.getValidToken() - Continuation malgré l\'erreur de test SharedPreferences');
      }

      accessToken = prefs.getString("token");
      refreshToken = prefs.getString("refresh_token");

      print('🔍 UserService.getValidToken() - SharedPreferences OK');
      print('🔍 UserService.getValidToken() - accessToken: ${accessToken != null ? "présent (${accessToken.length} chars)" : "null"}, refreshToken: ${refreshToken != null ? "présent (${refreshToken.length} chars)" : "null"}');
      print('🔍 UserService.getValidToken() - forceRefresh: $forceRefresh, allowTempRefresh: $allowTempRefresh');

      // Vérifier toutes les clés de stockage avec valeurs détaillées
      final allKeys = prefs.getKeys();
      print('🔍 UserService.getValidToken() - Toutes les clés SharedPreferences: $allKeys');

      // Diagnostic détaillé des clés liées aux tokens
      for (final key in allKeys) {
        if (key.contains('token') || key.contains('user') || key.contains('auth')) {
          final value = prefs.get(key);
          final valueType = value.runtimeType.toString();
          final valuePreview = value is String && value.length > 50
              ? '${value.substring(0, 50)}...'
              : value.toString();
          print('🔍 UserService.getValidToken() - Clé: $key, Type: $valueType, Valeur: $valuePreview');
        }
      }

      // Vérifier les clés spécifiques attendues
      final expectedKeys = ['token', 'refresh_token', 'user', 'userId'];
      for (final key in expectedKeys) {
        final exists = prefs.containsKey(key);
        final value = prefs.get(key);
        print('🔍 UserService.getValidToken() - Clé "$key": ${exists ? "présente" : "absente"}, Valeur: ${value ?? "null"}');
      }

      if (accessToken == null || accessToken.isEmpty) {
        print('❌ UserService.getValidToken() - Aucun token d\'accès trouvé dans SharedPreferences');
        print('🔍 UserService.getValidToken() - Clés disponibles: ${allKeys.where((key) => key.contains("token") || key.contains("user")).toList()}');
        print('🔍 UserService.getValidToken() - DEBUG: accessToken is null: ${accessToken == null}, isEmpty: ${accessToken?.isEmpty ?? "N/A"}');
        print('🔍 UserService.getValidToken() - DEBUG: Instance token available: ${_token != null && _token!.isNotEmpty}');

        // Essayer de récupérer depuis les variables d'instance si disponibles
        if (_token != null && _token!.isNotEmpty) {
          print('🔄 UserService.getValidToken() - Tentative de récupération depuis variable d\'instance');
          print('✅ UserService.getValidToken() - Token récupéré depuis instance: ${_token!.length} chars');

          // Sauvegarder le token d'instance dans SharedPreferences pour la persistance
          try {
            await prefs.setString('token', _token!);
            if (refreshToken != null && refreshToken.isNotEmpty) {
              await prefs.setString('refresh_token', refreshToken);
            }
            print('✅ UserService.getValidToken() - Token d\'instance sauvegardé dans SharedPreferences');
          } catch (e) {
            print('⚠️ UserService.getValidToken() - Impossible de sauvegarder le token d\'instance: $e');
          }

          return _token;
        }

        // Tentative de récupération depuis un backup (si disponible)
        final backupToken = await _getTokenFromBackup();
        if (backupToken != null) {
          print('✅ UserService.getValidToken() - Token récupéré depuis backup');
          // Restaurer le token depuis le backup
          await prefs.setString('token', backupToken);
          _token = backupToken;
          return backupToken;
        }

        return null;
      }

      final isExpired = isTokenExpired(accessToken);
      print('🔍 UserService.getValidToken() - Token expiré: $isExpired');

      // Force refresh if requested or if token is expired
      if (forceRefresh || isExpired) {
        print("🔄 UserService.getValidToken() - ${forceRefresh ? 'Refresh forcé' : 'Token expiré'}, tentative de rafraîchissement...");
        try {
          // Check if refresh token is null or empty/whitespace
          final isRefreshTokenInvalid = refreshToken == null ||
                                        refreshToken.trim().isEmpty ||
                                        refreshToken == 'null';

          if (isRefreshTokenInvalid) {
            print('⚠️ UserService.getValidToken() - Token de rafraîchissement invalide (null/vide): "$refreshToken"');
            print('🔄 UserService.getValidToken() - Tentative d\'utilisation du backup_token comme refresh token...');

            // Try to use backup_token as refresh token
            final backupToken = await _getTokenFromBackup();
            if (backupToken != null && backupToken.isNotEmpty) {
              print('✅ UserService.getValidToken() - Backup token trouvé, tentative de refresh avec backup...');
              try {
                final newTokens = await AuthService().refreshToken(backupToken);
                await prefs.setString("token", newTokens['accessToken']!);
                await prefs.setString("refresh_token", newTokens['refreshToken']!);
                _token = newTokens['accessToken']!;
                print('✅ UserService.getValidToken() - Rafraîchissement réussi avec backup token');
                print('🔍 UserService.getValidToken() - Nouveau token sauvegardé (${newTokens['accessToken']!.length} chars)');
                return _token;
              } catch (backupRefreshError) {
                print('❌ UserService.getValidToken() - Échec du refresh avec backup token: $backupRefreshError');
                print('🔄 UserService.getValidToken() - Backup token invalide, déclenchement de la reconnexion forcée');
              }
            } else {
              print('⚠️ UserService.getValidToken() - Aucun backup token disponible');
            }

            print('🔄 UserService.getValidToken() - Token expiré et pas de refresh possible - déclenchement de la reconnexion forcée');

            // Déclencher le callback de reconnexion forcée si défini
            if (_onForceReLogin != null) {
              print('🔄 UserService.getValidToken() - Callback de reconnexion forcée appelé');
              _onForceReLogin!();
            } else {
              print('⚠️ UserService.getValidToken() - Aucun callback de reconnexion défini - nettoyage manuel des tokens');
              // Nettoyer les tokens invalides même sans callback
              await clearInvalidTokens();
            }

            return null;
          }

          print('🔄 UserService.getValidToken() - Appel de AuthService.refreshToken()...');
          final newTokens = await AuthService().refreshToken(refreshToken);
          await prefs.setString("token", newTokens['accessToken']!);
          await prefs.setString("refresh_token", newTokens['refreshToken']!);
          _token = newTokens['accessToken']!;
          print('✅ UserService.getValidToken() - Rafraîchissement du token réussi');
          print('🔍 UserService.getValidToken() - Nouveau token sauvegardé (${newTokens['accessToken']!.length} chars)');
          print('🔍 UserService.getValidToken() - Nouveau refresh token sauvegardé (${newTokens['refreshToken']!.length} chars)');
          return _token;
        } catch (e, stackTrace) {
          print("❌ UserService.getValidToken() - Échec du rafraîchissement du token: $e");
          print("❌ UserService.getValidToken() - Stack trace: $stackTrace");
          print("🔍 UserService.getValidToken() - Refresh token utilisé: ${refreshToken != null ? refreshToken.substring(0, refreshToken.length > 10 ? 10 : refreshToken.length) + '...' : 'null'}");

          // Nettoyer la session suite à l'échec du refresh
          print('🔄 UserService.getValidToken() - Nettoyage automatique de la session suite à l\'échec du refresh');
          await clearInvalidTokens();
          return null;
        }
      }

      print('✅ UserService.getValidToken() - Token valide, pas de rafraîchissement nécessaire');
      return accessToken;

    } catch (e, stackTrace) {
      print('❌ UserService.getValidToken() - ERREUR lors de l\'accès à SharedPreferences: $e');
      print('❌ UserService.getValidToken() - Stack trace: $stackTrace');
      return null;
    }
  }

  /// Vérifie si token JWT est expiré avec buffer pour les délais réseau
  bool isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final payloadMap = json.decode(decoded);
      final exp = payloadMap['exp'] as int;
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      // Ajouter un buffer supplémentaire pour les délais réseau (5 minutes)
      final networkDelayBuffer = 300; // 5 minutes en secondes
      final effectiveGracePeriod = _tokenGracePeriodSeconds + networkDelayBuffer;

      final isExpired = exp < (now - effectiveGracePeriod);
      final timeUntilExpiry = exp - now;

      print('🔍 UserService.isTokenExpired() - Token exp: $exp, now: $now');
      print('🔍 UserService.isTokenExpired() - Temps jusqu\'à expiration: ${timeUntilExpiry}s (${(timeUntilExpiry / 60).round()}min)');
      print('🔍 UserService.isTokenExpired() - Période de grâce: ${effectiveGracePeriod}s, isExpired: $isExpired');

      // Avertissement si le token expire bientôt (dans moins de 10 minutes)
      if (timeUntilExpiry > 0 && timeUntilExpiry < 600) {
        print('⚠️ UserService.isTokenExpired() - Token expire bientôt (${(timeUntilExpiry / 60).round()} minutes)');
      }

      return isExpired;
    } catch (e) {
      print('❌ UserService.isTokenExpired() - Erreur lors de la vérification: $e');
      return true;
    }
  }

  /// Supprime la session utilisateur
  Future<void> clearCurrentUser() async {
    _currentUser = null;
    _userId = null;
    _token = null;
    _cachedAuthState = null; // Clear cache
    _lastAuthCheck = null; // Clear cache timestamp

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    await prefs.remove('userId');
    await prefs.remove('token');
    await prefs.remove('refresh_token');

    print('✅ UserService: session utilisateur nettoyée');

    // TODO: Add event or callback to notify UI about logout/session expiration
  }

  /// Nettoie les tokens invalides sans supprimer les données utilisateur
  Future<void> clearInvalidTokens() async {
    _token = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('refresh_token');

    print('✅ UserService: tokens invalides nettoyés (données utilisateur conservées)');
  }

  /// Charger utilisateur depuis SharedPreferences
  Future<bool> loadUser() async {
    if (_isLoading) {
      print('🔄 UserService.loadUser() - Chargement déjà en cours, annulation');
      return false;
    }
    _isLoading = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUserJson = prefs.getString('user');
      final savedToken = await getValidToken();

      print('🔍 UserService.loadUser() - Données utilisateur présentes: ${savedUserJson != null}, Token valide: ${savedToken != null ? "oui" : "non"}');

      if (savedUserJson == null) {
        print('❌ UserService.loadUser() - Aucune donnée utilisateur trouvée dans SharedPreferences');
        _isLoading = false;
        return false;
      }

      if (savedToken == null) {
        print('❌ UserService.loadUser() - Aucun token valide disponible');
        print('⚠️ UserService.loadUser() - Données utilisateur présentes mais token invalide - nettoyage des tokens');
        print('🔍 UserService.loadUser() - DEBUG: Vérification des clés SharedPreferences...');

        // Debug: Check what's actually in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final allKeys = prefs.getKeys();
        print('🔍 UserService.loadUser() - DEBUG: Toutes les clés: $allKeys');

        for (final key in allKeys) {
          if (key.contains('token') || key.contains('user')) {
            final value = prefs.get(key);
            print('🔍 UserService.loadUser() - DEBUG: $key = ${value ?? "null"}');
          }
        }

        await clearInvalidTokens();
        _isLoading = false;
        return false;
      }

      _token = savedToken;
      _currentUser = AuthentificationModel.fromJson(jsonDecode(savedUserJson));
      _userId = _currentUser?.id;

      print('✅ UserService.loadUser() - Utilisateur chargé avec succès: ${_currentUser!.nom} (ID: ${_currentUser!.id})');
      print('🔍 UserService.loadUser() - Profil: ${_currentUser!.profilId}');
      _isLoading = false;
      return true;
    } catch (e, stackTrace) {
      print('❌ UserService.loadUser() - ERREUR lors du chargement: $e');
      print('❌ UserService.loadUser() - Stack trace: $stackTrace');
      print('🔄 UserService.loadUser() - Nettoyage automatique de la session suite à l\'erreur');
      await clearCurrentUser();
      _isLoading = false;
      return false;
    }
  }

  /// Vérifie si des données utilisateur sont stockées localement
  Future<bool> hasStoredUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final hasUserId = prefs.containsKey('userId');
    final hasToken = prefs.containsKey('token');
    return hasUserId && hasToken;
  }

  /// Vérifie si l'utilisateur est authentifié (avec cache pour éviter les appels répétés)
  Future<bool> isUserAuthenticated({bool forceRefresh = false}) async {
    // Vérifier le cache si disponible et pas expiré (30 secondes)
    if (!forceRefresh && _cachedAuthState != null && _lastAuthCheck != null) {
      final cacheAge = DateTime.now().difference(_lastAuthCheck!);
      if (cacheAge.inSeconds < 30) {
        print('🔍 UserService.isUserAuthenticated() - Utilisation du cache: $_cachedAuthState (âge: ${cacheAge.inSeconds}s)');
        return _cachedAuthState!;
      }
    }

    print('🔍 UserService.isUserAuthenticated() - Vérification de l\'authentification...');

    // Vérifier d'abord les variables d'instance pour un contrôle rapide
    if (_currentUser != null && _token != null && _token!.isNotEmpty) {
      final isTokenValid = !isTokenExpired(_token!);
      if (isTokenValid) {
        print('🔍 UserService.isUserAuthenticated() - Token valide en cache, authentification confirmée');
        _cachedAuthState = true;
        _lastAuthCheck = DateTime.now();
        return true;
      }
    }

    // Vérifier le stockage persistant
    final hasData = await hasStoredUserData();
    print('🔍 UserService.isUserAuthenticated() - Données stockées présentes: $hasData');

    if (hasData) {
      final result = await loadUser();
      print('🔍 UserService.isUserAuthenticated() - Résultat du chargement: $result');
      _cachedAuthState = result;
      _lastAuthCheck = DateTime.now();
      return result;
    }

    // Fallback aux variables d'instance si aucune donnée stockée
    final fallbackResult = _currentUser != null && _token != null && _token!.isNotEmpty && !isTokenExpired(_token!);
    print('🔍 UserService.isUserAuthenticated() - Fallback aux variables d\'instance: $fallbackResult');

    _cachedAuthState = fallbackResult;
    _lastAuthCheck = DateTime.now();
    return fallbackResult;
  }

  /// S'assure que l'utilisateur est chargé
  Future<void> ensureUserLoaded() async {
    if (_currentUser == null) {
      // Check if we have stored data first
      final hasData = await hasStoredUserData();
      if (hasData) {
        await loadUser();
      }
    }
  }

  /// Récupère le token actuel
  Future<String?> getToken() async {
    if (_token != null && _token!.isNotEmpty) {
      return _token;
    }

    // Try to get valid token from storage
    return await getValidToken();
  }

  /// Tentative de récupération du token depuis un backup
  Future<String?> _getTokenFromBackup() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Vérifier les clés de backup potentielles
      final backupKeys = ['backup_token', 'token_backup', 'emergency_token'];
      for (final key in backupKeys) {
        final backupToken = prefs.getString(key);
        if (backupToken != null && backupToken.isNotEmpty) {
          print('🔍 UserService._getTokenFromBackup() - Token trouvé dans backup: $key');
          return backupToken;
        }
      }

      print('🔍 UserService._getTokenFromBackup() - Aucun token de backup trouvé');
      return null;
    } catch (e) {
      print('❌ UserService._getTokenFromBackup() - Erreur lors de la récupération du backup: $e');
      return null;
    }
  }

  /// Créer un backup du token actuel
  Future<void> _createTokenBackup(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('backup_token', token);
      await prefs.setString('backup_timestamp', DateTime.now().toIso8601String());
      print('✅ UserService._createTokenBackup() - Backup créé pour le token');
    } catch (e) {
      print('❌ UserService._createTokenBackup() - Erreur lors de la création du backup: $e');
    }
  }

  /// Créer un backup des données avant sauvegarde pour rollback
  Future<Map<String, String?>> _createBackupBeforeSave(SharedPreferences prefs) async {
    final backup = <String, String?>{};
    try {
      final keysToBackup = ['user', 'userId', 'token', 'refresh_token'];
      for (final key in keysToBackup) {
        backup[key] = prefs.getString(key);
      }
      print('✅ UserService._createBackupBeforeSave() - Backup créé pour rollback');
      return backup;
    } catch (e) {
      print('❌ UserService._createBackupBeforeSave() - Erreur lors de la création du backup: $e');
      return backup; // Retourner un backup vide en cas d'erreur
    }
  }

  /// Effectuer un rollback en cas d'échec de sauvegarde
  Future<void> _rollbackSave(SharedPreferences prefs, Map<String, String?> backupData) async {
    try {
      for (final entry in backupData.entries) {
        if (entry.value != null) {
          await prefs.setString(entry.key, entry.value!);
        } else {
          await prefs.remove(entry.key);
        }
      }
      print('✅ UserService._rollbackSave() - Rollback effectué avec succès');
    } catch (e) {
      print('❌ UserService._rollbackSave() - Erreur lors du rollback: $e');
      rethrow;
    }
  }
}
