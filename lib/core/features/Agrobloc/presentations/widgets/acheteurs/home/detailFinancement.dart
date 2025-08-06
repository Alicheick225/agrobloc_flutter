import 'package:agrobloc/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/annoncePrefinancementModel.dart';

class FinancementDetailsPage extends StatelessWidget {
  final AnnonceFinancement data;

  const FinancementDetailsPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Préfinancement de Culture",
          style: TextStyle(fontSize: 18),
        ),
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primaryGreen,
            child: Text(
              data.nom.isNotEmpty ? data.nom[0].toUpperCase() : '?',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.nom,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  data.adresse,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: () {
              // Action voir profil à définir
            },
            icon: const Icon(Icons.remove_red_eye_outlined,
                color: AppColors.primaryGreen, size: 18),
            label: const Text('Voir profil',
                style:
                    TextStyle(color: AppColors.primaryGreen, fontSize: 12)),
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
        children: [
          Text(
            data.libelle,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 12),
          _InfoRow(
              label: "Montant à préfinancer",
              value: "${data.montantPref.toStringAsFixed(0)} FCFA"),
          _InfoRow(
              label: "Prix préférentiel",
              value: "${data.prixKgPref.toStringAsFixed(0)} FCFA / Kg"),
          _InfoRow(label: "Superficie", value: "${data.surface} hectares"),
          _InfoRow(
              label: "Production estimée",
              value: "${data.quantite.toStringAsFixed(1)} Tonnes"),
          _InfoRow(
              label: "Valeur de la production",
              value:
                  "${(data.quantite * data.prixKgPref).toStringAsFixed(0)} FCFA"),
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
      child: Text(
        data.description,
        style: const TextStyle(fontSize: 13),
      ),
    );
  }

  Widget _buildButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.primaryGreen),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onPressed: () {
          // Action de préfinancement à implémenter
        },
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
                  style:
                      const TextStyle(fontWeight: FontWeight.w500, fontSize: 13))),
          Text(value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}
