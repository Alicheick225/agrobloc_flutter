import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:agrobloc/core/features/Agrobloc/data/models/commandeModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CommandeService {
  final String baseUrl =
      'http://192.168.252.199:3000/commandes'; // 🔁 Mets à jour si besoin

  Future<CommandeModel> enregistrerCommande({
    required String acheteurId,
    required double quantite,
    required double prixTotal,
    required String modePaiementId,
    required String typeCulture,
  }) async {
    final url = Uri.parse('$baseUrl/commandes-ventes');

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      print("❌ Erreur : Token manquant.");
      throw Exception("Token manquant. Veuillez vous reconnecter.");
    }

    final body = {
      'acheteur_id': acheteurId,
      'quantite': quantite.toStringAsFixed(2),
      'prix_total': prixTotal.toStringAsFixed(2),
      'mode_paiement_id': modePaiementId,
      'type_culture': typeCulture,
    };

    print("🔎 Données envoyées au serveur : $body");

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return CommandeModel.fromJson(data['commande']);
      } else {
        print("❌ Erreur HTTP - Status: ${response.statusCode}");
        print("🧾 Réponse serveur : ${response.body}");
        throw Exception('Erreur enregistrement commande : ${response.body}');
      }
    } catch (e, stacktrace) {
      print("❌ Exception attrapée dans enregistrerCommande: $e");
      print("🧱 Stacktrace: $stacktrace");
      rethrow;
    }
  }
}
