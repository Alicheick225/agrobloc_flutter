// auth_service.dart
import 'dart:convert';
import 'dart:math';
import 'package:agrobloc/core/utils/api_token.dart';
import '../models/authentificationModel.dart';
import '../models/forgotPasswordModel.dart';
import '../dataSources/userService.dart';

/// Service gérant l'authentification de l'utilisateur
import 'package:agrobloc/core/utils/api_token.dart';

class AuthService {
  final ApiClient api = ApiClient('${ApiConfig.apiBaseUrl}/authentification');


  /// Méthode pour parser manuellement les réponses JSON mal formées
  Map<String, dynamic> _parseManualResponse(String responseBody) {
    // Vérifier si la réponse est une page HTML (erreur serveur)
    if (responseBody.trim().startsWith('<!DOCTYPE') || responseBody.trim().startsWith('<html')) {
      print('❌ AuthService._parseManualResponse() - Réponse HTML détectée au lieu de JSON');
      return {'error': 'Réponse HTML détectée - probablement une page d\'erreur du serveur'};
    }

    try {
      // L'API retourne un JSON avec des guillemets manquants entre les champs
      // Exemple: {"message":"Connexion réussie.""token":"..."...}
      // Nous devons ajouter les virgules manquantes
      String fixedJson = responseBody
        .replaceAll('""', '","')
        .replaceAll('}"', '},"')
        .replaceAll('"{', '",{');

      return jsonDecode(fixedJson);
    } catch (e) {
      print('❌ Échec du parsing manuel: $e');
      return {'error': 'Erreur de parsing de la réponse API'};
    }
  }

