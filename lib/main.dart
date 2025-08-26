import 'package:agrobloc/core/features/Agrobloc/presentations/pagesProducteurs/homeProducteur.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 🆕 NOUVEAU : Import du service de notifications
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/notificationService.dart';
// 🆕 NOUVEAU : Import du UserService
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/userService.dart';

import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/connexion/select_profile.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/pagesAcheteurs/homePage.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/connexion/login.dart';
// ignore: unused_import
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/layout/parametre.dart';

// 🆕 MODIFIÉ : Fonction main avec initialisation des notifications et UserService
Future<void> main() async {
  // 🆕 NOUVEAU : Assurer l'initialisation des widgets
  WidgetsFlutterBinding.ensureInitialized();
  
  // Récupération des préférences existantes
  final prefs = await SharedPreferences.getInstance();
  bool modeSombreInitial = prefs.getBool('modeSombre') ?? false;

  // 🆕 NOUVEAU : Initialiser le service de notifications au démarrage
  try {
    await NotificationService().initializePushNotifications();
    debugPrint('✅ Service de notifications initialisé avec succès');
  } catch (e) {
    debugPrint('❌ Erreur lors de l\'initialisation des notifications: $e');
  }

  // 🆕 NOUVEAU : Logique de routage initial
  String initialRoute = '/'; // Route par défaut
  
  try {
    final userService = UserService();
    final hasStoredData = await userService.hasStoredUserData();
    
    if (hasStoredData) {
      final loaded = await userService.loadUser();
      if (loaded) {
        // L'utilisateur est connecté, on détermine son profil
        final storedProfileId = await userService.getStoredProfileId();
        if (storedProfileId == 'f23423d4-ca9e-409b-b3fb-26126ab66581') {
          initialRoute = '/homeProducteur';
        } else if (storedProfileId == '7b74a4f6-67b6-474a-9bf5-d63e04d2a804') {
          initialRoute = '/homeAcheteur';
        } else {
          initialRoute = '/';
        }
        debugPrint('✅ Utilisateur connecté. Redirection vers : $initialRoute');
      } else {
        debugPrint('ℹ️ UserService: données utilisateur invalides ou problème de connexion');
        debugPrint('ℹ️ Redirection vers l\'écran de connexion nécessaire');
        initialRoute = '/';
      }
    } else {
      debugPrint('ℹ️ UserService: aucune donnée utilisateur trouvée - première utilisation');
      debugPrint('ℹ️ Redirection vers l\'écran de sélection de profil');
      initialRoute = '/';
    }
  } catch (e) {
    debugPrint('⚠️ Erreur lors de l\'initialisation du UserService: $e');
    debugPrint('ℹ️ L\'application continue avec l\'utilisateur déconnecté');
    initialRoute = '/';
  }

  runApp(MyApp(
    modeSombreInitial: modeSombreInitial,
    initialRoute: initialRoute, // Passe la route initiale à l'application
  ));
}

class MyApp extends StatefulWidget {
  final bool modeSombreInitial;
  final String initialRoute; // 🆕 NOUVEAU : Propriété pour la route initiale

  const MyApp({super.key, required this.modeSombreInitial, required this.initialRoute});

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
      final userService = UserService(); // Utilisez le Singleton
      String? currentUserId = userService.userId;
      
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
      theme: _modeSombre
          ? ThemeData.dark().copyWith(
              primaryColor: const Color(0xFF5d9643),
              scaffoldBackgroundColor: const Color(0xFF121212),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF5d9643),
                foregroundColor: Colors.white,
              ),
              bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                backgroundColor: Color(0xFF121212),
                selectedItemColor: const Color(0xFF5d9643),
                unselectedItemColor: Colors.grey,
              ),
            )
          : ThemeData.light().copyWith(
              primaryColor: const Color(0xFF5d9643),
              scaffoldBackgroundColor: Colors.white,
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF5d9643),
                foregroundColor: Colors.white,
              ),
              bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                backgroundColor: Colors.white,
                selectedItemColor: const Color(0xFF5d9643),
                unselectedItemColor: Colors.grey,
              ),
            ),
      // 🆕 MODIFIÉ : Utiliser la route initiale dynamique
      initialRoute: widget.initialRoute,
      routes: {
        '/': (context) => const SelectProfilePage(),
        '/loginAcheteur': (context) => const LoginPage(profile: 'acheteur'),
        '/loginProducteur': (context) => const LoginPage(profile: 'producteur'),
        '/homeAcheteur': (context) => const HomePage(
              acheteurId: 'acheteur',
              profile: 'acheteur',
            ),
        // ❌ CORRECTION : suppression de 'const' pour HomeProducteur
        '/homeProducteur': (context) => const HomeProducteur(),
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
