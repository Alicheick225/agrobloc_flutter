import 'package:flutter/material.dart';
import 'package:agrobloc/core/themes/app_text_styles.dart';
import 'package:agrobloc/core/themes/app_colors.dart';
import 'package:agrobloc/core/feactures/Agrobloc/data/models/offreRecommandeModels.dart';
import 'package:agrobloc/core/feactures/Agrobloc/presentations/pages/offreDetail.dart';

class RecommendationCard extends StatelessWidget {
  final RecommendationModel recommendation;

  const RecommendationCard({super.key, required this.recommendation});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    OffreDetailPage(recommendation: recommendation)));
      },
      child: Container(
        constraints: const BoxConstraints(maxHeight: 90),
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(blurRadius: 3, color: Colors.black12)],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 📸 Image
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
                    children: [
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            text: recommendation.name,
                            style: AppTextStyles.body.copyWith(fontSize: 14),
                            children: [
                              TextSpan(
                                text: " ${recommendation.quantity}",
                                style: AppTextStyles.body.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
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

                  // 💰 Prix
                  Text(
                    recommendation.price,
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),

                  // 📍 Localisation
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 10, color: Colors.grey),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          recommendation.location,
                          style: AppTextStyles.body
                              .copyWith(fontSize: 10, color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  // ⏰ Temps + Statut (badge stylisé)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.access_time,
                              size: 10, color: Colors.grey),
                          const SizedBox(width: 2),
                          Text(
                            recommendation.timeAgo,
                            style: AppTextStyles.body.copyWith(fontSize: 10),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: recommendation.status == "Disponible"
                              ? Colors.white
                              : Colors.white,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: recommendation.status == "Disponible"
                                ? AppColors.primaryGreen
                                : AppColors.border,
                          ),
                        ),
                        child: Text(
                          recommendation.status,
                          style: AppTextStyles.price.copyWith(
                            fontSize: 10,
                            color: recommendation.status == "Disponible"
                                ? AppColors.primaryGreen
                                : AppColors.primaryGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
