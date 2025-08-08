import 'package:agrobloc/core/features/Agrobloc/data/dataSources/AnnoncePrefinancementService.dart';
import 'package:flutter/material.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/annoncePrefinancementModel.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/acheteurs/home/commande_enregistree.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/acheteurs/home/detailFinancement.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/AnnonceVenteModel.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/annonceVenteService.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/acheteurs/home/offreCard.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/acheteurs/home/financementCard.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/acheteurs/home/recommande.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/acheteurs/home/statut_commande.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/layout/filter_boutton.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/layout/nav_bar.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/layout/recherche_bar.dart';
import 'package:agrobloc/core/themes/app_colors.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/pagesAcheteurs/transactionPage.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/pagesAcheteurs/annonce_achat_page.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/pagesAcheteurs/profilPage.dart';

/// Page principale affichant les différentes sections et la navigation
class HomePage extends StatefulWidget {
  final String acheteurId; // ID de l'acheteur pour les transactions
  const HomePage({super.key, required this.acheteurId});

  @override
  State<HomePage> createState() => _HomePageState();
}

/// Page principale affichant les différentes sections et la navigation
class _HomePageState extends State<HomePage> {
  // Index de l'onglet sélectionné dans la barre de navigation inférieure
  int _selectedIndex = 0;

  // Index du filtre sélectionné (0 = annonces, 1 = financements)
  int _selectedFilterIndex = 0;

  // Page courante pour la pagination
  int _currentPage = 0;

  // Nombre d'éléments par page pour la pagination
  final int _pageSize = 2;

  // Liste complète des annonces de vente
  List<AnnonceVente> annonces = [];

  // Liste complète des financements
  List<AnnonceFinancement> financements = [];

  // Sous-liste paginée des annonces affichées
  List<AnnonceVente> paginatedAnnonces = [];

  // Sous-liste paginée des financements affichés
  List<AnnonceFinancement> paginatedFinancements = [];

  // Indicateur de chargement des données
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Chargement initial des données lors de l'initialisation du widget
    _loadAllData();
  }

  /// Charge toutes les données nécessaires (annonces et financements)
  Future<void> _loadAllData() async {
    setState(() => isLoading = true);
    try {
      final annonceService = AnnonceService();
      final ventesData = await annonceService.getAllAnnonces();
      final prefinancementService = PrefinancementService();
      final financementsData =
          await prefinancementService.fetchPrefinancements();

      setState(() {
        annonces = ventesData;
        financements = financementsData;
        _currentPage = 0;
        _updatePagination();
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Erreur de chargement des données : $e");
      setState(() => isLoading = false);
    }
  }

  /// Met à jour les sous-listes paginées en fonction de la page courante et du filtre sélectionné
  void _updatePagination() {
    final start = _currentPage * _pageSize;
    final end = (_currentPage + 1) * _pageSize;

    if (_selectedFilterIndex == 0) {
      paginatedAnnonces = annonces.sublist(
        start.clamp(0, annonces.length),
        end.clamp(0, annonces.length),
      );
    } else if (_selectedFilterIndex == 1) {
      paginatedFinancements = financements.sublist(
        start.clamp(0, financements.length),
        end.clamp(0, financements.length),
      );
    }
  }

  /// Liste des pages affichées dans le corps principal
  List<Widget> get pages => [
        _buildHomeContent(),
        const AnnonceAchatPage(),
        const TransactionPage(),
        const ProfilPage(),
      ];

  /// Page affichant la section annonces avec boutons de navigation vers d'autres pages
  Widget _buildAnnoncesPage() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text("Section Annonces", style: TextStyle(fontSize: 24)),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const CommandeEnregistreePage()),
              );
            },
            icon: const Icon(Icons.receipt),
            label: const Text("Voir Commande Enregistrée"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StatutCommandePage()),
              );
            },
            icon: const Icon(Icons.local_shipping),
            label: const Text("Voir Statut de Commande"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AnnonceAchatPage()),
              );
            },
            icon: const Icon(Icons.add_shopping_cart),
            label: const Text("Créer / Modifier une Offre d'Achat"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          ),
        ],
      ),
    );
  }

  /// Contenu principal de la page d'accueil avec barre de recherche et filtres
  Widget _buildHomeContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SearchBarWidget(),
                  const SizedBox(height: 16),
                  FilterButtons(
                    onFilterSelected: (index) {
                      setState(() {
                        _selectedFilterIndex = index;
                        _currentPage = 0;
                        _updatePagination();
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildFilteredContent(),
                ],
              ),
            ),
    );
  }

  /// Contenu filtré affiché selon le filtre sélectionné (annonces ou financements)
  Widget _buildFilteredContent() {
    switch (_selectedFilterIndex) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Top offres avec pagination
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Top offres",
                    style: Theme.of(context).textTheme.titleLarge),
                TextButton(
                  onPressed: () {
                    if (annonces.isNotEmpty) {
                      setState(() {
                        final maxPage = (annonces.length / _pageSize).ceil();
                        _currentPage = (_currentPage + 1) % maxPage;
                        _updatePagination();
                      });
                    }
                  },
                  child: const Text(
                    "Suivant >",
                    style: TextStyle(
                        color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: paginatedAnnonces.isEmpty
                  ? const Center(child: Text("Aucune offre disponible"))
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: paginatedAnnonces.length,
                      itemBuilder: (context, index) {
                        final annonce = paginatedAnnonces[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: SizedBox(
                            width: 160,
                            child: OffreCard(
                              data: annonce,
                              acheteurId: '',
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 45),

            /// Section Recommandé
            Text("Recommandé", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 5),
            Column(
              children: annonces.map((annonce) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: RecommendationCard(
                    recommendation: annonce,
                    acheteurId: '',
                  ),
                );
              }).toList(),
            ),
          ],
        );

      case 1:
        return paginatedFinancements.isEmpty
            ? const Center(child: Text("Aucun financement disponible"))
            : ListView.builder(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: paginatedFinancements.length,
                itemBuilder: (context, index) {
                  final financement = paginatedFinancements[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                FinancementDetailsPage(data: financement),
                          ),
                        );
                      },
                      child: FinancementCard(
                        key: ValueKey(financement.id),
                        data: financement,
                      ),
                    ),
                  );
                },
              );

      default:
        return const Center(
            child: Text("Aucun contenu disponible pour ce filtre."));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: pages[_selectedIndex],
        bottomNavigationBar: BottomNavBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
        ),
      ),
    );
  }
}
