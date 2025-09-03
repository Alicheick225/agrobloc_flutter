// api_client.dart
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/userService.dart';

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
      final timeSinceLastFailure = DateTime.now().difference(_circuitBreakerLastFailure!);
      if (timeSinceLastFailure > _circuitBreakerTimeout) {
        print('🔄 ApiClient._isCircuitBreakerOpen() - Circuit breaker timeout écoulé, réessai autorisé');
        _circuitBreakerOpen = false;
        _circuitBreakerFailureCount = 0;
        return false;
      }
    }

    print('⚠️ ApiClient._isCircuitBreakerOpen() - Circuit breaker ouvert, requête rejetée');
    return true;
  }

  /// Enregistre un échec pour le circuit breaker
  void _recordFailure() {
    _circuitBreakerFailureCount++;
    _circuitBreakerLastFailure = DateTime.now();

    if (_circuitBreakerFailureCount >= _circuitBreakerMaxFailures) {
      _circuitBreakerOpen = true;
      print('🚫 ApiClient._recordFailure() - Circuit breaker ouvert après $_circuitBreakerFailureCount échecs');
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
    final delayMs = _initialRetryDelay.inMilliseconds * pow(_backoffMultiplier, attempt - 1);
    return Duration(milliseconds: delayMs.toInt().clamp(500, 10000)); // Max 10 secondes
  }

  /// Récupère les headers (avec ou sans token) avec circuit breaker et retry
  Future<Map<String, String>> _getHeaders({bool withAuth = true}) async {
    final headers = {"Content-Type": "application/json"};

    if (withAuth) {
      print('🔄 ApiClient._getHeaders() - Récupération du token pour les headers...');

      // Vérifier le circuit breaker
      if (_isCircuitBreakerOpen()) {
        throw Exception("Service temporairement indisponible (circuit breaker ouvert)");
      }

      int attempt = 0;
      while (attempt < _maxRetries) {
        attempt++;
        try {
          final token = await UserService().getValidToken();
          if (token == null) {
            print('❌ ApiClient._getHeaders() - Token null retourné par getValidToken()');
            _recordFailure();
            throw Exception("Token non trouvé ou invalide. Veuillez vous connecter.");
          }

          print('✅ ApiClient._getHeaders() - Token valide récupéré (${token.length} chars)');
          headers["Authorization"] = "Bearer $token";
          _recordSuccess();
          break;
        } catch (e, stackTrace) {
          print('❌ ApiClient._getHeaders() - ERREUR lors de la récupération du token (tentative $attempt/$_maxRetries): $e');

          if (attempt >= _maxRetries) {
            _recordFailure();
            print('❌ ApiClient._getHeaders() - Échec définitif après $_maxRetries tentatives');
            rethrow;
          }

          // Exponential backoff
          final delay = _calculateBackoffDelay(attempt);
          print('🔄 ApiClient._getHeaders() - Attente de ${delay.inMilliseconds}ms avant nouvelle tentative...');
          await Future.delayed(delay);
        }
      }
    }
    return headers;
  }

  /// Requête GET
  Future<http.Response> get(String endpoint, {bool withAuth = true}) async {
    final headers = await _getHeaders(withAuth: withAuth);
    final url = Uri.parse('$baseUrl$endpoint');
    return http.get(url, headers: headers);
  }

  /// Requête POST
  Future<http.Response> post(String endpoint, Map<String, dynamic> body, {bool withAuth = true}) async {
    final headers = await _getHeaders(withAuth: withAuth);
    final url = Uri.parse('$baseUrl$endpoint');
    return http.post(url, headers: headers, body: jsonEncode(body));
  }

  /// Requête PUT
  Future<http.Response> put(String endpoint, Map<String, dynamic> body, {bool withAuth = true}) async {
    final headers = await _getHeaders(withAuth: withAuth);
    final url = Uri.parse('$baseUrl$endpoint');
    return http.put(url, headers: headers, body: jsonEncode(body));
  }

  /// Requête DELETE
  Future<http.Response> delete(String endpoint, {bool withAuth = true}) async {
    final headers = await _getHeaders(withAuth: withAuth);
    final url = Uri.parse('$baseUrl$endpoint');
    return http.delete(url, headers: headers);
  }

  /// 🔑 Récupérer le userId depuis le token JWT
  Future<String> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      throw Exception("Token non trouvé. Veuillez vous connecter.");
    }

    // Décoder le token
    final payload = Jwt.parseJwt(token);

    if (!payload.containsKey("user_id")) {
      throw Exception("user_id manquant dans le token");
    }

    return payload["user_id"].toString();
  }

  /// Méthode de secours pour l'authentification en cas d'échec total
  Future<Map<String, String>> _getFallbackHeaders() async {
    print('🔄 ApiClient._getFallbackHeaders() - Tentative d\'authentification de secours...');

    try {
      // Essayer de récupérer depuis les variables d'instance de UserService
      final userService = UserService();
      if (userService.token != null && userService.token!.isNotEmpty) {
        print('✅ ApiClient._getFallbackHeaders() - Token trouvé dans les variables d\'instance');
        return {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${userService.token}"
        };
      }

      // Essayer de récupérer depuis un backup
      final prefs = await SharedPreferences.getInstance();
      final backupToken = prefs.getString('backup_token');
      if (backupToken != null && backupToken.isNotEmpty) {
        print('✅ ApiClient._getFallbackHeaders() - Token trouvé dans le backup');
        return {
          "Content-Type": "application/json",
          "Authorization": "Bearer $backupToken"
        };
      }

      print('❌ ApiClient._getFallbackHeaders() - Aucune méthode de secours disponible');
      throw Exception("Aucune méthode d'authentification de secours disponible");
    } catch (e) {
      print('❌ ApiClient._getFallbackHeaders() - Erreur dans l\'authentification de secours: $e');
      rethrow;
    }
  }
}
