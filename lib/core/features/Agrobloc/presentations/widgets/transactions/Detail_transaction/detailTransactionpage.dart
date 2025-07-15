import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/transactions/Detail_transaction/button.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/transactions/Detail_transaction/card.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/transactions/Detail_transaction/detail_card.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/transactions/Detail_transaction/nav.dart';
import 'package:flutter/material.dart';

class Detailtransactionpage extends StatelessWidget {
  const Detailtransactionpage({super.key});

  @override
  Widget build(BuildContext context) {
    // Données d'exemple - vous pouvez les remplacer par vos vraies données
    final List<TransactionActor> actors = [
      TransactionActor(
        name: 'Vincent Patrick',
        role: 'Acheteur',
        organization: 'Orange Money',
        action: 'Paiement par OM',
        date: 'Sep 10, 2025',
        time: '16:30',
        isCompleted: true,
      ),
      TransactionActor(
        name: 'Koussai Antoine',
        role: 'Planteur',
        organization: '',
        action: 'Réception par wave',
        date: 'Sep 10, 2025',
        time: '16:35',
        isCompleted: true,
      ),
    ];

    final TransactionDetails details = TransactionDetails(
      transactionId: '#1235DKZ13Z',
      totalTransaction: '15.000.000,00',
      transactionFees: '0,5%',
      totalPaid: '15.075.000,00',
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Widget de navigation
          NavWidget(
            title: 'Détails paiement',
            onBackPressed: () => Navigator.pop(context),
            onInfoPressed: () {
              // Action pour le bouton info
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Information'),
                  content: Text('Détails sur cette transaction'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),

          // Contenu scrollable
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  // Widget des cartes d'acteurs
                  CardWidget(actors: actors),
                  SizedBox(height: 24),

                  // Widget des détails de transaction
                  DetailCardWidget(details: details),
                  SizedBox(height: 32),

                  // Widget du bouton d'impression
                  ImprimerWidget(
                    onPressed: () {
                      _handlePrintReceipt(context);
                    },
                  ),
                ],
              ),
            ),
          ),

          // Navigation bottom (optionnelle)
        ],
      ),
    );
  }

  void _handlePrintReceipt(BuildContext context) {
    // Logique d'impression du reçu
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Impression du reçu en cours...'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home_outlined, 'Accueil', false),
          _buildNavItem(Icons.notifications_outlined, '', false),
          _buildNavItem(Icons.chat_bubble_outline, 'WhatsApp', true),
          _buildNavItem(Icons.person_outline, 'Profil', false),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isActive ? Colors.green[700] : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isActive ? Colors.white : Colors.grey[600],
            size: 24,
          ),
        ),
        if (label.isNotEmpty) ...[
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isActive ? Colors.green[700] : Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }
}
