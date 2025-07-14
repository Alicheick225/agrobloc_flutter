import 'package:agrobloc/core/features/Agrobloc/presentations/pages/homePage.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/transactions/card.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/transactions/detail.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/transactions/filter.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/transactions/filter_status.dart';
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text("Mes transactions"),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomePage()),
              );
            }),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                      onDetails: () {},
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
