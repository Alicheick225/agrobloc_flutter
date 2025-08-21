import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/commandeModel.dart';

class CommandeService {
  final String baseUrl =
      'http://192.168.252.199:3000/commandes'; // 🔁 Mets à jour si besoin

  Future<CommandeModel> enregistrerCommande({
    required String annoncesVenteId,
    required double quantite,
    required String unite,
    required String modePaiementId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      throw Exception("Token non trouvé. Veuillez vous connecter.");
    }

    final url = Uri.parse('$baseUrl/commandes-ventes');

    final body = jsonEncode({
      'annonces_vente_id': annoncesVenteId,
      'quantite': quantite,
      'unite': unite,
      'types_paiement_id': modePaiementId,
    });
    print("🔎 Corps envoyé : $body");

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: body,
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 201 || response.statusCode == 200) {
      if (response.body.isEmpty) {
        throw Exception("Réponse serveur vide");
      }
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (!responseData.containsKey('commande')) {
        throw Exception("Clé 'commande' manquante dans la réponse");
      }

      return CommandeModel.fromJson(responseData['commande']);
    } else {
      if (response.body.isEmpty) {
        throw Exception("Erreur inconnue, réponse vide du serveur");
      }
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Erreur inconnue');
    }
  }

  /// Récupérer toutes les commandes de l'acheteur
  Future<List<CommandeModel>> getAllCommandes() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      throw Exception("Token non trouvé. Veuillez vous connecter.");
    }

    final url = Uri.parse("$baseUrl/commandes-ventes");

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    print('📡 Response status: ${response.statusCode}');
    print('📡 Response body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      // Attention ici à la clé contenant la liste des commandes
      if (!data.containsKey('commandes')) {
        throw Exception(
            "Réponse serveur invalide : clé 'commandes' manquante.");
      }

      final List<dynamic> commandesJson = data['commandes'];

      // ✅ Debug pour voir la structure des données
      if (commandesJson.isNotEmpty) {
        print('🔍 Structure d\'une commande : ${commandesJson.first}');
      }

      return commandesJson.map((json) => CommandeModel.fromJson(json)).toList();
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
