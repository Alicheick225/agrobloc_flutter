import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:agrobloc/core/features/Agrobloc/data/models/commandeModel.dart';
class CommandeService {
  final String baseUrl = 'http://192.168.252.199:3000/commandes'; // 🔁 À adapter

  Future<CommandeModel> enregistrerCommande({
    required String acheteurId,
    required double quantite,
    required double prixTotal,
    required String modePaiementId,
    required String typeCulture,
  }) async {
    final url = Uri.parse('$baseUrl/commandes-ventes');

    final body = {
      'acheteur_id': acheteurId,
      'quantite': quantite.toStringAsFixed(2),
      'prix_total': prixTotal.toStringAsFixed(2),
      'mode_paiement_id': modePaiementId,
      'type_culture': typeCulture,
    };

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    // Vérification de la réponse

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return CommandeModel.fromJson(data['commande']);
    } else {
      print("Status: ${response.statusCode}");
      print("Response body: ${response.body}");
      throw Exception('Erreur enregistrement commande : ${response.body}');
    }


  }

}
