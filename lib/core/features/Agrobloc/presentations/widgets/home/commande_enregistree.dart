import 'package:flutter/material.dart';

class CommandeEnregistreePage extends StatelessWidget {
  const CommandeEnregistreePage({super.key});

  static const Color primaryGreen = Color(0xFF5D9643);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,  // <-- Fond blanc ici
      appBar: AppBar(
        title: const Text('Commande enregistrée',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      // ✅ Contenu principal
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
            _buildInfoRow("Statut commande", "En attente de paiement",
                color: Colors.orange),
            const SizedBox(height: 80), // Espace pour ne pas cacher le bouton
          ],
        ),
      ),

      // ✅ Bouton fixé en bas
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // Action paiement
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              side: const BorderSide(color: primaryGreen),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              "Entamer le paiement",
              style: TextStyle(
                color: primaryGreen,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: primaryGreen,
          child: Text("A", style: TextStyle(color: Colors.white)),
        ),
        title: const Text("Antoine Kouassi"),
        trailing: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryGreen,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: const Text("Discuter", style: TextStyle(color: Colors.white)),
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
            Text("Anarcade",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            _DetailRow(label: "Montant à facturer", value: "15.075.000 FCFA"),
            _DetailRow(label: "Prix Unitaire", value: "1.700 FCFA"),
            _DetailRow(label: "Quantité à recevoir", value: "10 Tonnes"),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value,
      {Color color = Colors.black}) {
    return Row(
      children: [
        Expanded(
            child: Text(label, style: const TextStyle(color: Colors.grey))),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
      ],
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
