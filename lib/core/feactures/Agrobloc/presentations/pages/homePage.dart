import 'package:agrobloc/core/feactures/Agrobloc/data/models/offreModels.dart';
import 'package:agrobloc/core/feactures/Agrobloc/data/models/offreRecommandeModels.dart';
import 'package:agrobloc/core/feactures/Agrobloc/presentations/widgets/recommande.dart';
import 'package:flutter/material.dart';
import 'package:agrobloc/core/feactures/Agrobloc/presentations/widgets/filter_boutton.dart';
import 'package:agrobloc/core/feactures/Agrobloc/presentations/widgets/nav_bar.dart';
import 'package:agrobloc/core/feactures/Agrobloc/presentations/widgets/recherche_bar.dart';
import 'package:agrobloc/core/feactures/Agrobloc/presentations/widgets/top_offres_card.dart';
import 'package:agrobloc/core/themes/app_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  int _currentPage = 0;
  final int _pageSize = 2;

  final List<OfferModel> offers = [
    OfferModel(
      image: 'assets/images/image.png',
      location: 'Agboville, Cote D`Ivoire',
      type: 'Disponible',
      product: 'Hévéa',
      quantity: '40 tonnes',
      price: '1700 FCFA / kg',
    ),
    OfferModel(
      image: 'assets/images/image copy.png',
      location: 'Bouaké, Cote D`Ivoire',
      type: 'Disponible',
      product: 'Maïs',
      quantity: '25 tonnes',
      price: '1100 FCFA / kg',
    ),
    OfferModel(
      image: 'assets/images/image copy.png',
      location: 'Bouaké, Cote D`Ivoire',
      type: 'Disponible',
      product: 'Maïs',
      quantity: '25 tonnes',
      price: '1100 FCFA / kg',
    ),
  ];

  final List<RecommendationModel> recommendations = [
    RecommendationModel(
      image: 'assets/images/image.png',
      name: 'Maïs Jaune',
      location: 'Korhogo, Cote D`Ivoire',
      quantity: '40 tonnes',
      price: '1700 FCFA / kg',
      timeAgo: 'il y a 1 jour',
      status: 'Disponible',
    ),
    RecommendationModel(
      image: 'assets/images/image copy.png',
      name: 'Hévéa Séché',
      location: 'Gagnoa, Cote D`Ivoire',
      quantity: '10 tonnes',
      price: '1700 FCFA / kg',
      timeAgo: 'il y a 2 jours',
      status: 'Prévisionnel',
    ),
  ];

  List<OfferModel> get paginatedOffers {
    final int start = _currentPage * _pageSize;
    final int end = (_currentPage + 1) * _pageSize;
    return offers.sublist(start, end.clamp(0, offers.length));
  }

  List<Widget> get pages => [
        _buildHomeContent(),
        const Center(child: Text("Annonces", style: TextStyle(fontSize: 24))),
        const Center(child: Text("Transactions", style: TextStyle(fontSize: 24))),
        const Center(child: Text("Profil", style: TextStyle(fontSize: 24))),
      ];

  Widget _buildHomeContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SearchBarWidget(),
            const SizedBox(height: 16),
            const FilterButtons(),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Top offres", style: Theme.of(context).textTheme.titleLarge),
                TextButton(
                  onPressed: () {
                    setState(() {
                      if ((_currentPage + 1) * _pageSize < offers.length) {
                        _currentPage++;
                      } else {
                        _currentPage = 0; // retour au début
                      }
                    });
                  },
                  child: const Text(
                    "Suivant >",
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: paginatedOffers.length,
                itemBuilder: (context, index) {
                  return TopOffersCard(offer: paginatedOffers[index]);
                },
              ),
            ),
            const SizedBox(height: 45),
            Text("Recommandé", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 5),
            Column(
              children: recommendations.map((recommendation) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: RecommendationCard(recommendation: recommendation),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
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
