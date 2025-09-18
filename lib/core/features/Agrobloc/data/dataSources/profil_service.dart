import 'dart:convert';
import 'package:agrobloc/core/features/Agrobloc/data/models/profil_model.dart';
import 'package:agrobloc/core/utils/api_token.dart';

class ProfilService {
  final ApiClient _apiClient = ApiClient("http://192.168.252.199:3000/authentification");

  /// Récupérer le profil utilisateur avec authentification
  Future<ProfilResponse> getProfilUtilisateur(String userId) async {
    try {
      print("🔄 ProfilService.getProfilUtilisateur() - Récupération du profil pour userId: $userId");
      print("URL appelée: ${_apiClient.baseUrl}/informations-profil/$userId");

      // Utiliser l'ApiClient avec authentification automatique (withAuth: true par défaut)
      final response = await _apiClient.get("/informations-profil/$userId");

      print("Status Code: ${response.statusCode}");
      print("Response Headers: ${response.headers}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        // Vérifier si la réponse est bien du JSON
        if (response.body.startsWith('<!DOCTYPE') || response.body.startsWith('<html')) {
          return ProfilResponse(
            success: false,
            message: "Le serveur a retourné du HTML au lieu de JSON. Vérifiez l'URL de l'API.",
          );
        }
        
        try {
          final data = jsonDecode(response.body);
          print("✅ ProfilService.getProfilUtilisateur() - Données JSON parsées avec succès");
          
          // Vérifier la structure de la réponse
          if (data.containsKey("user")) {
            final user = MesInformationsModel.fromJson(data["user"]);
            return ProfilResponse(success: true, user: user);
          } else if (data.containsKey("success") && data["success"] == true) {
            // Si la structure est différente, adapter selon votre API
            final user = MesInformationsModel.fromJson(data["data"] ?? data);
            return ProfilResponse(success: true, user: user);
          } else if (data.containsKey("nom") || data.containsKey("email")) {
            // Si les données utilisateur sont directement dans la réponse
            final user = MesInformationsModel.fromJson(data);
            return ProfilResponse(success: true, user: user);
          } else {
            print("❌ ProfilService.getProfilUtilisateur() - Structure de réponse inattendue: ${data.keys}");
            return ProfilResponse(
              success: false,
              message: data["message"] ?? "Structure de réponse inattendue",
            );
          }
        } catch (jsonError) {
          print("❌ ProfilService.getProfilUtilisateur() - Erreur de parsing JSON: $jsonError");
          return ProfilResponse(
            success: false,
            message: "Erreur de format de réponse: ${jsonError.toString()}",
          );
        }
      } else {
        // Gestion des erreurs HTTP
        print("❌ ProfilService.getProfilUtilisateur() - Erreur HTTP ${response.statusCode}");
        
        String errorMessage;
        switch (response.statusCode) {
          case 401:
            errorMessage = "Session expirée. Veuillez vous reconnecter.";
            break;
          case 403:
            errorMessage = "Accès refusé. Permissions insuffisantes.";
            break;
          case 404:
            errorMessage = "Utilisateur non trouvé ou endpoint incorrect.";
            break;
          case 500:
            errorMessage = "Erreur serveur interne. Réessayez plus tard.";
            break;
          case 502:
          case 503:
          case 504:
            errorMessage = "Service temporairement indisponible. Réessayez plus tard.";
            break;
          default:
            errorMessage = "Erreur HTTP ${response.statusCode}";
        }
        
        // Essayer de parser le message d'erreur du serveur
        try {
          if (!response.body.startsWith('<!DOCTYPE') && !response.body.startsWith('<html')) {
            final data = jsonDecode(response.body);
            errorMessage = data["message"] ?? data["error"] ?? errorMessage;
          }
        } catch (e) {
          // Ignore si ce n'est pas du JSON valide
          print("Impossible de parser l'erreur JSON: $e");
        }
        
        return ProfilResponse(success: false, message: errorMessage);
      }
    } catch (e) {
      print("❌ ProfilService.getProfilUtilisateur() - Exception: $e");
      
      // Gestion spécifique des exceptions de votre ApiClient
      if (e.toString().contains('circuit breaker ouvert')) {
        return ProfilResponse(
          success: false,
          message: "Service temporairement indisponible. Réessayez dans quelques instants.",
        );
      } else if (e.toString().contains('Token non trouvé') || e.toString().contains('Token non trouvé ou invalide')) {
        return ProfilResponse(
          success: false,
          message: "Session expirée. Veuillez vous reconnecter.",
        );
      } else if (e.toString().contains('SocketException')) {
        return ProfilResponse(
          success: false,
          message: "Erreur de connexion réseau. Vérifiez votre connexion internet.",
        );
      } else if (e.toString().contains('TimeoutException')) {
        return ProfilResponse(
          success: false,
          message: "Délai d'attente dépassé. Réessayez plus tard.",
        );
      } else if (e.toString().contains('FormatException')) {
        return ProfilResponse(
          success: false,
          message: "Réponse invalide du serveur. L'API retourne du HTML au lieu de JSON.",
        );
      }
      
      return ProfilResponse(
        success: false,
        message: "Erreur de connexion: ${e.toString()}",
      );
    }
  }

