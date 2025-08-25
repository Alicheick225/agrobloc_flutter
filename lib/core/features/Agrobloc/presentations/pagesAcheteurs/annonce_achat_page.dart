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
                                                  text: '${annonce.prix} FCFA',
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
