import 'package:flutter/material.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/commandeModel.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/acheteurs/transactions/order%20tracking/nav.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/acheteurs/transactions/order%20tracking/order_tracking_widget.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;
  final CommandeModel commande; // ✅ Ajouté

  const OrderTrackingScreen({
    super.key,
    required this.orderId,
    required this.commande, // ✅ Requis
  });

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: NavWidget(
          title: 'Statut commande',
          onBackPressed: () => Navigator.pop(context),
          onInfoPressed: () {},
        ),
      ),
      body: OrderTrackingWidget(
        commande: widget.commande, // ✅ Données réelles
        onStatusUpdate: (_) {}, // ou appelle ton service ici
      ),
    );
  }
}
