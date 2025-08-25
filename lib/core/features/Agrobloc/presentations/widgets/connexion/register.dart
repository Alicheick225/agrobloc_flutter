import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';
import 'select_profile.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/authService.dart';
import 'widgetAuth.dart';

/// Page d'inscription permettant à l'utilisateur de créer un compte avec un profil
class SignUpPage extends StatefulWidget {
  final String profile;
  const SignUpPage({super.key, required this.profile});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  final AuthService _authService = AuthService();

  void _togglePasswordVisibility() {
    setState(() { _obscurePassword = !_obscurePassword; });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() { _obscureConfirmPassword = !_obscureConfirmPassword; });
  }

  Future<void> _signUp() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Les mots de passe ne correspondent pas')),
      );
      return;
    }

    // Validation des champs selon le profil
    if ((widget.profile == 'acheteur' || widget.profile == 'cooperative') &&
        emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez saisir un email valide')),
      );
      return;
    }
    if (widget.profile == 'planteur' && phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez saisir un numéro valide')),
      );
      return;
    }

    setState(() { _isLoading = true; });

    try {
      // Déterminer le profilId en fonction du profil
      String profilId = '';
      if (widget.profile == 'acheteur') {
        profilId = '7b74a4f6-67b6-474a-9bf5-d63e04d2a804';
      } else if (widget.profile == 'cooperative') {
        profilId = '35a3c32a-17f8-4771-a0d8-9295b1bc5917';
      } else if (widget.profile == 'planteur') {
        profilId = 'f23423d4-ca9e-409b-b3fb-26126ab66581';
      }

      final user = await _authService.register(
        nom: fullNameController.text.trim(),
        email: (widget.profile == 'acheteur' || widget.profile == 'cooperative')
            ? emailController.text.trim()
            : null,
        numeroTel: widget.profile == 'planteur' ? phoneController.text.trim() : null,
        password: passwordController.text,
        confirmPassword: confirmPasswordController.text,
        profilId: profilId,
      );

      // Marque que l'utilisateur a déjà utilisé la page d'inscription
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isFirstLaunch', false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bienvenue, ${user.nom}! Inscription réussie.')),
      );

      // Redirection vers LoginPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(
            profile: widget.profile,
            prefillIdentifiant: (widget.profile == 'acheteur' || widget.profile == 'cooperative')
                ? emailController.text.trim()
                : phoneController.text.trim(),
            prefillPassword: passwordController.text,
          ),
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'inscription: $e')),
      );
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inscription'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SelectProfilePage()),
            );
          },
        ),
      ),
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

              (widget.profile == 'acheteur' || widget.profile == 'cooperative')
                  ? customTextField(
                      icon: Icons.email,
                      hintText: "Email",
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                    )
                  : customTextField(
                      icon: Icons.phone,
                      hintText: "Numéro de téléphone",
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                    ),
              const SizedBox(height: 16),

              TextFormField(
                controller: passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  prefixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      SizedBox(width: 8),
                      Icon(Icons.lock, color: Colors.green),
                      SizedBox(width: 8),
                      VerticalDivider(color: Colors.green, thickness: 1, width: 1),
                      SizedBox(width: 8),
                    ],
                  ),
                  hintText: "Mot de passe",
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.green, width: 2),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.green,
                    ),
                    onPressed: _togglePasswordVisibility,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  prefixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      SizedBox(width: 8),
                      Icon(Icons.lock, color: Colors.green),
                      SizedBox(width: 8),
                      VerticalDivider(color: Colors.green, thickness: 1, width: 1),
                      SizedBox(width: 8),
                    ],
                  ),
                  hintText: "Confirmer mot de passe",
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.green, width: 2),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.green,
                    ),
                    onPressed: _toggleConfirmPasswordVisibility,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : customButton("Inscription", _signUp),

              const SizedBox(height: 16),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Vous avez déjà un compte ?"),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginPage(profile: widget.profile),
                          ),
                        );
                      },
                      child: const Text(
                        "Connectez-vous !",
                        style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
