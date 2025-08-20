import 'package:agrobloc/core/features/Agrobloc/presentations/pagesProducteurs/homeProducteur.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 🆕 NOUVEAU : Import du service de notifications
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/notificationService.dart';

import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/connexion/select_profile.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/pagesAcheteurs/homePage.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/connexion/login.dart';
// ignore: unused_import
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/layout/parametre.dart';

// 🆕 MODIFIÉ : Fonction main avec initialisation des notifications
Future<void> main() async {
  // 🆕 NOUVEAU : Assurer l'initialisation des widgets
  WidgetsFlutterBinding.ensureInitialized();
  
  // 🆕 NOUVEAU : Initialiser le service de notifications au démarrage
  try {
    await NotificationService().initializePushNotifications();
    debugPrint('✅ Service de notifications initialisé avec succès');
  } catch (e) {
    debugPrint('❌ Erreur lors de l\'initialisation des notifications: $e');
  }
  
  // Récupération des préférences existantes
  final prefs = await SharedPreferences.getInstance();
  bool modeSombreInitial = prefs.getBool('modeSombre') ?? false;

  runApp(MyApp(modeSombreInitial: modeSombreInitial));
}

class MyApp extends StatefulWidget {
  final bool modeSombreInitial;

  const MyApp({super.key, required this.modeSombreInitial});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool _modeSombre;
  // 🆕 NOUVEAU : Instance du service de notifications
  final NotificationService _notificationService = NotificationService();
  bool _isNotificationInitialized = false;

  @override
  void initState() {
    super.initState();
    _modeSombre = widget.modeSombreInitial;
    // 🆕 NOUVEAU : Initialiser les notifications pour l'utilisateur
    _initializeNotifications();
  }

  // 🆕 NOUVEAU : Initialiser les notifications
  Future<void> _initializeNotifications() async {
    try {
      // Vous pouvez récupérer l'ID utilisateur depuis SharedPreferences ou votre système d'auth
      final prefs = await SharedPreferences.getInstance();
      String? currentUserId = prefs.getString('currentUserId');
      
      if (currentUserId != null) {
        // Enregistrer le token de l'utilisateur
        final registered = await _notificationService.registerDeviceToken(currentUserId);
        
        if (registered) {
          // Démarrer l'écoute des notifications
          await _notificationService.startListening(userId: currentUserId);
          
          setState(() {
            _isNotificationInitialized = true;
          });
          
          debugPrint('✅ Notifications push activées pour l\'utilisateur: $currentUserId');
        }
      } else {
        debugPrint('⚠️ Aucun utilisateur connecté, notifications en attente');
      }
    } catch (e) {
      debugPrint('❌ Erreur initialisation notifications utilisateur: $e');
    }
  }

  // 🆕 NOUVEAU : Fonction pour initialiser les notifications après connexion
  Future<void> initializeNotificationsForUser(String userId) async {
    try {
      final registered = await _notificationService.registerDeviceToken(userId);
      
      if (registered) {
        await _notificationService.startListening(userId: userId);
        
        setState(() {
          _isNotificationInitialized = true;
        });
        
        // Sauvegarder l'ID utilisateur pour la prochaine ouverture
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('currentUserId', userId);
        
        debugPrint('✅ Notifications activées pour l\'utilisateur: $userId');
      }
    } catch (e) {
      debugPrint('❌ Erreur activation notifications: $e');
    }
  }

  // Fonction existante pour changer le thème
  void _changerTheme(bool val) async {
    setState(() {
      _modeSombre = val;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('modeSombre', val);
  }

  @override
  void dispose() {
    // 🆕 NOUVEAU : Nettoyer les ressources
    _notificationService.dispose();
    super.dispose();
  }

 @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Agrobloc',
      theme: ThemeData.light().copyWith(
        primaryColor: const Color(0xFF5d9643),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF5d9643),
          foregroundColor: Colors.white,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF5d9643),
          unselectedItemColor: Colors.grey,
        ),
      ),
      home: const SelectProfilePage(),
      routes: {
        '/homePage': (context) => const HomePage(
              acheteurId: 'acheteur',
              profile: 'acheteur',
            ),
        '/homePoducteur': (context) => const HomePoducteur(),
        '/login': (context) => const LoginPage(profile: 'acheteur'),
      },
    );
  }
}


// 🆕 NOUVEAU : Extension pour accéder au service de notifications depuis n'importe où
extension NotificationExtension on BuildContext {
  Future<void> initializeUserNotifications(String userId) async {
    final appState = findAncestorStateOfType<_MyAppState>();
    if (appState != null) {
      await appState.initializeNotificationsForUser(userId);
    }
  }
}

