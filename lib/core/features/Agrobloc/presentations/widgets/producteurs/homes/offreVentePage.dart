import 'package:flutter/material.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/producteurs/homes/AnnonceForm.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/producteurs/homes/prefinancementForm.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/annonceVenteService.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/AnnoncePrefinancementService.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/userService.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/AnnonceVenteModel.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/annoncePrefinancementModel.dart';
import 'package:agrobloc/core/themes/app_colors.dart';
import 'package:agrobloc/core/themes/app_text_styles.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/layout/recherche_bar.dart';
import 'package:intl/intl.dart';

class OffreVentePage extends StatefulWidget {
  final int initialTabIndex; // 1 = Offres Vente, 2 = Financement

  const OffreVentePage({super.key, this.initialTabIndex = 1});

  @override
  State<OffreVentePage> createState() => _OffreVentePageState();
}

class _OffreVentePageState extends State<OffreVentePage> {
  late int _selectedButtonIndex; // 1 = Offres Vente, 2 = Financement

  final AnnonceService _service = AnnonceService();
  final PrefinancementService _prefinancementService = PrefinancementService();
  final UserService _userService = UserService();

  final List<AnnonceVente> _annonces = [];
  final List<AnnoncePrefinancement> _prefinancements = [];
  List<dynamic> _filteredAnnonces = [];

  bool _isLoading = true;
  bool _isAuthenticated = false;
  bool _authChecked = false;

  @override
  void initState() {
    super.initState();
    _selectedButtonIndex = widget.initialTabIndex;
    // Configurer le callback de reconnexion forcée
    _userService.setForceReLoginCallback(_handleForceReLogin);
    _checkAuthenticationAndLoadData();
  }

  /// Vérifie l'authentification une seule fois puis charge les données
  Future<void> _checkAuthenticationAndLoadData() async {
    try {
      print('🔄 OffreVentePage: Début de vérification d\'authentification...');
      _isAuthenticated = await _userService.isUserAuthenticated().timeout(const Duration(seconds: 20));
      _authChecked = true;
      print('✅ OffreVentePage: Authentification vérifiée: $_isAuthenticated');

      if (_isAuthenticated) {
        print('🔄 OffreVentePage: Chargement des données utilisateur...');
        await _userService.ensureUserLoaded();
        final currentUserId = _userService.userId;
        print('🔍 OffreVentePage: UserId récupéré: ${currentUserId ?? "null"}');

        if (currentUserId == null || currentUserId.isEmpty) {
          throw Exception('Utilisateur non identifié. Veuillez vous reconnecter.');
        }

        print('🔄 OffreVentePage: Chargement des annonces et préfinancements...');
        await Future.wait([
          _loadAnnonces(),
          _loadPrefinancements(),
        ]).timeout(const Duration(seconds: 25));
        print('✅ OffreVentePage: Données chargées avec succès');
      } else {
        print('⚠️ OffreVentePage: Utilisateur non authentifié');
        setState(() => _isLoading = false);
        _showSnackBar('Veuillez vous connecter pour accéder à vos annonces.', color: Colors.red);
      }
    } catch (e) {
      print('❌ OffreVentePage: Erreur lors du chargement: $e');
      setState(() => _isLoading = false);
      _showSnackBar('Erreur lors du chargement des données: ${e.toString()}', color: Colors.red);
    } finally {
      // Assurer que _isLoading est toujours false à la fin
      if (mounted && _isLoading) {
        print('🔧 OffreVentePage: Forçage de _isLoading = false');
        setState(() => _isLoading = false);
      }
    }
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

  /// Gère la reconnexion forcée quand le token est expiré
  void _handleForceReLogin() {
    print('🔄 OffreVentePage: Gestion de la reconnexion forcée');
    if (mounted) {
      _showSnackBar('Session expirée. Veuillez vous reconnecter.', color: Colors.red);
      // Naviguer vers la page de connexion
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );
    }
  }

