// commande_service.dart
import 'dart:convert';
import 'package:agrobloc/core/utils/api_token.dart';
import '../models/commandeModel.dart';

class CommandeService {
  final ApiClient api = ApiClient(ApiConfig.commandesBaseUrl);

  /// Enregistrer une commande
  Future<CommandeModel> enregistrerCommande({
    required String annonceId,
    required double quantite,
    required String unite,
    String? modePaiementId,
    String typeCommande = 'Annonce vente',
  }) async {
    // Validations client-side
    if (typeCommande.isEmpty || quantite <= 0 || unite.isEmpty) {
      throw Exception('Champs obligatoires manquants.');
    }

    if (typeCommande == 'Annonce vente' && annonceId.isEmpty) {
      throw Exception('annonces_vente_id requis pour type_commande Annonce vente.');
    }

    if (typeCommande == 'Annonce achat' && annonceId.isEmpty) {
      throw Exception('annonces_achat_id requis pour type_commande Annonce achat.');
    }

    if (!['Annonce vente', 'Annonce achat'].contains(typeCommande)) {
      throw Exception('type_commande invalide.');
    }

    print('🛒 Tentative de création de commande - Annonce ID: $annonceId, Quantité: $quantite $unite');

    final response = await api.post(
      '/commandes',
      {
        'type_commande': typeCommande,
        'annonces_vente_id': typeCommande == 'Annonce vente' ? annonceId : null,
        'annonces_achat_id': typeCommande == 'Annonce achat' ? annonceId : null,
        'quantite': quantite,
        'unite': unite,
        'mode_paiement_id': modePaiementId,
      },
    );

    print('📥 [POST] /commandes-> ${response.statusCode}');
    print('📄 Réponse: ${response.body}');

    if (response.statusCode == 201 || response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (!data.containsKey('commande')) {
        throw Exception("Clé 'commande' manquante dans la réponse");
      }
      print('✅ Commande créée avec succès - ID: ${data['commande']['id']}');
      return CommandeModel.fromJson(data['commande']);
    } else {
      // Améliorer la gestion des erreurs pour différencier les cas
      String errorMessage = 'Erreur inconnue lors de la création de commande';
      try {
        final errorData = jsonDecode(response.body);
        errorMessage = errorData['message'] ?? errorData['error'] ?? response.body;
      } catch (e) {
        errorMessage = response.body;
      }

      // Messages d'erreur spécifiques selon le code HTTP et le contenu
      if (response.statusCode == 404) {
        if (errorMessage.toLowerCase().contains('annonce') && errorMessage.toLowerCase().contains('trouv')) {
          errorMessage = "Cette annonce n'existe plus ou a été supprimée";
        } else {
          errorMessage = "Annonce introuvable - elle a peut-être été supprimée";
        }
      } else if (response.statusCode == 400) {
        if (errorMessage.toLowerCase().contains('disponible') || errorMessage.toLowerCase().contains('statut')) {
          errorMessage = "Cette annonce n'est plus disponible pour commande";
        } else if (errorMessage.toLowerCase().contains('quantite') || errorMessage.toLowerCase().contains('stock')) {
          errorMessage = "Quantité insuffisante en stock pour cette annonce";
        }
      } else if (response.statusCode == 409) {
        errorMessage = "Cette annonce a déjà été commandée ou n'est plus disponible";
      }

      print('❌ Erreur création commande: $errorMessage (Code: ${response.statusCode})');
      throw Exception(errorMessage);
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
