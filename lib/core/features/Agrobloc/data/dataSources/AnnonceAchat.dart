import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;

import '../models/AnnonceAchatModel.dart';
import '../dataSources/userService.dart';

class AnnonceAchatService {
  // Endpoints (adapte si besoin)
  static const String _baseUrl = 'http://192.168.252.199:8080/annonces_achat';
  static const String _culturesUrl = 'http://192.168.252.249:8080/api/types-cultures';

  /// Headers avec token (si présent)
  Future<Map<String, String>> _getHeaders() async {
    final token = await UserService().getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Build Uri avec query parameters optionnels
  Uri _buildUri(String base, [Map<String, String?> params = const {}]) {
    final clean = <String, String>{};
    params.forEach((k, v) {
      if (v != null && v.isNotEmpty) clean[k] = v;
    });
    final uri = Uri.parse(base);
    return clean.isEmpty
        ? uri
        : uri.replace(queryParameters: {
            ...uri.queryParameters,
            ...clean,
          });
  }

  // ---------------------------
  // LECTURE
  // ---------------------------

  /// Récupère toutes les annonces (avec filtres serveur facultatifs)
  /// - user_id
  /// - statut
  /// - type_culture_id
  Future<List<AnnonceAchat>> fetchAnnonces({
    String? userId,
    String? statut,
    String? typeCultureId,
  }) async {
    try {
      final headers = await _getHeaders();
      final uri = _buildUri(_baseUrl, {
        'user_id': userId,
        'statut': statut,
        'type_culture_id': typeCultureId,
      });

      final response =
          await http.get(uri, headers: headers).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> body = json.decode(response.body);
        return body.map((item) => AnnonceAchat.fromJson(item)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Utilisateur non authentifié');
      } else {
        throw HttpException('Erreur ${response.statusCode}: ${response.reasonPhrase}');
      }
    } on SocketException {
      throw Exception('Pas de connexion Internet');
    } on TimeoutException {
      throw Exception('La requête a expiré');
    } catch (e) {
      throw Exception('Erreur inconnue: $e');
    }
  }

  /// Récupère UNIQUEMENT les annonces de l'utilisateur connecté (filtrage serveur via user_id)
  Future<List<AnnonceAchat>> fetchAnnoncesByUser() async {
    try {
      await UserService().ensureUserLoaded();
      final currentUserId = UserService().userId;
      if (currentUserId == null || currentUserId.isEmpty) {
        throw Exception('Utilisateur non connecté. Veuillez vous reconnecter.');
      }

      // Appel direct avec ?user_id=... pour laisser le serveur filtrer
      return await fetchAnnonces(userId: currentUserId);
    } on SocketException {
      throw Exception('Pas de connexion Internet');
    } on TimeoutException {
      throw Exception('La requête a expiré');
    } catch (e) {
      throw Exception('Erreur inconnue: $e');
    }
  }

  /// Récupère la liste des types de culture (fallback sur liste locale)
  static final List<Map<String, dynamic>> _defaultCultures = [
    {'id': '1', 'libelle': 'Maïs'},
    {'id': '2', 'libelle': 'Riz'},
    {'id': '3', 'libelle': 'Blé'},
    {'id': '4', 'libelle': 'Manioc'},
    {'id': '5', 'libelle': 'Sorgho'},
    {'id': '6', 'libelle': 'Mil'},
    {'id': '7', 'libelle': 'Arachide'},
    {'id': '8', 'libelle': 'Coton'},
    {'id': '9', 'libelle': 'Café'},
    {'id': '10', 'libelle': 'Cacao'},
    {'id': '11', 'libelle': 'Hévéa'},
    {'id': '12', 'libelle': 'Palmier à huile'},
    {'id': '13', 'libelle': 'Anacarde'},
    {'id': '14', 'libelle': 'Mangue'},
    {'id': '15', 'libelle': 'Banane'},
  ];

  Future<List<Map<String, dynamic>>> fetchCultures() async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(Uri.parse(_culturesUrl), headers: headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> body = json.decode(response.body);
        return body
            .map<Map<String, dynamic>>((item) => {
                  'id': item['id'].toString(),
                  'libelle': item['libelle'] ?? '',
                })
            .toList();
      } else if (response.statusCode == 401) {
        throw Exception('Utilisateur non authentifié. Veuillez vous reconnecter.');
      } else {
        return _defaultCultures;
      }
    } on SocketException {
      return _defaultCultures;
    } on TimeoutException {
      return _defaultCultures;
    } on http.ClientException {
      return _defaultCultures;
    } catch (_) {
      return _defaultCultures;
    }
  }

  /// Récupère une annonce par ID
  Future<AnnonceAchat> getAnnonceById(String id) async {
    try {
      final headers = await _getHeaders();
      final url = '$_baseUrl/$id';
      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return AnnonceAchat.fromJson(json.decode(response.body));
      } else if (response.statusCode == 401) {
        throw Exception('Utilisateur non authentifié');
      } else {
        throw HttpException('Erreur ${response.statusCode}: ${response.reasonPhrase}');
      }
    } on SocketException {
      throw Exception('Pas de connexion Internet');
    } on TimeoutException {
      throw Exception('La requête a expiré');
    } catch (e) {
      throw Exception('Erreur inconnue: $e');
    }
  }

  // ---------------------------
  // ÉCRITURE
  // ---------------------------

  /// Crée une nouvelle annonce d’achat
  /// API attend: statut, description, type_culture_id (UUID), quantite, prix_kg
  Future<AnnonceAchat> createAnnonceAchat({
    required String statut,
    required String description,
    required String typeCultureId,
    required double quantite,
    required double prix,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .post(
            Uri.parse(_baseUrl),
            headers: headers,
            body: jsonEncode({
              'statut': statut,
              'description': description,
              'type_culture_id': typeCultureId,
              'quantite': quantite,
              'prix_kg': prix,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 201 || response.statusCode == 200) {
        return AnnonceAchat.fromJson(json.decode(response.body));
      } else if (response.statusCode == 401) {
        throw Exception('Utilisateur non authentifié');
      } else {
        throw HttpException('Erreur ${response.statusCode}: ${response.body}');
      }
    } on SocketException {
      throw Exception('Pas de connexion Internet');
    } on TimeoutException {
      throw Exception('La requête a expiré');
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }

  /// Met à jour une annonce existante
  Future<AnnonceAchat> updateAnnonceAchat({
    required String id,
    required String statut,
    required String description,
    required String typeCultureId,
    required double quantite,
    required double prix,
  }) async {
    try {
      final headers = await _getHeaders();
      final url = '$_baseUrl/$id';
      final response = await http
          .put(
            Uri.parse(url),
            headers: headers,
            body: jsonEncode({
              'statut': statut,
              'description': description,
              'type_culture_id': typeCultureId,
              'quantite': quantite,
              'prix_kg': prix,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return AnnonceAchat.fromJson(json.decode(response.body));
      } else if (response.statusCode == 401) {
        throw Exception('Utilisateur non authentifié');
      } else {
        throw HttpException('Erreur ${response.statusCode}: ${response.body}');
      }
    } on SocketException {
      throw Exception('Pas de connexion Internet');
    } on TimeoutException {
      throw Exception('La requête a expiré');
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }

  /// Supprime une annonce
  Future<void> deleteAnnonceAchat(String id) async {
    try {
      final headers = await _getHeaders();
      final url = '$_baseUrl/$id';
      final response = await http
          .delete(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 401) {
        throw Exception('Utilisateur non authentifié');
      } else if (response.statusCode != 200 && response.statusCode != 204) {
        throw HttpException('Erreur ${response.statusCode}: ${response.body}');
      }
    } on SocketException {
      throw Exception('Pas de connexion Internet');
    } on TimeoutException {
      throw Exception('La requête a expiré');
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }
}