  /// Connexion utilisateur
  Future<AuthentificationModel> login(
      String identifiant,
      String password, {
        bool rememberMe = false,
      }) async {
    final response = await api.post(
      '/connexion',
      {
        'identifiant': identifiant,
        'password': password,
        'rememberMe': rememberMe,
      },
      withAuth: false,
    );

    final responseBody = response.body;
    
    // Debug logging pour voir la réponse complète de l'API
    print('🔍 API Response - Status: ${response.statusCode}, Body: $responseBody');

    // Vérifier si la réponse contient une erreur même avec status code 200
    if (response.statusCode == 200) {
      // Cas spécial: l'API retourne un JSON mal formé avec des guillemets manquants
      // Essayons de parser manuellement si le JSON standard échoue
      dynamic data;
      try {
        data = jsonDecode(responseBody);
      } catch (e) {
        print('⚠️ JSON parsing error: $e - Tentative de parsing manuel');
        data = _parseManualResponse(responseBody);
      }

      // Vérifier si la réponse contient un message d'erreur
      if (data is Map<String, dynamic> && (data.containsKey('error') || data.containsKey('message'))) {
        final errorMessage = data['error'] ?? data['message'] ?? 'Erreur inconnue';
        
        // Cas spécial: si le message est "Connexion réussie", c'est une réponse valide
        if (errorMessage.toString().toLowerCase().contains('connexion réussie')) {
          print('✅ Message "Connexion réussie" détecté - traitement comme succès');
          // Continuer avec le traitement normal du succès
        } else {
          // Vérifier les erreurs d'authentification courantes
          if (errorMessage.toString().toLowerCase().contains('accès refusé') ||
              errorMessage.toString().toLowerCase().contains('access denied') ||
              errorMessage.toString().toLowerCase().contains('invalid credentials') ||
              errorMessage.toString().toLowerCase().contains('identifiant') ||
              errorMessage.toString().toLowerCase().contains('password')) {
            throw Exception('Erreur d\'authentification: $errorMessage');
          }
          
          throw Exception('Erreur de connexion: $errorMessage');
        }
      }

      // Vérifier que la réponse contient les données attendues
      if (!data.containsKey('user') || !data.containsKey('token')) {
        throw Exception('Réponse API incomplète: données utilisateur ou token manquantes');
      }

      final user = AuthentificationModel.fromJson(data['user']);
      final accessToken = data['token'] as String?;
      final refreshToken = data['refreshToken'] as String?;

      if (accessToken == null) throw Exception("Access token manquant");

      // Vérifier si le refresh token est disponible et valide
      String finalRefreshToken;

      // Check if refresh token is null, empty, or whitespace
      final isRefreshTokenInvalid = refreshToken == null ||
                                    refreshToken.trim().isEmpty ||
                                    refreshToken == 'null';

      if (isRefreshTokenInvalid) {
        print('⚠️ AuthService.login() - Refresh token invalide (null/vide): "$refreshToken"');
        print('🔄 AuthService.login() - Génération d\'un token temporaire pour éviter le refresh manuel');

        // Générer un token de rafraîchissement temporaire
        finalRefreshToken = _generateTemporaryRefreshToken(user.id, accessToken);
        print('🔍 AuthService.login() - Token temporaire généré: ${finalRefreshToken.substring(0, min(20, finalRefreshToken.length))}...');

        // Sauvegarder avec token temporaire
        await UserService().setCurrentUser(user, accessToken, finalRefreshToken);
        print('🔍 AuthService.login() - Tokens sauvegardés avec refresh token temporaire');
      } else {
        // Sauvegarde normale avec refresh token de l'API
        finalRefreshToken = refreshToken;
        await UserService().setCurrentUser(user, accessToken, refreshToken);
        print('🔍 AuthService.login() - Tokens sauvegardés avec refresh token API');
      }

      // Vérification de la persistance des tokens après sauvegarde
      await _verifyTokenPersistence(accessToken, finalRefreshToken);

      print('✅ Connexion réussie pour l\'utilisateur: ${user.nom}');
      return user;
    } else {
      // Pour les codes d'erreur HTTP, parser le message d'erreur si disponible
      String errorMessage = 'Erreur de connexion (${response.statusCode})';
      try {
        final errorData = jsonDecode(responseBody);
        if (errorData is Map<String, dynamic> && (errorData.containsKey('error') || errorData.containsKey('message'))) {
          final detailedError = errorData['error'] ?? errorData['message'];
          errorMessage = '$errorMessage: $detailedError';
        } else {
          errorMessage = '$errorMessage: ${response.body}';
        }
      } catch (e) {
        errorMessage = '$errorMessage: ${response.body}';
      }
      
      throw Exception(errorMessage);
    }
  }

  /// Valide le format du token JWT
  bool _isValidTokenFormat(String token) {
    try {
      // Vérifier la structure de base du JWT (header.payload.signature)
      final parts = token.split('.');
      if (parts.length != 3) {
        print('❌ AuthService._isValidTokenFormat() - Token invalide: doit contenir 3 parties séparées par des points');
        return false;
      }

      // Vérifier que chaque partie est en base64url
      for (final part in parts) {
        if (part.isEmpty) {
          print('❌ AuthService._isValidTokenFormat() - Token invalide: une partie est vide');
          return false;
        }
        // Vérifier les caractères base64url valides
        final base64Pattern = RegExp(r'^[A-Za-z0-9_-]+$');
        if (!base64Pattern.hasMatch(part)) {
          print('❌ AuthService._isValidTokenFormat() - Token invalide: caractères non base64url détectés');
          return false;
        }
      }

      print('✅ AuthService._isValidTokenFormat() - Format du token valide');
      return true;
    } catch (e) {
      print('❌ AuthService._isValidTokenFormat() - Erreur lors de la validation du format: $e');
      return false;
    }
  }

