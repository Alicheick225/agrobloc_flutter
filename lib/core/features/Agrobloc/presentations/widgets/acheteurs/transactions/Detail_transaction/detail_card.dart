import 'package:flutter/material.dart';

class DetailCardWidget extends StatelessWidget {
  final TransactionDetails details;

  const DetailCardWidget({
    Key? key,
    required this.details,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Détails Commande',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 20),
          _buildDetailRow('Transaction ID', details.transactionId),
          SizedBox(height: 16),
          _buildDetailRow('Total transaction', details.totalTransaction),
          SizedBox(height: 16),
          _buildDetailRow('Frais transaction', details.transactionFees),
          SizedBox(height: 16),
          Divider(color: Colors.grey[300]),
          SizedBox(height: 16),
          _buildDetailRow(
            'Total payé',
            details.totalPaid,
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: isTotal ? Colors.black : Colors.grey[800],
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// Modèle de données pour les détails de transaction
class TransactionDetails {
  final String transactionId;
  final String totalTransaction;
  final String transactionFees;
  final String totalPaid;

  TransactionDetails({
    required this.transactionId,
    required this.totalTransaction,
    required this.transactionFees,
    required this.totalPaid,
  });
}
