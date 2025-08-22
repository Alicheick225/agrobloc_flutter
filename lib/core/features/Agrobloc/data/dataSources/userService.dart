import 'package:shared_preferences/shared_preferences.dart';
import '../models/authentificationModel.dart';
import '../dataSources/authService.dart';

class UserService {
  static final UserService _instance = UserService._internal();

  AuthentificationModel? _currentUser;
  String? _userId;
  String? _token;
  bool _isLoading = false;

  factory UserService() => _instance;

  UserService._internal();

  AuthentificationModel? get currentUser => _currentUser;
  String? get userId => _userId;
  String? get token => _token;
  bool get isLoggedIn => _currentUser != null && _token != null && _token!.isNotEmpty;
  bool get isLoading => _isLoading;

  /// Vérifie si des données utilisateur sont stockées dans SharedPreferences
  Future<bool> hasStoredUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUserId = prefs.getString('userId');
      final savedToken = prefs.getString('token');
      
      return savedUserId != null && savedUserId.isNotEmpty && 
             savedToken != null && savedToken.isNotEmpty;
    } catch (e) {
      print('❌ UserService: erreur lors de la vérification des données stockées: $e');
      return false;
    }
  }

  /// Sauvegarde l'utilisateur ET le token dans la mémoire + SharedPreferences
  Future<void> setCurrentUser(AuthentificationModel user, String token) async {
    _currentUser = user;
    _userId = user.id;
    _token = token;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', user.id);
    await prefs.setString('token', token);

    print('✅ UserService: utilisateur et token sauvegardés - User ID: ${user.id}, Nom: ${user.nom}');
  }

  /// Récupère le token depuis SharedPreferences
  Future<String?> getToken() async {
    if (_token != null && _token!.isNotEmpty) {
      print('✅ UserService: token disponible en mémoire');
      return _token;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('token');
      
      if (_token != null && _token!.isNotEmpty) {
        print('✅ UserService: token récupéré depuis SharedPreferences');
      } else {
        print('ℹ️ UserService: aucun token trouvé dans SharedPreferences - utilisateur non connecté');
      }
      
      return _token;
    } catch (e) {
      print('❌ UserService: erreur lors de la récupération du token: $e');
      return null;
    }
  }

  /// Charge l'utilisateur et le token depuis SharedPreferences et API
  Future<bool> loadUser() async {
    if (_isLoading) return false;
    
    _isLoading = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUserId = prefs.getString('userId');
      final savedToken = prefs.getString('token');

      print('🔍 UserService: Chargement utilisateur - UserID: $savedUserId, Token présent: ${savedToken != null && savedToken.isNotEmpty}');

      // Vérifier si des données utilisateur existent
      final hasUserData = await hasStoredUserData();
      
      if (!hasUserData) {
        print('ℹ️ UserService: aucune donnée utilisateur trouvée - première utilisation ou utilisateur déconnecté');
        return false;
      }

      if (savedUserId != null && savedUserId.isNotEmpty && 
          savedToken != null && savedToken.isNotEmpty) {
        _userId = savedUserId;
        _token = savedToken;

        try {
          final user = await AuthService().getUserById(savedUserId);
          _currentUser = user;
          print('✅ UserService: utilisateur chargé avec succès - ID: ${user.id}, Nom: ${user.nom}');
          return true;
        } catch (e) {
          final errorMessage = e.toString();
          
          // Distinguer les différents types d'erreurs
          if (errorMessage.contains('Accès refusé')) {
            print('🔐 UserService: accès refusé par l\'API - token probablement expiré ou invalide');
            print('⚠️ UserService: redirection vers la connexion nécessaire (token invalide)');
          } else if (errorMessage.contains('Erreur API')) {
            print('❌ UserService: erreur API lors du chargement utilisateur: $e');
          } else if (errorMessage.contains('format de données')) {
            print('❌ UserService: format de réponse API invalide: $e');
          } else {
            print('❌ UserService: erreur lors du chargement utilisateur depuis API: $e');
            print('⚠️ UserService: problème de connexion ou utilisateur introuvable');
          }
          
          // Nettoyer les données invalides
          await clearCurrentUser();
          return false;
        }
      } else {
        print('⚠️ UserService: informations utilisateur incomplètes dans le stockage');
        // Nettoyer les données incomplètes
        await clearCurrentUser();
        return false;
      }
    } catch (e) {
      print('❌ UserService: erreur inattendue lors du chargement: $e');
      return false;
    } finally {
      _isLoading = false;
    }
  }

  /// Vérifie si l'utilisateur est authentifié et valide
  Future<bool> isUserAuthenticated() async {
    try {
      // Vérifier d'abord en mémoire
      if (isLoggedIn) {
        print('✅ UserService: utilisateur authentifié en mémoire');
        return true;
      }

      // Sinon, essayer de charger depuis le stockage
      final token = await getToken();
      if (token == null || token.isEmpty) {
        print('⚠️ UserService: aucun token disponible pour l\'authentification');
        return false;
      }

      // Charger l'utilisateur depuis l'API
      final loaded = await loadUser();
      if (loaded && isLoggedIn) {
        print('✅ UserService: utilisateur authentifié après chargement depuis API');
        return true;
      }

      print('❌ UserService: échec de l\'authentification - utilisateur non chargé ou invalide');
      return false;
    } catch (e) {
      final errorMessage = e.toString();
      
      // Distinguer les différents types d'erreurs d'authentification
      if (errorMessage.contains('Accès refusé')) {
        print('🔐 UserService: authentification échouée - accès refusé par l\'API');
      } else if (errorMessage.contains('token')) {
        print('🔐 UserService: authentification échouée - problème de token');
      } else {
        print('❌ UserService: erreur lors de la vérification d\'authentification: $e');
      }
      
      return false;
    }
  }

  /// Supprime la session utilisateur et token (logout)
  Future<void> clearCurrentUser() async {
    _currentUser = null;
    _userId = null;
    _token = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('token');

    print('✅ UserService: session utilisateur nettoyée');
  }

  /// Assure que l'utilisateur est chargé (utile avant des appels protégés)
  Future<bool> ensureUserLoaded() async {
    try {
      if (isLoggedIn) {
        print('✅ UserService: utilisateur déjà chargé en mémoire');
        return true;
      }

      final authenticated = await isUserAuthenticated();
      if (!authenticated) {
        print('⚠️ UserService: utilisateur non authentifié, redirection nécessaire');
        throw Exception('Utilisateur non authentifié. Veuillez vous reconnecter.');
      }
      
      print('✅ UserService: utilisateur chargé avec succès');
      return true;
    } catch (e) {
      print('❌ UserService: erreur lors du chargement de l\'utilisateur: $e');
      throw Exception('Impossible de charger l\'utilisateur. Veuillez vous reconnecter.');
    }
  }
}
