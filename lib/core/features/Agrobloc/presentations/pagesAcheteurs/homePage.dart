import 'package:agrobloc/core/features/Agrobloc/data/dataSources/AnnoncePrefinancementService.dart';
import 'package:flutter/material.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/annoncePrefinancementModel.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/acheteurs/home/commande_enregistree.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/acheteurs/home/compteSequestre.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/acheteurs/home/detailFinancement.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/AnnonceVenteModel.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/annonceVenteService.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/acheteurs/home/offreCard.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/acheteurs/home/financementCard.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/acheteurs/home/recommande.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/acheteurs/home/statut_commande.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/layout/filter_boutton.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/layout/nav_bar.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/layout/navBarAll.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/layout/recherche_bar.dart';
import 'package:agrobloc/core/themes/app_colors.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/pagesAcheteurs/transactionPage.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/pagesAcheteurs/annonce_achat_page.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/pagesAcheteurs/profilPage.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/userService.dart';

class HomePage extends StatefulWidget {
  final String acheteurId;
  const HomePage(
      {super.key, required this.acheteurId, String profile = 'acheteur'});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  int _selectedFilterIndex = 0;
  int _currentPage = 0;
  final int _pageSize = 2; // pagination seulement pour les offres

  List<AnnonceVente> annonces = [];
  List<AnnoncePrefinancement> financements = [];
  List<AnnonceVente> paginatedAnnonces = [];

  // Infinite scroll for Recommandé section
  List<AnnonceVente> recommandeAnnonces = [];
  bool isLoadingRecommande = false;
  bool hasMoreRecommande = true;
  int recommandeOffset = 0;
  final int recommandeLimit = 10;
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();

  bool isLoading = true;
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _checkAuthenticationAndLoadData();
    _scrollController.addListener(_onScroll);
    _searchFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {});
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent &&
        !isLoadingRecommande &&
        hasMoreRecommande) {
      _loadMoreRecommande();
    }
  }

  Future<void> _checkAuthenticationAndLoadData() async {
    final isAuthenticated = await _userService.isUserAuthenticated();
    if (isAuthenticated) {
      _loadAllData();
      _loadInitialRecommande();
    } else {
      // User is not authenticated, don't load data
      debugPrint('⚠️ HomePage - Utilisateur non authentifié, chargement des données annulé');
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadInitialRecommande() async {
    try {
      final initialAnnonces = await AnnonceService().getAllAnnonces(
        limit: recommandeLimit,
        offset: 0,
      );

      setState(() {
        recommandeAnnonces = initialAnnonces;
        recommandeOffset = recommandeLimit;
        hasMoreRecommande = initialAnnonces.length == recommandeLimit;
      });
    } catch (e) {
      debugPrint('Erreur lors du chargement initial des annonces recommandées: $e');
    }
  }

  Future<void> _loadMoreRecommande() async {
    if (isLoadingRecommande || !hasMoreRecommande) return;

    setState(() => isLoadingRecommande = true);

    try {
      final newAnnonces = await AnnonceService().getAllAnnonces(
        limit: recommandeLimit,
        offset: recommandeOffset,
      );

      if (newAnnonces.length < recommandeLimit) {
        hasMoreRecommande = false;
      }

      setState(() {
        recommandeAnnonces.addAll(newAnnonces);
        recommandeOffset += recommandeLimit;
        isLoadingRecommande = false;
      });
    } catch (e) {
      debugPrint('Erreur lors du chargement des annonces recommandées: $e');
      setState(() => isLoadingRecommande = false);
    }
  }

  Future<void> _loadAllData() async {
    setState(() => isLoading = true);
    try {
      final ventesData = await AnnonceService().getAllAnnonces();
      final financementsData =
          await PrefinancementService().fetchPrefinancements();

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

  /// Pagination uniquement pour les offres (index 0)
  void _updatePagination() {
    final start = _currentPage * _pageSize;
    final end = (_currentPage + 1) * _pageSize;

    if (_selectedFilterIndex == 0) {
      paginatedAnnonces = annonces.sublist(
        start.clamp(0, annonces.length),
        end.clamp(0, annonces.length),
      );
    }
    // Les financements ne sont pas paginés
  }

  List<Widget> get pages => [
        _buildHomeContent(),
        const AnnonceAchatPage(),
        const TransactionPage(child: Text("Transactions")),
        const ProfilPage(),
      ];

  Widget _buildAnnoncesPage() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text("Section Annonces", style: TextStyle(fontSize: 24)),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const CommandeEnregistreePage())),
            icon: const Icon(Icons.receipt),
            label: const Text("Voir Commande Enregistrée"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const StatutCommandePage())),
            icon: const Icon(Icons.local_shipping),
            label: const Text("Voir Statut de Commande"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AnnonceAchatPage())),
            icon: const Icon(Icons.add_shopping_cart),
            label: const Text("Créer / Modifier une Offre d'Achat"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CompteSequestre(),
                    //const SizedBox(height: 16),
                    //SearchBarWidget(),
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
            ),
    );
  }
  Widget _buildFilteredContent() {
    switch (_selectedFilterIndex) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Text("Top offres",
                      style: Theme.of(context).textTheme.titleMedium),
                ),
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
                    "Suivant ->",
                    style: TextStyle(
                        color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 1),
            SizedBox(
              height: 180,
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
                                data: annonce, acheteurId: widget.acheteurId),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Recommandé", style: Theme.of(context).textTheme.titleMedium),
                Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: TextField(
                        focusNode: _searchFocusNode,
                        decoration: InputDecoration(
                          hintText: 'Rechercher...',
                          hintStyle: const TextStyle(fontSize: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Colors.green, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                        ),
                        style: const TextStyle(fontSize: 12),
                        onChanged: (value) {
                          // TODO: Implement search functionality
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.tune, color: Colors.green),
                      onPressed: () {
                        // TODO: Implement filter functionality
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 5),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recommandeAnnonces.length + (isLoadingRecommande ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == recommandeAnnonces.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                final a = recommandeAnnonces[index];
                return RecommendationCard(
                  recommendation: a,
                  acheteurId: widget.acheteurId,
                  annonceVenteId: a.id,
                );
              },
            ),
          ],
        );

      case 1:
        return financements.isEmpty
            ? const Center(child: Text("Aucun financement disponible"))
            : ListView.builder(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: financements.length,
                itemBuilder: (context, index) {
                  final f = financements[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FinancementDetailsPage(data: f),
                        ),
                      ),
                      child: FinancementCard(
                        key: ValueKey(f.id),
                        data: f,
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
  void dispose() {
    _scrollController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _selectedIndex != 3 ? PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: const NavBarAll(),
        ) : null,
        body: pages[_selectedIndex],
        bottomNavigationBar: BottomNavBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
        ),
      ),
    );
  }
}
