import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:agrobloc/core/features/Agrobloc/data/models/financementModel.dart';

class PrefinancementService {
  static const String baseUrl = 'http://192.168.252.19:8080';

  // Le constructeur n'a plus besoin de baseUrl car c'est une constante statique
  PrefinancementService();

  Future<List<AnnonceFinancement>> fetchPrefinancements() async {
  final url = Uri.parse('$baseUrl/annonces_pref');

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final List<dynamic> jsonList = json.decode(response.body);

    return jsonList
        .map((jsonItem) => AnnonceFinancement.fromJson(jsonItem))
        .toList();
  } else {
    throw Exception('Erreur lors du chargement des préfinancements');
  }
}

  Future<AnnonceFinancement> fetchPrefinancementById(String id) async {
    final url = Uri.parse('$baseUrl/annonce_pref/$id');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonItem = json.decode(response.body);
      return AnnonceFinancement.fromJson(jsonItem);
    } else {
      throw Exception('Erreur lors du chargement du préfinancement');
    }
  }

}
    