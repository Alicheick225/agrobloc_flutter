
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:agrobloc/core/features/Agrobloc/data/models/notificationModel.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
// 🆕 NOUVEAU : Imports pour les notifications locales
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static const String _baseUrl = 'http://192.168.252.183:8082/api';
  
  // 🆕 NOUVEAU : Instance singleton pour les notifications push
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // 🆕 NOUVEAU : Plugin pour les notifications locales
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // 🆕 NOUVEAU : Variables pour le système push
  String? _deviceToken;
  Timer? _pollingTimer;
  bool _isListening = false;
  String? _currentUserId;

  // 🆕 NOUVEAU : Getter pour le token
  String get deviceToken => _deviceToken ?? '';
  bool get isListening => _isListening;

  // 🆕 NOUVEAU : Callback pour les nouvelles notifications
  Function(NotificationModel)? onNewNotification;

  // Méthode existante - conservée
  Future<List<NotificationModel>> fetchNotifications() async {
    final uri = Uri.parse('$_baseUrl/notifications/');
    final response = await http.get(uri);

    if (kDebugMode) {
      debugPrint('Response body: ${response.body}');
    }

    if (response.statusCode != 200) {
      throw Exception('Échec du chargement (${response.statusCode})');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final List<dynamic> data = decoded['notifications'] as List<dynamic>;

    final notifications = data.map((item) {
      if (kDebugMode) debugPrint('raw item: $item');
      return NotificationModel.fromJson(item as Map<String, dynamic>);
    }).toList();

    notifications.sort((a, b) => b.date.compareTo(a.date));
    return notifications;
  }

  // 🆕 NOUVEAU : Initialisation du système de notifications push
  Future<void> initializePushNotifications() async {
    try {
      // Initialiser les notifications locales
      await _initializeLocalNotifications();
      
      // Générer le token de l'appareil
      await _generateDeviceToken();
      
      // Demander les permissions
      await _requestPermissions();
      
      if (kDebugMode) {
        debugPrint('🔔 Service de notifications push initialisé');
        debugPrint('📱 Token de l\'appareil: $_deviceToken');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Erreur lors de l\'initialisation: $e');
    }
  }

  // 🆕 NOUVEAU : Configuration des notifications locales
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  // 🆕 NOUVEAU : Génération du token unique de l'appareil
  Future<void> _generateDeviceToken() async {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomNumber = random.nextInt(999999);
    
    _deviceToken = '${Platform.operatingSystem}_${timestamp}_$randomNumber';
  }

  // 🆕 NOUVEAU : Demande des permissions
  Future<bool> _requestPermissions() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      return status.isGranted;
    } else if (Platform.isIOS) {
      final result = await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return result ?? false;
    }
    return false;
  }

  // 🆕 NOUVEAU : Enregistrement du token sur le serveur
  Future<bool> registerDeviceToken(String userId) async {
    if (_deviceToken == null) {
      if (kDebugMode) debugPrint('❌ Aucun token généré');
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/register-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'device_token': _deviceToken,
          'platform': Platform.operatingSystem,
        }),
      );

      if (response.statusCode == 200) {
        _currentUserId = userId;
        if (kDebugMode) debugPrint('✅ Token enregistré avec succès');
        return true;
      } else {
        if (kDebugMode) debugPrint('❌ Erreur enregistrement: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Erreur réseau: $e');
      return false;
    }
  }

  // 🆕 NOUVEAU : Démarrer l'écoute des notifications
  Future<void> startListening({String? userId}) async {
    if (_isListening) return;

    final targetUserId = userId ?? _currentUserId;
    if (targetUserId == null) {
      if (kDebugMode) debugPrint('❌ Aucun userId fourni');
      return;
    }

    _isListening = true;
    _currentUserId = targetUserId;

    // Polling toutes les 30 secondes
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      await _checkForNewNotifications(targetUserId);
    });

    if (kDebugMode) debugPrint('🎧 Écoute des notifications démarrée pour l\'utilisateur: $targetUserId');
  }

  // 🆕 NOUVEAU : Arrêter l'écoute des notifications
  void stopListening() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _isListening = false;
    if (kDebugMode) debugPrint('🛑 Écoute des notifications arrêtée');
  }

  // 🆕 NOUVEAU : Vérification des nouvelles notifications
  Future<void> _checkForNewNotifications(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/notifications/user/$userId/unread'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final List<dynamic> notifications = decoded['notifications'] as List<dynamic>;
        
        for (var notifData in notifications) {
          final notification = NotificationModel.fromJson(notifData);
          
          // Afficher la notification locale
          await _showLocalNotification(notification);
          
          // Appeler le callback si défini
          onNewNotification?.call(notification);
          
          // Marquer comme affichée sur le serveur
          await _markNotificationAsDisplayed(notification.id);
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Erreur lors de la vérification: $e');
    }
  }

  // 🆕 NOUVEAU : Affichage d'une notification locale
  Future<void> _showLocalNotification(NotificationModel notification) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'agrobloc_channel',
      'Agrobloc Notifications',
      channelDescription: 'Notifications de l\'application Agrobloc',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      int.tryParse(notification.id) ?? DateTime.now().millisecond,
      notification.title,
      notification.message,
      details,
      payload: jsonEncode(notification.toJson()),
    );

    if (kDebugMode) debugPrint('📱 Notification affichée: ${notification.title}');
  }

  // 🆕 NOUVEAU : Marquer une notification comme affichée
  Future<void> _markNotificationAsDisplayed(String notificationId) async {
    try {
      await http.put(
        Uri.parse('$_baseUrl/notifications/$notificationId/displayed'),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Erreur marquage affiché: $e');
    }
  }

  // 🆕 NOUVEAU : Gestionnaire de tap sur notification
  void _onNotificationTapped(NotificationResponse response) {
    if (kDebugMode) debugPrint('🔔 Notification tappée: ${response.payload}');
    
    if (response.payload != null) {
      try {
        final notificationData = jsonDecode(response.payload!);
        final notification = NotificationModel.fromJson(notificationData);
        
        // Vous pouvez ajouter ici la navigation vers une page spécifique
        // NavigationService.navigateToNotificationDetail(notification);
        
      } catch (e) {
        if (kDebugMode) debugPrint('❌ Erreur parsing payload: $e');
      }
    }
  }

  // 🔧 MODIFIÉ : Méthode existante améliorée
  static Future<void> showNow({
    required int id, 
    required String title, 
    required String body, 
    required bool isHeadsUp,
    // 🆕 NOUVEAU : Paramètres optionnels
    String? payload,
  }) async {
    final instance = NotificationService();
    
    // 🆕 NOUVEAU : Créer un modèle de notification
    final notification = NotificationModel(
      id: id.toString(),
      title: title,
      message: body,
      type: 'manual',
      date: DateTime.now(),
    );

    // 🆕 NOUVEAU : Afficher immédiatement la notification
    await instance._showLocalNotification(notification);
  }

  // 🆕 NOUVEAU : Marquer une notification comme lue
  Future<void> markAsRead(String notificationId) async {
    try {
      await http.put(
        Uri.parse('$_baseUrl/notifications/$notificationId/read'),
        headers: {'Content-Type': 'application/json'},
      );
      if (kDebugMode) debugPrint('✅ Notification $notificationId marquée comme lue');
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Erreur marquage lu: $e');
    }
  }

  // 🆕 NOUVEAU : Marquer toutes les notifications comme lues
  Future<void> markAllAsRead(String userId) async {
    try {
      await http.put(
        Uri.parse('$_baseUrl/notifications/user/$userId/mark-all-read'),
        headers: {'Content-Type': 'application/json'},
      );
      if (kDebugMode) debugPrint('✅ Toutes les notifications marquées comme lues');
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Erreur marquage global: $e');
    }
  }

  // 🆕 NOUVEAU : Nettoyage des ressources
  void dispose() {
    stopListening();
  }
}
