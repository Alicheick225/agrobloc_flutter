import 'package:flutter/material.dart';

class TransactionCard extends StatelessWidget {
  final String nom;
  final String prixUnitaire;
  final String moyenPaiement;
  final String montantTotal;
  final String statut;
  final Color statutColor;
  final VoidCallback onDetails;

  const TransactionCard({
    Key? key,
    required this.nom,
    required this.prixUnitaire,
    required this.moyenPaiement,
    required this.montantTotal,
    required this.statut,
    required this.statutColor,
    required this.onDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Ligne 1 : Avatar + nom + bouton détails
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.green[100],
                      child: Text(nom[0],
                          style: const TextStyle(color: Colors.black)),
                    ),
                    const SizedBox(width: 5),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(nom,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        const Text("99 transactions (4.9/5)  100%"),
                      ],
                    ),
                  ],
                ),
                TextButton(
                  onPressed: onDetails,
                  child: const Text("Détails",
                      style: TextStyle(color: Colors.blue)),
                )
              ],
            ),
            const Divider(height: 20),

            /// Ligne 2 : FCFA 1700 / kg
            Text("FCFA $prixUnitaire /kg",
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),

            /// Ligne 3 : Moyen paiement
            Text(moyenPaiement, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 4),

            /// Ligne 4 : Montant à payer
            RichText(
              text: TextSpan(
                text: "Montant à payer  ",
                style: const TextStyle(color: Colors.black),
                children: [
                  TextSpan(
                    text: montantTotal,
                    style: const TextStyle(
                        color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),

            /// Ligne 5 : Statut
            Row(
              children: [
                const Text("Statut transaction: "),
                Text(
                  statut,
                  style: TextStyle(
                      color: statutColor, fontWeight: FontWeight.bold),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
