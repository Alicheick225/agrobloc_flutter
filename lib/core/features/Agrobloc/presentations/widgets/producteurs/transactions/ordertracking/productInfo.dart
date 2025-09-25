import 'package:flutter/material.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/commandeModel.dart';

class ProductInfoWidget extends StatefulWidget {
  final CommandeModel commande;
  final bool isExpanded;
  final VoidCallback? onToggle;

  const ProductInfoWidget({
    super.key,
    required this.commande,
    this.isExpanded = false,
    this.onToggle,
  });

  @override
  State<ProductInfoWidget> createState() => _ProductInfoWidgetState();
}

class _ProductInfoWidgetState extends State<ProductInfoWidget> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final cmd = widget.commande;

    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre du produit
            Text(
              cmd.nomCommande,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),

            // Montant à facturer
            _buildInfoRow(
              'Montant à facturer',
              '${cmd.prixTotal.toStringAsFixed(2)} FCFA',
              isHighlighted: true,
            ),
            const SizedBox(height: 16),

            // Prix unitaire (approximation)
            _buildInfoRow(
              'Prix Unitaire',
              '${(cmd.prixTotal / cmd.quantite).toStringAsFixed(2)} FCFA/kg',
            ),
            const SizedBox(height: 16),

            // Quantité à recevoir
            _buildInfoRow(
              'Quantité à recevoir',
              '${cmd.quantite.toStringAsFixed(1)} kg',
            ),
            const SizedBox(height: 20),

            // Ligne flèche + avatar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() => _isExpanded = !_isExpanded);
                    widget.onToggle?.call();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 24,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: cmd.photoPlanteurUrl != null
                      ? NetworkImage(cmd.photoPlanteurUrl!)
                      : null,
                  child: cmd.photoPlanteurUrl == null
                      ? Text(
                          cmd.nomCulture.isNotEmpty
                              ? cmd.nomCulture[0].toUpperCase()
                              : '?',
                          style: const TextStyle(color: Colors.black87),
                        )
                      : null,
                ),
              ],
            ),

            // Contenu étendu
            if (_isExpanded) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Détails supplémentaires',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Commande n°${cmd.id}\n'
                      'Type : ${cmd.typeCulture}\n'
                      'Statut : ${cmd.statut.name}\n'
                      'Créée le : ${cmd.createdAt.day}/${cmd.createdAt.month}/${cmd.createdAt.year}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value,
      {bool isHighlighted = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }
}
