// type_culture_service.dart
import 'dart:convert';
import 'package:agrobloc/core/features/Agrobloc/data/models/cultureModel.dart';

import 'package:agrobloc/core/utils/api_token.dart';
import 'dart:async';

class cultureService {
  final ApiClient api = ApiClient(ApiConfig.culturesBaseUrl);
  static const Duration timeoutDuration = Duration(seconds: 30);

  // ✅ Récupérer toutes les cultures
  Future<List<Culture>> getAllCulture() async {
    try {
      print('🔄 cultureService: Appel API /api/cultures');
      final response = await api.get('/api/cultures').timeout(timeoutDuration);
      print('📥 cultureService: Réponse reçue - Status: ${response.statusCode}');
      print('📄 cultureService: Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('📊 cultureService: ${data.length} éléments JSON reçus');
        return data.map((json) => Culture.fromJson(json)).toList();
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      // Gestion spécifique des erreurs
      if (e.toString().contains('Token non trouvé') || e.toString().contains('TokenInvalidException')) {
        throw Exception('Token non trouvé. Veuillez vous connecter.');
      }
      if (e.toString().contains('Serveur non accessible')) {
        throw Exception('Serveur non accessible. Vérifiez votre connexion réseau ou contactez le support.');
      }
      if (e is TimeoutException) {
        throw Exception('Délai d\'attente dépassé. Le serveur met trop de temps à répondre. Réessayez plus tard.');
      }
      print('❌ cultureService: Erreur lors de la récupération des  culture: $e');
      throw Exception('Erreur lors de la récupération des  culture: $e');
    }
  }

  // ✅ Récupérer une culture par ID
  Future<Culture> getTypeById(String id) async {
    try {
      final response = await api.get('/api/cultures/$id').timeout(timeoutDuration);

      if (response.statusCode == 200) {
        return Culture.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération du type de culture: $e');
    }
  }

  // ✅ Créer une nouvelle culture
  Future<Culture> createType(Culture type) async {
    try {
      final response = await api.post('/api/cultures', type.toJson())
          .timeout(timeoutDuration);

      if (response.statusCode == 201) {
        return Culture.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la création du type de culture: $e');
    }
  }

  // ✅ Mettre à jour une culture
  Future<Culture> updateType(String id, Culture type) async {
    try {
      final response = await api.put('/api/cultures/$id', type.toJson())
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        return Culture.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du type de culture: $e');
    }
  }

  // ✅ Supprimer une culture
  Future<void> deleteType(String id) async {
    try {
      final response = await api.delete('/api/cultures/$id')
          .timeout(timeoutDuration);

      if (response.statusCode != 200) {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la suppression du type de culture: $e');
    }
  }

}
