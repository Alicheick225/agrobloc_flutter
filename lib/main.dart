import 'package:agrobloc/core/features/Agrobloc/presentations/pagesProducteurs/homeProducteur.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 🆕 Import Supabase
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabaseConfig.dart';

// 🆕 NOUVEAU : Import du service de notifications
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/notificationService.dart';
// 🆕 NOUVEAU : Import du UserService
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/userService.dart';

import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/connexion/select_profile.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/pagesAcheteurs/homePage.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/connexion/login.dart';
// ignore: unused_import
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/layout/parametre.dart';

// 🆕 AJOUT : Import ScreenUtil pour l'initialisation
import 'package:flutter_screenutil/flutter_screenutil.dart';

// 🆕 AJOUT : Imports pour la route detailOffreVente
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/producteurs/homes/detailOffreVente.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/AnnonceAchatModel.dart';

// 🆕 MODIFIÉ : Fonction main avec initialisation Supabase, notifications et UserService
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🟢 Initialisation Supabase
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );
  debugPrint('✅ Supabase initialisé');

  // 🆕 AJOUT : Initialisation ScreenUtil
  await ScreenUtil.ensureScreenSize();
  debugPrint('✅ ScreenUtil initialisé');

  final prefs = await SharedPreferences.getInstance();
  bool modeSombreInitial = prefs.getBool('modeSombre') ?? false;
  bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true; // 🔹 Nouveau
  if (isFirstLaunch) {
    await prefs.setBool(
        'isFirstLaunch', false); // Set to false after first launch
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
      debugPrint(
          '🔍 main() - Tentative de chargement de l\'utilisateur depuis le stockage...');
      final success = await userService.loadUser();
      if (success) {
        debugPrint(
            '✅ main() - Utilisateur chargé avec succès depuis le stockage');
        debugPrint(
            '🔍 main() - Utilisateur connecté: ${userService.currentUser?.nom} (${userService.currentUser?.profilId})');
      } else {
        debugPrint(
            '❌ main() - Échec du chargement de l\'utilisateur depuis le stockage');
        debugPrint(
            'ℹ️ main() - L\'application démarrera sur la page de connexion');
      }
    } else {
      debugPrint('ℹ️ main() - Aucune donnée utilisateur stockée trouvée');
      debugPrint(
          'ℹ️ main() - L\'application démarrera sur la page de connexion');
    }

    // Set up force re-login callback for session expiry handling
    userService.setForceReLoginCallback(() async {
      debugPrint('🔄 main() - Callback de reconnexion forcée déclenché');
      try {
        // Clear current user session
        await userService.clearCurrentUser();
        debugPrint('✅ main() - Session utilisateur nettoyée');

        // Navigate to appropriate login page based on user's profile
        final lastProfile = await userService.getLastProfile();
        final profileId = lastProfile ?? 'producteur';

        // Determine the correct login route based on profile
        String loginRoute;
        if (profileId == 'producteur' || profileId == 'f23423d4-ca9e-409b-b3fb-26126ab66581') {
          loginRoute = '/loginProducteur';
        } else if (profileId == 'acheteur' || profileId == '35a3c32a-17f8-4771-a0d8-9295b1bc5917') {
          loginRoute = '/loginAcheteur';
        } else if (profileId == 'cooperative' || profileId == '7b74a4f6-67b6-474a-9bf5-d63e04d2a804') {
          loginRoute = '/loginCooperative';
        } else {
          loginRoute = '/login';
        }

        // Navigate to the appropriate login page
        MyApp.navigatorKey.currentState?.pushNamedAndRemoveUntil(loginRoute, (route) => false);

        debugPrint('🔄 main() - Redirection vers la page de connexion: $loginRoute');

      } catch (e) {
        debugPrint(
            '❌ main() - Erreur lors du nettoyage de session dans callback: $e');
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

  const MyApp(
      {super.key,
      required this.modeSombreInitial,
      required this.isFirstLaunch});

  // Global navigator key for navigation from callbacks
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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
    final userService = UserService();
    userService.setForceReLoginCallback(() async {
      debugPrint('🔄 MyApp - Callback de reconnexion forcée reçu');
      if (mounted) {
        setState(() {
          _forceLogin = true;
        });
      }

      // Navigate to appropriate login page based on user's profile
      final lastProfile = await userService.getLastProfile();
      final profileId = lastProfile ?? 'producteur';

      // Determine the correct login route based on profile
      String loginRoute;
      if (profileId == 'producteur' || profileId == 'f23423d4-ca9e-409b-b3fb-26126ab66581') {
        loginRoute = '/loginProducteur';
      } else if (profileId == 'acheteur' || profileId == '35a3c32a-17f8-4771-a0d8-9295b1bc5917') {
        loginRoute = '/loginAcheteur';
      } else if (profileId == 'cooperative' || profileId == '7b74a4f6-67b6-474a-9bf5-d63e04d2a804') {
        loginRoute = '/loginCooperative';
      } else {
        loginRoute = '/login';
      }

      // Navigate to the appropriate login page
      MyApp.navigatorKey.currentState?.pushNamedAndRemoveUntil(loginRoute, (route) => false);
      debugPrint('🔄 MyApp - Redirection vers la page de connexion: $loginRoute');
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
  return ScreenUtilInit(
    designSize: const Size(375, 812), // iPhone X size as base
    minTextAdapt: true,
    splitScreenMode: true,
    builder: (context, child) {
      return MaterialApp(
        navigatorKey: MyApp.navigatorKey, // Add navigator key
        debugShowCheckedModeBanner: false,
        title: 'Agrobloc',
        theme: ThemeData.light().copyWith(
          primaryColor: const Color(0xFF5d9643),
          scaffoldBackgroundColor: Colors.white,
        ),
        home: FutureBuilder<Map<String, dynamic>>(
          future: _getAuthenticationStatus(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final data =
                snapshot.data ?? {'isAuthenticated': false, 'lastProfile': null};
            final isAuthenticated = data['isAuthenticated'] as bool;
            final lastProfile = data['lastProfile'] as String?;

            Widget homePage;

            if (_forceLogin) {
              homePage = LoginPage(profile: lastProfile ?? 'producteur');
            } else if (widget.isFirstLaunch) {
              homePage = const SelectProfilePage();
            } else {
              final userService = UserService();

              if (isAuthenticated && userService.currentUser != null) {
                final profileId = userService.currentUser!.profilId;
                if (profileId == 'producteur' ||
                    profileId == 'f23423d4-ca9e-409b-b3fb-26126ab66581') {
                  homePage = const HomeProducteur();
                } else {
                  homePage = const HomePage(acheteurId: 'acheteur');
                }
                debugPrint(
                    '✅ MyApp - Utilisateur authentifié: ${userService.currentUser!.nom} (${profileId})');
              } else {
                homePage = LoginPage(profile: lastProfile ?? 'producteur');
              }
            }

            return homePage;
          },
        ),
        routes: {
          '/homePage': (context) => const HomePage(acheteurId: 'acheteur'),
          '/homeProducteur': (context) => const HomeProducteur(),
          '/login': (context) => const LoginPage(profile: 'producteur'),
          '/loginProducteur': (context) => const LoginPage(profile: 'producteur'),
          '/loginAcheteur': (context) => const LoginPage(profile: 'acheteur'),
          '/loginCooperative': (context) => const LoginPage(profile: 'cooperative'),
          '/detailOffreVente': (context) {
            final args =
                ModalRoute.of(context)!.settings.arguments as AnnonceAchat;
            return DetailOffreVente(annonce: args);
          },
        },
      );
    },
  );
  }

  Future<Map<String, dynamic>> _getAuthenticationStatus() async {
    final userService = UserService();
    final isAuthenticated = await userService.isUserAuthenticated();
    final lastProfile = await userService.getLastProfile();
    return {
      'isAuthenticated': isAuthenticated,
      'lastProfile': lastProfile,
    };
  }

  @override
  void dispose() {
    _notificationService.dispose();
    super.dispose();
  }
}