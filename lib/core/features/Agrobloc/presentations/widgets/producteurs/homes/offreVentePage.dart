import 'package:flutter/material.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/producteurs/homes/AnnonceForm.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/annonceVenteService.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/userService.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/AnnonceVenteModel.dart';
import 'package:agrobloc/core/themes/app_colors.dart';
import 'package:agrobloc/core/themes/app_text_styles.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/layout/recherche_bar.dart';
import 'package:intl/intl.dart';

class OffreVentePage extends StatefulWidget {
  const OffreVentePage({super.key});

  @override
  State<OffreVentePage> createState() => _OffreVentePageState();
}

class _OffreVentePageState extends State<OffreVentePage> {
  int _selectedButtonIndex = 1; // 1 = Offres Vente, 2 = Financement

  final AnnonceService _service = AnnonceService();
  final UserService _userService = UserService();

  final List<AnnonceVente> _annonces = [];
  List<AnnonceVente> _filteredAnnonces = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnnonces();
  }

  /// Affiche une snackbar générique
  void _showSnackBar(String message, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color ?? AppColors.primaryGreen,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Charge uniquement les annonces de l'utilisateur connecté
  Future<void> _loadAnnonces() async {
    try {
      setState(() => _isLoading = true);
      await UserService().ensureUserLoaded();
      final currentUserId = UserService().userId;
      if (currentUserId == null || currentUserId.isEmpty) {
        throw Exception('Utilisateur non connecté. Veuillez vous reconnecter.');
      }
      final annonces = await _service.getAnnoncesByUserID(currentUserId);

      // Debug: Print the fetched data
      for (var annonce in annonces) {
        print('Annonce ID: ${annonce.id}');
        print('Type Culture Libelle: ${annonce.typeCultureLibelle}');
        print('Created At: ${annonce.createdAt}');
        print('---');
      }

      if (!mounted) return;
      setState(() {
        _annonces
          ..clear()
          ..addAll(annonces);
        _filteredAnnonces = annonces;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnackBar('Erreur: ${e.toString()}', color: Colors.red);
    }
  }

  /// Filtrage via la barre de recherche
  void _filterAnnonces(String query) {
    final lowerQuery = query.toLowerCase();
    setState(() {
      _filteredAnnonces = _annonces.where((annonce) {
        final libelle = annonce.typeCultureLibelle ?? '';
        final statut = annonce.statut ?? '';
        return libelle.toLowerCase().contains(lowerQuery) ||
               statut.toLowerCase().contains(lowerQuery);
      }).toList();
    });
  }

  /// Navigation vers le formulaire de création / édition
  Future<void> _navigateToForm({AnnonceVente? annonce}) async {
    final isAuthenticated = await _userService.isUserAuthenticated();
    if (!isAuthenticated) {
      _showSnackBar('Vous devez être connecté pour créer une offre.', color: Colors.red);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AnnonceForm(annonce: annonce), // Edition si annonce != null
      ),
    ).then((_) => _loadAnnonces());
  }

  /// Supprime une annonce
  Future<void> _deleteAnnonce(AnnonceVente annonce) async {
    try {
      await _service.deleteAnnonce(annonce.id);
      _showSnackBar('Annonce supprimée avec succès');
      _loadAnnonces();
    } catch (e) {
      _showSnackBar('Erreur lors de la suppression: ${e.toString()}', color: Colors.red);
    }
  }

  /// Confirme la suppression
  Future<void> _confirmDeleteAnnonce(AnnonceVente annonce) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          //title: const Text('Confirmer la suppression'),
          content: const Text('Voulez-vous vraiment supprimer cette annonce ?'),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Non'),
              style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Oui'),
              style: TextButton.styleFrom(foregroundColor: AppColors.primaryGreen),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmed == true) await _deleteAnnonce(annonce);
  }

  /// Change le type d'annonces affichées (Offres Vente / Financement)
  void _onChangeCategory(int index) {
    setState(() {
      _selectedButtonIndex = index;
      _filteredAnnonces = _annonces.where((annonce) {
        final statut = (annonce.statut ?? '').toLowerCase();
        if (index == 1) {
          return true; // Affiche tout
        } else {
          return statut.contains('financement');
        }
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Mes Offres de Vente',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.primaryGreen,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                /// Barre de recherche
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: SearchBarWidget(onChanged: _filterAnnonces),
                ),
                /// Boutons de navigation (Offres / Financement)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ElevatedButton(
                            onPressed: () => _onChangeCategory(1),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _selectedButtonIndex == 1
                                  ? AppColors.primaryGreen
                                  : Colors.white,
                              foregroundColor: _selectedButtonIndex == 1
                                  ? Colors.white
                                  : AppColors.primaryGreen,
                              textStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            child: const Text("Mes Offres Vente"),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ElevatedButton(
                            onPressed: () => _onChangeCategory(2),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _selectedButtonIndex == 2
                                  ? AppColors.primaryGreen
                                  : Colors.white,
                              foregroundColor: _selectedButtonIndex == 2
                                  ? Colors.white
                                  : AppColors.primaryGreen,
                              textStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text("Financement"),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                /// Liste des annonces
                Expanded(
                  child: _filteredAnnonces.isEmpty
                      ? Center(
                          child: Text(
                            'Aucune annonce créée par vous',
                            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredAnnonces.length,
                          itemBuilder: (context, index) {
                            final annonce = _filteredAnnonces[index];
                            final isValidated = (annonce.statut ?? '').toLowerCase() == 'validé';

                            return Card(
                              color: Colors.white,
                              elevation: 2,
                              margin: const EdgeInsets.only(bottom: 16),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            (annonce.typeCultureLibelle != null && annonce.typeCultureLibelle!.isNotEmpty)
                                                ? annonce.typeCultureLibelle!
                                                : 'Type de culture non spécifié',
                                            style: AppTextStyles.heading.copyWith(
                                              fontSize: 16,
                                              color: (annonce.typeCultureLibelle != null && annonce.typeCultureLibelle!.isNotEmpty)
                                                  ? AppColors.primaryGreen
                                                  : Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text.rich(
                                            TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: 'Quantité: ',
                                                  style: TextStyle(color: Colors.grey[700]),
                                                ),
                                                TextSpan(
                                                  text: '${annonce.quantite} kg',
                                                  style: const TextStyle(
                                                    color: Color.fromARGB(255, 55, 55, 55),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text.rich(
                                            TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: 'Prix unitaire: ',
                                                  style: TextStyle(color: Colors.grey[700]),
                                                ),
                                                TextSpan(
                                                  text: '${annonce.prixKg} FCFA',
                                                  style: const TextStyle(
                                                    color: Color.fromARGB(255, 55, 55, 55),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text.rich(
                                            TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: 'Statut: ',
                                                  style: TextStyle(color: Colors.grey[700]),
                                                ),
                                                TextSpan(
                                                  text: (annonce.statut ?? 'Inconnu'),
                                                  style: TextStyle(
                                                    color: isValidated ? Colors.green : const Color.fromARGB(255, 99, 169, 248),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          () {
                                            if (annonce.createdAt != null && annonce.createdAt!.isNotEmpty) {
                                              try {
                                                DateTime date = DateTime.parse(annonce.createdAt!);
                                                Duration diff = DateTime.now().difference(date);
                                                if (diff.inDays > 30) {
                                                  return 'il y a plus d\'un mois';
                                                } else if (diff.inDays >= 7) {
                                                  int weeks = diff.inDays ~/ 7;
                                                  return weeks == 1 ? 'il y a 1 semaine' : 'il y a $weeks semaines';
                                                } else if (diff.inDays > 0) {
                                                  return diff.inDays == 1 ? 'il y a 1 jour' : 'il y a ${diff.inDays} jours';
                                                } else if (diff.inHours > 0) {
                                                  return diff.inHours == 1 ? 'il y a 1 heure' : 'il y a ${diff.inHours} heures';
                                                } else {
                                                  return 'il y a quelques minutes';
                                                }
                                              } catch (e) {
                                                return 'Date invalide';
                                              }
                                            } else {
                                              return 'Date non disponible';
                                            }
                                          }(),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit_outlined),
                                              color: AppColors.primaryGreen,
                                              onPressed: () => _navigateToForm(annonce: annonce),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete_outline),
                                              color: AppColors.primaryGreen,
                                              onPressed: () => _confirmDeleteAnnonce(annonce),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(),
        backgroundColor: AppColors.primaryGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
