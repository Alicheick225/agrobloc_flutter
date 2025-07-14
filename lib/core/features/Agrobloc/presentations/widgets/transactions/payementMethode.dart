import 'package:flutter/material.dart';

class PaymentMethodPage extends StatefulWidget {
  const PaymentMethodPage({super.key});

  @override
  State<PaymentMethodPage> createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends State<PaymentMethodPage> {
  final TextEditingController cardHolderController = TextEditingController();
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController expDateController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();

  @override
  void dispose() {
    cardHolderController.dispose();
    cardNumberController.dispose();
    expDateController.dispose();
    cvvController.dispose();
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
        title: const Text(
          "Mode de paiement",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Carte Bancaire
            Row(
              children: const [
                Icon(Icons.credit_card, color: Colors.blue),
                SizedBox(width: 10),
                Text(
                  "Carte Bancaire",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Carte déjà enregistrée
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: const [
                  Icon(Icons.credit_card, color: Colors.blue),
                  SizedBox(width: 10),
                  Text("**** **** **** 3076", style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const Divider(),
            const Text(
              "Payer via une nouvelle carte",
              style: TextStyle(color: Colors.grey),
            ),
            const Divider(),
            const SizedBox(height: 12),

            // Nom du titulaire
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Nom du titulaire de la carte",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: cardHolderController,
              decoration: InputDecoration(
                hintText: "Maxime Crowd",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 20),

            // Infos carte
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Informations de la carte",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // Numéro de carte
                  TextField(
                    controller: cardNumberController,
                    decoration: const InputDecoration(
                      hintText: "Numéro de carte",
                      prefixIcon: Icon(Icons.credit_card),
                      border: InputBorder.none,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const Divider(),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: expDateController,
                          decoration: const InputDecoration(
                            hintText: "MM/AA",
                            border: InputBorder.none,
                          ),
                          keyboardType: TextInputType.datetime,
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: cvvController,
                          decoration: const InputDecoration(
                            hintText: "CVC",
                            border: InputBorder.none,
                          ),
                          keyboardType: TextInputType.number,
                          obscureText: true,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),

            const Spacer(),

            // Bouton Suivant
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text("Suivant"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
