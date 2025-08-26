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
    if (hasStoredData) {
      await userService.loadUser();
    }
  } catch (e) {
    debugPrint('⚠️ Erreur UserService: $e');
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
      // 🔹 Si c’est le premier lancement, on affiche SelectProfilePage
      home: widget.isFirstLaunch ? const SelectProfilePage() : const LoginPage(profile: 'acheteur'), // Ensure correct access
      routes: {
        '/homePage': (context) => const HomePage(acheteurId: 'acheteur'),
        '/homeProducteur': (context) => const HomePoducteur(),
        '/login': (context) => const LoginPage(profile: 'acheteur'),
      },
    );
  }

  @override
  void dispose() {
    _notificationService.dispose();
    super.dispose();
  }
}
