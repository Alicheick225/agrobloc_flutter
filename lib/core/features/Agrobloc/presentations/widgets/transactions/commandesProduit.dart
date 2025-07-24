import 'package:flutter/material.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/moyensPaiementModel.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/moyensPaiementService.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/transactions/payementMethode.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/transactions/paiementMoney.dart';

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
  List<MoyenPaiement> moyensPaiement = [];
  List<String> selectedPayments = [];
  bool showPaymentList = false;
  bool isLoading = true;

  double get totalPrix {
    double qteKg = unite == "T" ? quantite * 1000 : quantite.toDouble();
    return widget.prixUnitaire * qteKg;
  }

  @override
  void initState() {
    super.initState();
    chargerMoyensPaiement();
  }

  Future<void> chargerMoyensPaiement() async {
    try {
      final result = await MoyensPaiementService.fetchMoyensPaiement();
      setState(() {
        moyensPaiement = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur de chargement des moyens de paiement")),
      );
    }
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
            /// ✅ Image et nom du produit
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

            /// ✅ Prix total
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

            /// ✅ Moyens de paiement
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
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      children: moyensPaiement.map((payment) {
                        final isSelected = selectedPayments.contains(payment.id);
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isSelected ? Colors.green : Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          child: ListTile(
                            leading: Image.network(
                              payment.logo,
                              width: 40,
                              height: 40,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.image_not_supported),
                            ),
                            title: Text(payment.libelle),
                            trailing: Checkbox(
                              activeColor: Colors.green,
                              value: isSelected,
                              onChanged: (val) {
                                setState(() {
                                  if (val == true) {
                                    selectedPayments.add(payment.id);
                                  } else {
                                    selectedPayments.remove(payment.id);
                                  }
                                });
                              },
                            ),
                          ),
                        );
                      }).toList(),
                    ),
            const SizedBox(height: 30),

            /// ✅ Bouton de commande
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: (selectedPayments.isEmpty || quantite <= 0)
                    ? null
                    : () {
                        bool isMobileMoney = moyensPaiement
                            .where((m) => selectedPayments.contains(m.id))
                            .any((m) =>
                                m.libelle.contains("Orange Money") ||
                                m.libelle.contains("MTN"));

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
