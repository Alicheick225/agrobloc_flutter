import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/AnnonceVenteModel.dart';

class AnnonceService {
  static const String baseUrl = 'http://192.168.56.1:8081';
  static const Duration timeoutDuration = Duration(seconds: 60);

  // Headers communs pour les requêtes simples (pas pour MultipartRequest)
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// ✅ Récupérer toutes les annonces
  Future<List<AnnonceVente>> getAllAnnonces({
    String? userId,
    String? statut,
    String? typeCultureId,
  }) async {
    try {
      final queryParameters = <String, String>{};
      if (userId != null) queryParameters['user_id'] = userId;
      if (statut != null) queryParameters['statut'] = statut;
      if (typeCultureId != null)
        queryParameters['type_culture_id'] = typeCultureId;

      final uri = Uri.parse('$baseUrl/annonces_vente')
          .replace(queryParameters: queryParameters);

      final response =
          await http.get(uri, headers: headers).timeout(timeoutDuration);

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

  /// ✅ Récupérer une annonce par ID
  Future<AnnonceVente> getAnnonceById(String id) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/annonce_vente/$id'),
            headers: headers,
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        return AnnonceVente.fromJson(jsonDecode(response.body));
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      throw _handleException(e);
    }
  }

  /// ✅ Créer une annonce (multipart si photo)
  Future<AnnonceVente> createAnnonce({
    required String userId,
    required String typeCultureId,
    required String parcelleId,
    required String statut,
    required String description,
    required double quantite,
    required double prixKg,
    XFile? photo,
  }) async {
    try {
      var request =
          http.MultipartRequest('POST', Uri.parse('$baseUrl/annonce_vente'));

      // ⚠️ Ne pas ajouter Content-Type JSON pour MultipartRequest
      request.fields.addAll({
        'user_id': userId,
        'type_culture_id': typeCultureId,
        'parcelle_id': parcelleId,
        'statut': statut,
        'description': description,
        'quantite': quantite.toString(),
        'prix_kg': prixKg.toString(),
      });

      if (photo != null) {
        final fileExtension = photo.path.split('.').last;
        request.files.add(await http.MultipartFile.fromPath(
          'photo',
          photo.path,
          contentType: MediaType('image', fileExtension),
        ));
      }

      final response = await request.send().timeout(timeoutDuration);
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        return AnnonceVente.fromJson(jsonDecode(responseBody));
      } else {
        throw _handleError(http.Response(responseBody, response.statusCode));
      }
    } catch (e) {
      throw _handleException(e);
    }
  }

  /// ✅ Mettre à jour une annonce
  Future<AnnonceVente> updateAnnonce({
    required String id,
    required String statut,
    required String description,
    required double quantite,
    required double prixKg,
    required String parcelleId,
    required String typeCultureId,
    XFile? photo,
  }) async {
    try {
      var request =
          http.MultipartRequest('PUT', Uri.parse('$baseUrl/annonce_vente/$id'));

      request.fields.addAll({
        'statut': statut,
        'description': description,
        'quantite': quantite.toString(),
        'prix_kg': prixKg.toString(),
        'parcelle_id': parcelleId,
        'type_culture_id': typeCultureId,
      });

      if (photo != null) {
        final fileExtension = photo.path.split('.').last;
        request.files.add(await http.MultipartFile.fromPath(
          'photo',
          photo.path,
          contentType: MediaType('image', fileExtension),
        ));
      }

      final response = await request.send().timeout(timeoutDuration);
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return AnnonceVente.fromJson(jsonDecode(responseBody));
      } else {
        throw _handleError(http.Response(responseBody, response.statusCode));
      }
    } catch (e) {
      throw _handleException(e);
    }
  }

  /// ✅ Supprimer une annonce
  Future<void> deleteAnnonce(String id) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl/annonce_vente/$id'),
            headers: headers,
          )
          .timeout(timeoutDuration);

      if (response.statusCode != 200) {
        throw _handleError(response);
      }
    } catch (e) {
      throw _handleException(e);
    }
  }

  /// ✅ Gestion des erreurs HTTP
  Exception _handleError(http.Response response) {
    final statusCode = response.statusCode;
    String errorMessage = "Erreur inconnue";

    try {
      final body = jsonDecode(response.body);
      errorMessage = body['message'] ?? response.body;
    } catch (_) {
      errorMessage = response.body;
    }

    switch (statusCode) {
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
        return Exception('Erreur inattendue (code $statusCode): $errorMessage');
    }
  }

  /// ✅ Gestion des exceptions
  Exception _handleException(dynamic e) {
    if (e is http.ClientException) {
      return Exception('Erreur de connexion: ${e.message}');
    } else if (e is TimeoutException) {
      return Exception('La requête a expiré');
    } else if (e is FormatException) {
      return Exception('Erreur de format des données');
    }
    return Exception('Erreur inattendue: ${e.toString()}');
  }
}