  /// Charge uniquement les annonces de l'utilisateur connecté
  Future<void> _loadAnnonces() async {
    try {
      print('🔄 OffreVentePage: Chargement des annonces...');
      final currentUserId = _userService.userId;
      if (currentUserId == null || currentUserId.isEmpty) {
        throw Exception('Utilisateur non connecté. Veuillez vous reconnecter.');
      }
      final annonces = await _service.getAnnoncesByUserID(currentUserId).timeout(const Duration(seconds: 20));

      // Debug: Print the fetched data
      print('✅ OffreVentePage: ${annonces.length} annonces chargées');
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
        if (_selectedButtonIndex == 1) {
          _filteredAnnonces = annonces;
        }
      });
      print('✅ OffreVentePage: Annonces mises à jour dans l\'UI');
    } catch (e) {
      print('❌ OffreVentePage: Erreur lors du chargement des annonces: $e');
      if (!mounted) return;
      _showSnackBar('Erreur lors du chargement des annonces: ${e.toString()}', color: Colors.red);
      rethrow; // Re-throw to be caught by the main method
    }
  }

  /// Charge les prefinancements de l'utilisateur connecté
  Future<void> _loadPrefinancements() async {
    try {
      print('🔄 OffreVentePage: Début du chargement des préfinancements...');
      final currentUserId = _userService.userId;
      print('🔍 OffreVentePage: UserId récupéré: ${currentUserId ?? "null"}');

      if (currentUserId == null || currentUserId.isEmpty) {
        print('❌ OffreVentePage: UserId null ou vide - utilisateur non connecté');
        throw Exception('Utilisateur non connecté. Veuillez vous reconnecter.');
      }

      print('📡 OffreVentePage: Appel de fetchPrefinancementsByUser avec userId: $currentUserId');
      final prefinancements = await _prefinancementService.fetchPrefinancementsByUser(currentUserId).timeout(const Duration(seconds: 20));
      print('✅ OffreVentePage: ${prefinancements.length} préfinancements reçus du service');

      // Forcer le rechargement du cache des types de culture pour garantir la mise à jour des libellés
      await _prefinancementService.cacheTypeCultures(forceReload: true);

      // Debug: Log details of each prefinancement
      for (int i = 0; i < prefinancements.length; i++) {
        final p = prefinancements[i];
        print('📋 Prefinancement $i: ID=${p.id}, Statut=${p.statut}, TypeCulture=${p.libelle}, typeCultureLibelle=${p.typeCultureLibelle}, typeCultureId=${p.typeCultureId}, Quantite=${p.quantite} ${p.quantiteUnite}');
      }

      if (!mounted) {
        print('⚠️ OffreVentePage: Widget non monté, annulation de la mise à jour UI');
        return;
      }

      print('🔄 OffreVentePage: Mise à jour de l\'état UI...');
      setState(() {
        _prefinancements
          ..clear()
          ..addAll(prefinancements);
        if (_selectedButtonIndex == 2) {
          _filteredAnnonces = prefinancements;
          print('📋 OffreVentePage: _filteredAnnonces mis à jour avec ${prefinancements.length} préfinancements');
        }
      });
      print('✅ OffreVentePage: Préfinancements mis à jour dans l\'UI avec succès');
    } catch (e) {
      print('❌ OffreVentePage: Erreur lors du chargement des préfinancements: $e');
      print('🔍 OffreVentePage: Type d\'erreur: ${e.runtimeType}');
      print('🔍 OffreVentePage: Message d\'erreur: ${e.toString()}');

      if (!mounted) {
        print('⚠️ OffreVentePage: Widget non monté lors de l\'erreur');
        return;
      }

      // Handle specific error types
      String errorMessage = 'Erreur lors du chargement des préfinancements';
      if (e.toString().contains('Token manquant') || e.toString().contains('non connecté')) {
        errorMessage = 'Session expirée. Veuillez vous reconnecter.';
      } else if (e.toString().contains('réseau') || e.toString().contains('network') || e.toString().contains('connection')) {
        errorMessage = 'Problème de connexion. Vérifiez votre connexion internet.';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Délai d\'attente dépassé. Réessayez plus tard.';
      } else {
        errorMessage = 'Erreur lors du chargement des préfinancements: ${e.toString()}';
      }

      _showSnackBar(errorMessage, color: Colors.red);
      rethrow; // Re-throw to be caught by the main method
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
  Future<void> _navigateToForm({AnnonceVente? annonce, AnnoncePrefinancement? prefinancement}) async {
    if (!_isAuthenticated) {
      _showSnackBar('Session expirée. Veuillez vous reconnecter.', color: Colors.red);
      return;
    }

    if (_selectedButtonIndex == 1) {
      // Offres de vente
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AnnonceForm(annonce: annonce), // Edition si annonce != null
        ),
      ).then((_) => _loadAnnonces());
    } else {
      // Préfinancements
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PrefinancementForm(prefinancement: prefinancement),
        ),
      ).then((_) => _loadPrefinancements());
    }
  }

  /// Supprime une annonce ou un prefinancement
  Future<void> _deleteAnnonce(dynamic item) async {
    try {
      if (item is AnnonceVente) {
        await _service.deleteAnnonce(item.id);
        _showSnackBar('Annonce supprimée avec succès');
        _loadAnnonces();
      } else if (item is AnnoncePrefinancement) {
        await _prefinancementService.deletePrefinancement(item.id);
        _showSnackBar('Préfinancement supprimé avec succès');
        _loadPrefinancements();
      }
    } catch (e) {
      _showSnackBar('Erreur lors de la suppression: ${e.toString()}', color: Colors.red);
    }
  }

  /// Confirme la suppression
  Future<void> _confirmDeleteAnnonce(dynamic item) async {
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

    if (confirmed == true) await _deleteAnnonce(item);
  }

  /// Change le type d'annonces affichées (Offres Vente / Financement)
  void _onChangeCategory(int index) {
    setState(() {
      _selectedButtonIndex = index;
      if (index == 1) {
        _filteredAnnonces = _annonces.where((annonce) {
          final statut = (annonce.statut ?? '').toLowerCase();
          return true; // Affiche tout
        }).toList();
      } else if (index == 2) {
        _filteredAnnonces = _prefinancements.where((prefinancement) {
          return true; // Affiche tout
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          _selectedButtonIndex == 1 ? 'Mes Offres de Vente' : 'Mes Préfinancements',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
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
                            _selectedButtonIndex == 1
                                ? 'Aucune offre de vente créée par vous'
                                : 'Aucun préfinancement créé par vous',
                            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredAnnonces.length,
                          itemBuilder: (context, index) {
                            final item = _filteredAnnonces[index];

                            if (item is AnnonceVente) {
                              final isValidated = (item.statut ?? '').toLowerCase() == 'validé';
                              return Card(
                                color: Colors.white,
                                elevation: 2,
                                margin: const EdgeInsets.only(bottom: 16),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    (item.typeCultureLibelle != null && item.typeCultureLibelle!.isNotEmpty)
                                                        ? item.typeCultureLibelle!
                                                        : 'Culture non spécifié',
                                                    style: AppTextStyles.heading.copyWith(
                                                      fontSize: 16,
                                                      color: (item.typeCultureLibelle != null && item.typeCultureLibelle!.isNotEmpty)
                                                          ? AppColors.primaryGreen
                                                          : Colors.grey,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  () {
                                                    if (item.createdAt != null && item.createdAt!.isNotEmpty) {
                                                      try {
                                                        DateTime date = DateTime.parse(item.createdAt!);
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
                                                  textAlign: TextAlign.right,
                                                ),
                                              ],
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
                                                    text: '${item.quantite} kg',
                                                    style: const TextStyle(
                                                      color: Color.fromARGB(255, 55, 55, 55),
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text.rich(
                                              TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: 'Prix unitaire: ',
                                                    style: TextStyle(color: Colors.grey[700]),
                                                  ),
                                                  TextSpan(
                                                    text: '${item.prixKg} FCFA',
                                                    style: const TextStyle(
                                                      color: Color.fromARGB(255, 55, 55, 55),
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text.rich(
                                              TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: 'Statut: ',
                                                    style: TextStyle(color: Colors.grey[700]),
                                                  ),
                                                  TextSpan(
                                                    text: (item.statut ?? 'Inconnu'),
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
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.edit_outlined),
                                                color: AppColors.primaryGreen,
                                                onPressed: () => _navigateToForm(annonce: item),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete_outline),
                                                color: AppColors.primaryGreen,
                                                onPressed: () => _confirmDeleteAnnonce(item),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            } else if (item is AnnoncePrefinancement) {
                              final isValidated = item.statut.toLowerCase() == 'validé';
                              return Card(
                                color: Colors.white,
                                elevation: 2,
                                margin: const EdgeInsets.only(bottom: 16),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    (item.typeCultureLibelle != null && item.typeCultureLibelle!.isNotEmpty)
                                                        ? item.typeCultureLibelle!
                                                        : 'Type de culture non spécifié',
                                                    style: AppTextStyles.heading.copyWith(
                                                      fontSize: 16,
                                                      color: (item.typeCultureLibelle != null && item.typeCultureLibelle!.isNotEmpty)
                                                          ? AppColors.primaryGreen
                                                          : Colors.grey,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  () {
                                                    if (item.createdAt != null) {
                                                      Duration diff = DateTime.now().difference(item.createdAt!);
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
                                                    } else {
                                                      return 'Date non disponible';
                                                    }
                                                  }(),
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey,
                                                  ),
                                                  textAlign: TextAlign.right,
                                                ),
                                              ],
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
                                                    text: '${item.quantite} kg',
                                                    style: const TextStyle(
                                                      color: Color.fromARGB(255, 55, 55, 55),
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text.rich(
                                              TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: 'Prix unitaire: ',
                                                    style: TextStyle(color: Colors.grey[700]),
                                                  ),
                                                  TextSpan(
                                                    text: '${item.prixKgPref} FCFA',
                                                    style: const TextStyle(
                                                      color: Color.fromARGB(255, 55, 55, 55),
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text.rich(
                                              TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: 'Statut: ',
                                                    style: TextStyle(color: Colors.grey[700]),
                                                  ),
                                                  TextSpan(
                                                    text: item.statut,
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
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.edit_outlined),
                                                color: AppColors.primaryGreen,
                                                onPressed: () => _navigateToForm(prefinancement: item),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete_outline),
                                                color: AppColors.primaryGreen,
                                                onPressed: () => _confirmDeleteAnnonce(item),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
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
