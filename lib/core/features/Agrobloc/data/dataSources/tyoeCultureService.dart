// type_culture_service.dart
import 'dart:convert';
import 'package:agrobloc/core/features/Agrobloc/data/models/typecultureModel.dart';

import 'package:agrobloc/core/utils/api_token.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class TypeCultureService {
  final ApiClient api = ApiClient('http://192.168.252.249:8080/api');
  static const Duration timeoutDuration = Duration(seconds: 15);

  // ✅ Récupérer toutes les cultures
  Future<List<TypeCulture>> getAllTypes() async {
    try {
      final response = await api.get('/types-cultures').timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
         // 👉 Si tu veux afficher ligne par ligne
        for (var item in data) {
          print("Item: $item");
        }
        return data.map((json) => TypeCulture.fromJson(json)).toList();
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des types de culture: $e');
    }
  }

  // ✅ Récupérer une culture par ID
  Future<TypeCulture> getTypeById(String id) async {
    try {
      final response = await api.get('/types_cultures/$id').timeout(timeoutDuration);

      if (response.statusCode == 200) {
        return TypeCulture.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération du type de culture: $e');
    }
  }

  // ✅ Créer une nouvelle culture
  Future<TypeCulture> createType(TypeCulture type) async {
    try {
      final response = await api.post('/types_culture', type.toJson())
          .timeout(timeoutDuration);

      if (response.statusCode == 201) {
        return TypeCulture.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la création du type de culture: $e');
    }
  }

  
}
