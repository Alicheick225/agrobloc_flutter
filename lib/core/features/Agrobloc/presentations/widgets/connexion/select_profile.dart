import 'package:flutter/material.dart';
import 'login.dart';
import 'register.dart';

/// Page de sélection du type de profil utilisateur
class SelectProfilePage extends StatelessWidget {
  const SelectProfilePage({super.key});

  /// Navigue vers la page de connexion avec le profil sélectionné
  void _navigateToLogin(BuildContext context, String profile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(profile: profile),
      ),
    );
  }

  /// Navigue vers la page d'inscription avec le profil sélectionné
  void _navigateToRegister(BuildContext context, String profile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SignUpPage(profile: profile),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choisissez votre profil'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ProfileCard(
                      icon: Icons.account_balance_wallet,
                      label: 'Acheteur',
                      onTap: () {
                        _navigateToRegister(context, 'acheteur');
                      },
                    ),
                    _ProfileCard(
                      icon: Icons.agriculture,
                      label: 'Planteur',
                      onTap: () {
                        _navigateToRegister(context, 'planteur');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _ProfileCard(
                  icon: Icons.apartment,
                  label: 'Coopérative',
                  onTap: () {
                    _navigateToRegister(context, 'cooperative');
                  },
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

/// Widget carte représentant une option de profil utilisateur
class _ProfileCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ProfileCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: 140,
          height: 140,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 64, color: Colors.green),
              const SizedBox(height: 12),
              Text(
                label,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
