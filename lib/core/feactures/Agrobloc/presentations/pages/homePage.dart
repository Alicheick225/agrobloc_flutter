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

  final List<OfferModel> offers = [
    OfferModel(
      image: 'assets/images/image.png',
      location: 'Agboville',
      type: 'Disponible',
      product: 'Hévéa',
      quantity: '40 tonnes',
      price: '1700 FCFA / kg',
    ),
    OfferModel(
      image: 'assets/images/image copy.png',
      location: 'Bouaké',
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
      location: 'Korhogo',
      quantity: '40 tonnes',
    ),
    RecommendationModel(
      image: 'assets/images/image copy.png',
      name: 'Hévéa Séché',
      location: 'Gagnoa',
      quantity: '10 tonnes',
    ),
  ];

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

            // 🟢 Titre + bouton "Suivant"
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Top offres", style: Theme.of(context).textTheme.titleLarge),
                TextButton(
                  onPressed: () {
                    // Action si besoin
                  },
                  child: const Text("Suivant >"),
                ),
              ],
            ),

            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: offers.length,
                itemBuilder: (context, index) {
                  return TopOffersCard(offer: offers[index]);
                },
              ),
            ),

            const SizedBox(height: 32),
            Text("Recommandé", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Column(
              children: recommendations.map((recommendation) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
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
