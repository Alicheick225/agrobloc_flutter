import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/transactions/order%20tracking/actioncard.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/transactions/order%20tracking/discuterBouton.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/transactions/order%20tracking/productInfo.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/transactions/order%20tracking/producteur_info.dart';
import 'package:flutter/material.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/order_status.dart';


class OrderTrackingWidget extends StatelessWidget {
  final OrderTrackingData orderData;
  final Function(OrderStatus)? onStatusUpdate;

const OrderTrackingWidget({
  Key? key,
  required this.orderData,
  required this.onStatusUpdate,
}) : super(key: key);

  @override
Widget build(BuildContext context) {
  return SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        _buildStatusTimeline(context),
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
        const SizedBox(height: 24),
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
          ProducerInfoWidget(
            producerName: 'Antoine Kouassi',
            phoneNumber: '07 69 28 3031',
            orderStatus: orderData.currentStatus,
          ),
        const SizedBox(height: 24),
        _buildCurrentActions(),
      ],
    ),
  );
}

Widget _buildOrderHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Commande #${orderData.orderId}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Planteur: ${orderData.planteurName}',
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              'Acheteur: ${orderData.acheteurName}',
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              'Créée le: ${_formatDate(orderData.createdAt)}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

   Widget _buildStatusTimeline(BuildContext context) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Suivi de la commande',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: _buildHorizontalTimelineSteps(context),
            ),
          ],
        ),
      ),
    );
  }

   Widget _buildHorizontalTimelineSteps(BuildContext context) {
    return Row(
      children: [
        _buildHorizontalStatusStep(
          context: context,
          title: 'Confirmation',
          description: 'Planteur confirme',
          isCompleted: _isStatusCompleted(OrderStatus.waitingPlanteurConfirmation),
          isActive: orderData.currentStatus == OrderStatus.waitingPlanteurConfirmation,
          isLast: false,
          icon: Icons.pending_actions,
        ),
        _buildHorizontalStatusStep(
          context: context,
          title: 'Paiement',
          description: 'Acheteur paie',
          isCompleted: _isStatusCompleted(OrderStatus.waitingPayment),
          isActive: orderData.currentStatus == OrderStatus.waitingPayment,
          isLast: false,
          icon: Icons.payment,
          activeColor: Colors.orange,
        ),
        _buildHorizontalStatusStep(
          context: context,
          title: 'Livraison',
          description: 'Livraison en cours',
          isCompleted: _isStatusCompleted(OrderStatus.waitingDelivery),
          isActive: orderData.currentStatus == OrderStatus.waitingDelivery,
          isLast: false,
          icon: Icons.local_shipping,
          activeColor: Colors.purple,
        ),
        _buildHorizontalStatusStep(
          context: context,
          title: 'Terminé',
          description: 'Colis reçu',
          isCompleted: orderData.currentStatus == OrderStatus.completed,
          isActive: orderData.currentStatus == OrderStatus.completed,
          isLast: true,
          icon: Icons.check_circle,
          activeColor: Colors.green,
        ),
      ],
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
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            ..._getCurrentActionButtons(),
          ],
        ),
      ),
    );
  }


  List<Widget> _getCurrentActionButtons() {
    switch (orderData.currentStatus) {
      case OrderStatus.waitingPlanteurConfirmation:
        return [
          ActionButtonWidget(
            text: 'Confirmer la commande',
            type: ActionButtonType.success,
            onPressed: () => onStatusUpdate?.call(OrderStatus.waitingPayment),
          ),
          const SizedBox(height: 12),
          ActionButtonWidget(
            text: 'Annuler la transaction',
            type: ActionButtonType.danger,
            onPressed: () => _showCancelDialog(),
          ),
        ];

      case OrderStatus.waitingPayment:
        return [
          ActionButtonWidget(
            text: 'Faire le paiement',
            type: ActionButtonType.success,
            onPressed: () => onStatusUpdate?.call(OrderStatus.waitingDelivery),
          ),
          const SizedBox(height: 12),
          ActionButtonWidget(
            text: 'Annuler la transaction',
            type: ActionButtonType.danger,
            onPressed: () => _showCancelDialog(),
          ),
        ];

      case OrderStatus.waitingDelivery:
        return [
          ActionButtonWidget(
            text: 'Confirmer la livraison',
            type: ActionButtonType.success,
            onPressed: () => _showDeliveryConfirmation(),
          ),
          const SizedBox(height: 12),
          ActionButtonWidget(
            text: 'Signaler un problème',
            type: ActionButtonType.danger,
            onPressed: () => _showProblemDialog(),
          ),
        ];

      case OrderStatus.completed:
        return [
          ActionButtonWidget(
            text: 'Commande terminée',
            type: ActionButtonType.secondary,
            isEnabled: false,
            onPressed: null,
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
    onStatusUpdate?.call(OrderStatus.completed);
  }

  void _showCancelDialog() {
    // Logique pour annuler la transaction
  }

  void _showProblemDialog() {
    // Logique pour signaler un problème
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

}

