// commande_service.dart
import 'dart:convert';
import 'package:agrobloc/core/utils/api_token.dart';
import '../models/commandeModel.dart';

class CommandeService {
  final ApiClient api = ApiClient(ApiConfig.commandesBaseUrl);

  /// Enregistrer une commande
  Future<CommandeModel> enregistrerCommande({
    required String annoncesVenteId,
    required double quantite,
    required String unite,
    String? modePaiementId,
  }) async {
    final response = await api.post(
      '/commandes',
      {
        'annonces_vente_id': annoncesVenteId,
        'quantite': quantite,
        'unite': unite,
        'types_paiement_id': modePaiementId,
      },
    );

    print('📥 [POST] /commandes -> ${response.statusCode}');
    print(response.body);

    if (response.statusCode == 201 || response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (!data.containsKey('commande')) {
        throw Exception("Clé 'commande' manquante dans la réponse");
      }
      return CommandeModel.fromJson(data['commande']);
    } else {
      throw Exception(
          jsonDecode(response.body)['message'] ?? 'Erreur inconnue');
    }
  }

  /// Récupérer toutes les commandes
  Future<List<CommandeModel>> getAllCommandes() async {
    final response = await api.get('/commandes');

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (!data.containsKey('commandes')) {
        throw Exception(
            "Réponse serveur invalide : clé 'commandes' manquante.");
      }
      return (data['commandes'] as List)
          .map((json) => CommandeModel.fromJson(json))
          .toList();
    } else {
      throw Exception("Erreur récupération commandes : ${response.body}");
    }
  }

  /// Récupérer les commandes d’un producteur
  Future<List<CommandeModel>> getProducerOrders(
      {String? status, bool? pending}) async {
    String query = '/commandes/producer';
    Map<String, String> queryParams = {};

    if (status != null) queryParams['status'] = status;
    if (pending != null) queryParams['pending'] = pending.toString();

    if (queryParams.isNotEmpty) {
      final queryString =
          queryParams.entries.map((e) => '${e.key}=${e.value}').join('&');
      query = '$query?$queryString';
    }

    final response = await api.get(query);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (!data.containsKey('commandes')) {
        throw Exception(
            "Réponse serveur invalide : clé 'commandes' manquante.");
      }
      return (data['commandes'] as List)
          .map((json) => CommandeModel.fromJson(json))
          .toList();
    } else {
      throw Exception(
          "Erreur récupération commandes producteur : ${response.body}");
    }
  }

  /// Confirmer le paiement d’une commande
  Future<bool> confirmerPaiement(String commandeId) async {
    final response =
        await api.post('/commandes/$commandeId/confirmer-paiement', {});

    print(
        "📥 [POST] /commandes/$commandeId/confirmer-paiement -> ${response.statusCode}");
    return response.statusCode == 200;
  }

  /// Annuler une commande spécifique
  Future<bool> annulerCommande(String id) async {
    if (id.isEmpty) {
      throw Exception("ID de la commande manquant ou invalide.");
    }

    try {
      // ✅ Ne rajoute pas "commandes/" puisque c'est déjà dans la base URL
      final response = await api.put('/commandes/$id/annuler', {});

      print("📥 [PUT] /commandes/$id/annuler -> ${response.statusCode}");
      print(response.body);

      if (response.statusCode == 200) {
        return true;
      } else if ([400, 403, 404].contains(response.statusCode)) {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Erreur lors de l’annulation');
      } else {
        throw Exception("Erreur inconnue : ${response.body}");
      }
    } catch (e) {
      if (e is FormatException) {
        throw Exception("Erreur de parsing de la réponse du serveur");
      }
      rethrow;
    }
  }
}