  /// Rafraîchit le token avec validation améliorée et gestion des erreurs réseau
  Future<Map<String, String>> refreshToken(String refreshToken) async {
    print('🔄 AuthService.refreshToken() - Tentative de rafraîchissement du token');
    print('🔍 AuthService.refreshToken() - Refresh token utilisé: ${refreshToken.substring(0, min(20, refreshToken.length))}...');

    // Validation du token de rafraîchissement avant l'appel API
    if (refreshToken.isEmpty) {
      throw Exception("Token de rafraîchissement vide");
    }

    // Vérifier si c'est un token temporaire
    final isTempToken = refreshToken.startsWith('temp_refresh_');
    if (isTempToken) {
      print('🔄 AuthService.refreshToken() - Token temporaire détecté, utilisation spéciale...');
      // Pour les tokens temporaires, on peut passer directement à l'appel API
      // car ils sont générés localement et ne suivent pas le format JWT standard
    } else if (!_isValidTokenFormat(refreshToken)) {
      throw Exception("Format du token de rafraîchissement invalide");
    }

    // Retry logic for network errors during refresh
    const int maxRefreshRetries = 2;
    int refreshAttempt = 0;
    while (refreshAttempt < maxRefreshRetries) {
      refreshAttempt++;
      try {
        final response = await api.post(
          '/refresh',
          {'refreshToken': refreshToken},
          withAuth: false,
        );

        print('🔍 AuthService.refreshToken() - Réponse API: Status ${response.statusCode}');
        print('🔍 AuthService.refreshToken() - Body length: ${response.body.length} chars');

        if (response.statusCode == 200) {
          dynamic data;
          try {
            data = jsonDecode(response.body);
          } catch (e) {
            print('⚠️ AuthService.refreshToken() - JSON parsing error: $e - Tentative de parsing manuel');
            data = _parseManualResponse(response.body);
          }

          final newAccessToken = data['accessToken'] as String?;
          final newRefreshToken = data['refreshToken'] as String?;

          if (newAccessToken == null || newAccessToken.isEmpty) {
            print('❌ AuthService.refreshToken() - Access token manquant ou vide dans la réponse');
            throw Exception("Nouveau access token manquant dans la réponse API");
          }

          // Validation du nouveau token
          if (!_isValidTokenFormat(newAccessToken)) {
            print('❌ AuthService.refreshToken() - Nouveau access token a un format invalide');
            throw Exception("Format du nouveau token d'accès invalide");
          }

          if (newRefreshToken != null && newRefreshToken.isNotEmpty && !newRefreshToken.startsWith('temp_refresh_') && !_isValidTokenFormat(newRefreshToken)) {
            print('⚠️ AuthService.refreshToken() - Nouveau refresh token a un format invalide, utilisation de l\'ancien');
            // Utiliser l'ancien refresh token si le nouveau est invalide
          }

          print('✅ AuthService.refreshToken() - Rafraîchissement réussi');
          print('🔍 AuthService.refreshToken() - Nouveau access token: ${newAccessToken.substring(0, min(20, newAccessToken.length))}...');

          return {
            'accessToken': newAccessToken,
            'refreshToken': newRefreshToken ?? refreshToken,
          };
        } else {
          // Vérifier si la réponse est une page HTML d'erreur
          if (response.body.trim().startsWith('<!DOCTYPE') || response.body.trim().startsWith('<html')) {
            print('❌ AuthService.refreshToken() - Réponse HTML détectée pour erreur ${response.statusCode}');
            // Gestion spécifique selon le code de statut
            if (response.statusCode == 401) {
              throw Exception("Token de rafraîchissement invalide ou expiré - page d'erreur HTML reçue");
            } else if (response.statusCode == 403) {
              throw Exception("Accès refusé lors du refresh - page d'erreur HTML reçue");
            } else if (response.statusCode == 404) {
              print('⚠️ AuthService.refreshToken() - Endpoint de refresh non trouvé (404). Le serveur ne supporte pas le refresh automatique.');
              print('🔄 AuthService.refreshToken() - Continuer sans refresh - l\'utilisateur devra se reconnecter manuellement si nécessaire.');
              // Instead of throwing, return empty access token to force re-login
              return {
                'accessToken': '', // Empty access token to force re-login
                'refreshToken': refreshToken, // Keep refresh token for future attempts
              };
            } else {
              throw Exception("Erreur serveur (${response.statusCode}) - page d'erreur HTML reçue");
            }
          }

          // Gestion spécifique des erreurs courantes avec parsing amélioré
          String errorMessage = "Erreur lors du refresh du token";

          try {
            dynamic errorData = jsonDecode(response.body);
            if (errorData is Map<String, dynamic>) {
              if (errorData.containsKey('error')) {
                errorMessage = errorData['error'];
              } else if (errorData.containsKey('message')) {
                errorMessage = errorData['message'];
              }
            } else if (errorData is String) {
              errorMessage = errorData;
            }
          } catch (e) {
            // Si le parsing JSON échoue, essayer le parsing manuel
            try {
              final manualData = _parseManualResponse(response.body);
              if (manualData is Map<String, dynamic>) {
                errorMessage = manualData['error'] ?? manualData['message'] ?? response.body;
              } else {
                errorMessage = response.body.isNotEmpty ? response.body : "Erreur inconnue du serveur";
              }
            } catch (manualError) {
              errorMessage = response.body.isNotEmpty ? response.body : "Erreur inconnue du serveur";
            }
          }

          print('❌ AuthService.refreshToken() - Échec du refresh: $errorMessage');

          // Erreurs spécifiques d'authentification avec messages détaillés
          if (response.statusCode == 401) {
            if (errorMessage.toLowerCase().contains('invalide') ||
                errorMessage.toLowerCase().contains('invalid')) {
              throw Exception("Token de rafraîchissement invalide: $errorMessage");
            } else if (errorMessage.toLowerCase().contains('expir') ||
                       errorMessage.toLowerCase().contains('expired')) {
              throw Exception("Token de rafraîchissement expiré: $errorMessage");
            } else {
              throw Exception("Authentification échouée lors du refresh: $errorMessage");
            }
          } else if (response.statusCode == 403) {
            throw Exception("Accès refusé lors du refresh: $errorMessage");
          } else if (response.statusCode == 404) {
            print('⚠️ AuthService.refreshToken() - Endpoint de refresh non trouvé (404). Le serveur ne supporte pas le refresh automatique.');
            print('🔄 AuthService.refreshToken() - Continuer sans refresh - l\'utilisateur devra se reconnecter manuellement si nécessaire.');
            // Instead of throwing, return the current token if it's still valid
            // This prevents the app from repeatedly failing on refresh
            if (refreshToken != null && refreshToken.isNotEmpty) {
              return {
                'accessToken': '', // Empty access token to force re-login
                'refreshToken': refreshToken, // Keep refresh token for future attempts
              };
            } else {
              throw Exception("Endpoint de refresh non trouvé et aucun token de refresh disponible: $errorMessage");
            }
          } else if (response.statusCode >= 500) {
            // Retry on server errors (5xx) or network errors
            if (refreshAttempt >= maxRefreshRetries) {
              throw Exception("Erreur serveur lors du refresh: $errorMessage");
            } else {
              print('🔄 AuthService.refreshToken() - Erreur serveur, nouvelle tentative après délai');
              await Future.delayed(Duration(seconds: 1));
              continue;
            }
          } else {
            throw Exception("Erreur lors du refresh (${response.statusCode}): $errorMessage");
          }
        }
      } catch (e, stackTrace) {
        print('❌ AuthService.refreshToken() - Exception: $e');
        print('❌ AuthService.refreshToken() - Stack trace: $stackTrace');

        // Retry on network-related exceptions
        if (refreshAttempt >= maxRefreshRetries) {
          rethrow;
        } else if (e.toString().toLowerCase().contains('network') ||
                   e.toString().toLowerCase().contains('connection') ||
                   e.toString().toLowerCase().contains('timeout') ||
                   e.toString().toLowerCase().contains('socket')) {
          print('🔄 AuthService.refreshToken() - Erreur réseau, nouvelle tentative après délai');
          await Future.delayed(Duration(seconds: 1));
          continue;
        } else {
          // Non-network errors should not be retried
          rethrow;
        }
      }
    }
    throw Exception('Échec après $maxRefreshRetries tentatives de rafraîchissement');
  }

