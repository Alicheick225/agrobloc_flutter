import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/acheteurs/Annonces/annonce_form_page.dart';
import 'package:flutter/material.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/AnnonceAchat.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/AnnonceAchatModel.dart';
import 'package:agrobloc/core/themes/app_colors.dart';
import 'package:agrobloc/core/themes/app_text_styles.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/layout/recherche_bar.dart';

/// Page d'annonce d'achat pour créer ou modifier une offre d'achat
class AnnonceAchatPage extends StatefulWidget {
  const AnnonceAchatPage({super.key});

  @override
  State<AnnonceAchatPage> createState() => _AnnonceAchatPageState();
}

class _AnnonceAchatPageState extends State<AnnonceAchatPage> {
  final AnnonceAchatService _service = AnnonceAchatService();
  final List<AnnonceAchat> _annonces = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnnonces();
  }

  Future<void> _loadAnnonces() async {
    try {
      final annonces = await _service.fetchAnnonces();
      if (!mounted) return;
      setState(() {
        _annonces.clear();
        _annonces.addAll(annonces);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
  }

  void _navigateToForm() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AnnonceFormPage(),
      ),
    ).then((_) => _loadAnnonces());
  }

  void _navigateToEditForm(AnnonceAchat annonce) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AnnonceFormPage(annonceToEdit: annonce),
      ),
    ).then((_) => _loadAnnonces());
  }

  Future<void> _deleteAnnonce(AnnonceAchat annonce) async {
    try {
      await _service.deleteAnnonceAchat(annonce.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Annonce supprimée avec succès')),
      );
      _loadAnnonces();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erreur lors de la suppression: ${e.toString()}')),
      );
    }
  }

  Future<void> _confirmDeleteAnnonce(AnnonceAchat annonce) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: const Text('Voulez-vous vraiment supprimer cette annonce ?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Non'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Oui'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _deleteAnnonce(annonce);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Offres d\'Achat',
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
                  child: _annonces.isEmpty
                      ? const Center(child: Text('Aucune annonce d\'achat disponible'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _annonces.length,
                          itemBuilder: (context, index) {
                            final annonce = _annonces[index];
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
                                            annonce.typeCultureLibelle,
                                            style: AppTextStyles.heading.copyWith(
                                              fontSize: 16,
                                              color: AppColors.primaryGreen,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text.rich(
                                            TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: 'Quantité: ',
                                                  style: TextStyle(
                                                    color: Colors.grey[700],
                                                  ),
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
                                                  style: TextStyle(
                                                    color: Colors.grey[700],
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: '${annonce.prix}',
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
                                                  style: TextStyle(
                                                    color: Colors.grey[700],
                                                  ),
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
