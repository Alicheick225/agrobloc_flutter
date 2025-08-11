import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/commandeModel.dart';
import '../dataSources/userService.dart';

class CommandeService {
  final String baseUrl = 'http://192.168.252.199:3000/commandes';

  Future<CommandeModel> enregistrerCommande({
  required double quantite,
  required double prixTotal,
  required String modePaiementId,
  required String typeCulture,
  required String annoncesVenteId,
  String unite = "Kg",
}) async {
  final acheteurId = UserService().userId;
  if (acheteurId == null) {
    throw Exception("Utilisateur non connecté !");
  }

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  if (token == null) {
    throw Exception("Token non trouvé. Veuillez vous connecter.");
  }

  final url = Uri.parse("$baseUrl/commandes-ventes");

  if (annoncesVenteId.isEmpty) {
    throw Exception("Erreur : annoncesVenteId est vide.");
  }

  final body = {
    "quantite": quantite.toStringAsFixed(2),
    "prix_total": prixTotal.toStringAsFixed(2),
    "mode_paiement_id": modePaiementId,
    "type_culture": typeCulture,
    "acheteur_id": acheteurId,
    "annonces_vente_id": annoncesVenteId,
  };

  print("🔎 Données envoyées au serveur : $body");

  final response = await http.post(
    url,
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    },
    body: jsonEncode(body),
  );

  print("📡 Status HTTP: ${response.statusCode}");
  print("🧾 Réponse serveur : ${response.body}");

  if (response.statusCode == 201 || response.statusCode == 200) {
    final data = jsonDecode(response.body);

    // On vérifie que la clé 'commande' existe dans la réponse
    if (data.containsKey('commande')) {
      return CommandeModel.fromJson(data['commande']);
    } else {
      throw Exception("Réponse serveur invalide : clé 'commande' manquante.");
    }
  } else {
    throw Exception("Erreur enregistrement commande : ${response.body}");
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

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => CommandeModel.fromJson(json)).toList();
    } else {
      throw Exception("Erreur récupération commandes : ${response.body}");
    }
  }
}