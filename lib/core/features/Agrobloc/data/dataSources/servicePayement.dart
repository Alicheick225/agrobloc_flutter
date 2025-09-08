// lib/services/payement_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:agrobloc/core/features/Agrobloc/data/models/payementModeModel.dart';

class PayementService {
  static const String _base = 'http://192.168.252.199:8084/api';

  Future<List<PayementModel>> fetchModes() async {
    final uri = Uri.parse('$_base/moyensPaiement');
    final res = await http.get(uri);

    if (res.statusCode == 200) {
      final List body = jsonDecode(res.body);
      return body.map((e) => PayementModel.fromJson(e)).toList();
    }
    throw Exception('Erreur chargement modes : ${res.statusCode}');
  }

  Future<void> payCommande({
    required String numeroCompteAcheteur,
    required String producteurId,
    required double montant,
    required String commandeId,
    required String moyensPaiementId,
  }) async {
    final uri = Uri.parse('$_base/commandes-ventes/payer');
    final body = jsonEncode({
      'numeroCompteAcheteur': numeroCompteAcheteur,
      'producteurId': producteurId,
      'montant': montant,
      'commandeId': commandeId,
      'moyensPaiementId': moyensPaiementId,
    });

    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (res.statusCode != 200) {
      throw Exception('Erreur paiement : ${res.body}');
    }
  }
}
