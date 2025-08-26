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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  bool modeSombreInitial = prefs.getBool('modeSombre') ?? false;

  try {
    await NotificationService().initializePushNotifications();
    debugPrint('✅ Service de notifications initialisé avec succès');
  } catch (e) {
    debugPrint('❌ Erreur lors de l\'initialisation des notifications: $e');
  }

  try {
    final userService = UserService();
    final hasStoredData = await userService.hasStoredUserData();

    if (hasStoredData) {
      final loaded = await userService.loadUser();
      if (loaded) {
        debugPrint('✅ UserService initialisé avec succès - Utilisateur connecté');
      } else {
        debugPrint('ℹ️ UserService: données utilisateur invalides ou problème de connexion');
      }
    } else {
      debugPrint('ℹ️ UserService: aucune donnée utilisateur trouvée - première utilisation');
    }
  } catch (e) {
    debugPrint('⚠️ Erreur lors de l\'initialisation du UserService: $e');
  }

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
  final NotificationService _notificationService = NotificationService();
  bool _isNotificationInitialized = false;

  @override
  void initState() {
    super.initState();
    _modeSombre = widget.modeSombreInitial;
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? currentUserId = prefs.getString('currentUserId');

      if (currentUserId != null) {
        final registered = await _notificationService.registerDeviceToken(currentUserId);
        if (registered) {
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

  Future<void> initializeNotificationsForUser(String userId) async {
    try {
      final registered = await _notificationService.registerDeviceToken(userId);
      if (registered) {
        await _notificationService.startListening(userId: userId);
        setState(() {
          _isNotificationInitialized = true;
        });
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('currentUserId', userId);
        debugPrint('✅ Notifications activées pour l\'utilisateur: $userId');
      }
    } catch (e) {
      debugPrint('❌ Erreur activation notifications: $e');
    }
  }

  void _changerTheme(bool val) async {
    setState(() {
      _modeSombre = val;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('modeSombre', val);
  }

  @override
  void dispose() {
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
        '/homeProducteur': (context) => const HomeProducteur(),
        '/loginAcheteur': (context) => const LoginPage(profile: 'acheteur'),
        '/loginProducteur': (context) => const LoginPage(profile: 'producteur'),
      },
    );
  }
}

extension NotificationExtension on BuildContext {
  Future<void> initializeUserNotifications(String userId) async {
    final appState = findAncestorStateOfType<_MyAppState>();
    if (appState != null) {
      await appState.initializeNotificationsForUser(userId);
    }
  }
}
