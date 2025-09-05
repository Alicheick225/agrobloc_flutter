// parcelle_service.dart
import 'dart:convert';
import 'package:agrobloc/core/features/Agrobloc/data/models/parcelleService.dart';
import 'package:agrobloc/core/utils/api_token.dart';
import 'dart:async';

class ParcelleService {
  final ApiClient api = ApiClient(ApiConfig.parcellesBaseUrl);
  static const Duration timeoutDuration = Duration(seconds: 15);

  // ✅ Récupérer toutes les parcelles
  Future<List<Parcelle>> getAllParcelles() async {
    try {
      print('🔄 ParcelleService: Appel API /api/parcelles/');
      final response = await api.get('/api/parcelles/').timeout(timeoutDuration);
      print('📥 ParcelleService: Réponse reçue - Status: ${response.statusCode}');
      print('📄 ParcelleService: Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('📊 ParcelleService: ${data.length} éléments JSON reçus');
        return data.map((json) => Parcelle.fromJson(json)).toList();
      } else {
        print('Erreur API getAllParcelles: ${response.statusCode} ${response.body}');
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e, stackTrace) {
      print('Exception getAllParcelles: $e');
      print(stackTrace);

      // Gestion spécifique de l'erreur "Token non trouvé"
      if (e.toString().contains('Token non trouvé') || e.toString().contains('TokenInvalidException')) {
        throw Exception('Token non trouvé. Veuillez vous connecter.');
      }
      if (e.toString().contains('Serveur non accessible')) {
        throw Exception('Serveur non accessible. Vérifiez votre connexion réseau ou contactez le support.');
      }
      if (e is TimeoutException) {
        throw Exception('Délai d\'attente dépassé. Le serveur met trop de temps à répondre. Réessayez plus tard.');
      }

      throw Exception('Erreur lors de la récupération des parcelles: $e');
    }
  }

  // ✅ Récupérer une parcelle par ID
  Future<Parcelle> getParcelleById(String id) async {
    try {
      print('🔄 ParcelleService: Appel API /api/parcelles/$id');
      final response = await api.get('/api/parcelles/$id').timeout(timeoutDuration);
      print('📥 ParcelleService: Réponse reçue - Status: ${response.statusCode}');
      print('📄 ParcelleService: Body: ${response.body}');

      if (response.statusCode == 200) {
        return Parcelle.fromJson(jsonDecode(response.body));
      } else {
        print('Erreur API getParcelleById: ${response.statusCode} ${response.body}');
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e, stackTrace) {
      print('Exception getParcelleById: $e');
      print(stackTrace);

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

      throw Exception('Erreur lors de la récupération de la parcelle: $e');
    }
  }
}
