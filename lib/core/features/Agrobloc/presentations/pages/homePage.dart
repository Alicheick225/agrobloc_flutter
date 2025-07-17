import 'package:agrobloc/core/features/Agrobloc/data/dataSources/AnnoncePrefinancement.dart';
import 'package:flutter/material.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/financementModel.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/offreModels.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/home/commande_enregistree.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/home/detailFinancement.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/AnnonceVenteModel.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/annonceService.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/home/offreCard.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/home/financementCard.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/home/detailFinancement.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/home/recommande.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/home/statut_commande.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/home/top_offres_card.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/layout/filter_boutton.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/layout/nav_bar.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/layout/recherche_bar.dart';
import 'package:agrobloc/core/themes/app_colors.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  int _selectedFilterIndex = 0;
  int _currentPage = 0;
  final int _pageSize = 2;

  List<AnnonceVente> annonces = [];
  List<AnnonceFinancement> financements = [];

  List<AnnonceVente> paginatedAnnonces = [];
  List<AnnonceFinancement> paginatedFinancements = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => isLoading = true);
    try {
      final annonceService = AnnonceService();
      final ventesData = await annonceService.getAllAnnonces();
      final prefinancementService = PrefinancementService();
      final financementsData = await prefinancementService.fetchPrefinancements(); // ✅ Correction ici

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

  List<Widget> get pages => [
        _buildHomeContent(),
_buildAnnoncesPage(),
        const Center(child: Text("Transactions", style: TextStyle(fontSize: 24))),
        const Center(child: Text("Profil", style: TextStyle(fontSize: 24))),
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
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CommandeEnregistreePage()),
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
      ],
    ),
  );
}


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

  Widget _buildFilteredContent() {
    switch (_selectedFilterIndex) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ✅ Top offres avec pagination
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Top offres", style: Theme.of(context).textTheme.titleLarge),
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
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
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
                            child: OffreCard(data: annonce),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 45),

            /// ✅ Section Recommandé
            Text("Recommandé", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 5),
            Column(
              children: annonces.map((annonce) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: RecommendationCard(recommendation: annonce),
                );
              }).toList(),
            ),
          ],
        );

      case 1:
        return paginatedFinancements.isEmpty
            ? const Center(child: Text("Aucun financement disponible"))
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
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
                            builder: (_) => FinancementDetailsPage(data: financement),
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
        return const Center(child: Text("Aucun contenu disponible pour ce filtre."));
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
    ),
  );
}
