import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/acheteurs/transactions/order%20tracking/nav.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/acheteurs/transactions/order%20tracking/order_tracking_widget.dart';
import 'package:flutter/material.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/order_status.dart';


class OrderTrackingScreen extends StatefulWidget {
  final String orderId;

  const OrderTrackingScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  OrderTrackingData? orderData;
  @override
  void initState() {
    super.initState();
    orderData = OrderTrackingData(
      orderId: widget.orderId,
      currentStatus: OrderStatus.waitingPayment,
      createdAt: DateTime.now(),
      planteurName: 'KOFFI',
      acheteurName: 'BILEY',
      planteurConfirmedAt: null,
      paymentInitiatedAt: null,
      deliveredAt: null,
    );
  }

  @override
  Widget build(BuildContext context) {

    if (orderData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
              preferredSize: const Size.fromHeight(70), // hauteur de ton NavWidget
              child: NavWidget(
                title: 'status commande',
                onBackPressed: () => Navigator.pop(context),
                onInfoPressed: () => print('Info pressed'),
              ),
            ),
      body: OrderTrackingWidget(
        orderData: orderData!,
        onStatusUpdate: _updateOrderStatus,
        
      ),
      
    );
  }

  void _updateOrderStatus(OrderStatus newStatus) {
    setState(() {
      orderData = OrderTrackingData(
        orderId: orderData!.orderId,
        currentStatus: newStatus,
        createdAt: orderData!.createdAt,
        planteurName: orderData!.planteurName,
        acheteurName: orderData!.acheteurName,
        planteurConfirmedAt: newStatus.index >= OrderStatus.waitingPayment.index 
            ? DateTime.now() 
            : orderData!.planteurConfirmedAt,
        paymentInitiatedAt: newStatus.index >= OrderStatus.waitingDelivery.index 
            ? DateTime.now() 
            : orderData!.paymentInitiatedAt,
        deliveredAt: newStatus == OrderStatus.completed 
            ? DateTime.now() 
            : orderData!.deliveredAt,
      );
    });

    // Afficher un message de confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_getStatusUpdateMessage(newStatus)),
        backgroundColor: Colors.green,
      ),
    );
  }

  String _getStatusUpdateMessage(OrderStatus status) {
    switch (status) {
      case OrderStatus.waitingPayment:
        return 'Commande confirmée par le planteur !';
      case OrderStatus.waitingDelivery:
        return 'Paiement effectué avec succès !';
      case OrderStatus.completed:
        return 'Commande terminée avec succès !';
      default:
        return 'Statut mis à jour';
    }
  }
}
