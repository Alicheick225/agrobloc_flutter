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

  /// Vérifie si des données utilisateur sont stockées
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

  /// Sauvegarde l'utilisateur et le token
  Future<void> setCurrentUser(AuthentificationModel user, String token) async {
    _currentUser = user;
    _userId = user.id;
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', user.id);
    await prefs.setString('token', token);
    await prefs.setString('userNom', user.nom);

    // 🔥 AJOUT : sauvegarde aussi le profileId
    if (user.profilId != null) {
      await prefs.setString('profileId', user.profilId);
    }
  }

  /// Récupère le token depuis SharedPreferences
  Future<String?> getToken() async {
    if (_token != null && _token!.isNotEmpty) return _token;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    return _token;
  }

  /// Charge l'utilisateur depuis l'API et SharedPreferences
  Future<bool> loadUser() async {
    if (_isLoading) return false;
    _isLoading = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUserId = prefs.getString('userId');
      final savedToken = prefs.getString('token');
      if (savedUserId == null || savedToken == null) {
        await clearCurrentUser();
        return false;
      }
      _userId = savedUserId;
      _token = savedToken;
      final user = await AuthService().getUserById(savedUserId);
      _currentUser = user;

      // 🔥 Ajout : remettre le profilId en mémoire si dispo
      if (user.profilId != null) {
        await prefs.setString('profileId', user.profilId);
      }

      return true;
    } catch (e) {
      await clearCurrentUser();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  /// Vérifie si l'utilisateur est authentifié
  Future<bool> isUserAuthenticated() async {
    if (isLoggedIn) return true;
    final hasData = await hasStoredUserData();
    if (!hasData) return false;
    return await loadUser();
  }

  /// Supprime la session utilisateur et token
  Future<void> clearCurrentUser() async {
    _currentUser = null;
    _userId = null;
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('token');
    await prefs.remove('userNom');

    // 🔥 AJOUT : nettoyer aussi le profileId
    await prefs.remove('profileId');
  }

  /// Déconnexion via API + suppression locale
  Future<void> logoutUser() async {
    await AuthService().logout();
  }

  /// Assure que l'utilisateur est chargé avant les appels protégés
  Future<bool> ensureUserLoaded() async {
    if (isLoggedIn) return true;
    final loaded = await isUserAuthenticated();
    if (!loaded) throw Exception('Utilisateur non authentifié. Veuillez vous reconnecter.');
    return true;
  }

  /// Récupère l'ID du profil stocké
  Future<String?> getStoredProfileId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('profileId');
  }
}
