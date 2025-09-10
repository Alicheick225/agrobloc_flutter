import 'dart:convert';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/userService.dart';
import 'package:http/http.dart' as http;
import '../models/annoncePrefinancementModel.dart';
import 'tyoeCultureService.dart';

import 'package:agrobloc/core/utils/api_token.dart';

class PrefinancementService {
  static final String _baseUrl = ApiConfig.annoncesBaseUrl;
  final TypeCultureService _typeCultureService = TypeCultureService();
  Map<String, String>? _typeCultureCache;

  /// Récupère le token valide et construit les headers
  Future<Map<String, String>> _getHeaders({bool forceRefresh = false}) async {
    final token = await UserService().getValidToken(forceRefresh: forceRefresh);
    if (token == null || token.isEmpty) {
      throw Exception("⚠️ Token manquant, reconnectez-vous.");
    }

    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  /// Cache all typeCultures for quick lookup
  Future<void> _cacheTypeCultures() async {
    if (_typeCultureCache != null) {
      return; // already cached
    }
    try {
      final types = await _typeCultureService.getAllTypes();
      _typeCultureCache = { for (var t in types) t.id : t.libelle };
    } catch (e) {
      rethrow;
    }
  }

  /// Enrich AnnoncePrefinancement list with typeCulture libelle from cache
  Future<List<AnnoncePrefinancement>> _enrichAnnoncesWithTypeCulture(List<AnnoncePrefinancement> annonces) async {
    try {
      await _cacheTypeCultures();
    } catch (e) {
      return annonces; // Return original annonces without enrichment
    }

    return annonces.map((annonce) {
      String enrichedLibelle = annonce.libelle;

      // Skip enrichment if typeCultureId is empty or null
      if (annonce.typeCultureId.isNotEmpty && annonce.typeCultureId != 'null') {
        final libelle = _typeCultureCache?[annonce.typeCultureId] ?? '';
        enrichedLibelle = libelle.isNotEmpty ? libelle : annonce.libelle;
      }

      return AnnoncePrefinancement(
        id: annonce.id,
        statut: annonce.statut,
        description: annonce.description,
        montantPref: annonce.montantPref,
        prixKgPref: annonce.prixKgPref,
        quantite: annonce.quantite,
        quantiteUnite: annonce.quantiteUnite,
        nom: annonce.nom,
        libelle: enrichedLibelle,
        typeCultureId: annonce.typeCultureId,
        adresse: annonce.adresse,
        surface: annonce.surface,
        createdAt: annonce.createdAt,
        updatedAt: annonce.updatedAt,
      );
    }).toList();
  }

  Future<List<AnnoncePrefinancement>> fetchPrefinancements() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/annonces_pref'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final annonces = data.map((json) => AnnoncePrefinancement.fromJson(json)).toList();
        return await _enrichAnnoncesWithTypeCulture(annonces);
      } else if (response.statusCode == 401) {
        // Try with forced refresh
        final headersRetry = await _getHeaders(forceRefresh: true);
        final retryResponse = await http.get(
          Uri.parse('$_baseUrl/annonces_pref'),
          headers: headersRetry,
        );

        if (retryResponse.statusCode == 200) {
          final List<dynamic> data = jsonDecode(retryResponse.body);
          final annonces = data.map((json) => AnnoncePrefinancement.fromJson(json)).toList();
          return await _enrichAnnoncesWithTypeCulture(annonces);
        } else {
          throw Exception('Erreur lors du chargement des préfinancements après retry : ${retryResponse.body}');
        }
      } else {
        throw Exception('Erreur lors du chargement des préfinancements : ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur lors du chargement des préfinancements : $e');
    }
  }

  /// Récupère les préfinancements d'un utilisateur spécifique
  Future<List<AnnoncePrefinancement>> fetchPrefinancementsByUser(String userId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/annonces_pref/user/$userId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final annonces = data.map((json) => AnnoncePrefinancement.fromJson(json)).toList();
        return await _enrichAnnoncesWithTypeCulture(annonces);
      } else if (response.statusCode == 401) {
        // Try with forced refresh
        print("🚨 PrefinancementService: Token rejeté (401) - tentative de refresh forcé");
        final headersRetry = await _getHeaders(forceRefresh: true);
        print('🔄 PrefinancementService: Retry avec headers refreshés');

        final retryResponse = await http.get(
          Uri.parse('$_baseUrl/annonces_pref/user/$userId'),
          headers: headersRetry,
        );

        print('📥 PrefinancementService: Réponse retry - Status: ${retryResponse.statusCode}');
        print('📄 PrefinancementService: Body retry: ${retryResponse.body}');

        if (retryResponse.statusCode == 200) {
          print('✅ PrefinancementService: Retry réussi, parsing des données...');
          final List<dynamic> data = jsonDecode(retryResponse.body);
          print('📊 PrefinancementService: ${data.length} éléments JSON reçus après retry');

          final annonces = data.map((json) {
            try {
              return AnnoncePrefinancement.fromJson(json);
            } catch (parseError) {
              print('❌ PrefinancementService: Erreur de parsing après retry pour élément: $json - Erreur: $parseError');
              rethrow;
            }
          }).toList();

          print('✅ PrefinancementService: ${annonces.length} annonces parsées après retry');
          final enriched = await _enrichAnnoncesWithTypeCulture(annonces);
          print('✅ PrefinancementService: ${enriched.length} annonces enrichies après retry');
          return enriched;
        } else {
          print('❌ PrefinancementService: Échec du retry - Status: ${retryResponse.statusCode}, Body: ${retryResponse.body}');
          throw Exception('Erreur lors du chargement des préfinancements utilisateur après retry : ${retryResponse.body}');
        }
      } else {
        print('❌ PrefinancementService: Erreur API - Status: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Erreur lors du chargement des préfinancements utilisateur : ${response.body}');
      }
    } catch (e) {
      print('❌ PrefinancementService: Exception dans fetchPrefinancementsByUser: $e');
      print('🔍 PrefinancementService: Type d\'exception: ${e.runtimeType}');
      throw Exception('Erreur lors du chargement des préfinancements utilisateur : $e');
    }
  }

  /// Récupérer une annonce de préfinancement par ID
  Future<AnnoncePrefinancement> fetchPrefinancementById(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/annonce_pref/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final jsonItem = json.decode(response.body);
        final annonce = AnnoncePrefinancement.fromJson(jsonItem);
        final enriched = await _enrichAnnoncesWithTypeCulture([annonce]);
        return enriched.first;
      } else {
        throw Exception('Erreur lors du chargement du préfinancement : ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur lors du chargement du préfinancement : $e');
    }
  }

  /// Supprimer une annonce de préfinancement
  Future<void> deletePrefinancement(String id) async {
    try {
      print('🔄 PrefinancementService: Début suppression préfinancement ID: $id');
      final headers = await _getHeaders();
      print('📡 PrefinancementService: Headers préparés, appel API DELETE: $_baseUrl/annonces_pref/$id');

      final response = await http.delete(
        Uri.parse('$_baseUrl/annonces_pref/$id'),
        headers: headers,
      );

      print('📥 PrefinancementService: Réponse suppression - Status: ${response.statusCode}');
      print('📄 PrefinancementService: Body réponse suppression: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ PrefinancementService: Préfinancement supprimé avec succès');
      } else if (response.statusCode == 401) {
        // Try with forced refresh
        print("🚨 PrefinancementService: Token rejeté lors de la suppression - tentative de refresh forcé");
        final headersRetry = await _getHeaders(forceRefresh: true);
        print('🔄 PrefinancementService: Retry suppression avec headers refreshés');

        final retryResponse = await http.delete(
          Uri.parse('$_baseUrl/annonces_pref/$id'),
          headers: headersRetry,
        );

        print('📥 PrefinancementService: Réponse retry suppression - Status: ${retryResponse.statusCode}');
        print('📄 PrefinancementService: Body retry suppression: ${retryResponse.body}');

        if (retryResponse.statusCode == 200 || retryResponse.statusCode == 204) {
          print('✅ PrefinancementService: Préfinancement supprimé avec succès après retry');
        } else {
          print('❌ PrefinancementService: Échec de la suppression après retry - Status: ${retryResponse.statusCode}, Body: ${retryResponse.body}');
          throw Exception('Erreur lors de la suppression du préfinancement après retry : ${retryResponse.body}');
        }
      } else {
        print('❌ PrefinancementService: Erreur lors de la suppression - Status: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Erreur lors de la suppression du préfinancement : ${response.body}');
      }
    } catch (e) {
      print('❌ PrefinancementService: Exception lors de la suppression: $e');
      print('🔍 PrefinancementService: Type d\'exception: ${e.runtimeType}');
      throw Exception('Erreur lors de la suppression du préfinancement : $e');
    }
  }

  Future<AnnoncePrefinancement> createPrefinancement({
    required String typeCultureId,
    required String parcelleId,
    required double quantite,
    required double prix,
    String description = "Pas de description",
  }) async {
    try {
      final headers = await _getHeaders();
      final Map<String, dynamic> body = {
        "statut": "EN_ATTENTE",
        "description": description,
        "type_culture_id": typeCultureId,
        "parcelle_id": parcelleId,
        "quantite": quantite,
        "prix": prix,
        "montant_pref": quantite * prix,
      };

      print("📤 Body envoyé : ${jsonEncode(body)}");

      final response = await http.post(
        Uri.parse('$_baseUrl/annonces_pref'),
        headers: headers,
        body: jsonEncode(body),
      );

      print("📥 Status code: ${response.statusCode}");
      print("📥 Body reçu: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonItem = json.decode(response.body);
        return AnnoncePrefinancement.fromJson(jsonItem);
      } else {
        // Handle authentication errors specifically
        if (response.statusCode == 401) {
          print("🚨 Token rejeté par le serveur - tentative de refresh forcé");

          // Force token refresh even if local check says it's valid
          final userService = UserService();
          final refreshedToken = await userService.getValidToken(forceRefresh: true, allowTempRefresh: true);

          if (refreshedToken != null) {
            print("✅ Token rafraîchi avec succès - nouvelle tentative");

            // Retry with refreshed token using _getHeaders with forceRefresh
            final newHeaders = await _getHeaders(forceRefresh: true);

            final retryResponse = await http.post(
              Uri.parse('$_baseUrl/annonces_pref'),
              headers: newHeaders,
              body: jsonEncode(body),
            );

            print("📥 Retry status code: ${retryResponse.statusCode}");
            print("📥 Retry body reçu: ${retryResponse.body}");

            if (retryResponse.statusCode == 200 || retryResponse.statusCode == 201) {
              final jsonItem = json.decode(retryResponse.body);
              return AnnoncePrefinancement.fromJson(jsonItem);
            } else if (retryResponse.statusCode == 401) {
              throw Exception("Erreur d'authentification: Token toujours invalide après refresh. Veuillez vous reconnecter.");
            } else {
              throw Exception('Erreur lors de la création du préfinancement après retry : ${retryResponse.body}');
            }
          } else {
            throw Exception("Erreur d'authentification: Impossible de rafraîchir le token. Veuillez vous reconnecter.");
          }
        }
        throw Exception('Erreur lors de la création du préfinancement : ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la création du préfinancement : $e');
    }
  }


}
