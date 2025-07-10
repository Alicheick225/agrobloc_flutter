import 'package:agrobloc/core/features/Agrobloc/data/dataSources/annonceService.dart';
import 'package:flutter/material.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/financementModel.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/offreModels.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/AnnonceVenteModel.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/pages/detailFinancement.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/filter_boutton.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/financementCard.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/nav_bar.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/recherche_bar.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/recommande.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/top_offres_card.dart';
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

  List<AnnonceVenteModel> annonces = [];
  List<AnnonceVenteModel> paginatedAnnonces = [];
  bool isLoading = true;

  final List<FinancementModel> financements = [
    FinancementModel(
      avatar: 'assets/images/avatar.jpg',
      nom: 'Antoine Kouassi',
      region: "Région de l’Iffou, Daoukro",
      culture: 'Cacao',
      superficie: '8 hectares',
      productionEstimee: '50 tonnes',
      valeurProduction: '20 Millions de FCFA',
      prixPreferentiel: '2.200 FCFA / Kg',
      montantPreFinancer: '1.5 Millions de FCFA',
    ),
    FinancementModel(
      avatar: 'assets/images/avatar.jpg',
      nom: 'Kouamé Akissi',
      region: "Région du Gôh, Gagnoa",
      culture: 'Maïs',
      superficie: '6 hectares',
      productionEstimee: '30 tonnes',
      valeurProduction: '10 Millions de FCFA',
      prixPreferentiel: '1.800 FCFA / Kg',
      montantPreFinancer: '800 000 FCFA',
    ),
  ];

  @override
  void initState() {
    super.initState();
    loadAnnonces();
  }

  void loadAnnonces() async {
    try {
      final data = await AnnonceService.fetchAnnonces();
      setState(() {
        annonces = data;
        isLoading = false;
        _updatePagination();
      });
    } catch (e) {
      print("Erreur de chargement des annonces : $e");
      setState(() => isLoading = false);
    }
  }

  void _updatePagination() {
    final start = _currentPage * _pageSize;
    final end = (_currentPage + 1) * _pageSize;
    paginatedAnnonces = annonces.sublist(start, end.clamp(0, annonces.length));
  }

  List<Widget> get pages => [
        _buildHomeContent(),
        const Center(child: Text("Annonces", style: TextStyle(fontSize: 50))),
        const Center(child: Text("Transactions", style: TextStyle(fontSize: 24))),
        const Center(child: Text("Profil", style: TextStyle(fontSize: 24))),
      ];

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
                      setState(() => _selectedFilterIndex = index);
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Top offres", style: Theme.of(context).textTheme.titleLarge),
                TextButton(
                  onPressed: () {
                    setState(() {
                      if ((_currentPage + 1) * _pageSize < annonces.length) {
                        _currentPage++;
                      } else {
                        _currentPage = 0;
                      }
                      _updatePagination();
                    });
                  },
                  child: const Text("Suivant >", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: paginatedAnnonces.length,
                itemBuilder: (context, index) {
                  final annonce = paginatedAnnonces[index];
                  return TopOffersCard(
                    offer: OfferModel(
                      image: annonce.photo,
                      location: annonce.parcelleId,
                      type: annonce.statut,
                      product: annonce.typeCultureId, // ou à mapper
                      quantity: "${annonce.quantite} kg",
                      price: "${annonce.prixKg} FCFA / kg",
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 45),
            Text("Recommandé", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 5),
            Column(
              children: annonces.map((annonce) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: RecommendationCard(
                    recommendation: AnnonceVenteModel(
                      photo: annonce.photo,
                      typeCultureId: annonce.typeCultureId,
                      parcelleId: annonce.parcelleId,
                      quantite: annonce.quantite,
                      prixKg: annonce.prixKg,
                      createdAt: annonce.createdAt,
                      statut: annonce.statut, 
                      id: '',
                      userId: '',
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      case 1:
        return Column(
          children: financements.map((financement) => 
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FinancementDetailsPage(),
                    ),
                  );
                },
                child: FinancementCard(data: financement),
              ),
            ),
          ).toList(),
        );
      case 2:
        return const Center(child: Text("Mes offres en cours de développement."));
      default:
        return const SizedBox();
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
