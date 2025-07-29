import 'package:flutter/material.dart';

class DebitCompletPage extends StatelessWidget {
  final String productName;
  final double unitPrice;
  final double quantity;
  final String unit; // Kg ou Tonne
  final double totalAmount;

  const DebitCompletPage({
    super.key,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    required this.unit,
    required this.totalAmount, required String nomProduit,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text("Commande enregistrée",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Text("A", style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 10),
                const Text(
                  "Antoine Kouassi",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Discuter"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(productName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  Text("Montant à facturer: ${totalAmount.toStringAsFixed(0)} FCFA",
                      style: const TextStyle(fontSize: 14)),
                  Text("Prix Unitaire: ${unitPrice.toStringAsFixed(0)} FCFA / Kg",
                      style: const TextStyle(fontSize: 14)),
                  Text("Quantité à recevoir: $quantity $unit",
                      style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: Colors.teal,
                child: Text("A", style: TextStyle(color: Colors.white)),
              ),
              title: Text("Nom du producteur",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: Text("Antoine Kouassi", style: TextStyle(fontSize: 14)),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.green,
                  side: const BorderSide(color: Colors.green),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Entamer le paiement",
                    style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
