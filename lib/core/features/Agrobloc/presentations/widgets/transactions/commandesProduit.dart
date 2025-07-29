import 'package:agrobloc/core/features/Agrobloc/data/dataSources/payementMode.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/transactions/payementMethode.dart';
import 'package:flutter/material.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/payementModeModel.dart';
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

  List<PaymentModel> allPayments = [];
  String? selectedPayment;
  bool showPaymentList = false;
  bool isLoadingPayments = true;

  @override
  void initState() {
    super.initState();
    loadPayments();
  }

  Future<void> loadPayments() async {
    try {
      final service = PaymentService();
      final payments = await service.fetchPayments();
      setState(() {
        allPayments = payments;
        isLoadingPayments = false;
      });
    } catch (e) {
      setState(() {
        isLoadingPayments = false;
      });
      print("Erreur lors du chargement des paiements: $e");
    }
  }

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
        title: Text(widget.nomProduit,
            style: const TextStyle(color: Colors.black)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            // Image produit
            Center(
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: widget.imageProduit.startsWith("http")
                        ? Image.network(widget.imageProduit,
                            width: 80, height: 80, fit: BoxFit.cover)
                        : Image.asset(widget.imageProduit,
                            width: 80, height: 80, fit: BoxFit.cover),
                  ),
                  const SizedBox(height: 8),
                  Text(widget.nomProduit,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Prix total
            Center(
              child: Text(
                "Prix total : ${totalPrix.toStringAsFixed(0)} FCFA",
                style: const TextStyle(
                    color: Colors.green, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),

            // Quantité + Unité
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    initialValue: quantite.toString(),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
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

            // Liste des moyens de paiement
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                selectedPayment == null
                    ? "Sélection du mode de paiement"
                    : "Mode choisi : $selectedPayment",
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.green),
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

            if (isLoadingPayments)
              const Center(child: CircularProgressIndicator()),

            if (showPaymentList && !isLoadingPayments)
              Column(
                children: allPayments.map((payment) {
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: selectedPayment == payment.libelle
                            ? Colors.green
                            : Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    child: RadioListTile<String>(
                      activeColor: Colors.green,
                      value: payment.libelle,
                      groupValue: selectedPayment,
                      onChanged: (value) {
                        setState(() {
                          selectedPayment = value;
                        });
                      },
                      title: Text(payment.libelle),
                      secondary: payment.logo != null
                          ? Image.network(payment.logo!,
                              width: 40,
                              height: 40,
                              errorBuilder: (_, __, ___) {
                                return const Icon(Icons.payment,
                                    color: Colors.green);
                              })
                          : const Icon(Icons.payment, color: Colors.green),
                    ),
                  );
                }).toList(),
              ),

            const SizedBox(height: 30),

            // Bouton vers paiement
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  final paymentLower = selectedPayment?.toLowerCase();

                  if (paymentLower == "orange money" || paymentLower == "mtn money" || paymentLower == "wave") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MobileMoneyOrderPage(
                          selectedPayment: selectedPayment!,
                          totalAmount: totalPrix,
                          productName: widget.nomProduit,
                          unitPrice: widget.prixUnitaire,
                          quantity: quantite.toDouble(),
                          unit: unite,
                        ),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PaymentMethodPage(
                          selectedPayment: selectedPayment!,
                          totalAmount: totalPrix,
                          productName: widget.nomProduit,
                          unitPrice: widget.prixUnitaire,
                          quantity: quantite.toDouble(),
                          unit: unite,
                        ),
                      ),
                    );
                  }
                },

                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.green,
                  side: const BorderSide(color: Colors.green),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Continuer vers le paiement"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
