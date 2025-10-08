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
  final ApiClient api = ApiClient(ApiConfig.annoncesBaseUrl);
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

      final response = await supabase.storage
          .from(bucketName)
          .uploadBinary(uniqueName, bytes,
              fileOptions: FileOptions(upsert: true, contentType: contentType));

      // On success, response is the path; on failure, throws exception
      final url = supabase.storage.from(bucketName).getPublicUrl(response);
      return url;
    } catch (e) {
      print("❌ Upload échoué: $e");
      return null;
    }
  }

  /// ---------------- TYPE CULTURE CACHE ----------------

  Future<void> _cacheCultures() async {
    if (_cultureCache != null) return;
    try {
      final culture = await _cultureService.getAllCulture();
      _cultureCache = {for (var t in culture) t.id: t.libelle};
    } catch (e) {
      _cultureCache = {};
      print("⚠ Erreur récupération types cultures: $e");
    }
  }

  Future<List<AnnonceVente>> _enrichAnnoncesWithCulture(
      List<AnnonceVente> annonces) async {
    await _cacheCultures();
    return annonces.map((annonce) {
      final libelle = _cultureCache?[annonce.typeCultureId] ?? '';
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
        typeCultureLibelle:
            libelle.isNotEmpty ? libelle : annonce.typeCultureLibelle,
        typeCultureId: annonce.typeCultureId,
        parcelleAdresse: annonce.parcelleAdresse,
        createdAt: annonce.createdAt,
        note: annonce.note,
      );
    }).toList();
  }

  /// ---------------- CRUD ANNONCES ----------------

  /// 🔹 Récupérer toutes les annonces
  Future<List<AnnonceVente>> getAllAnnonces() async {
    try {
      final response = await api.get('/annonces_vente');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final annonces = data.map((json) => AnnonceVente.fromJson(json)).toList();
        print(annonces);
        return await _enrichAnnoncesWithCulture(annonces);
      } else {
        throw _handleError(response);
      }
    } catch (e) {
     print("erreur");
      throw _handleException(e);

    }
  }

  /// 🔹 Créer une annonce (avec Supabase Storage pour l’image)
  Future<AnnonceVente> createAnnonce({
    required String userId,
    required String typeCultureId,
    required String parcelleId,
    required String statut,
    required String description,
    required double quantite,
    required double prixKg,
    XFile? photo,
  }) async {
    try {
      String? photoUrl;
      if (photo != null) {
        photoUrl = await _uploadToSupabase(photo);
        if (photoUrl == null) {
          throw Exception("Échec upload image Supabase");
        }
      }

      final body = {
        'user_id': userId,
        'type_culture_id': typeCultureId,
        'parcelle_id': parcelleId,
        'statut': statut,
        'description': description,
        'quantite': quantite,
        'prix_kg': prixKg,
        if (photoUrl != null) 'photo': photoUrl,
      };

      final response = await api.post('/annonces_vente', body);
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
    required String typeCultureId,
    required String parcelleId,
    required double quantite,
    required double prixKg,
    XFile? photo,
  }) async {
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
        'type_culture_id': typeCultureId,
        'parcelle_id': parcelleId,
        'quantite': quantite,
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

  /// 🔹 Supprimer une annonce
  Future<void> deleteAnnonce(String id) async {
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
}
