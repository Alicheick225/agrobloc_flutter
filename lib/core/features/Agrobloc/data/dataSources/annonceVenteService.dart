import 'dart:async';
import 'dart:convert';
import 'package:agrobloc/core/utils/api_token.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/AnnonceVenteModel.dart';
import 'typeCultureService.dart';
import 'userService.dart';

class AnnonceService {
  final ApiClient api = ApiClient(ApiConfig.devAnnoncesVenteBaseUrl);
  final TypeCultureService _typeCultureService = TypeCultureService();
  static const Duration timeoutDuration = Duration(seconds: 25);

  // Supabase
  final SupabaseClient supabase = Supabase.instance.client;
  final String bucketName = "agrobloc";
  final _uuid = const Uuid();

  Map<String, String>? _typeCultureCache;

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

  /// Upload image vers Supabase et retourne l’URL publique
  Future<String?> _uploadToSupabase(XFile photo) async {
    try {
      final bytes = await photo.readAsBytes();
      final ext = photo.path.split('.').last;
      final uniqueName = "uploads/${_uuid.v4()}.$ext";

      final response = await supabase.storage.from(bucketName).uploadBinary(
          uniqueName, bytes,
          fileOptions: const FileOptions(upsert: true));

      if (response.isNotEmpty) {
        throw Exception("Erreur upload Supabase: $response");
      }

      final url = supabase.storage.from(bucketName).getPublicUrl(uniqueName);
      return url;
    } catch (e) {
      print("❌ Upload échoué: $e");
      return null;
    }
  }

  /// ---------------- TYPE CULTURE CACHE ----------------

  Future<void> _cacheTypeCultures() async {
    if (_typeCultureCache != null) return;
    try {
      final types = await _typeCultureService.getAllTypes();
      _typeCultureCache = {for (var t in types) t.id: t.libelle};
    } catch (e) {
      _typeCultureCache = {};
      print("⚠ Erreur récupération types cultures: $e");
    }
  }

  Future<List<AnnonceVente>> _enrichAnnoncesWithTypeCulture(
      List<AnnonceVente> annonces) async {
    await _cacheTypeCultures();
    return annonces.map((annonce) {
      final libelle = _typeCultureCache?[annonce.typeCultureId] ?? '';
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
        typeProduit: annonce.typeProduit,
        prixBordChamp: annonce.prixBordChamp,
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
        final annonces =
            data.map((json) => AnnonceVente.fromJson(json)).toList();
        return await _enrichAnnoncesWithTypeCulture(annonces);
      } else {
        throw _handleError(response);
      }
    } catch (e) {
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

    // ➜ NOUVEAUX CHAMPS
    String? type, // "Vivrière" ou "de rente"
    double? prixBordChamp, // prix depuis la BD
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

        // ➜ NOUVEAUX CHAMPS
        if (type != null) 'type': type,
        if (prixBordChamp != null) 'prix_bord_champ': prixBordChamp,
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
        final enriched = await _enrichAnnoncesWithTypeCulture([annonce]);
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
        return await _enrichAnnoncesWithTypeCulture(annonces);
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

  /// 🔹 Culture catégorie Rente ou Vivrière

  Future<List<Map<String, dynamic>>> fetchCultures() async {
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
    try {
      // ➜ On construit l’URL à la main
      final url = '/cultures?Type=$Type';
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
