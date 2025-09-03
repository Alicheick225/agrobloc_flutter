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
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  bool modeSombreInitial = prefs.getBool('modeSombre') ?? false;
  bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true; // 🔹 Nouveau
  if (isFirstLaunch) {
    await prefs.setBool('isFirstLaunch', false); // Set to false after first launch
  }

  // Initialisation notifications
  try {
    await NotificationService().initializePushNotifications();
    debugPrint('✅ Notifications initialisées');
  } catch (e) {
    debugPrint('❌ Erreur notifications: $e');
  }

  // Initialisation UserService
  try {
    final userService = UserService();
    final hasStoredData = await userService.hasStoredUserData();
    debugPrint('🔍 main() - Données utilisateur stockées: $hasStoredData');

    if (hasStoredData) {
      debugPrint('🔍 main() - Tentative de chargement de l\'utilisateur depuis le stockage...');
      final success = await userService.loadUser();
      if (success) {
        debugPrint('✅ main() - Utilisateur chargé avec succès depuis le stockage');
        debugPrint('🔍 main() - Utilisateur connecté: ${userService.currentUser?.nom} (${userService.currentUser?.profilId})');
      } else {
        debugPrint('❌ main() - Échec du chargement de l\'utilisateur depuis le stockage');
        debugPrint('ℹ️ main() - L\'application démarrera sur la page de connexion');
      }
    } else {
      debugPrint('ℹ️ main() - Aucune donnée utilisateur stockée trouvée');
      debugPrint('ℹ️ main() - L\'application démarrera sur la page de connexion');
    }
  } catch (e, stackTrace) {
    debugPrint('❌ main() - Erreur lors de l\'initialisation UserService: $e');
    debugPrint('❌ main() - Stack trace: $stackTrace');
    debugPrint('🔄 main() - Nettoyage automatique de toute session invalide');
    try {
      await UserService().clearCurrentUser();
    } catch (clearError) {
      debugPrint('❌ main() - Erreur lors du nettoyage: $clearError');
    }
  }

  runApp(MyApp(
    modeSombreInitial: modeSombreInitial,
    isFirstLaunch: isFirstLaunch, // 🔹 Passage du flag
  ));
}

class MyApp extends StatefulWidget {
  final bool modeSombreInitial;
  final bool isFirstLaunch; // 🔹 Nouveau

  const MyApp({super.key, required this.modeSombreInitial, required this.isFirstLaunch});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool _modeSombre;
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _modeSombre = widget.modeSombreInitial;
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    String? currentUserId = prefs.getString('currentUserId');
    if (currentUserId != null) {
      await _notificationService.registerDeviceToken(currentUserId);
      await _notificationService.startListening(userId: currentUserId);
      debugPrint('✅ Notifications activées pour $currentUserId');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Agrobloc',
      theme: ThemeData.light().copyWith(
        primaryColor: const Color(0xFF5d9643),
        scaffoldBackgroundColor: Colors.white,
      ),
      // 🔹 Si c'est le premier lancement, on affiche SelectProfilePage
      home: widget.isFirstLaunch ? const SelectProfilePage() : const LoginPage(profile: 'producteur'), // Ensure correct access
      routes: {
        '/homePage': (context) => const HomePage(acheteurId: 'acheteur'),
        '/homeProducteur': (context) => const HomeProducteur(),
        '/login': (context) => const LoginPage(profile: 'producteur'),
      },
    );
  }

  @override
  void dispose() {
    _notificationService.dispose();
    super.dispose();
  }
}
