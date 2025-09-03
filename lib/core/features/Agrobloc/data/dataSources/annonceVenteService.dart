import 'dart:async';
import 'dart:convert';
import 'package:agrobloc/core/utils/api_token.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decode/jwt_decode.dart';
import '../models/AnnonceVenteModel.dart';

class AnnonceService {
  final ApiClient api = ApiClient('http://192.168.252.199:8080');
  static const Duration timeoutDuration = Duration(seconds: 15);

  /// Récupérer et valider le token JWT
  Future<String> _getValidToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      throw Exception("Token manquant. Veuillez vous reconnecter.");
    }

    if (Jwt.isExpired(token)) {
      throw Exception("Token expiré. Veuillez vous reconnecter.");
    }

    return token;
  }

  /// Construire les headers pour les requêtes
  Future<Map<String, String>> _getHeaders({bool isMultipart = false}) async {
    final token = await _getValidToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': isMultipart ? 'multipart/form-data' : 'application/json',
    };
  }

  Future<String> _getUserId() async {
  final prefs = await SharedPreferences.getInstance();
  final uid = prefs.getString("user_id");
  if (uid == null || uid.isEmpty) {
    throw Exception("⚠️ user_id manquant, reconnectez-vous.");
  }
  return uid;
}

  /// Récupérer toutes les annonces
  Future<List<AnnonceVente>> getAllAnnonces() async {
    try {
      final response = await api.get('/annonces_vente');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => AnnonceVente.fromJson(json)).toList();
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      throw _handleException(e);
    }
  }

  /// Créer une annonce avec ou sans photo
  Future<AnnonceVente> createAnnonce({
    required String userId,
    required String typeCultureId,
    required String parcelleId,
    required String statut,
    required String description,
    required double quantite,
    required double prixKg,
    XFile? photo, // gestion de la photo optionnelle
  }) async {
    try {
      if (photo == null) {
        // Pas de photo → POST simple
        final body = {
          'user_id': userId,
          'type_culture_id': typeCultureId,
          'parcelle_id': parcelleId,
          'statut': statut,
          'description': description,
          'quantite': quantite,
          'prix_kg': prixKg,
        };
        final response = await api.post('/annonces_vente', body);

        if (response.statusCode == 201 || response.statusCode == 200) {
          return AnnonceVente.fromJson(jsonDecode(response.body));
        } else {
          throw _handleError(response);
        }
      } else {
        // Avec photo → MultipartRequest
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('${api.baseUrl}/annonces_vente'),
        );

        request.headers.addAll(await _getHeaders(isMultipart: true));

        request.fields.addAll({
          'user_id': userId,
          'type_culture_id': typeCultureId,
          'parcelle_id': parcelleId,
          'statut': statut,
          'description': description,
          'quantite': quantite.toString(),
          'prix_kg': prixKg.toString(),
        });

        print("🟢 [AnnonceService] Creating annonce...");
        print("📦 Fields: ${request.fields}");
        print("📝 Headers: ${request.headers}");

        final fileExtension = photo.path.split('.').last;
        request.files.add(await http.MultipartFile.fromPath(
          'photo',
          photo.path,
          contentType: MediaType('image', fileExtension),
        ));

        final response = await request.send().timeout(timeoutDuration);
        final responseBody = await response.stream.bytesToString();

        if (response.statusCode == 201) {
          return AnnonceVente.fromJson(jsonDecode(responseBody));
        } else {
          throw _handleError(http.Response(responseBody, response.statusCode));
        }
      }
    } catch (e) {
      throw _handleException(e);
    }
  }

  /// Récupérer une annonce par ID
  Future<AnnonceVente> getAnnonceByID(String id) async {
    try {
      final response = await api.get('/annonces_vente/$id');
      if (response.statusCode == 200) {
        return AnnonceVente.fromJson(jsonDecode(response.body));
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      throw _handleException(e);
    }
  }

  /// Récupérer les annonces d'un utilisateur spécifique
  Future<List<AnnonceVente>> getAnnoncesByUserID(String userId) async {
    try {
      final response = await api.get('/annonces_vente/user/$userId');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => AnnonceVente.fromJson(json)).toList();
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      throw _handleException(e);
    }
  }

  /// Récupérer uniquement les annonces de l'utilisateur connecté
  Future<List<AnnonceVente>> fetchAnnoncesByUser() async {
    try {
      final userId = await _getUserId();
      return await getAnnoncesByUserID(userId);
    } catch (e) {
      throw _handleException(e);
    }
  }

  /// Mettre à jour une annonce
  Future<AnnonceVente> updateAnnonce({
    required String id,
    required String statut,
    required String description,
    required String typeCultureId,
    required String parcelleId,
    required double quantite,
    required double prixKg,
    XFile? photo,
  }) async {
    try {
      if (photo == null) {
        // Mise à jour sans photo
        final body = {
          'statut': statut,
          'description': description,
          'type_culture_id': typeCultureId,
          'parcelle_id': parcelleId,
          'quantite': quantite,
          'prix_kg': prixKg,
        };
        final response = await api.put('/annonces_vente/$id', body);

        if (response.statusCode == 200) {
          return AnnonceVente.fromJson(jsonDecode(response.body));
        } else {
          throw _handleError(response);
        }
      } else {
        // Mise à jour avec photo
        var request = http.MultipartRequest(
          'PUT',
          Uri.parse('${api.baseUrl}/annonces_vente/$id'),
        );

        request.headers.addAll(await _getHeaders(isMultipart: true));

        request.fields.addAll({
          'statut': statut,
          'description': description,
          'type_culture_id': typeCultureId,
          'parcelle_id': parcelleId,
          'quantite': quantite.toString(),
          'prix_kg': prixKg.toString(),
        });

        final fileExtension = photo.path.split('.').last;
        request.files.add(await http.MultipartFile.fromPath(
          'photo',
          photo.path,
          contentType: MediaType('image', fileExtension),
        ));

        final response = await request.send().timeout(timeoutDuration);
        final responseBody = await response.stream.bytesToString();

        if (response.statusCode == 200) {
          return AnnonceVente.fromJson(jsonDecode(responseBody));
        } else {
          throw _handleError(http.Response(responseBody, response.statusCode));
        }
      }
    } catch (e) {
      throw _handleException(e);
    }
  }

  /// Supprimer une annonce
  Future<void> deleteAnnonce(String id) async {
    try {
      final response = await api.delete('/annonces_vente/$id');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw _handleError(response);
      }
    } catch (e) {
      throw _handleException(e);
    }
  }

  /// Gestion des erreurs HTTP
  Exception _handleError(http.Response response) {
    String errorMessage = "Erreur inconnue";
    try {
      final body = jsonDecode(response.body);
      errorMessage = body['message'] ?? response.body;
    } catch (_) {
      errorMessage = response.body;
    }

    switch (response.statusCode) {
      case 400:
        return Exception('Requête invalide: $errorMessage');
      case 401:
        return Exception('Non autorisé: $errorMessage');
      case 403:
        return Exception('Accès refusé: $errorMessage');
      case 404:
        return Exception('Ressource non trouvée: $errorMessage');
      case 500:
        return Exception('Erreur serveur: $errorMessage');
      default:
        return Exception('Erreur inattendue (code ${response.statusCode}): $errorMessage');
    }
  }

  /// Gestion des exceptions
  Exception _handleException(dynamic e) {
    if (e is http.ClientException) {
      return Exception('Erreur de connexion: ${e.message}');
    } else if (e is TimeoutException) {
      return Exception('La requête a expiré');
    } else if (e is FormatException) {
      return Exception('Erreur de format des données');
    } else if (e.toString().contains('Token non trouvé')) {
      return Exception('Token non trouvé. Veuillez vous connecter.');
    }
    return Exception('Erreur inattendue: ${e.toString()}');
  }
}
