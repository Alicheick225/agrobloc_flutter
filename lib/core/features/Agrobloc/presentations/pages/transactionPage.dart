import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/transactions/Detail_transaction/detailTransactionpage.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/transactions/card.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/transactions/filter.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/transactions/filter_status.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/transactions/nav.dart';
import 'package:flutter/material.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  int selectedFilter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFCFC),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const NavTransactionWidget(),

            /// Boutons de filtres
            FilterTransactionButtons(
              selectedIndex: selectedFilter,
              onFilterSelected: (index) {
                setState(() => selectedFilter = index);
              },
            ),
            const SizedBox(height: 16),
            //FILTRE PAR STATUT
            const FilterStatus(),
            const SizedBox(height: 16),

            /// Liste des transactions (temporaire)
            Expanded(
              child: ListView(
                children: [
                  if (selectedFilter == 0)
                    TransactionCard(
                      nom: "Achats - Antoine",
                      prixUnitaire: "1700",
                      moyenPaiement: "Orange Money",
                      montantTotal: "15.000.000 FCFA",
                      statut: "Terminé",
                      statutColor: Colors.green,
                      onDetails: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => Detailtransactionpage(),
                          ),
                        );
                      },
                    ),
                  if (selectedFilter == 1)
                    TransactionCard(
                      nom: "Préfinancement - Antoine",
                      prixUnitaire: "2200",

                      moyenPaiement: "Wave",
                      montantTotal: "8.000.000 FCFA",
                      statut: "En Cours",
                      statutColor: Colors.orange,
                      onDetails: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const Detailtransactionpage(),
                          ),
                        );
                      },
                    ),
                  if (selectedFilter == 1)
                    TransactionCard(
                      nom: "Préfinancement - Antoine",
                      prixUnitaire: "2200",
                      moyenPaiement: "Wave",
                      montantTotal: "8.000.000 FCFA",
                      statut: "En Cours",
                      statutColor: Colors.orange,
                      onDetails: () {},
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
