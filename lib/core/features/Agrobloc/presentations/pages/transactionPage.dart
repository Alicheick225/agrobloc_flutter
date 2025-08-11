import 'package:agrobloc/core/features/Agrobloc/data/dataSources/commande_vente_service.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/commande_vente.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/acheteurs/transactions/card.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/acheteurs/transactions/filter.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/acheteurs/transactions/filter_status.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/acheteurs/transactions/nav.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/acheteurs/transactions/order%20tracking/Trackingpage.dart';

import 'package:flutter/material.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  CommandeStatus? _selectedStatus;
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
            FilterStatus(
                          selectedStatus: _selectedStatus,
                          onStatusChanged: (status) {
                            setState(() {
                              _selectedStatus = status;
                            });
                          },
                        ),
            const SizedBox(height: 16),

            /// Liste des transactions (temporaire)
          Expanded(
            child: FutureBuilder<List<CommandeVente>>(
              future: CommandeVenteService().getAllCommandes(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final list = snapshot.data ?? [];
                final filtered = _selectedStatus == null
                    ? list
                    : list.where((c) => c.statut == _selectedStatus).toList();

                if (filtered.isEmpty) {
                  return Center(child: Text('Aucune commande correspondante.'));
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final c = filtered[i];
                    return TransactionCard(
                      nom: 'Acheteur ${c.acheteurId}',
                      prixUnitaire: c.quantite.toStringAsFixed(0),
                      moyenPaiement: c.modePaiementId,
                      montantTotal: '${c.prixTotal.toStringAsFixed(0)} FCFA',
                      statut: c.statut.name,
                      statutColor: c.statut.color,
                      onDetails: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OrderTrackingScreen(orderId: "123"),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          ],
        ),
      ),
    );
  }
}
