import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:agrobloc/core/features/Agrobloc/data/models/authentificationModel.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/forgotPasswordModel.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/userService.dart';

class AuthService {
  static const String baseUrl = 'http://192.168.252.199:3000/authentification';

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
      final user = AuthentificationModel.fromJson(data);
      
      // Stocker l'utilisateur dans le UserService
      UserService().setCurrentUser(user);
      
      return user;
    } else {
      throw Exception('Erreur de connexion: ${response.body}');
    }
  }

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

  Future<ForgotPasswordModel> requestResetPassword(String identifiant) async {
    final url = Uri.parse(
        '$baseUrl/mot-de-passe-oublié');
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
}
