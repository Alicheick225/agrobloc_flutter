import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;

import '../models/AnnonceAchatModel.dart';
import '../dataSources/userService.dart';
import '../dataSources/cultureService.dart';
import 'package:agrobloc/core/utils/api_token.dart';

class AnnonceAchatService {
  // Endpoints
  static final String _baseUrl = '${ApiConfig.annoncesBaseUrl}/annonces_achat';
  final cultureService _cultureService = cultureService();

  /// Récupère le token valide et construit les headers
  Future<Map<String, String>> _getHeaders() async {
    final token = await UserService().getValidToken(); // refresh automatique
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Construit une Uri avec des query parameters optionnels
  Uri _buildUri(String base, [Map<String, String?> params = const {}]) {
    final clean = <String, String>{};
    params.forEach((k, v) {
      if (v != null && v.isNotEmpty) clean[k] = v;
    });
    final uri = Uri.parse(base);
    return clean.isEmpty
        ? uri
        : uri.replace(queryParameters: {...uri.queryParameters, ...clean});
  }

  // ---------------------------
  // LECTURE
  // ---------------------------

  /// Récupère toutes les annonces (optionnellement filtrées)
  Future<List<AnnonceAchat>> fetchAnnonces({
    String? userId,
    String? statut,
    String? cultureId,
    String? search,
    String? dateFrom,
    String? dateTo,
    String? type,
    double? priceMin,
    double? priceMax,
    double? quantiteMin,
    double? quantiteMax,
  }) async {
    try {
      final headers = await _getHeaders();
      final uri = _buildUri(_baseUrl, {
        'user_id': userId,
        'statut': statut,
        'culture_id': cultureId,
        'search': search,
        'date_from': dateFrom,
        'date_to': dateTo,
        'type': type,
        'price_min': priceMin?.toString(),
        'price_max': priceMax?.toString(),
        'quantite_min': quantiteMin?.toString(),
        'quantite_max': quantiteMax?.toString(),
      });

      final response =
          await http.get(uri, headers: headers).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> body = json.decode(response.body);
        return body.map((item) => AnnonceAchat.fromJson(item)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Utilisateur non authentifié');
      } else {
        throw HttpException('Erreur ${response.statusCode}: ${response.reasonPhrase}');
      }
    } on SocketException {
      throw Exception('Pas de connexion Internet');
    } on TimeoutException {
      throw Exception('La requête a expiré');
    } catch (e) {
      throw Exception('Erreur inconnue: $e');
    }
  }

  /// Récupère uniquement les annonces de l'utilisateur connecté
  Future<List<AnnonceAchat>> fetchAnnoncesByUser() async {
    try {
      await UserService().ensureUserLoaded();
      final currentUserId = UserService().userId;
      if (currentUserId == null || currentUserId.isEmpty) {
        throw Exception('Utilisateur non connecté. Veuillez vous reconnecter.');
      }

      final headers = await _getHeaders();
      final url = '$_baseUrl/user/$currentUserId';
      final response = await http.get(Uri.parse(url), headers: headers).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> body = json.decode(response.body);
        return body.map((item) => AnnonceAchat.fromJson(item)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Utilisateur non authentifié');
      } else {
        throw HttpException('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des annonces: $e');
    }
  }

  /// Récupère les annonces filtrées par type de culture 'cultures'
  Future<List<AnnonceAchat>> fetchAnnoncesByCultureType() async {
    try {
      final headers = await _getHeaders();
      final url = '$_baseUrl/cultures';
      final response = await http.get(Uri.parse(url), headers: headers).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> body = json.decode(response.body);
        return body.map((item) => AnnonceAchat.fromJson(item)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Utilisateur non authentifié');
      } else {
        throw HttpException('Erreur ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des annonces par type de culture: $e');
    }
  }

  /// Récupère la liste des types de cultures
  Future<List<Map<String, dynamic>>> fetchCultures() async {
    try {
      final cultures = await _cultureService.getAllCulture();
      return cultures.map((c) => {'id': c.id, 'libelle': c.libelle, 'type': c.type}).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des cultures: $e');
    }
  }

  /// Récupère une annonce par son ID
  Future<AnnonceAchat> getAnnonceById(String id) async {
    try {
      final headers = await _getHeaders();
      final url = '$_baseUrl/$id';
      final response = await http.get(Uri.parse(url), headers: headers).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return AnnonceAchat.fromJson(json.decode(response.body));
      } else if (response.statusCode == 401) {
        throw Exception('Utilisateur non authentifié');
      } else {
        throw HttpException('Erreur ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Erreur inconnue: $e');
    }
  }

  // ---------------------------
  // ÉCRITURE
  // ---------------------------

  /// Crée une nouvelle annonce d'achat
  Future<AnnonceAchat> createAnnonceAchat({
    required String statut,
    required String description,
    required String cultureId,
    required double quantite,
    required String unite,
    required double prix,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: headers,
        body: jsonEncode({
          'statut': statut,
          'description': description,
          'culture_id': cultureId,
          'quantite': quantite,
          'unite': unite,
          'prix_kg': prix,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201 || response.statusCode == 200) {
        return AnnonceAchat.fromJson(json.decode(response.body));
      } else if (response.statusCode == 401) {
        throw Exception('Utilisateur non authentifié');
      } else {
        throw HttpException('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }

  /// Met à jour une annonce existante
  Future<AnnonceAchat> updateAnnonceAchat({
    required String id,
    required String statut,
    required String description,
    required String cultureId,
    required double quantite,
    required String unite,
    required double prix,
  }) async {
    try {
      final headers = await _getHeaders();
      final url = '$_baseUrl/$id';
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode({
          'statut': statut,
          'description': description,
          'culture_id': cultureId,
          'quantite': quantite,
          'unite': unite,
          'prix_kg': prix,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return AnnonceAchat.fromJson(json.decode(response.body));
      } else if (response.statusCode == 401) {
        throw Exception('Utilisateur non authentifié');
      } else {
        throw HttpException('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }

  /// Décrémente la quantité d'une annonce d'achat
  Future<Map<String, dynamic>> decrementQuantite(String id, int quantite) async {
    try {
      final headers = await _getHeaders();
      final url = '$_baseUrl/$id/decrement';
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode({'quantite': quantite}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Utilisateur non authentifié');
      } else {
        throw HttpException('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la décrémentation de la quantité: $e');
    }
  }

  /// Supprime une annonce
  Future<void> deleteAnnonceAchat(String id) async {
    try {
      final headers = await _getHeaders();
      final url = '$_baseUrl/$id';
      final response = await http.delete(Uri.parse(url), headers: headers).timeout(const Duration(seconds: 10));

      if (response.statusCode == 401) {
        throw Exception('Utilisateur non authentifié');
      } else if (response.statusCode != 200 && response.statusCode != 204) {
        throw HttpException('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }

  /// Formate la date en format relatif (ex: il y a 5 min, hier, il y a 2 jours, etc.)
  String formatDate(String dateString) {
    if (dateString.isEmpty) return '';

    try {
      final parts = dateString.split(' ');
      if (parts.isEmpty) return dateString;

      final dateParts = parts[0].split('-');
      if (dateParts.length != 3) return dateString;

      final year = int.tryParse(dateParts[0]) ?? 0;
      final month = int.tryParse(dateParts[1]) ?? 0;
      final day = int.tryParse(dateParts[2]) ?? 0;

      if (year == 0 || month == 0 || day == 0) return dateString;

      final date = DateTime(year, month, day);
      final now = DateTime.now();
      final difference = now.difference(date);

      final minutes = difference.inMinutes;
      final hours = difference.inHours;
      final days = difference.inDays;

      if (minutes < 1) {
        return 'À l\'instant';
      } else if (minutes < 60) {
        return 'Il y a $minutes ${minutes == 1 ? 'minute' : 'minutes'}';
      } else if (hours < 24) {
        return 'Il y a $hours ${hours == 1 ? 'heure' : 'heures'}';
      } else if (days == 1) {
        return 'Hier';
      } else if (days < 7) {
        return 'Il y a $days ${days == 1 ? 'jour' : 'jours'}';
      } else if (days < 14) {
        return 'Il y a 1 semaine';
      } else if (days < 28) {
        final weeks = (days / 7).floor();
        return 'Il y a $weeks semaines';
      } else {
        // Format complet: "11 Août 2025"
        final monthNames = [
          'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
          'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
        ];
        return '$day ${monthNames[month - 1]} $year';
      }
    } catch (e) {
      return dateString;
    }
  }
}
