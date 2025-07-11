import 'package:flutter/material.dart';

class FilterStatus extends StatelessWidget {
  final VoidCallback? onFilterPressed;

  const FilterStatus({
    Key? key,
    this.onFilterPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<String> filters = ['Recent', 'Prix. U', 'Statut'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        /// Boutons texte avec flèche
        Expanded(
          child: Row(
            children: filters.map((filter) {
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: () {
                    // Tu peux plus tard ouvrir une modal ou menu
                    debugPrint("Filtre $filter tapé");
                  },
                  child: Row(
                    children: [
                      Text(
                        filter,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        /// Icône filtre (à droite)
        IconButton(
          onPressed: onFilterPressed ?? () {},
          icon: const Icon(Icons.filter_alt_outlined),
        ),
      ],
    );
  }
}
