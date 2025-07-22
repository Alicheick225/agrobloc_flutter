import 'package:flutter/material.dart';
import '../widgets/auth/widgetAuth.dart';
import 'login.dart';

class SignUpPage extends StatelessWidget {
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              const Center(
                child: Text(
                  "Créer un compte",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  "Rejoignez notre équipe en quelques clics,\ncréez votre compte et débutez l’aventure",
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              customTextField(
                icon: Icons.person,
                hintText: "Nom complet",
                controller: fullNameController,
              ),
              const SizedBox(height: 16),
              customTextField(
                icon: Icons.phone,
                hintText: "Numéro de téléphone",
                controller: phoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              customTextField(
                icon: Icons.lock,
                hintText: "Mot de passe",
                controller: passwordController,
                obscureText: true,
              ),
              const SizedBox(height: 16),
              customTextField(
                icon: Icons.lock,
                hintText: "Confirmer mot de passe",
                controller: confirmPasswordController,
                obscureText: true,
              ),
              const SizedBox(height: 24),
              customButton("inscription", () {
                // TODO: implement sign-up logic
              }),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  child: const Text("Vous avez déjà un compte ? Connectez-vous !"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
