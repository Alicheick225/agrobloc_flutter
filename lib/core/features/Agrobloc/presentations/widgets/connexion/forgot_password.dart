import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'otp_verification.dart';
import 'widgetAuth.dart';

/// Page permettant à l'utilisateur de récupérer son mot de passe via son numéro de téléphone
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

/// État de la page de récupération de mot de passe gérant le formulaire et la validation
class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  /// Soumet le formulaire et navigue vers la page de vérification OTP si valide
  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpVerificationPage(
            phoneNumber: phoneController.text,
          ),
        ),
      );
    }
  }

  /// Valide le numéro de téléphone saisi
  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre numéro de téléphone';
    }
    if (value.length != 10) {
      return 'Le numéro doit contenir exactement 10 chiffres';
    }
    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
      return 'Le numéro ne doit contenir que des chiffres';
    }
    return null;
  }

  /// Construit l'interface utilisateur de la page de récupération de mot de passe
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Mot de passe oublié ?'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 16),
                Image.asset(
                  'assets/images/password.jpeg',
                  height: 150,
                ),
                const SizedBox(height: 24),
                // Champ de saisie pour le numéro de téléphone avec validation
                customTextField(
                  icon: Icons.phone,
                  hintText: 'Numéro de téléphone',
                  controller: phoneController,
                  keyboardType: TextInputType.number,
                  validator: _validatePhone,
                ),
                const SizedBox(height: 24),
                // Bouton pour soumettre le formulaire
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _onSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Suivant',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
