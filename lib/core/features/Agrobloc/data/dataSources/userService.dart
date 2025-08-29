import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/authentificationModel.dart';
import 'authService.dart';

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

  /// Sauvegarde utilisateur + tokens
  Future<void> setCurrentUser(AuthentificationModel user, String token, String refreshToken) async {
    _currentUser = user;
    _userId = user.id;
    _token = token;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user.toJson()));
    await prefs.setString('userId', user.id);
    await prefs.setString('token', token);
    await prefs.setString('refresh_token', refreshToken);

    print('✅ UserService: utilisateur et tokens sauvegardés');
  }

  /// Récupère un token valide (refresh si nécessaire)
  Future<String?> getValidToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString("token");
    String? refreshToken = prefs.getString("refresh_token");

    print('🔍 UserService.getValidToken() - accessToken: ${accessToken != null ? "present" : "null"}, refreshToken: ${refreshToken != null ? "present" : "null"}');

    if (accessToken == null || accessToken.isEmpty) {
      print('❌ UserService.getValidToken() - No access token found');
      return null;
    }

    final isExpired = isTokenExpired(accessToken);
    print('🔍 UserService.getValidToken() - Token expired: $isExpired');
    
    if (isExpired) {
      print("🔄 UserService.getValidToken() - Token expiré, tentative de refresh...");
      try {
        if (refreshToken == null) {
          print('❌ UserService.getValidToken() - No refresh token available for refresh');
          await clearCurrentUser();
          return null;
        }
        
        final newTokens = await AuthService().refreshToken(refreshToken);
        await prefs.setString("token", newTokens['accessToken']!);
        await prefs.setString("refresh_token", newTokens['refreshToken']!);
        _token = newTokens['accessToken']!;
        print('✅ UserService.getValidToken() - Token refresh successful');
        return _token;
      } catch (e, stackTrace) {
        print("❌ UserService.getValidToken() - Refresh token échoué: $e");
        print("❌ Stack trace: $stackTrace");
        await clearCurrentUser();
        return null;
      }
    }

    print('✅ UserService.getValidToken() - Token is valid');
    return accessToken;
  }

  /// Vérifie si token JWT est expiré
  bool isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final payloadMap = json.decode(decoded);
      final exp = payloadMap['exp'] as int;
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      return exp < now;
    } catch (e) {
      return true;
    }
  }

  /// Supprime la session utilisateur
  Future<void> clearCurrentUser() async {
    _currentUser = null;
    _userId = null;
    _token = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    await prefs.remove('userId');
    await prefs.remove('token');
    await prefs.remove('refresh_token');

    print('✅ UserService: session utilisateur nettoyée');
  }

  /// Charger utilisateur depuis SharedPreferences
  Future<bool> loadUser() async {
    if (_isLoading) return false;
    _isLoading = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUserJson = prefs.getString('user');
      final savedToken = await getValidToken();
      
      print('🔍 UserService.loadUser() - savedUserJson present: ${savedUserJson != null}, savedToken: ${savedToken != null ? "present" : "null"}');
      
      if (savedUserJson == null || savedToken == null) {
        print('❌ UserService.loadUser() - Missing user data or token');
        _isLoading = false;
        return false;
      }

      _token = savedToken;
      _currentUser = AuthentificationModel.fromJson(jsonDecode(savedUserJson));
      _userId = _currentUser?.id;
      
      print('✅ UserService.loadUser() - Successfully loaded user: ${_currentUser!.nom} (ID: ${_currentUser!.id})');
      _isLoading = false;
      return true;
    } catch (e, stackTrace) {
      print('❌ UserService.loadUser() - ERROR: $e');
      print('❌ Stack trace: $stackTrace');
      await clearCurrentUser();
      _isLoading = false;
      return false;
    }
  }

  /// Vérifie si des données utilisateur sont stockées localement
  Future<bool> hasStoredUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final hasUserId = prefs.containsKey('userId');
    final hasToken = prefs.containsKey('token');
    return hasUserId && hasToken;
  }

  /// Vérifie si l'utilisateur est authentifié
  Future<bool> isUserAuthenticated() async {
    // Always check storage first - instance variables might not be loaded
    final hasData = await hasStoredUserData();
    if (hasData) {
      return await loadUser();
    }
    
    // Fallback to instance variables if no stored data
    return _currentUser != null && _token != null && _token!.isNotEmpty;
  }

  /// S'assure que l'utilisateur est chargé
  Future<void> ensureUserLoaded() async {
    if (_currentUser == null) {
      // Check if we have stored data first
      final hasData = await hasStoredUserData();
      if (hasData) {
        await loadUser();
      }
    }
  }

  /// Récupère le token actuel
  Future<String?> getToken() async {
    if (_token != null && _token!.isNotEmpty) {
      return _token;
    }
    
    // Try to get valid token from storage
    return await getValidToken();
  }
}
