import 'package:flutter/material.dart';
import 'forgot_password.dart';
import '../widgets/auth/widgetAuth.dart';
import 'register.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/authService.dart';

/// Page de connexion permettant à l'utilisateur de se connecter avec son profil
class LoginPage extends StatefulWidget {
  final String profile;
  final String? prefillIdentifiant; // email or phone to prefill
  final String? prefillPassword; // password to prefill

  const LoginPage({
    super.key,
    required this.profile,
    this.prefillIdentifiant,
    this.prefillPassword,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

/// État de la page de connexion gérant les contrôleurs et la logique de connexion
class _LoginPageState extends State<LoginPage> {
  late final TextEditingController emailController;
  final passwordController = TextEditingController();
  bool _obscurePassword = true; // Contrôle la visibilité du mot de passe
  bool _isLoading = false; // Indique si une opération de connexion est en cours
  bool _rememberMe = false; // État de la case "Se souvenir de moi"

  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    // Initialisation du contrôleur email avec pré-remplissage si profil acheteur
    emailController = TextEditingController(
      text: widget.prefillIdentifiant ?? '',
    );
    // Initialisation du contrôleur mot de passe avec pré-remplissage si fourni
    if (widget.prefillPassword != null) {
      passwordController.text = widget.prefillPassword!;
    }
  }

  /// Bascule la visibilité du mot de passe
  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  /// Valide les champs email/téléphone et mot de passe
  bool _validateInputs() {
    final emailOrPhone = emailController.text.trim();
    final password = passwordController.text;
    if (emailOrPhone.isEmpty || password.isEmpty) {
      return false;
    }
    // Validation simple pour email si profil acheteur
    if (widget.profile == 'acheteur') {
      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
      if (!emailRegex.hasMatch(emailOrPhone)) {
        return false;
      }
    } else {
      // Validation simple pour téléphone (chiffres uniquement, longueur minimale 8)
      final phoneRegex = RegExp(r'^\d{8,}$');
      if (!phoneRegex.hasMatch(emailOrPhone)) {
        return false;
      }
    }
    return true;
  }

  /// Effectue la connexion de l'utilisateur avec les informations saisies
  Future<void> _login() async {
    if (!_validateInputs()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez saisir des informations valides.')),
      );
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      final user = await _authService.login(
        emailController.text.trim(),
        passwordController.text,
      );
      // TODO: Gérer la persistance du choix "Se souvenir de moi" si nécessaire

      // Navigue vers la page principale de l'application (HomePage)
      Navigator.pushReplacementNamed(context, '/homePage');
    } catch (e) {
      // Affiche un message d'erreur en cas d'échec
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de connexion: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Construit l'interface utilisateur de la page de connexion
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      "assets/images/connexion.jpeg", // Image de fond de la page de connexion
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: ClipPath(
                      clipper: CustomClipperShape(),
                      child: Container(
                        height: 50,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: 0,
                  maxHeight: double.infinity,
                ),
                child: Column(
                  children: [
                    const Text(
                      "Se connecter",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    const SizedBox(height: 8),
                    const Text("Heureux de vous revoir !"),
                    const SizedBox(height: 16),
                    // Affiche le champ email si profil acheteur, sinon champ téléphone
                    widget.profile == 'acheteur'
                        ? customTextField(
                            icon: Icons.email,
                            hintText: "Email",
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                          )
                        : customTextField(
                            icon: Icons.phone,
                            hintText: "Numéro de téléphone",
                            controller: emailController,
                            keyboardType: TextInputType.phone,
                          ),
                    const SizedBox(height: 16),
                    // Champ de saisie pour le mot de passe avec visibilité contrôlable
                    TextFormField(
                      controller: passwordController,
                      obscureText: _obscurePassword,
                      keyboardType: TextInputType.text,
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
                          borderSide:
                              BorderSide(color: Colors.green, width: 2),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.green,
                          ),
                          onPressed: _togglePasswordVisibility,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (val) {
                                setState(() {
                                  _rememberMe = val ?? false;
                                });
                              },
                            ),
                            const Text("Se souvenir de moi"),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ForgotPasswordPage()),
                            );
                          },
                          child: const Text(
                            "mot de passe oublié ?",
                            style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Bouton de connexion ou indicateur de chargement
                    _isLoading
                        ? const CircularProgressIndicator()
                        : customButton(
                            "connexion",
                            _validateInputs() ? _login : () {},
                          ),
                    const SizedBox(height: 16),
                    // Bouton pour naviguer vers la page d'inscription
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  SignUpPage(profile: widget.profile)),
                        );
                      },
                      child: const Text(
                        "Inscrivez-vous ici !",
                        style: TextStyle(
                            color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget personnalisé pour la forme du clipper utilisée dans la page de connexion
class CustomClipperShape extends CustomClipper<Path> {
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
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
