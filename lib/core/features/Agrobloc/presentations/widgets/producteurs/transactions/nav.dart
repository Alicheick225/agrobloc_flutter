import 'package:agrobloc/core/features/Agrobloc/presentations/pagesAcheteurs/homePage.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/acheteurs/home/notification_livraison_page.dart';
import 'package:agrobloc/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

class NavTransactionWidget extends StatelessWidget {
  const NavTransactionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomePage(acheteurId: 'acheteur')), // Passer l'ID de l'acheteur ici
            );
          },
        ),
        const SizedBox(width: 12),
        const Text(
          'Mes Transactions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        //  Barre de recherche

        const SizedBox(width: 68),

        //  Notification avec badge (aligné)
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => NotificationLivraisonPage()),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(right: 0), // Alignement homogène
            child: Stack(
              children: [
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                      const Icon(Icons.notifications_none, color: Colors.white),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    height: 10,
                    width: 10,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        height: 6,
                        width: 6,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
