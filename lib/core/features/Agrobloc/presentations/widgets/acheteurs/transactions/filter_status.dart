import 'package:flutter/material.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/commandeModel.dart';

class FilterStatus extends StatelessWidget {
  final CommandeStatus? selectedStatus;
  final ValueChanged<CommandeStatus?> onStatusChanged;

  const FilterStatus({
    super.key,
    this.selectedStatus,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showStatusModal(context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                selectedStatus?.name ?? 'Statut',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.filter_alt_outlined),
            onPressed: () => _showStatusModal(context),
          ),
        ],
      ),
    );
  }

  void _showStatusModal(BuildContext context) async {
    final result = await showModalBottomSheet<CommandeStatus>(
      context: context,
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Filtrer par statut',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            ...CommandeStatus.values.map((status) => ListTile(
                  title: Text(status.name),
                  leading: Icon(
                    Icons.circle,
                    color: status.color,
                    size: 20,
                  ),
                  onTap: () => Navigator.pop(context, status),
                )),
            ListTile(
              title: const Text('Tous'),
              leading: const Icon(Icons.clear_all, color: Colors.grey),
              onTap: () => Navigator.pop(context, null),
            ),
          ],
        );
      },
    );
    onStatusChanged(result);
  }
}
