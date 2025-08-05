import 'package:agrobloc/core/features/Agrobloc/data/dataSources/payementMode.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/transactions/payementMethode.dart';
import 'package:agrobloc/core/utils/imagePayement.dart';
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
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Commander le produit',
        style: TextStyle(color: Colors.black),
      ),
      centerTitle: true,
    ),
    body: LayoutBuilder(
  builder: (context, constraints) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight),
        child: IntrinsicHeight(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // PRIX
              Center(
                child: Text(
                  "Prix  FCFA ${totalPrix.toStringAsFixed(0)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // IMAGE + NOM PRODUIT
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: widget.imageProduit.startsWith("http")
                          ? Image.network(widget.imageProduit, width: 50, height: 50, fit: BoxFit.cover)
                          : Image.asset(widget.imageProduit, width: 50, height: 50, fit: BoxFit.cover),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      widget.nomProduit,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // QUANTITE
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Quantité", style: TextStyle(color: Colors.grey)),
                          TextFormField(
                            initialValue: quantite.toString(),
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(border: InputBorder.none),
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            onChanged: (val) {
                              setState(() {
                                quantite = int.tryParse(val) ?? 1;
                                if (quantite < 1) quantite = 1;
                              });
                            },
                          ),
                        ],
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
              ),
              const SizedBox(height: 20),

              // SELECTION PAIEMENT
              GestureDetector(
                onTap: () {
                  setState(() {
                    showPaymentList = !showPaymentList;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Sélection du mode de paiement",
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.green.withOpacity(0.1),
                      child: Text(
                        "${allPayments.length}",
                        style: const TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

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
                        ),
                      ),
                      child: RadioListTile<String>(
                        value: payment.libelle,
                        groupValue: selectedPayment,
                        onChanged: (value) {
                          setState(() {
                            selectedPayment = value;
                          });
                        },
                        title: Text(payment.libelle),
                        activeColor: Colors.green,
                        secondary: payment.logo != null && payment.logo!.isNotEmpty
                            ? Image.network(
                                getLogoUrl(payment.logo),
                                width: 40,
                                height: 40,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.payment, color: Colors.green),
                              )
                            : const Icon(Icons.payment, color: Colors.green),
                      ),
                    );
                  }).toList(),
                ),

              const Spacer(), // <-- force le bouton en bas

              // BOUTON
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    if (selectedPayment == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Veuillez sélectionner un mode de paiement")),
                      );
                      return;
                    }

                    final selectedPaymentObj = allPayments.firstWhere(
                      (p) => p.libelle == selectedPayment,
                      orElse: () => PaymentModel(libelle: selectedPayment!, logo: null, id: ''),
                    );

                    final isMobileMoney = selectedPayment!.toLowerCase().contains('mtn') ||
                        selectedPayment!.toLowerCase().contains('orange') ||
                        selectedPayment!.toLowerCase().contains('wave') ||
                        selectedPayment!.toLowerCase().contains('moov');

                    if (isMobileMoney) {
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
                            logoUrl: selectedPaymentObj.logo,
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
                  child: const Text("Enregistrez ma commande"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  },
),
  );
}
}