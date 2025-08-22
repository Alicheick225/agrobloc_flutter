import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/AnnonceAchatModel.dart';
import '../dataSources/userService.dart';

class AnnonceAchatService {
  static const String _baseUrl = 'http://192.168.252.199:8080/annonces_achat';

  // Fixed field mappings for consistent API communication
  static const String _culturesUrl =
      'http://192.168.252.249:8080/api/types-cultures';

  /// Helper method to get headers with authentication token
  Future<Map<String, String>> _getHeaders() async {
    final token = await UserService().getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Récupère toutes les annonces avec le libellé de la culture
  Future<List<AnnonceAchat>> fetchAnnonces() async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(Uri.parse(_baseUrl), headers: headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> body = json.decode(response.body);
        return body.map((item) => AnnonceAchat.fromJson(item)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Utilisateur non authentifié');
      } else {
        throw HttpException(
            'Erreur ${response.statusCode}: ${response.reasonPhrase}');
      }
    } on SocketException {
      throw Exception('Pas de connexion Internet');
    } on TimeoutException {
      throw Exception('La requête a expiré');
    } catch (e) {
      throw Exception('Erreur inconnue: $e');
    }
  }

  /// Récupère la liste des types de culture
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
        throw Exception('Utilisateur non authentifié');
      } else {
        throw HttpException(
            'Erreur ${response.statusCode}: ${response.reasonPhrase}');
      }
    } on SocketException {
      throw Exception('Pas de connexion Internet');
    } on TimeoutException {
      throw Exception('La requête a expiré');
    } catch (e) {
      throw Exception('Erreur inconnue: $e');
    }
  }

  /// Crée une nouvelle annonce d'achat
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
        print('Erreur API ${response.statusCode} : ${response.body}');
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

  /// Supprime une annonce par son ID
  Future<void> deleteAnnonceAchat(String id) async {
    try {
      final headers = await _getHeaders();
      final url = '$_baseUrl/$id';
      final response = await http
          .delete(
            Uri.parse(url),
            headers: headers,
          )
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

  /// Récupère une annonce par son ID
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
        throw HttpException(
            'Erreur ${response.statusCode}: ${response.reasonPhrase}');
      }
    } on SocketException {
      throw Exception('Pas de connexion Internet');
    } on TimeoutException {
      throw Exception('La requête a expiré');
    } catch (e) {
      throw Exception('Erreur inconnue: $e');
    }
  }
}
