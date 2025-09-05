import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:agrobloc/core/features/Agrobloc/data/models/avisModel.dart';
import 'package:agrobloc/core/utils/api_token.dart';

class AvisService {
  static String get baseUrl => ApiConfig.apiBaseUrl;
  static const Duration timeout = Duration(seconds: 30);
  
  // Headers par défaut
  static Map<String, String> _getHeaders({String? token}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }

  // Créer un nouvel avis d'achat
  static Future<AvisAchatResponse> createAvisAchat({
    required CreateAvisAchatRequest request,
    required String token,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/avis-achat');
      
      final response = await http.post(
        url,
        headers: _getHeaders(token: token),
        body: json.encode(request.toJson()),
      ).timeout(timeout);

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body) as Map<String, dynamic>;
        return AvisAchatResponse.fromJson(responseData);
      } else if (response.statusCode == 400) {
        final errorData = json.decode(response.body) as Map<String, dynamic>;
        throw Exception(errorData['message'] ?? 'Données invalides');
      } else if (response.statusCode == 401) {
        throw Exception('Token d\'authentification invalide');
      } else if (response.statusCode == 500) {
        throw Exception('Erreur serveur');
      } else {
        throw Exception('Erreur inattendue: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('Pas de connexion internet');
    } on TimeoutException {
      throw Exception('Délai d\'attente dépassé');
    } catch (e) {
      rethrow;
    }
  }

  // Récupérer tous les avis d'une annonce d'achat
  static Future<List<AvisAchat>> getAvisAchatByAnnonce({
    required String annonceId,
    String? token,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/avis-achat/annonce/$annonceId');
      
      final response = await http.get(
        url,
        headers: _getHeaders(token: token),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body) as Map<String, dynamic>;
        final avisList = responseData['avis'] as List<dynamic>;
        
        return avisList
            .map((avis) => AvisAchat.fromJson(avis as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode == 404) {
        return []; // Aucun avis trouvé
      } else {
        throw Exception('Erreur lors de la récupération des avis');
      }
    } on SocketException {
      throw Exception('Pas de connexion internet');
    } on TimeoutException {
      throw Exception('Délai d\'attente dépassé');
    } catch (e) {
      rethrow;
    }
  }

  // Récupérer un avis par son ID
  static Future<AvisAchat> getAvisAchatById({
    required String avisId,
    String? token,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/avis-achat/$avisId');
      
      final response = await http.get(
        url,
        headers: _getHeaders(token: token),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body) as Map<String, dynamic>;
        return AvisAchat.fromJson(responseData['avis'] as Map<String, dynamic>);
      } else if (response.statusCode == 404) {
        throw Exception('Avis non trouvé');
      } else {
        throw Exception('Erreur lors de la récupération de l\'avis');
      }
    } on SocketException {
      throw Exception('Pas de connexion internet');
    } on TimeoutException {
      throw Exception('Délai d\'attente dépassé');
    } catch (e) {
      rethrow;
    }
  }

  // Récupérer les avis d'un utilisateur
  static Future<List<AvisAchat>> getAvisAchatByUser({
    required String userId,
    String? token,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/avis-achat/user/$userId');
      
      final response = await http.get(
        url,
        headers: _getHeaders(token: token),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body) as Map<String, dynamic>;
        final avisList = responseData['avis'] as List<dynamic>;
        
        return avisList
            .map((avis) => AvisAchat.fromJson(avis as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode == 404) {
        return []; // Aucun avis trouvé
      } else {
        throw Exception('Erreur lors de la récupération des avis');
      }
    } on SocketException {
      throw Exception('Pas de connexion internet');
    } on TimeoutException {
      throw Exception('Délai d\'attente dépassé');
    } catch (e) {
      rethrow;
    }
  }

  // Mettre à jour un avis
  static Future<AvisAchat> updateAvisAchat({
    required String avisId,
    required CreateAvisAchatRequest request,
    required String token,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/avis-achat/$avisId');
      
      final response = await http.put(
        url,
        headers: _getHeaders(token: token),
        body: json.encode(request.toJson()),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body) as Map<String, dynamic>;
        return AvisAchat.fromJson(responseData['avis'] as Map<String, dynamic>);
      } else if (response.statusCode == 404) {
        throw Exception('Avis non trouvé');
      } else if (response.statusCode == 403) {
        throw Exception('Vous n\'êtes pas autorisé à modifier cet avis');
      } else {
        throw Exception('Erreur lors de la mise à jour de l\'avis');
      }
    } on SocketException {
      throw Exception('Pas de connexion internet');
    } on TimeoutException {
      throw Exception('Délai d\'attente dépassé');
    } catch (e) {
      rethrow;
    }
  }

  // Supprimer un avis
  static Future<void> deleteAvisAchat({
    required String avisId,
    required String token,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/avis-achat/$avisId');
      
      final response = await http.delete(
        url,
        headers: _getHeaders(token: token),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        return; // Suppression réussie
      } else if (response.statusCode == 404) {
        throw Exception('Avis non trouvé');
      } else if (response.statusCode == 403) {
        throw Exception('Vous n\'êtes pas autorisé à supprimer cet avis');
      } else {
        throw Exception('Erreur lors de la suppression de l\'avis');
      }
    } on SocketException {
      throw Exception('Pas de connexion internet');
    } on TimeoutException {
      throw Exception('Délai d\'attente dépassé');
    } catch (e) {
      rethrow;
    }
  }
}
