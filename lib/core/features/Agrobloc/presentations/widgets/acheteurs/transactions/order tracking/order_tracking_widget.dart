import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/acheteurs/transactions/order%20tracking/payement/selectpayemode.dart';
import 'package:flutter/material.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/commandeModel.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/acheteurs/transactions/order%20tracking/actioncard.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/acheteurs/transactions/order%20tracking/discuterBouton.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/acheteurs/transactions/order%20tracking/productInfo.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/acheteurs/transactions/order%20tracking/producteur_info.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/order_status.dart';

class OrderTrackingWidget extends StatelessWidget {
  final CommandeModel commande;
  final Function(OrderStatus)? onStatusUpdate;

  const OrderTrackingWidget({
    super.key,
    required this.commande,
    this.onStatusUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          _buildStatusTimeline(context),

          ChatWidget(
            userName: _getPlanteurName(),
            userInitial: _getPlanteurInitial(),
            unreadCount: 0,
            onChatPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Ouvrir chat avec ${_getPlanteurName()}…'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
          TypePayementWidget(
            onConfirm: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Paiement lancé')),
              );
            },
            cardHolderController: TextEditingController(),
            cardNumberController: TextEditingController(),
            expDateController: TextEditingController(),
            cvvController: TextEditingController(),
          ),
          const SizedBox(height: 24),

          ProductInfoWidget(
            commande: commande,
            //isExpanded: false,
            //onToggle: () {},
          ),
          const SizedBox(height: 24),
          ProducerInfoWidget(commande: commande),
          const SizedBox(height: 24),
          _buildCurrentActions(),
          const SizedBox(height: 20),
          //  Widget de formulaire (carte ou mobile money)
        ],
      ),
    );
  }

  /* ------------------- Méthodes privées ------------------- */
  Widget _buildStatusTimeline(BuildContext context) {
    final currentOrderStatus = _convertToOrderStatus(commande.statut);

    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Suivi',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: commande.statut.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: commande.statut.color.withOpacity(0.3)),
                  ),
                  child: Text(
                    _getStatusText(commande.statut),
                    style: TextStyle(
                      color: commande.statut.color,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildHorizontalStatusStep(
                    context: context,
                    title: 'Paiement',
                    description: 'En cours',
                    isCompleted: _isStatusCompleted(OrderStatus.waitingPayment),
                    isActive: currentOrderStatus == OrderStatus.waitingPayment,
                    icon: Icons.payment,
                    activeColor: Colors.orange,
                  ),
                  _buildHorizontalStatusStep(
                    context: context,
                    title: 'Livraison',
                    description: 'En cours',
                    isCompleted:
                        _isStatusCompleted(OrderStatus.waitingDelivery),
                    isActive: currentOrderStatus == OrderStatus.waitingDelivery,
                    icon: Icons.local_shipping,
                    activeColor: Colors.purple,
                  ),
                  _buildHorizontalStatusStep(
                    context: context,
                    title: 'Terminé',
                    description: 'Colis reçu',
                    isCompleted: currentOrderStatus == OrderStatus.completed,
                    isActive: currentOrderStatus == OrderStatus.completed,
                    icon: Icons.check_circle,
                    activeColor: Colors.green,
                    isLast: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalStatusStep({
    required BuildContext context,
    required String title,
    required String description,
    required bool isCompleted,
    required bool isActive,
    required IconData icon,
    Color? activeColor,
    bool isLast = false,
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
    final currentOrderStatus = _convertToOrderStatus(commande.statut);
    final buttons = _getCurrentActionButtons(currentOrderStatus);

    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            ...buttons,
          ],
        ),
      ),
    );
  }

  List<Widget> _getCurrentActionButtons(OrderStatus status) {
    switch (status) {
      case OrderStatus.waitingPayment:
        return [
          ActionButtonWidget(
            text: 'Annuler la transaction',
            type: ActionButtonType.danger,
            onPressed: () {},
          ),
        ];

      case OrderStatus.waitingDelivery:
        return [
          ActionButtonWidget(
            text: 'Confirmer la livraison',
            type: ActionButtonType.success,
            onPressed: () => onStatusUpdate?.call(OrderStatus.completed),
          ),
          const SizedBox(height: 12),
          ActionButtonWidget(
            text: 'Signaler un problème',
            type: ActionButtonType.danger,
            onPressed: () {},
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

      // On retire waitingPlanteurConfirmation
      default:
        return const [];
    }
  }
  /* ------------------- Utilitaires ------------------- */

  String _getPlanteurName() => 'Producteur ${commande.nomCulture}';
  String _getPlanteurInitial() => commande.nomCulture.isNotEmpty
      ? commande.nomCulture[0].toUpperCase()
      : 'P';
  String _getPlanteurPhone() => '07 XX XX XX XX';

  String _getStatusText(CommandeStatus status) {
    switch (status) {
      case CommandeStatus.enAttentePaiement:
        return 'En attente de paiement';
      case CommandeStatus.enAttenteLivraison:
        return 'En attente de livraison';
      case CommandeStatus.enAttenteReception:
        return 'En attente de réception';
      case CommandeStatus.annulee:
        return 'Annulée';
      case CommandeStatus.terminee:
        return 'Terminée';
    }
  }

  OrderStatus _convertToOrderStatus(CommandeStatus commandeStatus) {
    switch (commandeStatus) {
      case CommandeStatus.enAttentePaiement:
        return OrderStatus.waitingPayment;
      case CommandeStatus.enAttenteLivraison:
        return OrderStatus.waitingDelivery;
      case CommandeStatus.enAttenteReception:
        return OrderStatus.waitingReception; // <-- OK maintenant
      case CommandeStatus.annulee:
        return OrderStatus.cancelled; // <-- OK maintenant
      case CommandeStatus.terminee:
        return OrderStatus.completed;
    }
  }

  bool _isStatusCompleted(OrderStatus target) {
    final current = _convertToOrderStatus(commande.statut);
    return current.index > target.index;
  }
}
