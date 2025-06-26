import 'package:flutter/material.dart';
import 'package:agrobloc/core/themes/app_colors.dart';
import 'package:agrobloc/core/feactures/Agrobloc/data/models/financementModel.dart';
import 'package:agrobloc/core/feactures/Agrobloc/presentations/widgets/financementCard.dart';

class HomeFinancement extends StatelessWidget {
  const HomeFinancement({super.key});

  @override
  Widget build(BuildContext context) {
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Financements'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
      ),
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: financements.length,
          itemBuilder: (context, index) {
            final financement = financements[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: FinancementCard(data: financement),
            );
          },
        ),
      ),
    );
  }
}
