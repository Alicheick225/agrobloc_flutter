import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:agrobloc/core/features/Agrobloc/data/models/moyensPaiementModel.dart';

class MoyensPaiementService {
  static const String baseUrl = "https://192.168.252.149:8082/api";

  static Future<List<MoyenPaiement>> fetchMoyensPaiement() async {
    final response = await http.get(Uri.parse("$baseUrl/moyensPaiement"));

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((item) => MoyenPaiement.fromJson(item)).toList();
    } else {
      throw Exception('Erreur de chargement des moyens de paiement');
    }
  }
}
