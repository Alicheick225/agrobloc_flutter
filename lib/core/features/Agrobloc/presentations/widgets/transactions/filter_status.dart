import 'package:flutter/material.dart';

class FilterStatus extends StatefulWidget {
  final VoidCallback? onFilterPressed; final Function(String?)? onStatusChanged;

  const FilterStatus({
    Key? key,
    this.onFilterPressed,
    this.onStatusChanged,
  }) : super(key: key);

  @override
  State<FilterStatus> createState() => _FilterStatusState();
  }
    class _FilterStatusState extends State<FilterStatus> {

        // Variables d'état pour les filtres
      String? selectedPriceFilter;
      String? selectedStatusFilter;
      
      @override
      Widget build(BuildContext context) {
      final List<String> filters = ['Statut'];
    
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
                      onTap: () => _handleFilterTap(filter),
                      child: Row(
                        children: [
                          Text(
                            filter,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: _isFilterActive(filter) ? Colors.blue : Colors.black,
                            ),
                          ),
                          Icon(
                            Icons.arrow_drop_down,
                            color: _isFilterActive(filter) ? Colors.blue : Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            /// Icône filtre (à droite)
            IconButton(
              //Reset des filtres + callback original
              onPressed: () {
                _resetFilters();
                widget.onFilterPressed?.call();
              },
              icon: Icon(
                Icons.filter_alt_outlined,
                //Couleur selon l'état des filtres
                color: (selectedStatusFilter != null) ? const Color.fromARGB(255, 249, 175, 1) : Colors.grey,
              ),
            ),
          ],
        );
      }


    void _showStatusFilterModal(BuildContext context) {
        showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white, // Fond blanc comme dans votre design
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)), // Bords arrondis en haut
        ),
        builder: (BuildContext context) {
          return Container(
            padding: const EdgeInsets.all(20), // Espacement intérieur
            child: Column(
              mainAxisSize: MainAxisSize.min, // Prend le minimum d'espace vertical
              crossAxisAlignment: CrossAxisAlignment.start, // Alignement à gauche
              children: [
                // Titre du modal et bouton de fermeture
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filtrer par statut',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context), // Ferme le modal
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 15), // Espacement

                // Option "Tous les statuts"
                _buildStatusOption(
                  context,
                  'Tous les statuts',
                  null, // null signifie "tous"
                  Colors.grey[600]!, // Couleur pour "Tous"
                  //  Vous devrez passer le nombre total de transactions ici
                  // Pour l'instant, on met 0 ou une valeur de test
                  0, // Placeholder pour le total
                ),

                const Divider(height: 30), // Ligne de séparation

                // Options pour chaque statut (En cours de Livraison, Annulé, Livré)
                // Vous devrez définir votre enum TransactionStatus et ses labels/couleurs
                // Pour l'instant, nous allons simuler avec des strings
                _buildStatusOption(
                  context,
                  'En cours de Livraison',
                  'enCoursLivraison', // Valeur à stocker pour ce statut
                  Colors.orange, // Couleur pour "En cours de Livraison"
                  0, // Placeholder pour le compte
                ),
                _buildStatusOption(
                  context,
                  'Annulé',
                  'annule', // Valeur à stocker pour ce statut
                  Colors.red, // Couleur pour "Annulé"
                  0, // Placeholder pour le compte
                ),
                _buildStatusOption(
                  context,
                  'Livré',
                  'livre', // Valeur à stocker pour ce statut
                  Colors.green, // Couleur pour "Livré"
                  0, // Placeholder pour le compte
                ),

                const SizedBox(height: 10), // Espacement en bas
              ],
            ),
          );
        },
      );
    }
    Widget _buildStatusOption(
      BuildContext context,
      String label, // Le texte affiché (ex: "En cours de Livraison")
      String? statusValue, // La valeur du statut (ex: 'enCoursLivraison' ou null pour "Tous")
      Color color, // La couleur associée à ce statut
      int count, // Le nombre de transactions pour ce statut
    ) {
      final isSelected = selectedStatusFilter == statusValue; // Vérifie si cette option est sélectionnée

      return Container(
        margin: const EdgeInsets.only(bottom: 8), // Marge entre les options
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
          leading: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color, // Carré de couleur
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          title: Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, // Gras si sélectionné
              color: isSelected ? color : Colors.black87, // Couleur du texte
              fontSize: 16,
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1), // Fond léger pour le compteur
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.3)), // Bordure légère
            ),
            child: Text(
              count.toString(), // Affiche le nombre de transactions
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          selected: isSelected, // Met en surbrillance si sélectionné
          selectedTileColor: color.withOpacity(0.05), // Couleur de surbrillance
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Bords arrondis pour le ListTile
          ),
          onTap: () {
            setState(() {
              selectedStatusFilter = statusValue; // Met à jour le filtre sélectionné
            });
            widget.onStatusChanged?.call(statusValue); // Appelle le callback avec le nouveau statut
            Navigator.pop(context); // Ferme le modal après sélection
          },
        ),
      );
    }
      // Méthodes pour gérer les filtres
      bool _isFilterActive(String filter) {
        if (filter == 'Statut') return selectedStatusFilter != null;
        return false;
      }

      void _handleFilterTap(String filter) {
        if (filter == 'Statut') {
          _showStatusFilterModal(context);
        }
      }

      void _resetFilters() {
        setState(() {
          selectedPriceFilter = null;
          selectedStatusFilter = null;
        });
      }


    }

  
  


