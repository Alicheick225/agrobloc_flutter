
import 'package:flutter/material.dart';
import 'forgot_password.dart';
import 'widgetAuth.dart';
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
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController emailController;
  late final TextEditingController phoneController;
  final passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _rememberMe = false;

  late String internalProfile;

  final AuthService _authService = AuthService();

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

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  bool _validateInputs() {
    final emailOrPhone = (internalProfile == 'acheteur' || internalProfile == 'cooperative')
        ? emailController.text.trim()
        : phoneController.text.trim();
    final password = passwordController.text;

    if (emailOrPhone.isEmpty || password.isEmpty) {
      return false;
    }

    if (internalProfile == 'acheteur' || internalProfile == 'cooperative') {
      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
      if (!emailRegex.hasMatch(emailOrPhone)) {
        return false;
      }
    } else if (internalProfile == 'producteur') {
      final phoneRegex = RegExp(r'^\d{8,}$');
      if (!phoneRegex.hasMatch(emailOrPhone)) {
        return false;
      }
    } else {
      // For other profiles, you can add validation if needed
      return false;
    }

    return true;
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print('internalProfile: $internalProfile');
      print('email: ${emailController.text.trim()}');
      print('phone: ${phoneController.text.trim()}');

      final user = await _authService.login(
        (['acheteur', 'cooperative'].contains(internalProfile))
            ? emailController.text.trim()
            : phoneController.text.trim(),
        passwordController.text,
      );

      // TODO: gérer la persistance du "Se souvenir de moi"

      Navigator.pushReplacementNamed(context, '/homePage');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de connexion: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
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
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                      ),
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
                                if (value == null || value.isEmpty) {
                                  return 'Veuillez saisir un email';
                                }
                                final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                                if (!emailRegex.hasMatch(value)) {
                                  return 'Veuillez saisir un email valide';
                                }
                                return null;
                              },
                            )
                          : customTextField(
                              icon: Icons.phone,
                              hintText: "Numéro de téléphone",
                              controller: phoneController,
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Veuillez saisir un numéro de téléphone';
                                }
                                final phoneRegex = RegExp(r'^\d{8,}$');
                                if (!phoneRegex.hasMatch(value)) {
                                  return 'Veuillez saisir un numéro valide';
                                }
                                return null;
                              },
                            ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: passwordController,
                        obscureText: _obscurePassword,
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez saisir un mot de passe';
                          }
                          return null;
                        },
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
                                MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
                              );
                            },
                            child: const Text(
                              "mot de passe oublié ?",
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 16),
                      _isLoading
                          ? const CircularProgressIndicator()
                          : customButton(
                              "Se connecter",
                              _login,
                            ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignUpPage(profile: widget.profile),
                            ),
                          );
                        },
                        child: const Text(
                          "Inscrivez-vous ici !",
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
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

/// Widget personnalisé pour la forme du clipper utilisée dans la page de connexion
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
