// lib/core/features/Agrobloc/presentations/widgets/connexion/login.dart

import 'package:flutter/material.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/authService.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/connexion/forgot_password.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/connexion/register.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/connexion/widgetAuth.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/userService.dart';

/// Page de connexion permettant à l'utilisateur de se connecter avec son profil
class LoginPage extends StatefulWidget {
  final String profile;
  final String? prefillIdentifiant; // email ou téléphone
  final String? prefillPassword; // mot de passe

  const LoginPage({
    super.key,
    required this.profile,
    this.prefillIdentifiant,
    this.prefillPassword,
  });

  static const Map<String, String> profilIdToName = {
    'f23423d4-ca9e-409b-b3fb-26126ab66581': 'producteur',
    '7b74a4f6-67b6-474a-9bf5-d63e04d2a804': 'cooperative',
    '35a3c32a-17f8-4771-a0d8-9295b1bc5917': 'acheteur',
  };

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController emailController;
  late final TextEditingController phoneController;
  final passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _rememberMe = false;
  late String internalProfile;

  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  bool get isPrefillEmail {
    if (widget.prefillIdentifiant == null) return false;
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(widget.prefillIdentifiant!);
  }

  @override
  void initState() {
    super.initState();
    internalProfile = widget.profile == 'planteur' ? 'producteur' : widget.profile;

    if (isPrefillEmail) {
      emailController = TextEditingController(text: widget.prefillIdentifiant ?? '');
      phoneController = TextEditingController(text: '');
    } else {
      emailController = TextEditingController(text: '');
      phoneController = TextEditingController(text: widget.prefillIdentifiant ?? '');
    }

    if (widget.prefillPassword != null) {
      passwordController.text = widget.prefillPassword!;
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final identifier = (['acheteur', 'cooperative'].contains(internalProfile))
          ? emailController.text.trim()
          : phoneController.text.trim();

      // 🌟 Utilisation de l'AuthService pour la connexion
      final user = await _authService.login(identifier, passwordController.text, rememberMe: _rememberMe);

      // 🌟 Utilisation de l'UserService pour le stockage local et la redirection
      await _userService.storeUser(user, rememberMe: _rememberMe);

      // 🌟 Redirection basée sur le profil (en utilisant les routes nommées)
      switch (user.profilId) {
        case '7b74a4f6-67b6-474a-9bf5-d63e04d2a804': // Cooperative
        case '35a3c32a-17f8-4771-a0d8-9295b1bc5917': // Acheteur
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/homePage');
          }
          break;
        case 'f23423d4-ca9e-409b-b3fb-26126ab66581': // Producteur
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/homeProducteur');
          }
          break;
        default:
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Profil utilisateur inconnu : ${user.profilId}")),
            );
          }
      }
    } catch (e) {
      String errorMessage = 'Erreur de connexion';
      final errorString = e.toString();
      if (errorString.contains('Erreur de connexion:')) {
        errorMessage = errorString.replaceFirst('Exception: ', '');
      } else if (errorString.contains('Erreur d\'authentification:')) {
        errorMessage = errorString.replaceFirst('Exception: ', '');
      } else {
        errorMessage = 'Erreur de connexion: ${errorString.replaceFirst('Exception: ', '')}';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
      debugPrint('❌ Erreur de connexion détaillée: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool showEmailInput = (widget.profile == 'acheteur' || widget.profile == 'cooperative' || isPrefillEmail);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.4,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        "assets/images/connexion.jpeg",
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: ClipPath(
                        clipper: _CustomClipperShape(),
                        child: Container(height: 50, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Text("Se connecter", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                    const SizedBox(height: 8),
                    const Text("Heureux de vous revoir !"),
                    const SizedBox(height: 16),
                    showEmailInput
                        ? customTextField(
                            icon: Icons.email,
                            hintText: "Email",
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Veuillez saisir un email';
                              final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                              if (!emailRegex.hasMatch(value)) return 'Veuillez saisir un email valide';
                              return null;
                            },
                          )
                        : customTextField(
                            icon: Icons.phone,
                            hintText: "Numéro de téléphone",
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Veuillez saisir un numéro';
                              final phoneRegex = RegExp(r'^\d{8,}$');
                              if (!phoneRegex.hasMatch(value)) return 'Veuillez saisir un numéro valide';
                              return null;
                            },
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
                        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.green)),
                        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.green, width: 2)),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.green),
                          onPressed: _togglePasswordVisibility,
                        ),
                      ),
                      validator: (value) => (value == null || value.isEmpty) ? 'Veuillez saisir un mot de passe' : null,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(value: _rememberMe, onChanged: (val) => setState(() => _rememberMe = val ?? false)),
                            const Text("Se souvenir de moi"),
                          ],
                        ),
                        TextButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ForgotPasswordPage())),
                          child: const Text("mot de passe oublié ?", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _isLoading ? const CircularProgressIndicator() : customButton("Se connecter", _login),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SignUpPage(profile: widget.profile))),
                      child: const Text("Inscrivez-vous ici !", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
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

class _CustomClipperShape extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, 20);
    path.quadraticBezierTo(size.width / 2, -20, size.width, 20);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}