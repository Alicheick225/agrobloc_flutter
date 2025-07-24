import 'package:flutter/material.dart';
import '../widgets/auth/widgetAuth.dart';
import 'login.dart';
import 'select_profile.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/authService.dart';

/// Page d'inscription permettant à l'utilisateur de créer un compte avec un profil
class SignUpPage extends StatefulWidget {
  final String profile;
  const SignUpPage({super.key, required this.profile});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

/// État de la page d'inscription gérant les contrôleurs et la logique d'inscription
class _SignUpPageState extends State<SignUpPage> {
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool _obscurePassword = true; // Contrôle la visibilité du mot de passe
  bool _obscureConfirmPassword = true; // Contrôle la visibilité du mot de passe de confirmation
  bool _isLoading = false; // Indique si une opération d'inscription est en cours

  final AuthService _authService = AuthService();

  /// Bascule la visibilité du mot de passe
  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  /// Bascule la visibilité du mot de passe de confirmation
  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  /// Effectue l'inscription de l'utilisateur avec les informations saisies
  Future<void> _signUp() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Les mots de passe ne correspondent pas')),
      );
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      // Déterminer le profilId en fonction du profil sélectionné
      String profilId = '';
      if (widget.profile == 'acheteur') {
        profilId = 'b74a4f6-67b6-474a-9bf5-d63e04d2a804'; // ID acheteur exemple
      } else if (widget.profile == 'planteur') {
        profilId = 'f23423d4-ca9e-409b-b3fb-26126ab66581'; // ID planteur exemple
      }

      final user = await _authService.register(
        nom: fullNameController.text.trim(),
        email: widget.profile == 'acheteur' ? phoneController.text.trim() : null,
        numeroTel: widget.profile == 'planteur' ? phoneController.text.trim() : null,
        password: passwordController.text,
        confirmPassword: confirmPasswordController.text,
        profilId: profilId,
      );
      // Affiche un message de bienvenue en cas de succès
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bienvenue, ${user.nom}! Inscription réussie.')),
      );
      // Navigue vers la page de connexion avec pré-remplissage des champs
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(
            profile: widget.profile,
            prefillIdentifiant: phoneController.text.trim(),
            prefillPassword: passwordController.text,
          ),
        ),
      );
    } catch (e) {
      // Affiche un message d'erreur en cas d'échec
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'inscription: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Construit l'interface utilisateur de la page d'inscription
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inscription'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigue vers la page de sélection de profil
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => SelectProfilePage()),
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
              // Champ de saisie pour le nom complet
              customTextField(
                icon: Icons.person,
                hintText: "Nom complet",
                controller: fullNameController,
              ),
              const SizedBox(height: 16),
              // Champ de saisie pour l'email ou le numéro de téléphone selon le profil
              widget.profile == 'acheteur'
                  ? customTextField(
                      icon: Icons.email,
                      hintText: "Email",
                      controller: phoneController,
                      keyboardType: TextInputType.emailAddress,
                    )
                  : customTextField(
                      icon: Icons.phone,
                      hintText: "Numéro de téléphone",
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                    ),
              const SizedBox(height: 16),
              // Champ de saisie pour le mot de passe avec visibilité contrôlable
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
                      VerticalDivider(
                        color: Colors.green,
                        thickness: 1,
                        width: 1,
                      ),
                      SizedBox(width: 8),
                    ],
                  ),
                  hintText: "Mot de passe",
                  hintStyle: const TextStyle(color: Colors.grey),
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
              // Champ de saisie pour la confirmation du mot de passe avec visibilité contrôlable
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
                      VerticalDivider(
                        color: Colors.green,
                        thickness: 1,
                        width: 1,
                      ),
                      SizedBox(width: 8),
                    ],
                  ),
                  hintText: "Confirmer mot de passe",
                  hintStyle: const TextStyle(color: Colors.grey),
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
              // Bouton d'inscription ou indicateur de chargement
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : customButton("inscription", _signUp),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () {
                    // Navigue vers la page de connexion
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage(profile: widget.profile)),
                    );
                  },
                  child: const Text(
                    "Vous avez déjà un compte ? Connectez-vous !",
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
