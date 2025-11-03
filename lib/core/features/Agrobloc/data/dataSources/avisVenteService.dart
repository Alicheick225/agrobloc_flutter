import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:agrobloc/core/features/Agrobloc/data/models/avisVenteModel.dart';
// Note: Assurez-vous que la classe ApiClient est correctement définie
// dans le chemin spécifié ou utilisez le client http directement comme dans l'exemple.
import 'package:agrobloc/core/utils/api_token.dart'; 

class AvisVenteService {
  final String _baseUrl = "http://192.168.252.199:3000/avis-vente";
  final http.Client _apiClient;

  // Constructeur pour initialiser le client HTTP
  AvisVenteService({http.Client? apiClient})
      : _apiClient = apiClient ?? http.Client();

  // Accesseur pour les en-têtes
  Map<String, String> _getHeaders({required String token}) {
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  /// Créer un avis de vente (méthode non-statique)
  Future<AvisVenteModel> createAvisVente({
    required CreateAvisVenteRequest request,
    required String token,
  }) async {
    try {
      final response = await _apiClient.post(
        Uri.parse(_baseUrl),
        headers: _getHeaders(token: token),
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return AvisVenteModel.fromJson(data);
      } else {
        _handleHttpError(response);
        throw Exception('Erreur inattendue');
      }
    } on SocketException {
      throw Exception('Pas de connexion internet');
    } on FormatException {
      throw Exception('Format de réponse invalide');
    } on http.ClientException {
      throw Exception('Délai d\'attente dépassé');
    } catch (e) {
      if (e.toString().contains('Token')) {
        throw Exception('Token d\'authentification invalide');
      }
      rethrow;
    }
  }

  /// Récupérer tous les avis d'une annonce de vente (méthode non-statique)
  Future<List<AvisVenteModel>> getAvisVente(String annoncesVenteId) async {
    try {
      final response = await _apiClient.get(
        Uri.parse('$_baseUrl/$annoncesVenteId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => AvisVenteModel.fromJson(json)).toList();
      } else {
        _handleHttpError(response);
        return [];
      }
    } on SocketException {
      throw Exception('Pas de connexion internet');
    } catch (e) {
      print('Erreur lors de la récupération des avis: $e');
      return [];
    }
  }

  /// Récupérer un avis spécifique (méthode non-statique)
  Future<AvisVenteModel?> getAvisById(String avisId, {required String token}) async {
    try {
      final response = await _apiClient.get(
        Uri.parse('$_baseUrl/detail/$avisId'),
        headers: _getHeaders(token: token),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return AvisVenteModel.fromJson(data);
      } else {
        _handleHttpError(response);
        return null;
      }
    } on SocketException {
      throw Exception('Pas de connexion internet');
    } catch (e) {
      print('Erreur lors de la récupération de l\'avis: $e');
      return null;
    }
  }

  /// Mettre à jour un avis (méthode non-statique)
  Future<AvisVenteModel> updateAvisVente({
    required String avisId,
    required CreateAvisVenteRequest request,
    required String token,
  }) async {
    try {
      final response = await _apiClient.post(
        Uri.parse('$_baseUrl/$avisId/update'),
        headers: _getHeaders(token: token),
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return AvisVenteModel.fromJson(data);
      } else {
        _handleHttpError(response);
        throw Exception('Erreur inattendue');
      }
    } on SocketException {
      throw Exception('Pas de connexion internet');
    } catch (e) {
      rethrow;
    }
  }

  /// Supprimer un avis (méthode non-statique)
  Future<bool> deleteAvisVente(String avisId, {required String token}) async {
    try {
      final response = await _apiClient.delete(
        Uri.parse('$_baseUrl/$avisId'),
        headers: _getHeaders(token: token),
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } on SocketException {
      throw Exception('Pas de connexion internet');
    } catch (e) {
      print('Erreur lors de la suppression de l\'avis: $e');
      return false;
    }
  }

  /// Gestion centralisée des erreurs HTTP
  void _handleHttpError(http.Response response) {
    switch (response.statusCode) {
      case 400:
        throw Exception('Données invalides');
      case 401:
        throw Exception('Token d\'authentification invalide');
      case 403:
        throw Exception('Accès interdit');
      case 404:
        throw Exception('Ressource non trouvée');
      case 409:
        throw Exception('Vous avez déjà évalué cette annonce');
      case 422:
        throw Exception('Données invalides');
      case 500:
        throw Exception('Erreur serveur');
      default:
        throw Exception('Erreur HTTP ${response.statusCode}');
    }
  }
}