import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/authentificationModel.dart';
import '../models/forgotPasswordModel.dart';
import '../dataSources/userService.dart';

class AuthService {
  static const String baseUrl = 'http://192.168.252.199:3000/authentification';

  /// Connexion utilisateur
  Future<AuthentificationModel> login(String identifiant, String password,
    {bool rememberMe = false}) async {
  final url = Uri.parse('$baseUrl/connexion');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'identifiant': identifiant,
      'password': password,
      'rememberMe': rememberMe,
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    // Supposons que l'API renvoie:
    // { "user": { ... }, "token": "xxxxxx" }

    final user = AuthentificationModel.fromJson(data['user']);
    final token = data['token'] as String?;

    if (token == null) {
      throw Exception("Token manquant dans la réponse");
    }

    // Sauvegarder l'utilisateur ET le token dans UserService + SharedPreferences
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
    final url = Uri.parse('$baseUrl/inscription');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nom': nom,
        'email': email,
        'numero_tel': numeroTel,
        'password': password,
        'confirmPassword': confirmPassword,
        'profil_id': profilId,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return AuthentificationModel.fromJson(data['user']);
    } else {
      throw Exception('Erreur d\'inscription: ${response.body}');
    }
  }

  /// Demande de réinitialisation de mot de passe
  Future<ForgotPasswordModel> requestResetPassword(String identifiant) async {
    final url = Uri.parse('$baseUrl/mot-de-passe-oublié');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'identifiant': identifiant}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ForgotPasswordModel.fromJson(data);
    } else {
      throw Exception(
          'Erreur lors de la demande de réinitialisation: ${response.body}');
    }
  }

  /// Récupère un utilisateur par ID (utile pour recharger la session)
  Future<AuthentificationModel> getUserById(String id) async {
    final url = Uri.parse('$baseUrl/utilisateur/$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return AuthentificationModel.fromJson(data);
    } else {
      throw Exception('Impossible de charger l\'utilisateur: ${response.body}');
    }
  }
}
