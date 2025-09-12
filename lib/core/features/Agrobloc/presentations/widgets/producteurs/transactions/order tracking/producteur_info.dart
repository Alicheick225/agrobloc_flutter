import 'package:flutter/material.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/commandeModel.dart';

class ProducerInfoWidget extends StatelessWidget {
  final CommandeModel commande;

  const ProducerInfoWidget({
    super.key,
    required this.commande,
  });

  @override
  Widget build(BuildContext context) {
    final planteurName = commande.photoPlanteurUrl?.split('/').last ??
        'Producteur ${commande.nomCulture}';
    final phoneNumber =
        'À renseigner'; // <-- ajoute ce champ côté back si besoin

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
              planteurName,
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
              _getStatusText(commande.statut),
              valueColor: commande.statut.color,
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
}
