import 'package:flutter/material.dart';

class MobileMoneyOrderPage extends StatefulWidget {
  const MobileMoneyOrderPage({super.key});

  @override
  State<MobileMoneyOrderPage> createState() => _MobileMoneyOrderPageState();
}

class _MobileMoneyOrderPageState extends State<MobileMoneyOrderPage> {
  final TextEditingController quantityController = TextEditingController(text: "10");
  final TextEditingController phoneController = TextEditingController(text: "+225 ** *****76");

  String selectedUnit = "T";
  String selectedPayment = "Orange Money";

  @override
  void dispose() {
    quantityController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFB930),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text("Commander le produit", style: TextStyle(color: Colors.black)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Prix
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text("Prix  ", style: TextStyle(fontSize: 16)),
                Text(
                  "FCFA 15000000",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Produit
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/images/25554.jpg', // Remplace par ton image
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Anacarde",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Quantité + unité
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: quantityController,
                    decoration: const InputDecoration(
                      labelText: "Quantité",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                ToggleButtons(
                  borderRadius: BorderRadius.circular(8),
                  isSelected: [selectedUnit == "Kg", selectedUnit == "T"],
                  onPressed: (index) {
                    setState(() {
                      selectedUnit = index == 0 ? "Kg" : "T";
                    });
                  },
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text("Kg"),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text("T"),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Moyens de paiement (Orange Money)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/orange_money.png', // Ton icône OM
                    width: 24,
                  ),
                  const SizedBox(width: 10),
                  const Text("Orange Money", style: TextStyle(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  const Icon(Icons.keyboard_arrow_down),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Numéro mobile
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: "+225 ** *****76",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const Spacer(),

            // Bouton enregistrer
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // Logique d’enregistrement de commande ici
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.green,
                  side: const BorderSide(color: Colors.green),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Enregistrez ma commande"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