  /// Récupérer le profil utilisateur en utilisant l'userId du token
  Future<ProfilResponse> getMyProfil() async {
    try {
      print("🔄 ProfilService.getMyProfil() - Récupération de l'userId depuis le token...");
      
      // Utiliser la méthode getUserId() de votre ApiClient
      final userId = await _apiClient.getUserId();
      print("✅ ProfilService.getMyProfil() - UserId récupéré: $userId");
      
      // Appeler getProfilUtilisateur avec l'userId
      return await getProfilUtilisateur(userId);
    } catch (e) {
      print("❌ ProfilService.getMyProfil() - Erreur lors de la récupération de l'userId: $e");
      
      if (e.toString().contains('Token non trouvé')) {
        return ProfilResponse(
          success: false,
          message: "Session expirée. Veuillez vous reconnecter.",
        );
      } else if (e.toString().contains('user_id manquant')) {
        return ProfilResponse(
          success: false,
          message: "Token invalide. Veuillez vous reconnecter.",
        );
      }
      
      return ProfilResponse(
        success: false,
        message: "Erreur lors de la récupération des informations utilisateur: ${e.toString()}",
      );
    }
  }

  /// Méthode pour tester la connectivité
  Future<bool> testConnectivity() async {
    try {
      print("🔄 ProfilService.testConnectivity() - Test de connectivité...");
      
      // Utiliser un endpoint simple pour tester
      final response = await _apiClient.get("/test", withAuth: false);
      
      final isConnected = response.statusCode == 200 || response.statusCode == 404; // 404 est OK pour un test
      print("✅ ProfilService.testConnectivity() - Résultat: $isConnected (status: ${response.statusCode})");
      
      return isConnected;
    } catch (e) {
      print("❌ ProfilService.testConnectivity() - Erreur: $e");
      return false;
    }
  }

  /// Méthode pour vérifier si l'utilisateur est connecté
  Future<bool> isAuthenticated() async {
    try {
      // Essayer de récupérer l'userId, ce qui vérifie implicitement le token
      await _apiClient.getUserId();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Méthode pour forcer la réinitialisation du circuit breaker
  void resetCircuitBreaker() {
    // Votre ApiClient gère automatiquement le circuit breaker
    // Cette méthode peut être utilisée si vous ajoutez une méthode reset dans ApiClient
    print("🔄 ProfilService.resetCircuitBreaker() - Circuit breaker sera réinitialisé automatiquement");
  }

  void dispose() {}
}

class ProfilResponse {
  final bool success;
  final MesInformationsModel? user;
  final String? message;

  ProfilResponse({required this.success, this.user, this.message});

  @override
  String toString() {
    return 'ProfilResponse(success: $success, user: ${user != null ? 'present' : 'null'}, message: $message)';
  }
}