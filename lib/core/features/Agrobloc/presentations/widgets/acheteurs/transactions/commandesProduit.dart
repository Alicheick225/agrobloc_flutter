import 'package:agrobloc/core/features/Agrobloc/data/dataSources/payementMode.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/servicePayement.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/AnnonceVenteModel.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/acheteurs/transactions/order%20tracking/Trackingpage.dart';
import 'package:flutter/material.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/payementModeModel.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/commandeService.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/acheteurs/transactions/payementMethode.dart';

class CommandeProduitPage extends StatefulWidget {
  final String nomProduit;
  final String imageProduit;
  final double prixUnitaire;
  final double stockDisponible;
  final AnnonceVente annonce;

  const CommandeProduitPage({
    super.key,
    required this.nomProduit,
    required this.imageProduit,
    required this.prixUnitaire,
    required this.stockDisponible,
    required this.annonce,
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

  double get totalPrix {
    double qteKg = unite == "T" ? quantite * 1000 : quantite.toDouble();
    return widget.prixUnitaire * qteKg;
  }

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    try {
      final paiementService = PaiementService();
      final modes = await paiementService.getModesPaiement();
      setState(() {
        allPayments = modes;
        isLoadingPayments = false;
      });
    } catch (e) {
      setState(() {
        isLoadingPayments = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : $e")),
      );
    }
  }

  IconData _getPaymentIcon(String libelle) {
    libelle = libelle.toLowerCase();
    if (libelle.contains("mobile money")) return Icons.phone_android;
    if (libelle.contains("carte")) return Icons.credit_card;
    if (libelle.contains("virement")) return Icons.account_balance;
    if (libelle.contains("crypto")) return Icons.currency_bitcoin;
    return Icons.payment;
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
      body: isLoadingPayments
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Prix total
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

                          // Infos produit
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
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover)
                                      : Image.asset(widget.imageProduit,
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  widget.nomProduit,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Quantité
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text("Quantité",
                                          style:
                                              TextStyle(color: Colors.grey)),
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
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 16),
                                      child: Text("Kg"),
                                    ),
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 16),
                                      child: Text("T"),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Sélection paiement
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
                                  backgroundColor:
                                      Colors.green.withOpacity(0.1),
                                  child: Text(
                                    "${allPayments.length}",
                                    style:
                                        const TextStyle(color: Colors.green),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          //if (showPaymentList)
                            Column(
                              children: allPayments.map((payment) {
                                return Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                      color:
                                          selectedPayment == payment.libelle
                                              ? Colors.green
                                              : Colors.transparent,
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
                                    secondary: Icon(
                                      _getPaymentIcon(payment.libelle),
                                      color: Colors.green,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),

                            const SizedBox(height: 20),

                          // Bouton commande
                          SizedBox(
                            width: double.infinity,
                                  child: OutlinedButton(
                                    onPressed: selectedPayment == null
                                        ? null
                                        : () async {
                                            if (quantite < 1) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text("La quantité doit être au moins 1")),
                                              );
                                              return;
                                            }

                                            try {
                                              final quantiteKg = unite == "T" ? quantite * 1000 : quantite.toDouble();

                                              final commandeService = CommandeService();

                                              final commande = await commandeService.enregistrerCommande(
                                                quantite: quantiteKg.toDouble(),
                                                modePaiementId: allPayments.firstWhere(
                                                  (p) => p.libelle == selectedPayment,
                                                ).id,
                                                annoncesVenteId: widget.annonce.id,
                                                unite: unite,
                                              );

                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text("Commande ${commande.id} enregistrée ✅")),
                                              );

                                              // 🔹 Nouvelle logique : redirection vers OrderTrackingScreen
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => OrderTrackingScreen(
                                                    orderId: commande.id.toString(),
                                                    commande: commande,
                                                  ),
                                                ),
                                              );

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
                                  )
                            ,
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
