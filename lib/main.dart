// lib/main.dart

import 'package:agrobloc/core/features/Agrobloc/presentations/pagesProducteurs/homeProducteur.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agrobloc/core/features/Agrobloc/data/dataSources/notificationService.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/userService.dart';

import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/connexion/select_profile.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/pagesAcheteurs/homePage.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/connexion/login.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/producteurs/homes/detailOffreVente.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/AnnonceAchatModel.dart';

// Importez les classes nécessaires pour les routes manquantes
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/connexion/login.dart'; 
// Si vous avez des pages de login distinctes, importez-les ici.
// import 'package:agrobloc/core/features/Agrobloc/presentations/pagesProducteurs/loginProducteurPage.dart';
// import 'package:agrobloc/core/features/Agrobloc/presentations/pagesAcheteurs/loginAcheteurPage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  bool modeSombreInitial = prefs.getBool('modeSombre') ?? false;
  bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
  if (isFirstLaunch) {
    await prefs.setBool('isFirstLaunch', false);
  }

  try {
    await NotificationService().initializePushNotifications();
    debugPrint('✅ Notifications initialisées');
  } catch (e) {
    debugPrint('❌ Erreur notifications: $e');
  }

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

    userService.setForceReLoginCallback(() async {
      debugPrint('🔄 main() - Callback de reconnexion forcée déclenché');
      try {
        await userService.clearCurrentUser();
        debugPrint('✅ main() - Session utilisateur nettoyée');
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
    isFirstLaunch: isFirstLaunch,
  ));
}

class MyApp extends StatefulWidget {
  final bool modeSombreInitial;
  final bool isFirstLaunch;

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
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          Widget homePage;

          if (_forceLogin) {
            debugPrint('🔄 MyApp - Navigation forcée vers la page de connexion');
            homePage = const LoginPage(profile: 'producteur');
          } else if (widget.isFirstLaunch) {
            homePage = const SelectProfilePage();
          } else {
            final isAuthenticated = snapshot.data ?? false;
            final userService = UserService();

            if (isAuthenticated && userService.currentUser != null) {
              final profileId = userService.currentUser!.profilId;
              if (profileId == 'producteur' || profileId == 'f23423d4-ca9e-409b-b3fb-26126ab66581') {
                homePage = const HomeProducteur();
              } else {
                homePage = const HomePage(acheteurId: 'acheteur');
              }
              debugPrint('✅ MyApp - Utilisateur authentifié: ${userService.currentUser!.nom} (${profileId})');
            } else {
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
        // 🌟 Ajout des routes de connexion spécifiques pour chaque profil
        '/loginProducteur': (context) => const LoginPage(profile: 'producteur'),
        '/loginAcheteur': (context) => const LoginPage(profile: 'acheteur'),
        '/detailOffreVente': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as AnnonceAchat;
          return DetailOffreVente(annonce: args);
        },
      },
    );
  }

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