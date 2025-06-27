import 'package:flutter/material.dart';
import 'package:agrobloc/core/themes/app_colors.dart';

class FinancementDetailsPage extends StatelessWidget {
  const FinancementDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Préfinancement de Culture", style: TextStyle(fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProducteurCard(),
            const SizedBox(height: 16),
            _buildInfosCulture(),
            const SizedBox(height: 16),
            _buildDescription(),
            const SizedBox(height: 24),
            _buildButton(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProducteurCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: AppColors.primaryGreen,
            child: Text('A', style: TextStyle(color: Colors.white, fontSize: 14)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Antoine Kouassi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                SizedBox(height: 4),
                Text('Région de l’Iffou, Daoukro', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.remove_red_eye_outlined, color: AppColors.primaryGreen, size: 18),
            label: const Text('Voir profil', style: TextStyle(color: AppColors.primaryGreen, fontSize: 12)),
          )
        ],
      ),
    );
  }

  Widget _buildInfosCulture() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text("Noix de cajou", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          SizedBox(height: 12),
          _InfoRow(label: "Montant à préfinancer", value: "1.500.000 FCFA"),
          _InfoRow(label: "Prix préférentiel", value: "2.200 FCFA / Kg"),
          _InfoRow(label: "Superficie", value: "8 hectares"),
          _InfoRow(label: "Production estimée", value: "50 Tonnes"),
          _InfoRow(label: "Valeur de la production", value: "9.000.000 FCFA"),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Description", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          SizedBox(height: 12),
          Text(
            "Je suis Antoine Kouassi, producteur d’anacarde basé à Korhogo. Je cultive 5 hectares d’anacardiers en production, avec un rendement moyen de 800 kg/ha. "
            "Pour la campagne 2025, je sollicite un préfinancement de 1 500 000 FCFA afin de couvrir les intrants, l’entretien du verger et la logistique.\n\n"
            "Le financement servira à l’achat d’engrais spécifiques (450 000 FCFA), traitements phytosanitaires (200 000 FCFA), main-d’œuvre (400 000 FCFA), "
            "transport et frais divers (450 000 FCFA).\n\n"
            "Avec une production prévisionnelle de 4 tonnes, vendue en moyenne à 500 FCFA/kg, je prévois un chiffre d’affaires brut d’environ 2 000 000 FCFA.",
            style: TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.primaryGreen),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onPressed: () {},
        child: const Text(
          'Préfinancer la production',
          style: TextStyle(
            color: AppColors.primaryGreen,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
              child: Text(label,
                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}
