import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/connexion/register.dart';
import 'package:flutter/material.dart';

class SelectProfilePage extends StatelessWidget {
  const SelectProfilePage({super.key});

  void _navigateToRegister(BuildContext context, String profile) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignUpPage(profile: profile)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choisissez votre profil')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ProfileCard(
                  icon: Icons.account_balance_wallet,
                  label: 'Acheteur',
                  onTap: () => _navigateToRegister(context, 'acheteur'),
                ),
                _ProfileCard(
                  icon: Icons.agriculture,
                  label: 'Planteur',
                  onTap: () => _navigateToRegister(context, 'planteur'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _ProfileCard(
              icon: Icons.apartment,
              label: 'Coopérative',
              onTap: () => _navigateToRegister(context, 'cooperative'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ProfileCard({required this.icon, required this.label, required this.onTap});

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
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
