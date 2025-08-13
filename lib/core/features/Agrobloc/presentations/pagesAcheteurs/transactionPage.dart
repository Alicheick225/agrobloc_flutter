import 'dart:convert';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/acheteurs/transactions/card.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/acheteurs/transactions/filter.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/commandeService.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/commandeModel.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/acheteurs/transactions/filter_status.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/acheteurs/transactions/nav.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/acheteurs/transactions/order%20tracking/Trackingpage.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  CommandeStatus? _selectedStatus;
  int selectedFilter = 0;
  late Future<List<CommandeModel>> _future;
  final CommandeService _commandeService = CommandeService();

  @override
  void initState() {
    super.initState();
    _loadCommandes();
  }

  void _loadCommandes() {
    _future = _commandeService.getAllCommandes();
  }

  void _onStatusChanged(CommandeStatus? status) {
    setState(() {
      _selectedStatus = status;
      // Tu peux aussi déclencher un reload si besoin :
      // _loadCommandes();
    });
  }

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
            const SizedBox(height: 16),
            /// Boutons de filtres
            FilterTransactionButtons(
              selectedIndex: selectedFilter,
              onFilterSelected: (index) {
                setState(() => selectedFilter = index);
              },
            ),
            const SizedBox(height: 16),
            //FILTRE PAR STATUT
            //FilterStatus(
             //   selectedStatus: _selectedStatus,
               // onStatusChanged: (status) {
                //  setState(() {
                //  _selectedStatus = status;
                  //      });
                  //  },
                //  ),
            const SizedBox(height: 16),

            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<CommandeModel>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Erreur : ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Aucune commande.'));
                  } else {
                    final commandes = snapshot.data!;
                    final filtered = _selectedStatus == null
                        ? commandes
                        : commandes.where((c) => c.statut == _selectedStatus).toList();

                    if (filtered.isEmpty) {
                      return const Center(child: Text('Aucune commande avec ce statut.'));
                    }

                    return ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final commande = filtered[i];
                        return TransactionCard(
                         nom: 'Acheteur ${commande.acheteurId}',
                         prixUnitaire: commande.quantite.toStringAsFixed(0),
                         moyenPaiement: commande.modePaiementId,
                         montantTotal: '${commande.prixTotal.toStringAsFixed(0)} FCFA',
                         statut: commande.statut.name,
                         statutColor: commande.statut.color,
                         onDetails: () {
                          Navigator.push(
                            context,
                              MaterialPageRoute(
                                builder: (_) => OrderTrackingScreen(orderId: commande.id),
                              ),
                            );
                          },
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
