import 'package:agrobloc/core/feactures/Agrobloc/presentations/pages/homePage.dart';
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
      title: 'Mon App Clean Archi',
      theme: ThemeData(
        primaryColor: const Color(0xFF5d9643), // AppColors.primary
        fontFamily: 'Poppins',
      ),
      home: const HomePage()
    );
  }
}
