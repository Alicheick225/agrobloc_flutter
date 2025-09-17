import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:agrobloc/core/features/Agrobloc/data/models/payementModeModel.dart';

class PaiementService {
  final String baseUrl = "http://192.168.252.249:8082/api";

  Future<List<PayementModel>> getModesPaiement() async {
    final url = Uri.parse("$baseUrl/typesPaiement");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => PayementModel.fromJson(e)).toList();
    } else {
      throw Exception("Erreur de chargement des modes de paiement");
    }
  }
}