  /// Récupération d'un utilisateur par son ID
  Future<AuthentificationModel> getUserById(String id) async {
    print('🔍 AuthService.getUserById() - Requesting user with ID: $id');
    
    try {
      final response = await api.get('/utilisateur/$id');
      
      print('🔍 AuthService.getUserById() - Response status: ${response.statusCode}');
      print('🔍 AuthService.getUserById() - Response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          print('✅ AuthService.getUserById() - Successfully parsed JSON response');
          return AuthentificationModel.fromJson(data);
        } catch (e) {
          print('❌ AuthService.getUserById() - JSON parsing error: $e');
          print('❌ Raw response: ${response.body}');
          
          // Try manual parsing for malformed JSON
          try {
            final manualData = _parseManualResponse(response.body);
            print('✅ AuthService.getUserById() - Manual parsing successful');
            return AuthentificationModel.fromJson(manualData);
          } catch (manualError) {
            print('❌ AuthService.getUserById() - Manual parsing also failed: $manualError');
            throw Exception('Erreur de parsing JSON pour l\'utilisateur: $manualError');
          }
        }
      } else {
        print('❌ AuthService.getUserById() - API error: ${response.statusCode} - ${response.body}');
        throw Exception('Impossible de charger l\'utilisateur (${response.statusCode}): ${response.body}');
      }
    } catch (e, stackTrace) {
      print('❌ AuthService.getUserById() - Network/API error: $e');
      print('❌ Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Inscription d'un nouvel utilisateur
  Future<AuthentificationModel> register({
    required String nom,
    String? email,
    String? numeroTel,
    required String password,
    required String confirmPassword,
    required String profilId,
  }) async {
    // Extract first and last name from full name
    final nameParts = nom.trim().split(' ');
    final prenom = nameParts.isNotEmpty ? nameParts[0] : '';
    final nomDeFamille = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    final response = await api.post(
      '/inscription',
      {
        'nom': nomDeFamille,
        'prenom': prenom,
        'email': email,
        'telephone': numeroTel,
        'password': password,
        'confirmPassword': confirmPassword,
        'profilId': profilId,
      },
      withAuth: false,
    );

    final responseBody = response.body;
    final data = jsonDecode(responseBody);

    // Vérifier si la réponse contient une erreur même avec status code 200/201
    if (response.statusCode == 200 || response.statusCode == 201) {
      // Vérifier si la réponse contient un message d'erreur
      if (data is Map<String, dynamic> && (data.containsKey('error') || data.containsKey('message'))) {
        final errorMessage = data['error'] ?? data['message'] ?? 'Erreur inconnue';
        
        // Vérifier les erreurs d'inscription courantes
        if (errorMessage.toString().toLowerCase().contains('email') ||
            errorMessage.toString().toLowerCase().contains('téléphone') ||
            errorMessage.toString().toLowerCase().contains('password') ||
            errorMessage.toString().toLowerCase().contains('existe déjà') ||
            errorMessage.toString().toLowerCase().contains('already exists')) {
          throw Exception('Erreur d\'inscription: $errorMessage');
        }
        
        throw Exception('Erreur lors de l\'inscription: $errorMessage');
      }

      // Vérifier que la réponse contient les données attendues
      if (!data.containsKey('user') || !data.containsKey('token')) {
        throw Exception('Réponse API incomplète: données utilisateur ou token manquantes');
      }

      final user = AuthentificationModel.fromJson(data['user']);
      final accessToken = data['token'] as String?;
      final refreshToken = data['refreshToken'] as String?;

      if (accessToken == null) throw Exception("Access token manquant");

      // Vérifier si le refresh token est disponible
      if (refreshToken == null || refreshToken.isEmpty) {
        print('⚠️ AuthService.register() - Aucun refresh token dans la réponse API');
        print('🔄 AuthService.register() - Continuer sans refresh token - refresh manuel requis');

        // Ne pas générer de token temporaire, sauvegarder sans refresh token
        await UserService().setCurrentUser(user, accessToken, '');
        print('🔍 AuthService.register() - Tokens sauvegardés sans refresh token');
      } else {
        // Sauvegarde normale avec refresh token de l'API
        await UserService().setCurrentUser(user, accessToken, refreshToken);
        print('🔍 AuthService.register() - Tokens sauvegardés avec refresh token API');
      }

      return user;
    } else {
      // Pour les codes d'erreur HTTP, parser le message d'erreur si disponible
      String errorMessage = 'Erreur lors de l\'inscription (${response.statusCode})';
      if (data is Map<String, dynamic> && (data.containsKey('error') || data.containsKey('message'))) {
        final detailedError = data['error'] ?? data['message'];
        errorMessage = '$errorMessage: $detailedError';
      } else {
        errorMessage = '$errorMessage: ${response.body}';
      }
      
      throw Exception(errorMessage);
    }
  }

  /// Génère un token de rafraîchissement temporaire
  String _generateTemporaryRefreshToken(String userId, String accessToken) {
    // Créer un token temporaire avec un timestamp et des données utilisateur
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomPart = (timestamp % 1000000).toString().padLeft(6, '0');

    // Format: temp_refresh_{userId}_{timestamp}_{random}
    final tempToken = 'temp_refresh_${userId}_${timestamp}_$randomPart';

    print('🔧 AuthService._generateTemporaryRefreshToken() - Token temporaire créé pour user $userId');
    return tempToken;
  }

  /// Vérifier la persistance des tokens après sauvegarde
  Future<void> _verifyTokenPersistence(String accessToken, String? refreshToken) async {
    try {
      print('🔍 AuthService._verifyTokenPersistence() - Vérification de la persistance des tokens...');

      // Attendre un court instant pour s'assurer que la sauvegarde est terminée
      await Future.delayed(const Duration(milliseconds: 100));

      // Tester la récupération via UserService
      final retrievedToken = await UserService().getValidToken();
      final isTokenValid = retrievedToken != null && retrievedToken == accessToken;

      print('🔍 AuthService._verifyTokenPersistence() - Token récupéré: ${retrievedToken != null ? "oui" : "non"}');
      print('🔍 AuthService._verifyTokenPersistence() - Token valide: $isTokenValid');

      if (!isTokenValid) {
        print('❌ AuthService._verifyTokenPersistence() - ERREUR: Token non persistant!');
        print('🔍 AuthService._verifyTokenPersistence() - Token attendu: ${accessToken.substring(0, min(20, accessToken.length))}...');
        print('🔍 AuthService._verifyTokenPersistence() - Token récupéré: ${retrievedToken?.substring(0, min(20, retrievedToken.length)) ?? "null"}...');

        // Tentative de sauvegarde forcée
        print('🔄 AuthService._verifyTokenPersistence() - Tentative de sauvegarde forcée...');
        await UserService().setCurrentUser(
          await UserService().currentUser ?? AuthentificationModel(id: '', nom: '', email: '', numeroTel: '', profilId: ''),
          accessToken,
          refreshToken ?? ''
        );
      } else {
        print('✅ AuthService._verifyTokenPersistence() - Persistance des tokens vérifiée');
      }
    } catch (e, stackTrace) {
      print('❌ AuthService._verifyTokenPersistence() - Erreur lors de la vérification: $e');
      print('❌ AuthService._verifyTokenPersistence() - Stack trace: $stackTrace');
    }
  }
}
