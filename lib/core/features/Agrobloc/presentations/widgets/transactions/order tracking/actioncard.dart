import 'package:flutter/material.dart';

class UserActionCard extends StatelessWidget {
  final String userType;
  final String action;
  final String status;
  final bool isActive;
  final VoidCallback? onActionPressed;
  final String? actionButtonText;

  const UserActionCard({
    Key? key,
    required this.userType,
    required this.action,
    required this.status,
    required this.isActive,
    this.onActionPressed,
    this.actionButtonText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isActive ? 4 : 1,
      color: isActive ? Colors.blue.shade50 : Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  userType == 'Planteur' ? Icons.agriculture : Icons.person,
                  color: isActive ? Colors.blue : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  userType,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isActive ? Colors.blue : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              action,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Statut: $status',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: isActive ? Colors.blue.shade700 : Colors.grey.shade600,
              ),
            ),
            if (isActive && onActionPressed != null && actionButtonText != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: ElevatedButton(
                  onPressed: onActionPressed,
                  child: Text(actionButtonText!),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
