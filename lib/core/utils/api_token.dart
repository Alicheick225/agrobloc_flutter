// api_client.dart
// api_client.dart
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/userService.dart';

// Centralized API configuration
class ApiConfig {
  // Base URLs for different environments
  static const String devApiBaseUrl = 'http://192.168.252.199:3000';
  static const String prodApiBaseUrl = 'https://api.yourproductiondomain.com';

  static const String devImageBaseUrl = 'http://192.168.252.199:8081';
  static const String prodImageBaseUrl =
      'https://images.yourproductiondomain.com';

  // Service-specific base URLs for dev environment
  static const String devAnnoncesVenteBaseUrl = 'http://192.168.252.199:8082';
  static const String devAnnoncesBaseUrl = 'http://192.168.252.199:8082';
  static const String devAnnoncesPrefBaseUrl = 'http://192.168.252.199:8082';
  static const String devCulturesBaseUrl = 'http://192.168.252.199:8004';
  static const String devParcellesBaseUrl = 'http://192.168.252.199:8004';
  static const String devCommandesBaseUrl =
      'http://192.168.252.199:3001/commandes';
  static const String devMessagerieBaseUrl = 'http://192.168.252.199:8087';

  // Service-specific base URLs for prod environment
  static const String prodAnnoncesBaseUrl =
      'https://api.yourproductiondomain.com';
  static const String prodAnnoncesPrefBaseUrl =
      'https://api.yourproductiondomain.com';
  static const String prodCulturesBaseUrl =
      'https://api.yourproductiondomain.com';
  static const String prodParcellesBaseUrl =
      'https://api.yourproductiondomain.com';
  static const String prodCommandesBaseUrl =
      'https://api.yourproductiondomain.com';
  static const String prodMessagerieBaseUrl =
      'https://api.yourproductiondomain.com';

  // Current environment: change this to switch environments
  static const bool isProduction = false;

  // Get API base URL depending on environment
  static String get apiBaseUrl => isProduction ? prodApiBaseUrl : devApiBaseUrl;

  // Get Image base URL depending on environment
  static String get imageBaseUrl =>
      isProduction ? prodImageBaseUrl : devImageBaseUrl;

  // Get service-specific base URLs
  static String get annoncesBaseUrl =>
      isProduction ? prodAnnoncesBaseUrl : devAnnoncesBaseUrl;
  static String get annoncesPrefBaseUrl =>
      isProduction ? prodAnnoncesPrefBaseUrl : devAnnoncesPrefBaseUrl;
  static String get culturesBaseUrl =>
      isProduction ? prodCulturesBaseUrl : devCulturesBaseUrl;
  static String get parcellesBaseUrl =>
      isProduction ? prodParcellesBaseUrl : devParcellesBaseUrl;
  static String get commandesBaseUrl =>
      isProduction ? prodCommandesBaseUrl : devCommandesBaseUrl;
  static String get messagerieBaseUrl =>
      isProduction ? prodMessagerieBaseUrl : devMessagerieBaseUrl;
}

/// Classes d'exception spécifiques pour les erreurs d'authentification
class AuthenticationException implements Exception {
  final String message;
  final String type;

  AuthenticationException(this.message, {this.type = 'authentication'});

  @override
  String toString() => 'AuthenticationException: $message (type: $type)';
}

class TokenExpiredException extends AuthenticationException {
  TokenExpiredException(String message) : super(message, type: 'token_expired');
}

class TokenInvalidException extends AuthenticationException {
  TokenInvalidException(String message) : super(message, type: 'token_invalid');
}

class NetworkAuthenticationException extends AuthenticationException {
  NetworkAuthenticationException(String message)
      : super(message, type: 'network');
}

class ApiClient {
  final String baseUrl;
  ApiClient(this.baseUrl);

  // Circuit breaker state
  bool _circuitBreakerOpen = false;
  DateTime? _circuitBreakerLastFailure;
  int _circuitBreakerFailureCount = 0;
  static const int _circuitBreakerMaxFailures = 3;
  static const Duration _circuitBreakerTimeout = Duration(seconds: 30);

  // Exponential backoff settings
  static const int _maxRetries = 3;
  static const Duration _initialRetryDelay = Duration(milliseconds: 500);
  static const double _backoffMultiplier = 2.0;

  /// Vérifie l'état du circuit breaker
  bool _isCircuitBreakerOpen() {
    if (!_circuitBreakerOpen) return false;

    // Vérifier si le timeout du circuit breaker est écoulé
    if (_circuitBreakerLastFailure != null) {
      final timeSinceLastFailure =
          DateTime.now().difference(_circuitBreakerLastFailure!);
      if (timeSinceLastFailure > _circuitBreakerTimeout) {
        print(
            '🔄 ApiClient._isCircuitBreakerOpen() - Circuit breaker timeout écoulé, réessai autorisé');
        _circuitBreakerOpen = false;
        _circuitBreakerFailureCount = 0;
        return false;
      }
    }

    print(
        '⚠️ ApiClient._isCircuitBreakerOpen() - Circuit breaker ouvert, requête rejetée');
    return true;
  }

