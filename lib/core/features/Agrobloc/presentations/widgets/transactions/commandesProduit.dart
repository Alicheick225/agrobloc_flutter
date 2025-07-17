import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/transactions/payementMethode.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/transactions/paiementMoney.dart';
import 'package:flutter/material.dart';

class CommandeProduitPage extends StatefulWidget {
  final String nomProduit;
  final String imageProduit;
  final double prixUnitaire;
  final double stockDisponible;

  const CommandeProduitPage({
    super.key,
    required this.nomProduit,
    required this.imageProduit,
    required this.prixUnitaire,
    required this.stockDisponible,
  });

  @override
  State<CommandeProduitPage> createState() => _CommandeProduitPageState();
}

class _CommandeProduitPageState extends State<CommandeProduitPage> {
  int quantite = 1;
  String unite = "Kg";
  final List<Map<String, String>> allPayments = [
    {"name": "Orange Money", "logo": "assets/images/orange_money.png"},
    {"name": "MTN Mobile Money", "logo": "assets/images/MTN_Money.png"},
    {"name": "Carte Bancaire", "logo": "assets/images/carte_bancaire.png"},
  ];
  List<String> selectedPayments = [];
  bool showPaymentList = false;

  double get totalPrix {
    double qteKg = unite == "T" ? quantite * 1000 : quantite.toDouble();
    return widget.prixUnitaire * qteKg;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(widget.nomProduit, style: const TextStyle(color: Colors.black)),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            /// ✅ Nom du produit et image
            Center(
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: widget.imageProduit.startsWith("http")
                        ? Image.network(
                            widget.imageProduit,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            widget.imageProduit,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.nomProduit,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            /// ✅ Prix dynamique
            Center(
              child: Text.rich(
                TextSpan(
                  text: "Prix total : ",
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  children: [
                    TextSpan(
                      text: "${totalPrix.toStringAsFixed(0)} FCFA",
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            /// ✅ Quantité
            const Text("Quantité", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    initialValue: quantite.toString(),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onChanged: (val) {
                      setState(() {
                        quantite = int.tryParse(val) ?? 1;
                        if (quantite < 1) quantite = 1;
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

            /// ✅ Modes de paiement
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
                      leading: Image.asset(payment["logo"]!, width: 40, height: 40),
                      title: Text(payment["name"]!),
                      trailing: Checkbox(
                        activeColor: Colors.green,
                        value: isSelected,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              selectedPayments.add(payment["name"]!);
                            } else {
                              selectedPayments.remove(payment["name"]!);
                            }
                          });
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 30),

            /// ✅ Bouton commande
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: (selectedPayments.isEmpty || quantite <= 0)
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
                child: const Text("Enregistrer ma commande"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
