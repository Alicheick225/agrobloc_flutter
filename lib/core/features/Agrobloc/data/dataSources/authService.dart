// auth_service.dart
import 'dart:convert';
import 'package:agrobloc/core/utils/api_token.dart';
import '../models/authentificationModel.dart';
import '../models/forgotPasswordModel.dart';
import '../dataSources/userService.dart';

/// Service gérant l'authentification de l'utilisateur
class AuthService {
  final ApiClient api = ApiClient('http://192.168.252.199:3000/authentification');


  /// Méthode pour parser manuellement les réponses JSON mal formées
  Map<String, dynamic> _parseManualResponse(String responseBody) {
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

      // Sauvegarde user + tokens
      await UserService().setCurrentUser(user, accessToken, refreshToken ?? "");

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

  /// Rafraîchit le token
  Future<Map<String, String>> refreshToken(String refreshToken) async {
    final response = await api.post(
      '/refresh',
      {'refreshToken': refreshToken},
      withAuth: false,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final newAccessToken = data['accessToken'] as String?;
      final newRefreshToken = data['refreshToken'] as String?;

      if (newAccessToken == null) throw Exception("Nouveau access token manquant");

      return {
        'accessToken': newAccessToken,
        'refreshToken': newRefreshToken ?? refreshToken,
      };
    } else {
      throw Exception("Erreur lors du refresh: ${response.body}");
    }
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

      // Sauvegarde user + tokens
      await UserService().setCurrentUser(user, accessToken, refreshToken ?? "");

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
}
