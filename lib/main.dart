import 'package:agrobloc/core/features/Agrobloc/presentations/pagesProducteurs/homeProducteur.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/connexion/select_profile.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/pagesAcheteurs/homePage.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/connexion/login.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/layout/parametre.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

  @override
  void initState() {
    super.initState();
    _modeSombre = widget.modeSombreInitial;
  }

  // Fonction appelée depuis la page paramètres
  void _changerTheme(bool val) async {
    setState(() {
      _modeSombre = val;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('modeSombre', val);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Agrobloc',
      theme: _modeSombre
          ? ThemeData.dark().copyWith(
              primaryColor: const Color(0xFF5d9643),
            )
          : ThemeData.light().copyWith(
              primaryColor: const Color(0xFF5d9643),
            ),
      home: SelectProfilePage(),
      routes: {
            '/homePage': (context) => const HomePage(
                  acheteurId: 'acheteur',
                  profile: 'acheteur',
                ),
            '/homePoducteur': (context) => const HomePoducteur(),
            '/login': (context) => const LoginPage(profile: 'acheteur'),
            '/parametres': (context) => ParametresPage(
                  onThemeChanged: _changerTheme,
                  modeSombreActuel: _modeSombre,
                ),
          },

    );
  }
}