  /// Enregistre un échec pour le circuit breaker
  void _recordFailure() {
    _circuitBreakerFailureCount++;
    _circuitBreakerLastFailure = DateTime.now();

    if (_circuitBreakerFailureCount >= _circuitBreakerMaxFailures) {
      _circuitBreakerOpen = true;
      print(
          '🚫 ApiClient._recordFailure() - Circuit breaker ouvert après $_circuitBreakerFailureCount échecs');
    }
  }

  /// Enregistre un succès pour le circuit breaker
  void _recordSuccess() {
    if (_circuitBreakerFailureCount > 0) {
      _circuitBreakerFailureCount = 0;
      print('✅ ApiClient._recordSuccess() - Circuit breaker remis à zéro');
    }
  }

  /// Calcule le délai d'attente pour l'exponential backoff
  Duration _calculateBackoffDelay(int attempt) {
    final delayMs = _initialRetryDelay.inMilliseconds *
        pow(_backoffMultiplier, attempt - 1);
    return Duration(
        milliseconds: delayMs.toInt().clamp(500, 10000)); // Max 10 secondes
  }

  /// Exécute une requête HTTP avec retry et exponential backoff
  Future<http.Response> _executeWithRetry(
      Future<http.Response> Function() requestFunction) async {
    // Vérifier la connectivité du serveur avant de commencer
    final isServerReachable = await _checkServerReachability();
    if (!isServerReachable) {
      print(
          '❌ ApiClient._executeWithRetry() - Serveur non accessible, abandon des tentatives');
      throw Exception(
          'Serveur non accessible. Vérifiez votre connexion réseau.');
    }

    int attempt = 0;
    while (attempt < _maxRetries) {
      attempt++;
      try {
        final response = await requestFunction();
        // Si la réponse est réussie (2xx), retourner immédiatement
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return response;
        }
        // Pour les erreurs serveur (5xx) ou erreurs réseau, retry
        if (response.statusCode >= 500 ||
            response.statusCode == 408 ||
            response.statusCode == 429) {
          if (attempt >= _maxRetries) {
            return response; // Retourner la dernière réponse d'erreur
          }
          final delay = _calculateBackoffDelay(attempt);
          print(
              '🔄 ApiClient._executeWithRetry() - Erreur ${response.statusCode}, retry dans ${delay.inMilliseconds}ms (tentative $attempt/$_maxRetries)');
          await Future.delayed(delay);
          continue;
        }
        // Pour les autres erreurs (4xx), ne pas retry
        return response;
      } catch (e) {
        // Pour les exceptions (TimeoutException, SocketException, etc.), retry
        if (attempt >= _maxRetries) {
          rethrow;
        }
        final delay = _calculateBackoffDelay(attempt);
        print(
            '🔄 ApiClient._executeWithRetry() - Exception: $e, retry dans ${delay.inMilliseconds}ms (tentative $attempt/$_maxRetries)');
        await Future.delayed(delay);
      }
    }
    throw Exception('Échec après $_maxRetries tentatives');
  }

  /// Récupère les headers (avec ou sans token) avec circuit breaker et retry
  Future<Map<String, String>> _getHeaders({bool withAuth = true}) async {
    final headers = {"Content-Type": "application/json"};

    if (withAuth) {
      // Vérifier d'abord si l'utilisateur est connecté pour éviter les tentatives inutiles
      final isLoggedIn = UserService().isLoggedIn;
      if (!isLoggedIn) {
        print('❌ ApiClient._getHeaders() - Utilisateur non connecté, impossible de récupérer le token');
        throw AuthenticationException(
            "Utilisateur non connecté. Veuillez vous connecter pour accéder à cette ressource.",
            type: 'not_logged_in');
      }

      print(
          '🔄 ApiClient._getHeaders() - Récupération du token pour les headers...');

      // Vérifier le circuit breaker
      if (_isCircuitBreakerOpen()) {
        throw Exception(
            "Service temporairement indisponible (circuit breaker ouvert)");
      }

      int attempt = 0;
      while (attempt < _maxRetries) {
        attempt++;
        try {
          final token = await UserService().getValidToken();
          if (token == null) {
            print(
                '❌ ApiClient._getHeaders() - Token null retourné par getValidToken()');
            _recordFailure();
            throw Exception(
                "Token non trouvé ou invalide. Veuillez vous connecter.");
          }

          print(
              '✅ ApiClient._getHeaders() - Token valide récupéré (${token.length} chars)');
          headers["Authorization"] = "Bearer $token";
          _recordSuccess();
          break;
        } catch (e, stackTrace) {
          print(
              '❌ ApiClient._getHeaders() - ERREUR lors de la récupération du token (tentative $attempt/$_maxRetries): $e');

          if (attempt >= _maxRetries) {
            _recordFailure();
            print(
                '❌ ApiClient._getHeaders() - Échec définitif après $_maxRetries tentatives');
            rethrow;
          }

          // Exponential backoff
          final delay = _calculateBackoffDelay(attempt);
          print(
              '🔄 ApiClient._getHeaders() - Attente de ${delay.inMilliseconds}ms avant nouvelle tentative...');
          await Future.delayed(delay);
        }
      }
    }
    return headers;
  }

  /// Requête GET avec retry
  Future<http.Response> get(String endpoint, {bool withAuth = true}) async {
    return _executeWithRetry(() async {
      final headers = await _getHeaders(withAuth: withAuth);
      final url = Uri.parse('$baseUrl$endpoint');
      return http.get(url, headers: headers);
    });
  }

  /// Requête POST avec retry
  Future<http.Response> post(String endpoint, Map<String, dynamic> body,
      {bool withAuth = true}) async {
    return _executeWithRetry(() async {
      final headers = await _getHeaders(withAuth: withAuth);
      final url = Uri.parse('$baseUrl$endpoint');
      return http.post(url, headers: headers, body: jsonEncode(body));
    });
  }

  /// Requête PUT avec retry
  Future<http.Response> put(String endpoint, Map<String, dynamic> body,
      {bool withAuth = true}) async {
    return _executeWithRetry(() async {
      final headers = await _getHeaders(withAuth: withAuth);
      final url = Uri.parse('$baseUrl$endpoint');
      return http.put(url, headers: headers, body: jsonEncode(body));
    });
  }

  /// Requête DELETE avec retry
  Future<http.Response> delete(String endpoint, {bool withAuth = true}) async {
    return _executeWithRetry(() async {
      final headers = await _getHeaders(withAuth: withAuth);
      final url = Uri.parse('$baseUrl$endpoint');
      return http.delete(url, headers: headers);
    });
  }

  /// 🔑 Récupérer le userId depuis le token JWT
  Future<String> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      throw TokenInvalidException("Token non trouvé. Veuillez vous connecter.");
    }

    // Décoder le token
    final payload = Jwt.parseJwt(token);

    if (!payload.containsKey("user_id")) {
      throw TokenInvalidException("user_id manquant dans le token");
    }

    return payload["user_id"].toString();
  }

  /// Vérifie la connectivité du serveur avec retry
  Future<bool> _checkServerReachability() async {
    const int maxRetries = 2;
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final url = Uri.parse('$baseUrl/'); // Check server root
        final response =
            await http.get(url).timeout(const Duration(seconds: 5));
        // Consider any HTTP response as reachable (server is responding)
        // 200-499 means server is up, only network errors mean unreachable
        if (response.statusCode >= 200 && response.statusCode < 500) {
          print(
              '✅ ApiClient._checkServerReachability() - Serveur accessible (tentative $attempt)');
          return true;
        } else {
          print(
              '⚠️ ApiClient._checkServerReachability() - Réponse serveur inattendue: ${response.statusCode} (tentative $attempt)');
          if (attempt >= maxRetries) return false;
        }
      } catch (e) {
        print(
            '⚠️ ApiClient._checkServerReachability() - Erreur de connectivité (tentative $attempt): $e');
        if (attempt >= maxRetries) {
          print(
              '❌ ApiClient._checkServerReachability() - Serveur non accessible après $maxRetries tentatives');
          return false;
        }
        // Wait before retry
        await Future.delayed(Duration(seconds: 1));
      }
    }
    return false;
  }

  /// Méthode de secours pour l'authentification en cas d'échec total
  Future<Map<String, String>> _getFallbackHeaders() async {
    print(
        '🔄 ApiClient._getFallbackHeaders() - Tentative d\'authentification de secours...');

    try {
      // Essayer de récupérer depuis les variables d'instance de UserService
      final userService = UserService();
      if (userService.token != null && userService.token!.isNotEmpty) {
        print(
            '✅ ApiClient._getFallbackHeaders() - Token trouvé dans les variables d\'instance');
        return {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${userService.token}"
        };
      }

      // Essayer de récupérer depuis un backup
      final prefs = await SharedPreferences.getInstance();
      final backupToken = prefs.getString('backup_token');
      if (backupToken != null && backupToken.isNotEmpty) {
        print(
            '✅ ApiClient._getFallbackHeaders() - Token trouvé dans le backup');
        return {
          "Content-Type": "application/json",
          "Authorization": "Bearer $backupToken"
        };
      }

      print(
          '❌ ApiClient._getFallbackHeaders() - Aucune méthode de secours disponible');
      throw TokenInvalidException(
          "Aucune méthode d'authentification de secours disponible");
    } catch (e) {
      print(
          '❌ ApiClient._getFallbackHeaders() - Erreur dans l\'authentification de secours: $e');
      if (e is AuthenticationException) {
        rethrow;
      }
      throw NetworkAuthenticationException(
          "Erreur réseau lors de l'authentification de secours: $e");
    }
  }
}
