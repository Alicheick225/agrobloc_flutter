import 'package:flutter/material.dart';
import 'package:agrobloc/core/themes/app_text_styles.dart';
import 'package:agrobloc/core/feactures/Agrobloc/data/models/offreRecommandeModels.dart';

class RecommendationCard extends StatelessWidget {
  final RecommendationModel recommendation;

  const RecommendationCard({super.key, required this.recommendation});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 100), // 📏 Limite la hauteur
      margin: const EdgeInsets.symmetric(vertical: 3),    // 🔽 Réduit l'espacement
      padding: const EdgeInsets.all(6),                   // 🔽 Réduit le padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),          // 🔽 Coins légèrement moins arrondis
        boxShadow: [BoxShadow(blurRadius: 3, color: Colors.black12)],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 📸 Image réduite
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              recommendation.image,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 6),
          // 📝 Contenu
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔝 Titre + like
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          text: recommendation.name,
                          style: AppTextStyles.subheading.copyWith(fontSize: 12, fontWeight: FontWeight.bold),
                          children: [
                            TextSpan(
                              text: " ${recommendation.quantity}",
                              style: AppTextStyles.body.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.normal,
                                color: Colors.grey,),
                            ),
                          ],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.favorite_border, size: 18),
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                Text("1700 FCFA / kg",
                    style: const TextStyle(
                        color: Colors.green, fontWeight: FontWeight.bold, fontSize: 10)),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 10, color: Colors.grey),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(recommendation.location,
                          style: AppTextStyles.body.copyWith(
                              fontSize: 10, color: Colors.grey),
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 10, color: Colors.grey),
                        const SizedBox(width: 1),
                        Text("il y a 2 jours",
                            style: AppTextStyles.body.copyWith(fontSize: 10)),
                      ],
                    ),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        minimumSize: const Size(0, 12),
                        side: const BorderSide(color: Colors.blue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text("Prévisionnel",
                          style: TextStyle(fontSize: 10, color: Colors.blue)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
