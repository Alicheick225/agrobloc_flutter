import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/acheteurs/Annonces/annonce_form_page.dart';
import 'package:flutter/material.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/AnnonceAchat.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/AnnonceAchatModel.dart';
import 'package:agrobloc/core/themes/app_colors.dart';
import 'package:agrobloc/core/themes/app_text_styles.dart';

/// Page d'annonce d'achat pour créer ou modifier une offre d'achat
class AnnonceAchatPage extends StatefulWidget {
  const AnnonceAchatPage({Key? key}) : super(key: key);

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
          'Annonces d\'Achat',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.primaryGreen,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _annonces.isEmpty
              ? const Center(child: Text('Aucune annonce d\'achat disponible'))
              : Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 0),
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _annonces.length,
                              itemBuilder: (context, index) {
                                final annonce = _annonces[index];
                                final isValidated =
                                    annonce.statut.toLowerCase() == 'validé';

                                return Card(
                                  color: Colors.white,
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  margin: const EdgeInsets.only(bottom: 16),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                CircleAvatar(
                                                  radius: 24,
                                                  backgroundImage: NetworkImage(
                                                    'https://via.placeholder.com/48',
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        annonce.userNom,
                                                        style: AppTextStyles
                                                            .heading
                                                            .copyWith(
                                                                fontSize: 18,
                                                                color: Colors
                                                                    .grey[700]),
                                                      ),
                                                      const SizedBox(height: 4),
                                                    ],
                                                  ),
                                                ),
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    IconButton(
                                                      icon: const Icon(
                                                          Icons.edit_outlined),
                                                      color: AppColors
                                                          .primaryGreen,
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 4),
                                                      onPressed: () =>
                                                          _navigateToEditForm(
                                                              annonce),
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(
                                                          Icons.delete_outline),
                                                      color: Colors.red,
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 4),
                                                      onPressed: () =>
                                                          _confirmDeleteAnnonce(
                                                              annonce),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Culture: ${annonce.typeCultureLibelle}',
                                              style: AppTextStyles.subheading
                                                  .copyWith(
                                                      color: Colors.grey[600]),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Quantité: ${annonce.quantite}',
                                              style: AppTextStyles.subheading
                                                  .copyWith(
                                                      color: Colors.grey[600]),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Prix unitaire: ',
                                              style: AppTextStyles.subheading
                                                  .copyWith(
                                                      color: Colors.grey[600]),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Adresse: ',
                                              style: AppTextStyles.subheading
                                                  .copyWith(
                                                      color: Colors.grey[600]),
                                            ),
                                            const SizedBox(height: 4),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Text(
                                                  'Statut: ',
                                                  style:
                                                      AppTextStyles.subheading,
                                                ),
                                                Text(
                                                  annonce.statut,
                                                  style: TextStyle(
                                                    color: isValidated
                                                        ? Colors.green
                                                        : Colors.orange,
                                                    fontWeight: FontWeight.bold,
                                                  ),
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
