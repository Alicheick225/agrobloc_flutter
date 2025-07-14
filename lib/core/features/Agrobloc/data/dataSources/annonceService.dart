import 'dart:convert';

import 'package:agrobloc/core/features/Agrobloc/data/models/AnnonceVenteModel.dart';
import 'package:http/http.dart' as http;

class AnnonceService {
  static const String baseUrl = 'http://192.168.252.19:8080';

  static Future<List<AnnonceVenteModel>> fetchAnnonces() async {
    final response = await http.get(Uri.parse('$baseUrl/annonces_vente'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => AnnonceVenteModel.fromJson(e)).toList();
    } else {
      throw Exception('Échec du chargement des annonces');
    }
  }
}
