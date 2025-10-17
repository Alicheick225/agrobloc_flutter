import 'package:agrobloc/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

class CompteSequestre extends StatefulWidget {
  const CompteSequestre({super.key});

  @override
  State<CompteSequestre> createState() => _CompteSequestreState();
}

class _CompteSequestreState extends State<CompteSequestre> {
  bool _isAmountVisible = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 160, // Adjusted to match parent constraints
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, top: 10, right: 10, bottom: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Mon Compte sequestre",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _isAmountVisible ? "12 000 " : "**** ",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _isAmountVisible ? "FCFA" : "",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isAmountVisible = !_isAmountVisible;
                      });
                    },
                    child: Icon(
                      _isAmountVisible ? Icons.visibility_off : Icons.visibility,
                      color: Colors.white.withOpacity(0.7),
                      size: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  _ActionButton(
                    icon: Icons.arrow_outward_rounded,
                    label: "Commandes",
                  ),
                  _ActionButton(
                    icon: Icons.public_rounded,
                    label: "Historique ",
                  ),
                  _ActionButton(
                    icon: Icons.card_giftcard_rounded,
                    label: "Carte cadeau",
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ActionButton({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 35,
          width: 35,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
