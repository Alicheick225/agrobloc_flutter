import 'dart:convert';
import 'package:agrobloc/core/features/Agrobloc/data/models/payementModeModel.dart';
import 'package:http/http.dart' as http;

class PaymentService {
  final String baseUrl = "http://192.168.252.29:8082/api"; // Remplace par ton URL

  Future<List<PaymentModel>> fetchPayments() async {
    final response = await http.get(Uri.parse("$baseUrl/moyensPaiement"));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => PaymentModel.fromJson(json)).toList();
    } else {
      throw Exception("Erreur lors du chargement des paiements");
    }
  }
}
