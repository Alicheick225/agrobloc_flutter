import 'package:agrobloc/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

class FilterButtons extends StatefulWidget {
  final void Function(int index) onFilterSelected;

  const FilterButtons({super.key, required this.onFilterSelected});

  @override
  State<FilterButtons> createState() => _FilterButtonsState();
}

class _FilterButtonsState extends State<FilterButtons> {
  int selectedIndex = 0;

  final List<String> filters = [
    'Offre de vente',
    'Financements',
    'Mes offres',
  ];

  void _handleTap(int index) {
    setState(() => selectedIndex = index);
    widget.onFilterSelected(index); // Notifie le parent
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          return GestureDetector(
            onTap: () => _handleTap(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryGreen : AppColors.cardBackground,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.primaryGreen : AppColors.border,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                filters[index],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.primaryGreen,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
