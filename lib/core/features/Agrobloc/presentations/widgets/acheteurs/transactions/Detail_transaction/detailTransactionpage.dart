import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/commande_vente.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/commande_vente_service.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/acheteurs/transactions/Detail_transaction/card.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/acheteurs/transactions/Detail_transaction/detail_card.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/acheteurs/transactions/Detail_transaction/nav.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/acheteurs/transactions/Detail_transaction/button.dart';

class Detailtransactionpage extends StatelessWidget {
  final String commandeId;

  const Detailtransactionpage({super.key, required this.commandeId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<CommandeVente>(
        future: CommandeVenteService().getCommandeById(commandeId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }

          final commande = snapshot.data!;

          // Acteurs
          final actors = [

            TransactionActor(
              name: '${commande.annoncesVenteId}',
              role: 'Planteur',
              organization: '',
              action: _getAction(commande.statut),
              date: DateFormat('MMM dd, yyyy').format(commande.createdAt),
              time: DateFormat('HH:mm').format(commande.createdAt),
              isCompleted: commande.statut != CommandeStatus.enCours,
            ),
                        TransactionActor(
              name: '${commande.acheteurId}',
              role: 'Acheteur',
              organization: commande.modePaiementId,
              action: 'Paiement via ${commande.modePaiementId}',
              date: DateFormat('MMM dd, yyyy').format(commande.createdAt),
              time: DateFormat('HH:mm').format(commande.createdAt),
              isCompleted: true,
            ),
          ];

          // Détails
          final details = TransactionDetails(
            transactionId: commande.id,
            totalTransaction: NumberFormat.currency(
              locale: 'fr_FR',
              symbol: '',
              decimalDigits: 0,
            ).format(commande.prixTotal),
            transactionFees: '0,5%',
            totalPaid: NumberFormat.currency(
              locale: 'fr_FR',
              symbol: '',
              decimalDigits: 0,
            ).format(commande.prixTotal * 1.005),
          );

          return Column(
            children: [
              NavWidget(
                title: 'Détails paiement',
                onBackPressed: () => Navigator.pop(context),
                onInfoPressed: () => print('Info pressed'),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CardWidget(actors: actors),
                      const SizedBox(height: 24),
                      DetailCardWidget(details: details),
                      const SizedBox(height: 32),
                      ImprimerWidget(
                        commandeStatus: commande.statut,
                        onPressed: () => _handleAction(context, commande),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _getAction(CommandeStatus status) {
    switch (status) {
      case CommandeStatus.enCours:
        return 'En attente de confirmation';
      case CommandeStatus.termine:
        return 'Commande livrée';
      case CommandeStatus.annule:
        return 'Commande annulée';
    }
  }

  void _handleAction(BuildContext context, CommandeVente commande) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Action sur ${commande.id}'),
        backgroundColor: commande.statut.color,
      ),
    );
  }
}