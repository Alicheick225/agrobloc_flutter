import 'package:flutter/material.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/order_status.dart';

class ProducerInfoWidget extends StatelessWidget {
  final String producerName;
  final String phoneNumber;
  final OrderStatus orderStatus;

  const ProducerInfoWidget({
    Key? key,
    required this.producerName,
    required this.phoneNumber,
    required this.orderStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildInfoRow(
              'Nom du producteur',
              producerName,
              valueColor: Colors.grey.shade700,
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              'Numéro de téléphone',
              phoneNumber,
              valueColor: Colors.grey.shade700,
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              'Statut commande',
              _getStatusText(orderStatus),
              valueColor: _getStatusColor(orderStatus),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 16,
              color: valueColor ?? Colors.grey.shade800,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.waitingPlanteurConfirmation:
        return 'En attente de confirmation';
      case OrderStatus.waitingPayment:
        return 'En attente de paiement';
      case OrderStatus.waitingDelivery:
        return 'En cours de livraison';
      case OrderStatus.completed:
        return 'Commande terminée';
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.waitingPlanteurConfirmation:
        return Colors.orange.shade600;
      case OrderStatus.waitingPayment:
        return Colors.blue.shade600;
      case OrderStatus.waitingDelivery:
        return Colors.purple.shade600;
      case OrderStatus.completed:
        return Colors.green.shade600;
    }
  }
}
