import 'package:shared_preferences/shared_preferences.dart';
import '../models/authentificationModel.dart';
import '../dataSources/authService.dart';

class UserService {
  static final UserService _instance = UserService._internal();

  AuthentificationModel? _currentUser;
  String? _userId;
  String? _token;

  factory UserService() => _instance;

  UserService._internal();

  AuthentificationModel? get currentUser => _currentUser;
  String? get userId => _userId;
  String? get token => _token;
  bool get isLoggedIn => _currentUser != null && _token != null;

  /// Sauvegarde l'utilisateur ET le token dans la mémoire + SharedPreferences
  Future<void> setCurrentUser(AuthentificationModel user, String token) async {
    _currentUser = user;
    _userId = user.id;
    _token = token;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', user.id);
    await prefs.setString('token', token);
    await prefs.setString('userNom', user.nom); // <-- ajoute ceci


    print('✅ UserService: utilisateur et token sauvegardés');
    print("Token envoyé: '$token'");
    print("User ID envoyé: '$userId'");
  }

  /// Récupère le token depuis SharedPreferences
  Future<String?> getToken() async {
    if (_token != null) return _token;

    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    return _token;
  }

  /// Charge l'utilisateur et le token depuis SharedPreferences et API
  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUserId = prefs.getString('userId');
    final savedToken = prefs.getString('token');

    if (savedUserId != null && savedToken != null) {
      _userId = savedUserId;
      _token = savedToken;

      try {
        final user = await AuthService().getUserById(savedUserId);
        _currentUser = user;
        print('✅ UserService: utilisateur chargé depuis API');
      } catch (e) {
        print('⚠️ UserService: erreur lors du chargement utilisateur $e');
        await clearCurrentUser();
      }
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

  Future<void> debugUserSession() async {
  final prefs = await SharedPreferences.getInstance();
  print("🔎 Debug session utilisateur :");
  print(" - userId: ${prefs.getString('userId')}");
  print(" - token: ${prefs.getString('token')}");
}

}
