import 'package:agrobloc/core/utils/image.dart';
import 'package:flutter/material.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/AnnonceVenteModel.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/acheteurs/home/offreDetail.dart';
import 'package:agrobloc/core/themes/app_colors.dart';
import 'package:agrobloc/core/themes/app_text_styles.dart';

class RecommendationCard extends StatelessWidget {
  final AnnonceVente recommendation;
  final String acheteurId; // ID de l'acheteur pour les transactions

  const RecommendationCard({super.key, required this.recommendation
    , required this.acheteurId});

  @override
  Widget build(BuildContext context) {
    final imageUrl = getImageUrl(recommendation.photo);

    final statutLower = recommendation.statut.toLowerCase();
    final isDisponible = statutLower == "disponible";
    final isPrevisionnel =
        statutLower == "prévisionnel" || statutLower == "previsionnel";

    /// ✅ Texte pour la date de publication
    String getTimeText() {
      if (recommendation.datePublication == null) return "Aujourd'hui";
      try {
        final date = DateTime.parse(recommendation.datePublication!);
        final daysAgo = DateTime.now().difference(date).inDays;
        return daysAgo == 0 ? "Aujourd'hui" : "il y a $daysAgo jours";
      } catch (_) {
        return "Aujourd'hui";
      }
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OffreDetailPage(
                recommendation: recommendation,
                acheteurId: acheteurId,
              ),
            ));
      },
      child: Container(
        height: 120,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black12)],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// ✅ IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image,
                        color: Colors.grey, size: 30),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: 80,
                    height: 80,
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),

            /// ✅ INFOS PRODUIT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "${recommendation.typeCultureLibelle} ${recommendation.quantite.toStringAsFixed(0)} tonnes",
                          style: AppTextStyles.body.copyWith(
                              fontSize: 13, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.favorite_border,
                          size: 18, color: Colors.black45),
                    ],
                  ),
                  Text(
                    "${recommendation.prixKg.toStringAsFixed(0)} FCFA / kg",
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 11, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          recommendation.parcelleAdresse,
                          style: AppTextStyles.body
                              .copyWith(fontSize: 10, color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.access_time,
                              size: 11, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            getTimeText(),
                            style: AppTextStyles.body
                                .copyWith(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: isDisponible
                                ? AppColors.primaryGreen
                                : isPrevisionnel
                                    ? Colors.blue
                                    : Colors.orange,
                          ),
                        ),
                        child: Text(
                          StringExtension(recommendation.statut).capitalize(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isDisponible
                                ? AppColors.primaryGreen
                                : isPrevisionnel
                                    ? Colors.blue
                                    : Colors.orange,
                          ),
                        ),
                      )
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

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
