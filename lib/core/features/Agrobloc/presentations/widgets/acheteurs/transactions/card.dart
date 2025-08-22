import 'package:agrobloc/core/features/Agrobloc/data/models/commandeModel.dart';
import 'package:agrobloc/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

class TransactionCard extends StatelessWidget {
  final CommandeModel commande;
  final VoidCallback onDetails;

  const TransactionCard({
    super.key,
    required this.commande,
    required this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
    final montantTotal = '${commande.prixTotal.toStringAsFixed(0)} FCFA';

    return Card(
      color: AppColors.cardBackground,
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // ✅ Avatar avec photo du planteur ou initiale du nom de culture
                _buildAvatar(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ✅ Nom de la culture depuis l'API
                      Text(
                        commande.nomCulture,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "certifié BIO CI (1/4) 100%",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      // ✅ Quantité si disponible
                      if (commande.quantite > 0)
                        Text(
                          "Quantité: ${commande.quantite.toStringAsFixed(1)} kg",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 20),

            // ✅ Informations de la commande
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.shopping_cart, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      commande.nomCommandeAvecDate,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            /// Montant à payer
            RichText(
              text: TextSpan(
                text: "Montant à payer  ",
                style: DefaultTextStyle.of(context).style,
                children: [
                  TextSpan(
                    text: montantTotal,
                    style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ✅ Statut de la commande
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              decoration: BoxDecoration(
                color: commande.statut.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: commande.statut.color.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: commande.statut.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getStatusText(commande.statut),
                    style: TextStyle(
                      color: commande.statut.color,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),

            /// Bouton de suivi
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onDetails,
                    icon: const Icon(Icons.track_changes, size: 18),
                    label: const Text("Suivez la commande"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    // ✅ Si on a une photo du planteur, l'afficher
    if (commande.photoPlanteurUrl != null) {
      return CircleAvatar(
        radius: 24,
        backgroundColor: Colors.grey[200],
        child: ClipOval(
          child: Image.network(
            commande.photoPlanteurUrl!,
            width: 48,
            height: 48,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // En cas d'erreur de chargement, afficher l'initiale
              return _buildInitialAvatar();
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const CircularProgressIndicator(strokeWidth: 2);
            },
          ),
        ),
      );
    }

    // ✅ Sinon, afficher l'initiale du nom de culture
    return _buildInitialAvatar();
  }

  Widget _buildInitialAvatar() {
    return CircleAvatar(
      radius: 24,
      backgroundColor: Colors.green[100],
      child: Text(
        commande.nomCulture.isNotEmpty
            ? commande.nomCulture[0].toUpperCase()
            : '?',
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }

  String _getStatusText(CommandeStatus status) {
    switch (status) {
      case CommandeStatus.enCours:
        return "En cours";
      case CommandeStatus.termine:
        return "Terminée";
      case CommandeStatus.annule:
        return "Annulée";
      default:
        return status.name;
    }
  }
}