import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/transactions/order%20tracking/actioncard.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/transactions/order%20tracking/discuterBouton.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/transactions/order%20tracking/productInfo.dart';
import 'package:flutter/material.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/order_status.dart';


class OrderTrackingWidget extends StatelessWidget {
  final OrderTrackingData orderData;
  final Function(OrderStatus)? onStatusUpdate;

  const OrderTrackingWidget({
    super.key,
    required this.orderData,
    this.onStatusUpdate,
  });

  @override
Widget build(BuildContext context) {
  return SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        _buildStatusTimeline(),
        ChatWidget(
            userName: 'Antoine Kouassi',
            userInitial: 'A',
            unreadCount: 4,
            onChatPressed: () {
              // Action pour ouvrir le chat
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ouverture du chat...'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ProductInfoWidget(
          productName: 'Cacao Premium',
          totalAmount: '1000 FCFA',
          unitPrice: '500 FCFA/kg',
          quantity: '2 kg',
          userInitial: 'A',
          onToggle: () {
            // Action pour basculer l'état développé
          },
        ),
        const SizedBox(height: 24),
        _buildCurrentActions(),
        const SizedBox(height: 24),
      ],
    ),
  );
}


  Widget _buildStatusTimeline() {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //const SizedBox(height: 0),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: _buildHorizontalTimelineSteps(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalTimelineSteps() {
    return Builder(
      builder: (context) => Row(
        children: [
          _buildHorizontalStatusStep(
            context: context,
            title: 'En attente planteur',
            description: '...',
            isCompleted: _isStatusCompleted(OrderStatus.waitingPlanteurConfirmation),
            isActive: orderData.currentStatus == OrderStatus.waitingPlanteurConfirmation,
            isLast: false,
            icon: Icons.pending_actions,
          ),
          _buildHorizontalStatusStep(
            context: context,
            title: 'En attente paiement',
            description: '...',
            isCompleted: _isStatusCompleted(OrderStatus.waitingPayment),
            isActive: orderData.currentStatus == OrderStatus.waitingPayment,
            isLast: false,
            icon: Icons.payment,
            activeColor: Colors.orange,
          ),
          _buildHorizontalStatusStep(
            context: context,
            title: 'En attente Livraison',
            description: '...',
            isCompleted: _isStatusCompleted(OrderStatus.waitingDelivery),
            isActive: orderData.currentStatus == OrderStatus.waitingDelivery,
            isLast: false,
            icon: Icons.local_shipping,
            activeColor: Colors.purple,
          ),
          _buildHorizontalStatusStep(
            context: context,
            title: 'Commande terminée',
            description: '...',
            isCompleted: orderData.currentStatus == OrderStatus.completed,
            isActive: orderData.currentStatus == OrderStatus.completed,
            isLast: true,
            icon: Icons.check_circle,
            activeColor: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalStatusStep({
    required BuildContext context,
    required String title,
    required String description,
    required bool isCompleted,
    required bool isActive,
    required bool isLast,
    required IconData icon,
    Color? activeColor,
  }) {
    final color = isCompleted 
        ? Colors.green 
        : isActive 
            ? (activeColor ?? Theme.of(context).primaryColor)
            : Colors.grey;

    return Row(
      children: [
        Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isCompleted ? Colors.green : Colors.white,
                border: Border.all(color: color, width: 2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCompleted ? Icons.check : icon,
                color: isCompleted ? Colors.white : color,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 55,
              child: Column(
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isActive ? color : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (!isLast)
          Container(
            width: 40,
            height: 3,
            margin: const EdgeInsets.only(bottom: 40),
            color: isCompleted ? Colors.green : Colors.grey.shade300,
          ),
      ],
    );
  }

  Widget _buildCurrentActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Actions en cours',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height:6),
            Row(
              children: _getCurrentActionCards()
                  .map((card) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 1),
                          child: card,
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _getCurrentActionCards() {
    switch (orderData.currentStatus) {
      case OrderStatus.waitingPlanteurConfirmation:
        return [
          UserActionCard(
            userType: 'Planteur',
            action: 'Confirmer la commande',
            status: 'Action requise',
            isActive: true,
            actionButtonText: 'Confirmer',
            onActionPressed: () => onStatusUpdate?.call(OrderStatus.waitingPayment),
         ),
          UserActionCard(
            userType: 'Acheteur',
            action: 'Attendre la confirmation',
            status: 'En attente',
            isActive: false,
          ),
        ];

      case OrderStatus.waitingPayment:
        return [
          UserActionCard(
            userType: 'Acheteur',
            action: 'Effectuer le paiement',
            status: 'Action requise',
            isActive: true,
            actionButtonText: 'Payer',
            onActionPressed: () => onStatusUpdate?.call(OrderStatus.waitingDelivery),
          ),
          const SizedBox(height: 8),
          UserActionCard(
            userType: 'Planteur',
            action: 'Attendre le paiement',
            status: 'En attente',
            isActive: false,
          ),
        ];

      case OrderStatus.waitingDelivery:
        return [
          UserActionCard(
            userType: 'Planteur',
            action: 'Confirmer la livraison',
            status: 'Action requise',
            isActive: true,
            actionButtonText: 'Livré',
            onActionPressed: () => _showDeliveryConfirmation(),
          ),
          const SizedBox(height: 8),
          UserActionCard(
            userType: 'Acheteur',
            action: 'Confirmer la réception',
            status: 'En attente de livraison',
            isActive: false,
          ),
        ];

      case OrderStatus.completed:
        return [
          UserActionCard(
            userType: 'Planteur',
            action: 'Commande terminée',
            status: 'Terminé',
            isActive: false,
          ),
          const SizedBox(height: 8),
          UserActionCard(
            userType: 'Acheteur',
            action: 'Commande reçue',
            status: 'Terminé',
            isActive: false,
          ),
        ];
    }
  }

  bool _isStatusCompleted(OrderStatus status) {
    switch (status) {
      case OrderStatus.waitingPlanteurConfirmation:
        return orderData.currentStatus.index > OrderStatus.waitingPlanteurConfirmation.index;
      case OrderStatus.waitingPayment:
        return orderData.currentStatus.index > OrderStatus.waitingPayment.index;
      case OrderStatus.waitingDelivery:
        return orderData.currentStatus.index > OrderStatus.waitingDelivery.index;
      case OrderStatus.completed:
        return orderData.currentStatus == OrderStatus.completed;
    }
  }

  void _showDeliveryConfirmation() {
    // Ici vous pouvez ajouter une logique pour confirmer la livraison
    // Par exemple, ouvrir un dialog de confirmation
    onStatusUpdate?.call(OrderStatus.completed);
  }

}

