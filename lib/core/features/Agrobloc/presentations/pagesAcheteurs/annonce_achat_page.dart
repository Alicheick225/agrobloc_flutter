import 'package:flutter/material.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/acheteurs/Annonces/annonce_form_page.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/AnnonceAchat.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/userService.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/AnnonceAchatModel.dart';
import 'package:agrobloc/core/themes/app_colors.dart';
import 'package:agrobloc/core/themes/app_text_styles.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/layout/recherche_bar.dart';

class AnnonceAchatPage extends StatefulWidget {
  const AnnonceAchatPage({super.key});

  @override
  State<AnnonceAchatPage> createState() => _AnnonceAchatPageState();
}

class _AnnonceAchatPageState extends State<AnnonceAchatPage> {
  final AnnonceAchatService _service = AnnonceAchatService();
  final UserService _userService = UserService();

  final List<AnnonceAchat> _annonces = [];
  final List<AnnonceAchat> _filteredAnnonces = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnnonces();
  }

  /// Charge uniquement les annonces de l'utilisateur connecté
  Future<void> _loadAnnonces() async {
    try {
      setState(() => _isLoading = true);
      final annonces = await _service.fetchAnnoncesByUser();

      if (!mounted) return;
      setState(() {
        _annonces
          ..clear()
          ..addAll(annonces);
        _filteredAnnonces
          ..clear()
          ..addAll(annonces);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
    }
  }

  /// Navigation vers le formulaire de création
  Future<void> _navigateToForm() async {
    final isAuthenticated = await _userService.isUserAuthenticated();
    if (!isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vous devez être connecté pour créer une offre.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AnnonceFormPage()),
    ).then((_) => _loadAnnonces());
  }

  /// Navigation vers le formulaire pour modifier une annonce
  void _navigateToEditForm(AnnonceAchat annonce) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AnnonceFormPage(annonceToEdit: annonce),
      ),
    ).then((_) => _loadAnnonces());
  }

  /// Supprime une annonce
  Future<void> _deleteAnnonce(AnnonceAchat annonce) async {
    try {
      await _service.deleteAnnonceAchat(annonce.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Annonce supprimée avec succès'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
      _loadAnnonces();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la suppression: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Confirme la suppression
  Future<void> _confirmDeleteAnnonce(AnnonceAchat annonce) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: const Text('Voulez-vous vraiment supprimer cette annonce ?'),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Non'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[700],
              ),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Oui'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryGreen,
              ),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmed == true) await _deleteAnnonce(annonce);
  }

  // Méthode pour formater la date avec format relatif
  String _formatDate(String dateString) {
    if (dateString.isEmpty) return '';
    
    try {
      final parts = dateString.split(' ');
      if (parts.isEmpty) return dateString;
      
      final dateParts = parts[0].split('-');
      if (dateParts.length != 3) return dateString;
      
      final year = int.tryParse(dateParts[0]) ?? 0;
      final month = int.tryParse(dateParts[1]) ?? 0;
      final day = int.tryParse(dateParts[2]) ?? 0;
      
      if (year == 0 || month == 0 || day == 0) return dateString;
      
      final date = DateTime(year, month, day);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = DateTime(now.year, now.month, now.day - 1);
      final dateOnly = DateTime(date.year, date.month, date.day);
      
      final difference = today.difference(dateOnly).inDays;
      
      if (dateOnly == today) {
        return 'Aujourd\'hui';
      } else if (dateOnly == yesterday) {
        return 'Hier';
      } else if (difference < 7) {
        return 'Il y a $difference ${difference == 1 ? 'jour' : 'jours'}';
      } else if (difference < 28) {
        final weeks = (difference / 7).floor();
        return 'Il y a $weeks ${weeks == 1 ? 'semaine' : 'semaines'}';
      } else {
        // Format complet: "11 Août 2025"
        final monthNames = [
          'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
          'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
        ];
        return '$day ${monthNames[month - 1]} $year';
      }
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Mes Offres d\'Achat',
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
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SearchBarWidget(),
                ),
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
                            final isValidated = annonce.statut.toLowerCase() == 'validé';

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
                                            annonce.typeCultureLibelle.isNotEmpty 
                                              ? annonce.typeCultureLibelle
                                              : 'Type de culture non spécifié',
                                            style: AppTextStyles.heading.copyWith(
                                              fontSize: 16,
                                              color: annonce.typeCultureLibelle.isNotEmpty
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
                                                  text: annonce.formattedQuantity,
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
                                                  text: 'Prix / kg: ',
                                                  style: TextStyle(color: Colors.grey[700]),
                                                ),
                                                TextSpan(
                                                  text: annonce.formattedPrice,
                                                  style: const TextStyle(
                                                    color: Color.fromARGB(255, 55, 55, 55),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          // Statut et Date sur la même ligne
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text.rich(
                                                TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: 'Statut: ',
                                                      style: TextStyle(color: Colors.grey[700]),
                                                    ),
                                                    TextSpan(
                                                      text: annonce.statut,
                                                      style: TextStyle(
                                                        color: isValidated
                                                            ? Colors.green
                                                            : const Color.fromARGB(255, 99, 169, 248),
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              // Date alignée à droite
                                              Text(
                                                _formatDate(annonce.createdAt),
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit_outlined),
                                          color: AppColors.primaryGreen,
                                          onPressed: () => _navigateToEditForm(annonce),
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
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToForm,
        backgroundColor: AppColors.primaryGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
