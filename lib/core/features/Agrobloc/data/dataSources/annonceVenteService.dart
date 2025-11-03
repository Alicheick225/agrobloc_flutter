import 'dart:async';
import 'dart:convert';
import 'package:agrobloc/core/utils/api_token.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/AnnonceVenteModel.dart';
import 'cultureService.dart';
import 'cultureService.dart';
import 'userService.dart';

class AnnonceService {
  final ApiClient api = ApiClient(ApiConfig.devAnnoncesVenteBaseUrl);
  final cultureService _cultureService = cultureService();
  static const Duration timeoutDuration = Duration(seconds: 25);

  // Supabase
  final SupabaseClient supabase = Supabase.instance.client;
  final String bucketName = "agrobloc";
  final _uuid = const Uuid();

  Map<String, String>? _cultureCache;

  /// ---------------- AUTH & HELPERS ----------------

  Future<String> _getValidToken() async {
    final userService = UserService();
    final token = await userService.getValidToken();
    if (token == null || token.isEmpty) {
      throw Exception("Token non trouvé ou invalide. Veuillez vous connecter.");
    }
    return token;
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getValidToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<String> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString("userId");
    if (uid == null || uid.isEmpty) {
      throw Exception("⚠️ userId manquant, reconnectez-vous.");
    }
    return uid;
  }

  String _getContentType(String ext) {
    switch (ext.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      default:
        return 'application/octet-stream';
    }
  }

  /// Upload image vers Supabase et retourne l’URL publique
  Future<String?> _uploadToSupabase(XFile photo) async {
    try {
      final bytes = await photo.readAsBytes();
      final ext = photo.path.split('.').last.toLowerCase();
      final uniqueName = "uploads/${_uuid.v4()}.$ext";
      final contentType = _getContentType(ext);

      // Succès : uploadBinary renvoie '' ou lève une exception
      await supabase.storage.from(bucketName).uploadBinary(uniqueName, bytes,
          fileOptions: const FileOptions(upsert: true));

      // Récupération de l’URL publique
      return supabase.storage.from(bucketName).getPublicUrl(uniqueName);
    } catch (e) {
      print("❌ Upload échoué: $e");
      return null;
    }
  }

  /// ---------------- TYPE CULTURE CACHE ----------------

  Future<void> _cacheCultures({bool forceReload = false}) async {
    if (_cultureCache != null && !forceReload) return;
    try {
      print('🔄 annonceVenteService: Chargement cache cultures...');
      final culture = await _cultureService.getAllCulture();
      _cultureCache = {for (var t in culture) t.id: t.libelle};
      print('✅ annonceVenteService: Cache cultures chargé avec ${_cultureCache?.length ?? 0} éléments');
    } catch (e) {
      _cultureCache = {};
      print("⚠ annonceVenteService: Erreur récupération types cultures: $e");
    }
  }

  Future<List<AnnonceVente>> _enrichAnnoncesWithCulture(
      List<AnnonceVente> annonces) async {
    await _cacheCultures();
    return annonces.map((annonce) {
      final libelle = _cultureCache?[annonce.cultureId] ?? '';
      final enrichedLibelle = libelle.isNotEmpty ? libelle : annonce.cultureLibelle;
      print('🔍 annonceVenteService: Enrichissement annonce ${annonce.id} avec cultureLibelle: $enrichedLibelle');
      return AnnonceVente(
        id: annonce.id,
        photo: annonce.photo,
        statut: annonce.statut,
        description: annonce.description,
        prixKg: annonce.prixKg,
        prixUnite: annonce.prixUnite,
        quantite: annonce.quantite,
        quantiteUnite: annonce.quantiteUnite,
        userNom: annonce.userNom,
        cultureLibelle: enrichedLibelle,
        cultureId: annonce.cultureId,
        cultureType: annonce.cultureType,
        parcelleId: annonce.parcelleId,
        parcelleAdresse: annonce.parcelleAdresse,
        createdAt: annonce.createdAt,
        note: annonce.note,
        culturePrixBordChamp: annonce.culturePrixBordChamp,
      );
    }).toList();
  }

  /// Force refresh culture cache
  Future<void> refreshCultureCache() async {
    await _cacheCultures(forceReload: true);
  }

  /// ---------------- CRUD ANNONCES ----------------

