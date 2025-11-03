import 'dart:convert';
import 'package:agrobloc/core/features/Agrobloc/data/models/modificationprofil_model.dart';
import 'package:agrobloc/core/utils/api_token.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ModifierProfilService {
  final ApiClient _apiClient = ApiClient("http://192.168.252.199:3000/authentification");

  /// Vérifier si l'utilisateur est authentifié
  Future<bool> isAuthenticated() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      print("🔍 Vérification token: ${token != null ? 'Token présent' : 'Token absent'}");
      
      if (token == null) {
        print("❌ Pas de token trouvé");
        return false;
      }
      
      // Tenter une requête pour vérifier la validité du token
      final response = await _apiClient.get("/modifier-informations-profil");
      print("🔍 Réponse /me: ${response.statusCode}");
      
      if (response.statusCode == 200) {
        print("✅ Token valide");
        return true;
      } else {
        print("❌ Token invalide ou expiré");
        return false;
      }
    } catch (e) {
      print("❌ Erreur lors de la vérification d'authentification: $e");
      return false;
    }
  }

  /// Récupérer le profil utilisateur
  Future<ModificationProfilResponse> getProfilUtilisateur() async {
    try {
      print("🚀 Début récupération profil utilisateur");
      
      // Vérifier l'authentification d'abord
      if (!await isAuthenticated()) {
        print("❌ Utilisateur non authentifié");
        return ModificationProfilResponse.error("Session expirée. Veuillez vous reconnecter.");
      }

      // Récupérer l'ID utilisateur
      final userId = await _getUserIdWithFallback();
      print("🔍 ID utilisateur récupéré: $userId");
      
      if (userId == null || userId.isEmpty) {
        print("❌ ID utilisateur introuvable");
        return ModificationProfilResponse.error("ID utilisateur introuvable. Veuillez vous reconnecter.");
      }

      final response = await _apiClient.get("/modifier-informations-profil/$userId");
      print("🔍 Réponse API: ${response.statusCode}");
      print("🔍 Corps de la réponse: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print("✅ Données reçues avec succès");
        return ModificationProfilResponse.fromJson(data);
      } else {
        final data = response.body.isNotEmpty ? jsonDecode(response.body) : {};
        print("❌ Erreur API: ${data['message'] ?? 'Erreur inconnue'}");
        return ModificationProfilResponse.error(
          data["message"] ?? "Erreur lors du chargement du profil (Code: ${response.statusCode})",
        );
      }
    } catch (e) {
      print("❌ Erreur lors de la récupération du profil: $e");
      // Gestion spécifique des erreurs d'authentification
      if (e.toString().contains("Session expirée") || 
          e.toString().contains("Token non trouvé") ||
          e.toString().contains("401")) {
        return ModificationProfilResponse.error("Session expirée. Veuillez vous reconnecter.");
      }
      return ModificationProfilResponse.error("Erreur de connexion: $e");
    }
  }

  /// Méthode améliorée pour récupérer l'ID utilisateur avec plusieurs fallbacks
  Future<String?> _getUserIdWithFallback() async {
    try {
      // Méthode 1: Via ApiClient
      print("🔍 Tentative 1: Via ApiClient.getUserId()");
      String? userId = await _apiClient.getUserId();
      if (userId != null && userId.isNotEmpty) {
        print("✅ ID trouvé via ApiClient: $userId");
        return userId;
      }

      // Méthode 2: Via SharedPreferences directement
      print("🔍 Tentative 2: Via SharedPreferences");
      final prefs = await SharedPreferences.getInstance();
      userId = prefs.getString('userId') ?? prefs.getString('user_id');
      if (userId != null && userId.isNotEmpty) {
        print("✅ ID trouvé via SharedPreferences: $userId");
        return userId;
      }

      // Méthode 3: Décoder le token JWT manuellement
      print("🔍 Tentative 3: Décoder le token JWT");
      final token = prefs.getString('token');
      if (token != null) {
        userId = _extractUserIdFromToken(token);
        if (userId != null && userId.isNotEmpty) {
          print("✅ ID trouvé via décodage JWT: $userId");
          return userId;
        }
      }

      // Méthode 4: Appel API /me pour récupérer les infos utilisateur
      print("🔍 Tentative 4: Via endpoint /me");
      final response = await _apiClient.get("/me");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        userId = data['id']?.toString() ?? data['user_id']?.toString() ?? data['userId']?.toString();
        if (userId != null && userId.isNotEmpty) {
          print("✅ ID trouvé via /me: $userId");
          // Sauvegarder pour les prochaines fois
          await prefs.setString('userId', userId);
          return userId;
        }
      }

      print("❌ Aucune méthode n'a permis de récupérer l'ID utilisateur");
      return null;
    } catch (e) {
      print("❌ Erreur dans _getUserIdWithFallback: $e");
      return null;
    }
  }

  /// Extraire l'ID utilisateur depuis le token JWT
  String? _extractUserIdFromToken(String token) {
    try {
      // Séparer le token en ses parties
      final parts = token.split('.');
      if (parts.length != 3) {
        print("❌ Format de token JWT invalide");
        return null;
      }

      // Décoder la partie payload (partie centrale)
      String payload = parts[1];
      
      // Ajouter le padding nécessaire pour base64
      switch (payload.length % 4) {
        case 1:
          payload += '===';
          break;
        case 2:
          payload += '==';
          break;
        case 3:
          payload += '=';
          break;
      }

      final decoded = utf8.decode(base64Url.decode(payload));
      final Map<String, dynamic> payloadMap = jsonDecode(decoded);
      
      print("🔍 Payload JWT décodé: $payloadMap");
      
      // Chercher l'ID utilisateur dans différents champs possibles
      return payloadMap['id']?.toString() ?? 
             payloadMap['user_id']?.toString() ?? 
             payloadMap['userId']?.toString() ??
             payloadMap['sub']?.toString(); // 'sub' est standard dans JWT
    } catch (e) {
      print("❌ Erreur lors du décodage du token JWT: $e");
      return null;
    }
  }

  /// Modifier le profil utilisateur
  Future<ModificationProfilResponse> modifierProfilUtilisateur(
      Map<String, dynamic> updatedData) async {
    try {
      print("🚀 Début modification profil utilisateur");
      
      // Vérifier l'authentification d'abord
      if (!await isAuthenticated()) {
        return ModificationProfilResponse.error("Session expirée. Veuillez vous reconnecter.");
      }

      final userId = await _getUserIdWithFallback();
      if (userId == null || userId.isEmpty) {
        return ModificationProfilResponse.error("ID utilisateur introuvable. Veuillez vous reconnecter.");
      }

      return await _modifierProfilAvecUserId(userId, updatedData);
    } catch (e) {
      print("❌ Erreur lors de la modification: $e");
      if (e.toString().contains("Session expirée") || 
          e.toString().contains("Token non trouvé")) {
        return ModificationProfilResponse.error("Session expirée. Veuillez vous reconnecter.");
      }
      return ModificationProfilResponse.error("Erreur lors de la modification: $e");
    }
  }

  /// Méthode privée pour modifier le profil avec l'ID utilisateur
  Future<ModificationProfilResponse> _modifierProfilAvecUserId(
      String userId, Map<String, dynamic> updatedData) async {
    try {
      print("🚀 Modification profil pour userId: $userId");
      
      List<String> culturesList = [];
      if (updatedData["cultures"] != null) {
        if (updatedData["cultures"] is String) {
          culturesList = updatedData["cultures"]
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
        } else if (updatedData["cultures"] is List) {
          culturesList = List<String>.from(updatedData["cultures"]);
        }
      }

      final Map<String, dynamic> apiData = {
        "nom": updatedData["nom"],
        "email": updatedData["email"],
        "numeroTel": updatedData["telephone"],
        "adresse": updatedData["adresse"],
        "cultures": culturesList,
        "cooperative": updatedData["cooperative"],
      };

      print("🔍 Données envoyées: $apiData");

      final String endpoint = "/modifier-informations-profil/$userId";
      final response = await _apiClient.put(endpoint, apiData);

      print("🔍 Réponse modification: ${response.statusCode}");
      print("🔍 Corps réponse: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("✅ Profil modifié avec succès");
        return ModificationProfilResponse.fromJson(data);
      } else {
        final data = response.body.isNotEmpty ? jsonDecode(response.body) : {};
        print("❌ Erreur modification: ${data['message'] ?? 'Erreur inconnue'}");
        return ModificationProfilResponse.error(
          data["message"] ?? "Erreur lors de la modification (Code: ${response.statusCode})",
          errors: data["errors"],
        );
      }
    } catch (e) {
      print("❌ Erreur dans _modifierProfilAvecUserId: $e");
      if (e.toString().contains("Session expirée") || 
          e.toString().contains("Token non trouvé")) {
        return ModificationProfilResponse.error("Session expirée. Veuillez vous reconnecter.");
      }
      return ModificationProfilResponse.error("Erreur de connexion: $e");
    }
  }

  /// Récupérer l'ID utilisateur depuis le backend via le token JWT
  Future<String?> getUserIdFromToken() async {
    try {
      return await _getUserIdWithFallback();
    } catch (e) {
      print("❌ Erreur lors de la récupération de l'userId: $e");
      return null;
    }
  }

  /// Méthode de diagnostic pour vérifier l'état de l'authentification
  Future<Map<String, dynamic>> debugAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getString('userId') ?? prefs.getString('user_id');
    
    return {
      'hasToken': token != null,
      'tokenLength': token?.length ?? 0,
      'hasUserId': userId != null,
      'userId': userId,
      'tokenPreview': token != null ? '${token.substring(0, 20)}...' : null,
    };
  }

  /// Déconnexion
  Future<void> logout() async {
    try {
      print("🚀 Déconnexion en cours...");
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Supprimer toutes les données stockées
      print("✅ Déconnexion terminée");
    } catch (e) {
      print("❌ Erreur lors de la déconnexion: $e");
    }
  }

  void dispose() {
    // Libération de ressources si nécessaire
    print("🧹 Nettoyage du service de modification profil");
  }
}