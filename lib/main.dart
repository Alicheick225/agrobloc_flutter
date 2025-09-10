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

// 🆕 AJOUT : Imports pour la route detailOffreVente
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/producteurs/homes/detailOffreVente.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/AnnonceAchatModel.dart';

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
    // debugPrint('✅ Notifications initialisées');
  } catch (e) {
    // debugPrint('❌ Erreur notifications: $e');
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

    // Set up force re-login callback for session expiry handling
    userService.setForceReLoginCallback(() async {
      debugPrint('🔄 main() - Callback de reconnexion forcée déclenché');
      try {
        // Clear current user session
        await userService.clearCurrentUser();
        debugPrint('✅ main() - Session utilisateur nettoyée');

        // The navigation will be handled by the widget tree when tokens become invalid
        // This callback ensures cleanup happens when refresh fails
      } catch (e) {
        debugPrint('❌ main() - Erreur lors du nettoyage de session dans callback: $e');
      }
    });
    debugPrint('✅ main() - Callback de reconnexion forcée configuré');

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
  bool _forceLogin = false;

  @override
  void initState() {
    super.initState();
    _modeSombre = widget.modeSombreInitial;
    _initializeNotifications();
    _setupAuthStateListener();
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

  void _setupAuthStateListener() {
    // Listen for authentication state changes
    // This will be triggered when tokens become invalid
    final userService = UserService();
    userService.setForceReLoginCallback(() async {
      debugPrint('🔄 MyApp - Callback de reconnexion forcée reçu');
      if (mounted) {
        setState(() {
          _forceLogin = true;
        });
      }
    });
  }

  // Method to reset authentication state (can be called after successful login)
  void resetAuthState() {
    if (mounted) {
      setState(() {
        _forceLogin = false;
      });
      debugPrint('✅ MyApp - État d\'authentification réinitialisé');
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
      home: FutureBuilder<bool>(
        future: _getAuthenticationStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show loading screen while checking authentication
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          // Determine which page to show based on authentication state
          Widget homePage;

          if (_forceLogin) {
            // Force navigation to login page when session expires
            debugPrint('🔄 MyApp - Navigation forcée vers la page de connexion');
            homePage = const LoginPage(profile: 'producteur');
          } else if (widget.isFirstLaunch) {
            // First launch - show profile selection
            homePage = const SelectProfilePage();
          } else {
            // Check authentication result from FutureBuilder
            final isAuthenticated = snapshot.data ?? false;
            final userService = UserService();

            if (isAuthenticated && userService.currentUser != null) {
              // User is authenticated - show appropriate home page
              final profileId = userService.currentUser!.profilId;
              if (profileId == 'producteur' || profileId == 'f23423d4-ca9e-409b-b3fb-26126ab66581') {
                homePage = const HomeProducteur();
              } else {
                homePage = const HomePage(acheteurId: 'acheteur');
              }
              debugPrint('✅ MyApp - Utilisateur authentifié: ${userService.currentUser!.nom} (${profileId})');
            } else {
              // Not authenticated - show login page
              debugPrint('ℹ️ MyApp - Utilisateur non authentifié - affichage page de connexion');
              homePage = const LoginPage(profile: 'producteur');
            }
          }

          return homePage;
        },
      ),
      routes: {
        '/homePage': (context) => const HomePage(acheteurId: 'acheteur'),
        '/homeProducteur': (context) => const HomeProducteur(),
        '/login': (context) => const LoginPage(profile: 'producteur'),
        '/detailOffreVente': (context) {
          final args = ModalRoute.of(context)!.settings.arguments;
          return DetailOffreVente(annonce: args);
        },
      },
    );
  }

  /// Get authentication status with proper token validation
  Future<bool> _getAuthenticationStatus() async {
    final userService = UserService();
    return await userService.isUserAuthenticated();
  }

  @override
  void dispose() {
    _notificationService.dispose();
    super.dispose();
  }
}
