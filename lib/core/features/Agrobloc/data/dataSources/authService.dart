// auth_service.dart
import 'dart:convert';
import 'package:agrobloc/core/utils/api_token.dart';
import '../models/authentificationModel.dart';
import '../models/forgotPasswordModel.dart';
import '../dataSources/userService.dart';

/// Service gérant l'authentification de l'utilisateur
class AuthService {
  final ApiClient api = ApiClient('http://192.168.252.199:3000/authentification');

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
      withAuth: false, // pas besoin de token pour se connecter
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final user = AuthentificationModel.fromJson(data['user']);
      final token = data['token'] as String?;
      if (token == null) throw Exception("Token manquant dans la réponse");

      // Sauvegarde de l'utilisateur et du token localement
      await UserService().setCurrentUser(user, token);

      return user;
    } else {
      throw Exception('Erreur de connexion: ${response.body}');
    }
  }

  /// Inscription utilisateur
  Future<AuthentificationModel> register({
    required String nom,
    String? email,
    String? numeroTel,
    required String password,
    required String confirmPassword,
    required String profilId,
  }) async {
    final response = await api.post(
      '/inscription',
      {
        'nom': nom,
        'email': email,
        'numero_tel': numeroTel,
        'password': password,
        'confirmPassword': confirmPassword,
        'profil_id': profilId,
      },
      withAuth: false,
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final user = AuthentificationModel.fromJson(data['user']);
      return user;
    } else {
      throw Exception('Erreur d\'inscription: ${response.body}');
    }
  }

  /// Demande de réinitialisation de mot de passe
  Future<ForgotPasswordModel> requestResetPassword(String identifiant) async {
    final response = await api.post(
      '/mot-de-passe-oublié',
      {'identifiant': identifiant},
      withAuth: false,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ForgotPasswordModel.fromJson(data);
    } else {
      throw Exception('Erreur lors de la demande de réinitialisation: ${response.body}');
    }
  }

  Future<bool> verifyOtp(String identifiant, String otp) async {
    final response = await api.post(
      '/verifier-otp',
      {'identifiant': identifiant, 'otp': otp},
      withAuth: false,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['valid'] == true;
    } else {
      throw Exception('Erreur de vérification OTP: ${response.body}');
    }
  }

  /// Récupération d'un utilisateur par son ID
  Future<AuthentificationModel> getUserById(String id) async {
    final response = await api.get('/utilisateur/$id');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      // Vérifier si la réponse contient un message d'erreur même avec status 200
      if (data is Map<String, dynamic> && data.containsKey('message')) {
        final errorMessage = data['message'] as String?;
        if (errorMessage != null && errorMessage.toLowerCase().contains('accès refusé')) {
          throw Exception('Accès refusé: $errorMessage');
        } else if (errorMessage != null && errorMessage.isNotEmpty) {
          throw Exception('Erreur API: $errorMessage');
        }
      }
      
      // Vérifier si la réponse contient les données utilisateur attendues
      if (data is Map<String, dynamic> && 
          (data.containsKey('id') || data.containsKey('nom') || data.containsKey('email'))) {
        return AuthentificationModel.fromJson(data);
      } else {
        throw Exception('Réponse API invalide: format de données utilisateur incorrect');
      }
    } else {
      // Gérer les autres codes d'erreur HTTP
      final errorData = jsonDecode(response.body);
      final errorMessage = errorData is Map<String, dynamic> && errorData.containsKey('message')
          ? errorData['message'] as String
          : response.body;
      
      throw Exception('Impossible de charger l\'utilisateur: $errorMessage');
    }
  }
}
