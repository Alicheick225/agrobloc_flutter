
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/AnnonceAchatModel.dart';

class AnnonceAchatService {
  static const String _baseUrl = 'http://192.168.252.19:8080/annonces_achat';
  
  // Fixed field mappings for consistent API communication
  static const String _culturesUrl = 'http://192.168.252.19:8080/types_culture';

  /// Récupère toutes les annonces avec le libellé de la culture
  Future<List<AnnonceAchat>> fetchAnnonces() async {
    try {
      final response = await http
          .get(Uri.parse(_baseUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> body = json.decode(response.body);
        return body.map((item) => AnnonceAchat.fromJson(item)).toList();
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

  /// Récupère la liste des types de culture
  Future<List<Map<String, dynamic>>> fetchCultures() async {
    try {
      final response = await http
          .get(Uri.parse(_culturesUrl))
          .timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final List<dynamic> body = json.decode(response.body);
        return body.map<Map<String, dynamic>>((item) => {
          'id': item['id'].toString(),
          'libelle': item['libelle'] ?? '',
        }).toList();
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

  /// Crée une nouvelle annonce d'achat
  Future<AnnonceAchat> createAnnonceAchat({
    required String statut,
    required String description,
    required String userId,
    required String typeCultureId,
    required double quantite,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(_baseUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'statut': statut,
              'description': description,
              'user_id': userId,
              'type_culture_id': typeCultureId,
              'quantite': quantite,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 201 || response.statusCode == 200) {
        return AnnonceAchat.fromJson(json.decode(response.body));
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
    required String userId,
    required String typeCultureId,
    required double quantite,
  }) async {
    try {
      final url = '$_baseUrl/$id';
      final response = await http
          .put(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'statut': statut,
              'description': description,
              'user_id': userId,
              'type_culture_id': typeCultureId,
              'quantite': quantite,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return AnnonceAchat.fromJson(json.decode(response.body));
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
      final url = '$_baseUrl/$id';
      final response = await http
          .delete(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200 && response.statusCode != 204) {
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
      final url = '$_baseUrl/$id';
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return AnnonceAchat.fromJson(json.decode(response.body));
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
}
