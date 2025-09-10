import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/authentificationModel.dart';
import 'authService.dart';

class UserService {
  static final UserService _instance = UserService._internal();

  // Set to true to enable verbose logging
  static const bool _verboseLogging = false;

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
        return false;
      }

      // Vérifier que chaque partie est en base64url
      for (final part in parts) {
        if (part.isEmpty) {
          return false;
        }
        // Vérifier les caractères base64url valides
        final base64Pattern = RegExp(r'^[A-Za-z0-9_-]+$');
        if (!base64Pattern.hasMatch(part)) {
          return false;
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Sauvegarde utilisateur + tokens avec validation et atomicité
  Future<void> setCurrentUser(AuthentificationModel user, String token, String refreshToken) async {
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

      // Vérifications de persistance détaillées
      if (savedToken != null && savedToken == token) {
      } else {
        await _rollbackSave(prefs, backupData);
        throw Exception('Échec de la persistance du token d\'accès');
      }

      if (savedRefreshToken != null && savedRefreshToken == refreshToken) {
      } else {
      }

      if (savedUserId != null && savedUserId == user.id) {
      } else {
        await _rollbackSave(prefs, backupData);
        throw Exception('Échec de la persistance du UserId');
      }

      if (savedUser != null) {
      } else {
        await _rollbackSave(prefs, backupData);
        throw Exception('Échec de la persistance des données utilisateur');
      }

    } catch (e, stackTrace) {
      // Tentative de rollback en cas d'échec
      if (prefs != null) {
        try {
          await _rollbackSave(prefs, await _createBackupBeforeSave(prefs));
        } catch (rollbackError) {
        }
      }

      rethrow;
    }
  }

  /// Récupère un token valide (refresh si nécessaire)
  Future<String?> getValidToken({bool forceRefresh = false, bool allowTempRefresh = false}) async {
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
          return null;
        }
      } catch (e) {
      }

      accessToken = prefs.getString("token");
      refreshToken = prefs.getString("refresh_token");

      if (accessToken == null || accessToken.isEmpty) {
        // Essayer de récupérer depuis les variables d'instance si disponibles
        if (_token != null && _token!.isNotEmpty) {
          // Sauvegarder le token d'instance dans SharedPreferences pour la persistance
          try {
            await prefs.setString('token', _token!);
            if (refreshToken != null && refreshToken.isNotEmpty) {
              await prefs.setString('refresh_token', refreshToken);
            }
          } catch (e) {
          }

          return _token;
        }

        // Tentative de récupération depuis un backup (si disponible)
        final backupToken = await _getTokenFromBackup();
        if (backupToken != null) {
          // Restaurer le token depuis le backup
          await prefs.setString('token', backupToken);
          _token = backupToken;
          return backupToken;
        }

        return null;
      }

      final isExpired = isTokenExpired(accessToken);

      // Force refresh if requested or if token is expired
      if (forceRefresh || isExpired) {
        // Retry logic for refresh attempts on network errors
        const int maxRefreshRetries = 3;
        int refreshAttempt = 0;
        while (refreshAttempt < maxRefreshRetries) {
          refreshAttempt++;
          try {
            // Check if refresh token is null or empty/whitespace
            final isRefreshTokenInvalid = refreshToken == null ||
                                          refreshToken.trim().isEmpty ||
                                          refreshToken == 'null';

            if (isRefreshTokenInvalid) {
              // Vérifier si c'est un token temporaire qui peut être utilisé pour le premier refresh
              final isTempToken = refreshToken != null && refreshToken.startsWith('temp_refresh_');
              if (isTempToken) {
                try {
                  final newTokens = await AuthService().refreshToken(refreshToken);
                  await prefs.setString("token", newTokens['accessToken']!);
                  await prefs.setString("refresh_token", newTokens['refreshToken']!);
                  _token = newTokens['accessToken']!;
                  return _token;
                } catch (tempRefreshError) {
                  if (tempRefreshError.toString().contains('Endpoint de refresh non trouvé') || tempRefreshError.toString().contains('404')) {
                    if (_token != null && !isTokenExpired(_token!)) {
                      return _token;
                    }
                  }
                  // Continue to backup token logic below
                }
              }

              // Try to use backup_token as refresh token
              final backupToken = await _getTokenFromBackup();
              if (backupToken != null && backupToken.isNotEmpty) {
                try {
                  final newTokens = await AuthService().refreshToken(backupToken);
                  await prefs.setString("token", newTokens['accessToken']!);
                  await prefs.setString("refresh_token", newTokens['refreshToken']!);
                  _token = newTokens['accessToken']!;
                  return _token;
                } catch (backupRefreshError) {
                  if (backupRefreshError.toString().contains('Endpoint de refresh non trouvé') || backupRefreshError.toString().contains('404')) {
                    if (_token != null && !isTokenExpired(_token!)) {
                      return _token;
                    }
                  }
                  if (refreshAttempt >= maxRefreshRetries) {
                    if (_onForceReLogin != null) {
                      _onForceReLogin!();
                    } else {
                      await clearInvalidTokens();
                    }
                    return null;
                  } else {
                    await Future.delayed(Duration(seconds: 2));
                    continue;
                  }
                }
              } else {
                if (refreshAttempt >= maxRefreshRetries) {
                  if (_onForceReLogin != null) {
                    _onForceReLogin!();
                  } else {
                    await clearInvalidTokens();
                  }
                  return null;
                } else {
                  await Future.delayed(Duration(seconds: 2));
                  continue;
                }
              }
            }

            try {
              final newTokens = await AuthService().refreshToken(refreshToken);
              await prefs.setString("token", newTokens['accessToken']!);
              await prefs.setString("refresh_token", newTokens['refreshToken']!);
              _token = newTokens['accessToken']!;
              return _token;
            } catch (e) {
              // Handle specific refresh errors
              if (e.toString().contains('Endpoint de refresh non trouvé') || e.toString().contains('404')) {
                // If current token is still valid, continue without refresh
                if (_token != null && !isTokenExpired(_token!)) {
                  return _token;
                } else {
                  if (_onForceReLogin != null) {
                    _onForceReLogin!();
                  } else {
                    await clearInvalidTokens();
                  }
                  return null;
                }
              } else {
                // Re-throw other errors
                rethrow;
              }
            }
          } catch (e, stackTrace) {
            if (refreshAttempt >= maxRefreshRetries) {
              await clearInvalidTokens();
              return null;
            } else {
              await Future.delayed(Duration(seconds: 2));
              continue;
            }
          }
        }
      }

      return accessToken;

    } catch (e, stackTrace) {
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

      return isExpired;
    } catch (e) {
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

    // TODO: Add event or callback to notify UI about logout/session expiration
  }

  /// Nettoie les tokens invalides sans supprimer les données utilisateur
  Future<void> clearInvalidTokens() async {
    _token = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('refresh_token');
  }

  /// Charger utilisateur depuis SharedPreferences
  Future<bool> loadUser() async {
    if (_isLoading) {
      return false;
    }
    _isLoading = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUserJson = prefs.getString('user');
      final savedToken = await getValidToken();

      if (savedUserJson == null) {
        _isLoading = false;
        return false;
      }

      if (savedToken == null) {
        await clearInvalidTokens();
        _isLoading = false;
        return false;
      }

      _token = savedToken;
      _currentUser = AuthentificationModel.fromJson(jsonDecode(savedUserJson));
      _userId = _currentUser?.id;

      _isLoading = false;
      return true;
    } catch (e, stackTrace) {
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
        return _cachedAuthState!;
      }
    }

    // Vérifier d'abord les variables d'instance pour un contrôle rapide
    if (_currentUser != null && _token != null && _token!.isNotEmpty) {
      final isTokenValid = !isTokenExpired(_token!);
      if (isTokenValid) {
        _cachedAuthState = true;
        _lastAuthCheck = DateTime.now();
        return true;
      }
    }

    // Vérifier le stockage persistant
    final hasData = await hasStoredUserData();

    if (hasData) {
      final result = await loadUser();
      _cachedAuthState = result;
      _lastAuthCheck = DateTime.now();
      return result;
    }

    // Fallback aux variables d'instance si aucune donnée stockée
    final fallbackResult = _currentUser != null && _token != null && _token!.isNotEmpty && !isTokenExpired(_token!);

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
          return backupToken;
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Créer un backup du token actuel
  Future<void> _createTokenBackup(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('backup_token', token);
      await prefs.setString('backup_timestamp', DateTime.now().toIso8601String());
    } catch (e) {
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
      return backup;
    } catch (e) {
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
    } catch (e) {
      rethrow;
    }
  }

  /// Déconnexion de l'utilisateur
  Future<void> logoutUser() async {
    await clearCurrentUser();
  }
}