  /// 🔹 Récupérer toutes les annonces avec filtres optionnels et pagination
  Future<List<AnnonceVente>> getAllAnnonces({
    String? userId,
    String? statut,
    String? cultureId,
    String? search,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? type,
    double? priceMin,
    double? priceMax,
    double? quantMin,
    double? quantMax,
    int? limit,
    int? offset,
  }) async {
    // Check authentication before making request
    if (!UserService().isLoggedIn) {
      print('⚠️ AnnonceService.getAllAnnonces - User not logged in, returning empty list');
      return [];
    }

    try {
      final queryParams = <String, String>{};
      if (userId != null) queryParams['user_id'] = userId;
      if (statut != null) queryParams['statut'] = statut;
      if (cultureId != null) queryParams['culture_id'] = cultureId;
      if (search != null) queryParams['search'] = search;
      if (dateFrom != null) queryParams['date_from'] = dateFrom.toIso8601String().split('T')[0];
      if (dateTo != null) queryParams['date_to'] = dateTo.toIso8601String().split('T')[0];
      if (type != null) queryParams['type'] = type;
      if (priceMin != null) queryParams['price_min'] = priceMin.toString();
      if (priceMax != null) queryParams['price_max'] = priceMax.toString();
      if (quantMin != null) queryParams['quantite_min'] = quantMin.toString();
      if (quantMax != null) queryParams['quantite_max'] = quantMax.toString();
      if (limit != null) queryParams['limit'] = limit.toString();
      if (offset != null) queryParams['offset'] = offset.toString();

      final uri = Uri.parse('${ApiConfig.devAnnoncesVenteBaseUrl}/annonces_vente').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: await _getHeaders());
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final annonces = data.map((json) => AnnonceVente.fromJson(json)).toList();
        return await _enrichAnnoncesWithCulture(annonces);
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      throw _handleException(e);
    }
  }

  /// ➜  CRÉATION MULTIPART conforme au back
  Future<AnnonceVente> createAnnonce({
    required String userId,
    required String cultureId,
    required String parcelleId,
    required String statut,
    required String description,
    required double quantite,
    required String quantiteUnite,
    required double prixKg,
    XFile? photo,
    String? type,
    double? prixBordChamp,
  }) async {
    try {
      final token = await _getValidToken();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.devAnnoncesVenteBaseUrl}/annonces_vente'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      // 1. champs texte
      request.fields['culture_id'] = cultureId;
      request.fields['parcelle_id'] = parcelleId;
      request.fields['statut'] = statut;
      request.fields['quantite'] = quantite.toStringAsFixed(2);
      request.fields['unite'] = quantiteUnite;
      request.fields['prix_kg'] = prixKg.toStringAsFixed(2);
      request.fields['description'] = description.trim();
      if (type != null) request.fields['type'] = type;
      if (prixBordChamp != null) {
        request.fields['prix_bord_champ'] = prixBordChamp.toStringAsFixed(2);
      }

      // 2. image déjà uploadée → on passe l'URL
      if (photo != null) {
        final photoUrl = await _uploadToSupabase(photo);
        if (photoUrl != null) request.fields['photo'] = photoUrl;
      }

      final streamed = await request.send().timeout(timeoutDuration);
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return AnnonceVente.fromJson(jsonDecode(response.body));
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      throw _handleException(e);
    }
  }

  /// 🔹 Récupérer une annonce par ID
  Future<AnnonceVente> getAnnonceByID(String id) async {
    // Check authentication before making request
    if (!UserService().isLoggedIn) {
      throw Exception('User not logged in');
    }

    try {
      final response = await api.get('/annonces_vente/$id');
      if (response.statusCode == 200) {
        final annonce = AnnonceVente.fromJson(jsonDecode(response.body));
        final enriched = await _enrichAnnoncesWithCulture([annonce]);
        return enriched.first;
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      throw _handleException(e);
    }
  }

  /// 🔹 Récupérer les annonces d’un utilisateur spécifique
  Future<List<AnnonceVente>> getAnnoncesByUserID(String userId) async {
    // Check authentication before making request
    if (!UserService().isLoggedIn) {
      print('⚠️ AnnonceService.getAnnoncesByUserID - User not logged in, returning empty list');
      return [];
    }

    try {
      final response = await api.get('/annonces_vente/user/$userId');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final annonces =
            data.map((json) => AnnonceVente.fromJson(json)).toList();
        return await _enrichAnnoncesWithCulture(annonces);
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      throw _handleException(e);
    }
  }

  /// 🔹 Récupérer uniquement les annonces de l’utilisateur connecté
  Future<List<AnnonceVente>> fetchAnnoncesByUser() async {
    // Check authentication before making request
    if (!UserService().isLoggedIn) {
      print('⚠️ AnnonceService.fetchAnnoncesByUser - User not logged in, returning empty list');
      return [];
    }

    try {
      final userId = await _getUserId();
      return await getAnnoncesByUserID(userId);
    } catch (e) {
      throw _handleException(e);
    }
  }

  /// 🔹 Mettre à jour une annonce
  Future<AnnonceVente> updateAnnonce({
    required String id,
    required String statut,
    required String description,
    required String cultureId,
    required String parcelleId,
    required double quantite,
    required String quantiteUnite,
    required double prixKg,
    XFile? photo,
  }) async {
    // Check authentication before making request
    if (!UserService().isLoggedIn) {
      throw Exception('User not logged in');
    }

    try {
      String? photoUrl;
      if (photo != null) {
        photoUrl = await _uploadToSupabase(photo);
        if (photoUrl == null) {
          throw Exception("Échec upload image Supabase");
        }
      }

      final body = {
        'statut': statut,
        'description': description,
        'culture_id': cultureId,
        'parcelle_id': parcelleId,
        'quantite': quantite,
        'unite': quantiteUnite,
        'prix_kg': prixKg,
        if (photoUrl != null) 'photo': photoUrl,
      };

      final response = await api.put('/annonces_vente/$id', body);
      if (response.statusCode == 200) {
        return AnnonceVente.fromJson(jsonDecode(response.body));
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      throw _handleException(e);
    }
  }

  /// 🔹 Décrémenter la quantité d'une annonce
  Future<void> decrementQuantite(String id, int quantite) async {
    // Check authentication before making request
    if (!UserService().isLoggedIn) {
      throw Exception('User not logged in');
    }

    try {
      final body = {'quantite': quantite};
      final response = await api.put('/annonces_vente/$id/decrement', body);
      if (response.statusCode != 200) {
        throw _handleError(response);
      }
    } catch (e) {
      throw _handleException(e);
    }
  }

  /// 🔹 Supprimer une annonce
  Future<void> deleteAnnonce(String id) async {
    // Check authentication before making request
    if (!UserService().isLoggedIn) {
      throw Exception('User not logged in');
    }

    try {
      final response = await api.delete('/annonces_vente/$id');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw _handleError(response);
      }
    } catch (e) {
      throw _handleException(e);
    }
  }

  /// ---------------- ERROR HANDLING ----------------

  Exception _handleError(http.Response response) {
    String errorMessage = "Erreur inconnue";
    try {
      final body = jsonDecode(response.body);
      errorMessage = body['message'] ?? response.body;
    } catch (_) {
      errorMessage = response.body;
    }
    return Exception("Erreur ${response.statusCode}: $errorMessage");
  }

  Exception _handleException(dynamic e) {
    if (e is http.ClientException) {
      return Exception('Erreur de connexion: ${e.message}');
    } else if (e is TimeoutException) {
      return Exception('La requête a expiré');
    } else if (e is FormatException) {
      return Exception('Erreur de format des données');
    }
    return Exception('Erreur inattendue: ${e.toString()}');
  }

  /// 🔹 Culture catégorie Rente ou Vivrière

  Future<List<Map<String, dynamic>>> fetchCultures() async {
    // Check authentication before making request
    if (!UserService().isLoggedIn) {
      print('⚠️ AnnonceService.fetchCultures - User not logged in, returning empty list');
      return [];
    }

    try {
      final response = await api.get('/cultures'); // <-- votre vraie route
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map<Map<String, dynamic>>((e) =>
                {'id': e['id'].toString(), 'libelle': e['libelle'] ?? ''})
            .toList();
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      // ➜ Jamais null : renvoie la liste de secours
      return [
        {'id': 'rente', 'libelle': 'Culture de rente'},
        {'id': 'vivriere', 'libelle': 'Culture vivrière'},
      ];
    }
  }

  /// 🔹 Récupérer **toutes les cultures** d’une **catégorie** ("rente" ou "vivrière")
  Future<List<Map<String, dynamic>>> fetchCulturesByCategory(
      String category) async {
    // Check authentication before making request
    if (!UserService().isLoggedIn) {
      print('⚠️ AnnonceService.fetchCulturesByCategory - User not logged in, returning empty list');
      return [];
    }

    try {
      // ➜ On construit l’URL à la main
      final url = '/cultures?type=$category';
      final response = await api.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map<Map<String, dynamic>>((e) => {
                  'id': e['id'].toString(),
                  'libelle': e['libelle'] ?? '',
                  'prix_bord_champ':
                      (e['prix_bord_champ'] as num?)?.toDouble() ?? 0.0
                })
            .toList();
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      // ➜ Jamais null : liste vide en cas d’erreur
      return [];
    }
  }
}
