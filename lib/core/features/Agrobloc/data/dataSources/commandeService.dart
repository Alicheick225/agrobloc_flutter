// commande_service.dart
import 'dart:convert';
import 'package:agrobloc/core/utils/api_token.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/commandeModel.dart';

class CommandeService {
  final ApiClient api = ApiClient('http://192.168.252.199:3001/commandes');

  final String baseUrl = "http:///192.168.252.199:3001";

  Future<CommandeModel> enregistrerCommande({
    required String annoncesVenteId,
    required double quantite,
    required String unite,
    String? modePaiementId,
  }) async {
    final response = await api.post(
      '/commandes-ventes',
      {
        'annonces_vente_id': annoncesVenteId,
        'quantite': quantite,
        'unite': unite,
        'types_paiement_id': modePaiementId,
      },
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

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

  Future<List<CommandeModel>> getAllCommandes() async {
    final response = await api.get('/commandes-ventes');

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

  Future<bool> confirmerPaiement(String commandeId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final url = Uri.parse('$baseUrl/commandes/$commandeId/confirmer-paiement');

    final res = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    return res.statusCode == 200;
  }
}
