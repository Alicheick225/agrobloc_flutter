import 'package:agrobloc/core/features/Agrobloc/presentations/pages/select_profile.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/pages/homePage.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/pages/login.dart';
// import 'package:agrobloc/core/features/Agrobloc/presentations/pages/register.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Agrobloc',
        theme: ThemeData(
          primaryColor: const Color(0xFF5d9643), // AppColors.primary
          fontFamily: 'Poppins',
        ),
        home: SelectProfilePage(),
        routes: {
          '/homePage': (context) => const HomePage(),
          '/login': (context) => const LoginPage(profile: 'acheteur'), // default profile example
          // Add other routes as needed
        },
      );
  }
}
