import 'package:flutter/material.dart';

class CommandeEnregistreePage extends StatelessWidget {
  const CommandeEnregistreePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Commande enregistrée'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserCard(),
            const SizedBox(height: 16),
            _buildCommandeDetailsCard(),
            const SizedBox(height: 24),
            _buildInfoRow("Nom du producteur", "Antoine Kouassi"),
            const SizedBox(height: 8),
            _buildInfoRow("Numéro de téléphone", "07 69 28 3031"),
            const SizedBox(height: 8),
            _buildInfoRow("Statut commande", "En attente de paiement", color: Colors.orange),
            const SizedBox(height: 40),
            _buildBottomButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green,
          child: const Text("A", style: TextStyle(color: Colors.white)),
        ),
        title: const Text("Antoine Kouassi"),
        trailing: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: const Text("Discuter"),
        ),
      ),
    );
  }

  Widget _buildCommandeDetailsCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("Anarcade", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            _DetailRow(label: "Montant à facturer", value: "15.075.000 FCFA"),
            _DetailRow(label: "Prix Unitaire", value: "1.700 FCFA"),
            _DetailRow(label: "Quantité à recevoir", value: "10 Tonnes"),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color color = Colors.black}) {
    return Row(
      children: [
        Expanded(child: Text(label, style: const TextStyle(color: Colors.grey))),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return Center(
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () {
            // Action paiement
          },
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.green),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text(
            "Entamer le paiement",
            style: TextStyle(color: Colors.green, fontSize: 16),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
