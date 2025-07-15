import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/transactions/payementMethode.dart';
import 'package:flutter/material.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/transactions/paiementMoney.dart';

class CommandeProduitPage extends StatefulWidget {
  const CommandeProduitPage({super.key});

  @override
  State<CommandeProduitPage> createState() => _CommandeProduitPageState();
}

class _CommandeProduitPageState extends State<CommandeProduitPage> {
  int quantite = 10;
  String unite = "T";
  final List<Map<String, String>> allPayments = [
    {"name": "Orange Money", "logo": "assets/images/orange_money.png"},
    {"name": "MTN Mobile Money", "logo": "assets/images/MTN_Money.png"},
    {"name": "Carte Bancaire", "logo": "assets/images/carte_bancaire.png"},
  ];
  List<String> selectedPayments = [];
  bool showPaymentList = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text("Commande Produit", style: TextStyle(color: Colors.black)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Center(
              child: Text(
                "Commander le produit",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            const SizedBox(height: 10),
            const Center(
              child: Text.rich(
                TextSpan(
                  text: "Prix  ",
                  children: [
                    TextSpan(
                      text: "FCFA 15000000",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    WidgetSpan(
                      child: Icon(Icons.autorenew, color: Colors.green, size: 18),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: const Image(
                      image: AssetImage('assets/images/25554.jpg'),
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    "Anacarde",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Quantité",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    initialValue: "10",
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onChanged: (val) {
                      setState(() {
                        quantite = int.tryParse(val) ?? 10;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                ToggleButtons(
                  isSelected: [unite == "Kg", unite == "T"],
                  onPressed: (index) {
                    setState(() {
                      unite = index == 0 ? "Kg" : "T";
                    });
                  },
                  borderRadius: BorderRadius.circular(10),
                  selectedColor: Colors.white,
                  fillColor: Colors.green,
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text("Kg"),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text("T"),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                selectedPayments.isEmpty
                    ? "Sélection du mode de paiement"
                    : "Modes choisis (${selectedPayments.length})",
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
              ),
              trailing: Icon(
                showPaymentList ? Icons.expand_less : Icons.expand_more,
                color: Colors.green,
              ),
              onTap: () {
                setState(() {
                  showPaymentList = !showPaymentList;
                });
              },
            ),
            if (showPaymentList)
              Column(
                children: allPayments.map((payment) {
                  bool isSelected = selectedPayments.contains(payment["name"]);
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected ? Colors.green : Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    child: ListTile(
                      leading: Image.asset(
                        payment["logo"]!,
                        width: 40,
                        height: 40,
                        fit: BoxFit.contain,
                      ),
                      title: Text(payment["name"]!),
                      trailing: Checkbox(
                        activeColor: Colors.green,
                        value: isSelected,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              selectedPayments.add(payment["name"]!);
                            } else {
                              selectedPayments.remove(payment["name"]);
                            }
                          });
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: selectedPayments.isEmpty
                    ? null
                    : () {
                        bool isMobileMoney = selectedPayments.any((payment) =>
                            payment == "Orange Money" || payment == "MTN Mobile Money");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => isMobileMoney
                                ? MobileMoneyOrderPage(selectedPayments: selectedPayments)
                                : PaymentMethodPage(selectedPayments: selectedPayments),
                          ),
                        );
                      },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.green,
                  side: const BorderSide(color: Colors.green),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
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