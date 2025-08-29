// parcelle_service.dart
import 'dart:convert';
import 'package:agrobloc/core/features/Agrobloc/data/models/parcelleService.dart';
import 'package:agrobloc/core/utils/api_token.dart';
import 'dart:async';

class ParcelleService {
  final ApiClient api = ApiClient('http://192.168.252.199:8000/api');
  static const Duration timeoutDuration = Duration(seconds: 15);

  // ✅ Récupérer toutes les parcelles
  Future<List<Parcelle>> getAllParcelles() async {
    try {
      final response = await api.get('/parcelles').timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Parcelle.fromJson(json)).toList();
      } else {
        print('Erreur API getAllParcelles: ${response.statusCode} ${response.body}');
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e, stackTrace) {
      print('Exception getAllParcelles: $e');
      print(stackTrace);
      throw Exception('Erreur lors de la récupération des parcelles: $e');
    }
  }

  // ✅ Récupérer une parcelle par ID
  Future<Parcelle> getParcelleById(String id) async {
    try {
      final response = await api.get('/parcelles/$id',).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        return Parcelle.fromJson(jsonDecode(response.body));
      } else {
        print('Erreur API getParcelleById: ${response.statusCode} ${response.body}');
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e, stackTrace) {
      print('Exception getParcelleById: $e');
      print(stackTrace);
      throw Exception('Erreur lors de la récupération de la parcelle: $e');
    }
  }
}
