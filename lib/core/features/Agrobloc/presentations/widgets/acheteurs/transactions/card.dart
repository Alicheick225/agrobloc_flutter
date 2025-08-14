import 'package:agrobloc/core/features/Agrobloc/data/dataSources/annonceVenteService.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/acheteurs/transactions/order%20tracking/Trackingpage.dart';
import 'package:agrobloc/core/themes/app_colors.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/pagesAcheteurs/transactionPage.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/AnnonceVenteModel.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/commandeModel.dart';
import 'package:flutter/material.dart';

class TransactionCard extends StatelessWidget {
  final String annoncesVenteId;
  final String prixUnitaire;
  final String moyenPaiement;
  final String montantTotal;
  final String statut;
  final Color statutColor;
  final VoidCallback onDetails;

  const TransactionCard({
    Key? key,
    required this.annoncesVenteId,
    required this.prixUnitaire,
    required this.moyenPaiement,
    required this.montantTotal,
    required this.statut,
    required this.statutColor,
    required this.onDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return FutureBuilder<AnnonceVente>(
      future: AnnonceService().getAnnonceById(annoncesVenteId),
      builder: (context, snapshot) {
        final produitNom = snapshot.data?.typeCultureLibelle ?? 'Chargement...';
    
      return Card(
        color: AppColors.cardBackground,
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.green[100],
                        child: Text(produitNom[0],
                            style: const TextStyle(color: Colors.black)),
                      ),
                      const SizedBox(width: 5),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(produitNom,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          const Text("certifiez BIO CI (1/4)  100%"),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 20),

              /// Ligne 2 : FCFA 1700 / kg
              //Text("FCFA $prixUnitaire /kg",
                  //style:
                      //const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 8),
              /// Ligne 4 : Montant à payer
              RichText(
                text: TextSpan(
                  text: "Montant à payer  ",
                  style: DefaultTextStyle.of(context).style,
                  children: [
                    TextSpan(
                      text: montantTotal,
                      style: const TextStyle(
                          color: Colors.green, fontWeight: FontWeight.bold,fontSize: 18),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              /// Ligne 5 : Statut
              /// 
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: ElevatedButton(
                    onPressed: onDetails,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Suivez la commande",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            )
            ],
          ),
        ),
      );
    });
  }            
}
