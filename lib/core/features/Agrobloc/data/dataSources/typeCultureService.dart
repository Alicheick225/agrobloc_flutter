// type_culture_service.dart
import 'dart:convert';
import 'package:agrobloc/core/features/Agrobloc/data/models/typecultureModel.dart';

import 'package:agrobloc/core/utils/api_token.dart';
import 'dart:async';

class TypeCultureService {
  final ApiClient api = ApiClient(ApiConfig.typesCulturesBaseUrl);
  static const Duration timeoutDuration = Duration(seconds: 30);

  // ✅ Récupérer toutes les cultures
  Future<List<TypeCulture>> getAllTypes() async {
    try {
      print('🔄 TypeCultureService: Appel API /api/cultures');
      final response = await api.get('/api/cultures').timeout(timeoutDuration);
      print(
          '📥 TypeCultureService: Réponse reçue - Status: ${response.statusCode}');
      print('📄 TypeCultureService: Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('📊 TypeCultureService: ${data.length} éléments JSON reçus');
        return data.map((json) => TypeCulture.fromJson(json)).toList();
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      // Gestion spécifique des erreurs
      if (e.toString().contains('Token non trouvé') ||
          e.toString().contains('TokenInvalidException')) {
        throw Exception('Token non trouvé. Veuillez vous connecter.');
      }
      if (e.toString().contains('Serveur non accessible')) {
        throw Exception(
            'Serveur non accessible. Vérifiez votre connexion réseau ou contactez le support.');
      }
      if (e is TimeoutException) {
        throw Exception(
            'Délai d\'attente dépassé. Le serveur met trop de temps à répondre. Réessayez plus tard.');
      }
      print(
          '❌ TypeCultureService: Erreur lors de la récupération des types de culture: $e');
      throw Exception(
          'Erreur lors de la récupération des types de culture: $e');
    }
  }

  // ✅ Récupérer une culture par ID
  Future<TypeCulture> getTypeById(String id) async {
    try {
      final response =
          await api.get('/api/cultures/$id').timeout(timeoutDuration);

      if (response.statusCode == 200) {
        return TypeCulture.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération du type de culture: $e');
    }
  }

  // ✅ Créer une nouvelle culture
  Future<TypeCulture> createType(TypeCulture type) async {
    try {
      final response = await api
          .post('/api/cultures', type.toJson())
          .timeout(timeoutDuration);

      if (response.statusCode == 201) {
        return TypeCulture.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la création du type de culture: $e');
    }
  }

  /// 🔹 Récupérer **uniquement les cultures de rente** (ou vivrière)
  Future<List<TypeCulture>> getTypesByCategory(String category) async {
    try {
      final allTypes = await getAllTypes();
      return allTypes
          .where(
              (t) => t.libelle.toLowerCase().contains(category.toLowerCase()))
          .toList();
    } catch (e) {
      return []; // ➜ jamais null
    }
  }
}
