import 'dart:convert';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/userService.dart';
import 'package:http/http.dart' as http;
import '../models/annoncePrefinancementModel.dart';

class PrefinancementService {
  static const String _baseUrl = 'http://192.168.252.199:8080';

  /// Récupère le token valide et construit les headers
  Future<Map<String, String>> _getHeaders({bool forceRefresh = false, bool allowTempRefresh = false}) async {
    final token = await UserService().getValidToken(forceRefresh: forceRefresh, allowTempRefresh: allowTempRefresh); // refresh automatique
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
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/annonces_pref'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => AnnoncePrefinancement.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        // Try with forced refresh and allow temp refresh
        print("🚨 Token rejeté lors du chargement des préfinancements - tentative de refresh");
        final headersRetry = await _getHeaders(forceRefresh: true, allowTempRefresh: true);
        final retryResponse = await http.get(
          Uri.parse('$_baseUrl/annonces_pref'),
          headers: headersRetry,
        );

        if (retryResponse.statusCode == 200) {
          final List<dynamic> data = jsonDecode(retryResponse.body);
          return data.map((json) => AnnoncePrefinancement.fromJson(json)).toList();
        } else {
          throw Exception('Erreur lors du chargement des préfinancements après retry : ${retryResponse.body}');
        }
      } else {
        throw Exception('Erreur lors du chargement des préfinancements : ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur lors du chargement des préfinancements : $e');
    }
  }

  /// Récupérer une annonce de préfinancement par ID
  Future<AnnoncePrefinancement> fetchPrefinancementById(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/annonce_pref/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final jsonItem = json.decode(response.body);
        return AnnoncePrefinancement.fromJson(jsonItem);
      } else {
        throw Exception('Erreur lors du chargement du préfinancement : ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur lors du chargement du préfinancement : $e');
    }
  }

  Future<AnnoncePrefinancement> createPrefinancement({
    required String typeCultureId,
    required String parcelleId,
    required double quantite,
    required double prix,
    String description = "Pas de description",
  }) async {
    try {
      final headers = await _getHeaders();
      final Map<String, dynamic> body = {
        "statut": "EN_ATTENTE",
        "description": description,
        "type_culture_id": typeCultureId,
        "parcelle_id": parcelleId,
        "quantite": quantite,
        "prix": prix,
        "montant_pref": quantite * prix,
      };

      print("📤 Body envoyé : ${jsonEncode(body)}");

      final response = await http.post(
        Uri.parse('$_baseUrl/annonces_pref'),
        headers: headers,
        body: jsonEncode(body),
      );

      print("📥 Status code: ${response.statusCode}");
      print("📥 Body reçu: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonItem = json.decode(response.body);
        return AnnoncePrefinancement.fromJson(jsonItem);
      } else {
        // Handle authentication errors specifically
        if (response.statusCode == 401) {
          print("🚨 Token rejeté par le serveur - tentative de refresh forcé");

          // Force token refresh even if local check says it's valid
          final userService = UserService();
          final refreshedToken = await userService.getValidToken(forceRefresh: true, allowTempRefresh: true);

          if (refreshedToken != null) {
            print("✅ Token rafraîchi avec succès - nouvelle tentative");

            // Retry with refreshed token using _getHeaders with forceRefresh and allowTempRefresh
            final newHeaders = await _getHeaders(forceRefresh: true, allowTempRefresh: true);

            final retryResponse = await http.post(
              Uri.parse('$_baseUrl/annonces_pref'),
              headers: newHeaders,
              body: jsonEncode(body),
            );

            print("📥 Retry status code: ${retryResponse.statusCode}");
            print("📥 Retry body reçu: ${retryResponse.body}");

            if (retryResponse.statusCode == 200 || retryResponse.statusCode == 201) {
              final jsonItem = json.decode(retryResponse.body);
              return AnnoncePrefinancement.fromJson(jsonItem);
            } else if (retryResponse.statusCode == 401) {
              throw Exception("Erreur d'authentification: Token toujours invalide après refresh. Veuillez vous reconnecter.");
            } else {
              throw Exception('Erreur lors de la création du préfinancement après retry : ${retryResponse.body}');
            }
          } else {
            throw Exception("Erreur d'authentification: Impossible de rafraîchir le token. Veuillez vous reconnecter.");
          }
        }
        throw Exception('Erreur lors de la création du préfinancement : ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la création du préfinancement : $e');
    }
  }


}
