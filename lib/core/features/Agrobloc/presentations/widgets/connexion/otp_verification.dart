import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Page de vérification du code OTP envoyé au numéro de téléphone de l'utilisateur
class OtpVerificationPage extends StatefulWidget {
  final String phoneNumber;
  final Function(String otp)? onOtpSubmitted;

  const OtpVerificationPage({
    super.key,
    required this.phoneNumber,
    this.onOtpSubmitted,
  });

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

/// État de la page de vérification OTP gérant les contrôleurs et la logique de saisie
class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final List<TextEditingController> _otpControllers =
      List.generate(4, (_) => TextEditingController());

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Renvoie le code OTP complet saisi
  String get _otpCode => _otpControllers.map((c) => c.text).join();

  /// Fonction pour renvoyer le code OTP
  void _resendCode() {
    // TODO: Implémenter la logique réelle de renvoi du code OTP
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Code renvoyé')),
    );

    // Reset des champs
    for (var controller in _otpControllers) {
      controller.clear();
    }
    FocusScope.of(context).requestFocus(FocusNode());
  }

  /// Fonction appelée lors de la validation du code OTP
  void _validateOtp() {
    if (_otpCode.length < 4 || _otpCode.contains('')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer le code complet')),
      );
      return;
    }

    if (widget.onOtpSubmitted != null) {
      widget.onOtpSubmitted!(_otpCode);
    }

    // TODO: Ajouter la logique d'appel à l'API pour valider le code OTP
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Code OTP soumis: $_otpCode')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Entrez le code de vérification'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Text(
                'Nous avons envoyé le code OTP au numéro ${widget.phoneNumber}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) {
                  return SizedBox(
                    width: 50,
                    height: 60,
                    child: TextField(
                      controller: _otpControllers[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: const InputDecoration(
                        counterText: '',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        if (value.length == 1 && index < 3) {
                          FocusScope.of(context).nextFocus();
                        } else if (value.isEmpty && index > 0) {
                          FocusScope.of(context).previousFocus();
                        }
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: _resendCode,
                child: const Text(
                  "Je n’ai pas reçu de code ? Cliquez pour renvoyer",
                  style: TextStyle(
                    color: Colors.green,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _validateOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Valider',
                    style: TextStyle(fontSize: 18, color: Colors.white),
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
