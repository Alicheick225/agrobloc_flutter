import 'package:agrobloc/core/features/Agrobloc/data/dataSources/commandeService.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/acheteurs/transactions/payementMethode.dart';
import 'package:flutter/material.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/payementModeModel.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/acheteurs/transactions/paiementMoney.dart';

// ... import statements inchangés ...

class CommandeProduitPage extends StatefulWidget {
  final String nomProduit;
  final String imageProduit;
  final double prixUnitaire;
  final double stockDisponible;
final String acheteurId;

  const CommandeProduitPage({
    super.key,
    required this.nomProduit,
    required this.imageProduit,
    required this.prixUnitaire,
    required this.stockDisponible,
    required this.acheteurId, // 🔥 ID de l'acheteur
  });
  

  @override
  State<CommandeProduitPage> createState() => _CommandeProduitPageState();
}

class _CommandeProduitPageState extends State<CommandeProduitPage> {
  int quantite = 1;
  String unite = "Kg";

  List<PaymentModel> allPayments = [
    PaymentModel(id: "1", libelle: "Carte bancaire (VISA)", logo: null),
    PaymentModel(id: "2", libelle: "Virement bancaire", logo: null),
    PaymentModel(id: "3", libelle: "Mobile money", logo: null),
  ];

  String? selectedPayment;
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
                                ? Image.network(widget.imageProduit,
                                    width: 50, height: 50, fit: BoxFit.cover)
                                : Image.asset(widget.imageProduit,
                                    width: 50, height: 50, fit: BoxFit.cover),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            widget.nomProduit,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
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
                                const Text("Quantité",
                                    style: TextStyle(color: Colors.grey)),
                                TextFormField(
                                  initialValue: quantite.toString(),
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                      border: InputBorder.none),
                                  style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
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
                            style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold),
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
                    if (showPaymentList)
                      Column(
                        children: allPayments.map((payment) {
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: selectedPayment == payment.libelle
                                    ? Colors.green
                                    : const Color.fromARGB(255, 250, 242, 242),
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
                              secondary: const Icon(Icons.payment,
                                  color: Colors.green),
                            ),
                          );
                        }).toList(),
                      ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: selectedPayment == null
                            ? null
                            : () async {
                                if (quantite < 1) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            "La quantité doit être au moins 1")),
                                  );
                                  return;
                                }

                                final selectedPaymentObj = allPayments.firstWhere(
                                  (p) => p.libelle == selectedPayment,
                                  orElse: () => PaymentModel(
                                      libelle: selectedPayment!, logo: null, id: ''),
                                );

                                try {
                                  // Quantité convertie en double en kg
                                  final quantite = unite == "T"
                                      ? this.quantite * 1000
                                      : this.quantite.toDouble();
                                  final totalPrix = quantite * widget.prixUnitaire;
                                  final prixTotal = totalPrix.toDouble();
                                  final modePaiementId = selectedPaymentObj.id;
                                  final acheteurId = widget.acheteurId; // 🔥 Utiliser l'ID de l'acheteur réel

                                  final commandeService = CommandeService();

                                  final commande = await commandeService
                                      .enregistrerCommande(
                                    quantite: quantite.toDouble(),
                                    prixTotal: prixTotal,
                                    modePaiementId: modePaiementId,
                                    typeCulture: widget.nomProduit,
                                     acheteurId: acheteurId, 
                                    );

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            "Commande ${commande.id} enregistrée")),
                                  );

                                  final isMobileMoney = selectedPayment!
                                      .toLowerCase()
                                      .contains('mobile');

                                  if (isMobileMoney) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => MobileMoneyOrderPage(
                                          selectedPayment: selectedPayment!,
                                          totalAmount: prixTotal,
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
                                          totalAmount: prixTotal,
                                          productName: widget.nomProduit,
                                          unitPrice: widget.prixUnitaire,
                                          quantity: quantite.toDouble(),
                                          unit: unite,
                                        ),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Erreur : $e")),
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
