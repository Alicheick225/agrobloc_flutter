import 'package:flutter/material.dart';

class FilterTransactionButtons extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onFilterSelected;

  const FilterTransactionButtons({
    super.key,
    required this.selectedIndex,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final filters = ['Achats', 'Préfinancements'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(filters.length, (index) {
        final isSelected = selectedIndex == index;

        return Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: OutlinedButton(
            onPressed: () => onFilterSelected(index),
            style: OutlinedButton.styleFrom(
              backgroundColor: isSelected ? Colors.green : Colors.white,
              side: BorderSide(color: isSelected ? Colors.green : Colors.grey),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
            child: Text(
              filters[index],
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }),
    );
  }
}
