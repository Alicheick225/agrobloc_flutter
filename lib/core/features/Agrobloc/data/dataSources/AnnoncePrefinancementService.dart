import 'dart:convert';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/userService.dart';
import 'package:agrobloc/core/utils/api_token.dart';
import 'package:http/http.dart' as http;
import '../models/annoncePrefinancementModel.dart';

class PrefinancementService {
  final ApiClient api = ApiClient('http://192.168.252.199:8080');

  /// Construire les headers pour les requêtes
  Future<Map<String, String>> _getHeaders() async {
    final token = await UserService().getToken();
    if (token == null || token.isEmpty) {
      throw Exception("⚠️ Token manquant, reconnectez-vous.");
    }

    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<List<AnnoncePrefinancement>> fetchPrefinancements() async {
    try {
      final response = await api.get('/annonces_pref');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((json) => AnnoncePrefinancement.fromJson(json))
            .toList();
      } else {
        throw Exception(
            'Erreur lors du chargement des préfinancements : ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur lors du chargement des préfinancements : $e');
    }
  }

  /// Récupérer une annonce de préfinancement par ID
  Future<AnnoncePrefinancement> fetchPrefinancementById(String id) async {
    final url = Uri.parse('${api.baseUrl}/annonce_pref/$id');
    final headers = await _getHeaders();

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final jsonItem = json.decode(response.body);
      return AnnoncePrefinancement.fromJson(jsonItem);
    } else {
      throw Exception(
          'Erreur lors du chargement du préfinancement : ${response.body}');
    }
  }

  Future<AnnoncePrefinancement> createPrefinancement({
    required String token,
    required String typeCultureId,
    required String parcelleId,
    required double quantite,
    required double prix,
    String description = "Pas de description",
  }) async {
    final url = Uri.parse('${api.baseUrl}/annonces_pref');

    final Map<String, dynamic> body = {
      "statut": "EN_ATTENTE",
      "description": description,
      "type_culture_id": typeCultureId,
      "parcelle_id": parcelleId,
      "quantite": quantite,
      "prix": prix,
    };

    print("🔑 Token utilisé : $token");
    print("📤 Body envoyé : ${jsonEncode(body)}");

    final headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );

    print("📥 Status code: ${response.statusCode}");
    print("📥 Body reçu: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonItem = json.decode(response.body);
      return AnnoncePrefinancement.fromJson(jsonItem);
    } else {
      throw Exception(
          'Erreur lors de la création du préfinancement : ${response.body}');
    }
  }
}
