import 'package:flutter/material.dart';

class ProductInfoWidget extends StatefulWidget {
  final String productName;
  final String totalAmount;
  final String unitPrice;
  final String quantity;
  final String userInitial;
  final bool isExpanded;
  final VoidCallback? onToggle;

  const ProductInfoWidget({
    super.key,
    required this.productName,
    required this.totalAmount,
    required this.unitPrice,
    required this.quantity,
    required this.userInitial,
    this.isExpanded = false,
    this.onToggle,
  });

  @override
  State<ProductInfoWidget> createState() => _ProductInfoWidgetState();
}

class _ProductInfoWidgetState extends State<ProductInfoWidget> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre du produit
            Text(
              widget.productName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),

            // Montant à facturer (souligné)
            _buildInfoRow(
              'Montant à facturer',
              widget.totalAmount,
              isHighlighted: true,
            ),
            const SizedBox(height: 16),

            // Prix unitaire
            _buildInfoRow(
              'Prix Unitaire',
              widget.unitPrice,
            ),
            const SizedBox(height: 16),

            // Quantité à recevoir
            _buildInfoRow(
              'Quantité à recevoir',
              widget.quantity,
            ),
            const SizedBox(height: 20),

            // Section avec flèche et avatar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Flèche d'expansion
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                    widget.onToggle?.call();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      size: 24,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),

                // Avatar utilisateur
              ],
            ),

            // Contenu étendu (si nécessaire)
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
                      'Informations détaillées sur le produit et la commande...',
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

  Widget _buildInfoRow(String label, String value, {bool isHighlighted = false}) {
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
            //decoration: isHighlighted ? TextDecoration.underline : null,
            //decorationColor: isHighlighted ? Colors.blue : null,
            //decorationThickness: isHighlighted ? 2 : null,
          ),
        ),
      ],
    );
  }
}
