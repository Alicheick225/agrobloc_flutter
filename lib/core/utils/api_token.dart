// api_client.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decode/jwt_decode.dart';

class ApiClient {
  final String baseUrl;
  ApiClient(this.baseUrl);

  /// Récupère les headers (avec ou sans token)
  Future<Map<String, String>> _getHeaders({bool withAuth = true}) async {
    final headers = {"Content-Type": "application/json"};
    if (withAuth) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        throw Exception("Token non trouvé. Veuillez vous connecter.");
      }
      headers["Authorization"] = "Bearer $token";
    }
    return headers;
  }

  /// Requête GET
  Future<http.Response> get(String endpoint, {bool withAuth = true}) async {
    final headers = await _getHeaders(withAuth: withAuth);
    final url = Uri.parse('$baseUrl$endpoint');
    return http.get(url, headers: headers);
  }

  /// Requête POST
  Future<http.Response> post(String endpoint, Map<String, dynamic> body,
      {bool withAuth = true}) async {
    final headers = await _getHeaders(withAuth: withAuth);
    final url = Uri.parse('$baseUrl$endpoint');
    return http.post(url, headers: headers, body: jsonEncode(body));
  }

  /// 🔑 Récupérer le userId depuis le token JWT
  Future<String> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      throw Exception("Token non trouvé. Veuillez vous connecter.");
    }

    // Décoder le token
    final payload = Jwt.parseJwt(token);

    if (!payload.containsKey("user_id")) {
      throw Exception("user_id manquant dans le token");
    }

    return payload["user_id"].toString();
  }
}
