import 'package:agrobloc/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

class TransactionDetailsPage extends StatelessWidget {
  const TransactionDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Détails Paiement", style: TextStyle(fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [
          Icon(Icons.info_outline, color: Colors.grey),
          SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildParticipantCard(
              avatar: "V",
              name: "Vincent Patrick",
              role: "Acheteur",
              method: "Orange Money",
              date: "Sep 10, 2025, 15:30",
            ),
            const SizedBox(height: 12),
            _buildParticipantCard(
              avatar: "A",
              name: "Kouassi Antoine",
              role: "Planteur",
              method: "Wave",
              date: "Sep 10, 2025, 15:35",
            ),
            const SizedBox(height: 16),
            _buildTransactionResume(),
            const SizedBox(height: 24),
            _buildPrintButton(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantCard({
    required String avatar,
    required String name,
    required String role,
    required String method,
    required String date,
  }) {
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
            child: Text(avatar,
                style: const TextStyle(color: Colors.white, fontSize: 14)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("$name ($role)",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text("Paiement via $method",
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
                Text(date,
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionResume() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text("Résumé de la Transaction",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          SizedBox(height: 12),
          _InfoRow(label: "Transaction ID", value: "#123SDKZ13Z"),
          _InfoRow(label: "Montant", value: "15.000.000 FCFA"),
          _InfoRow(label: "Frais", value: "0.5%"),
          _InfoRow(label: "Total payé", value: "15.075.000 FCFA"),
        ],
      ),
    );
  }

  Widget _buildPrintButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: const Icon(Icons.print, size: 18, color: AppColors.primaryGreen),
        label: const Text(
          "Imprimer votre reçu de paiement",
          style: TextStyle(
            color: AppColors.primaryGreen,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.primaryGreen),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onPressed: () {
          // TODO: ajouter logique d'impression
        },
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
                    const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
          ),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}
