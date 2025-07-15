import 'package:flutter/material.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/AnnonceVenteModel.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/home/offreDetail.dart';
import 'package:agrobloc/core/themes/app_colors.dart';
import 'package:agrobloc/core/themes/app_text_styles.dart';

class RecommendationCard extends StatelessWidget {
  final AnnonceVente recommendation;

  const RecommendationCard({super.key, required this.recommendation});

  @override
  Widget build(BuildContext context) {
    final imageUrl = (recommendation.photo != null && recommendation.photo!.startsWith("http"))
        ? recommendation.photo!
        : "http://192.168.56.1:8000/uploads/${recommendation.photo ?? ''}";

    final statutLower = recommendation.statut.toLowerCase();
    final isDisponible = statutLower == "disponible";
    final isPrevisionnel = statutLower == "prévisionnel";

    String getTimeText() {
      if (recommendation.datePublication == null) return "Aujourd'hui";
      return recommendation.datePublication!.contains("jours") 
          ? recommendation.datePublication! 
          : "Aujourd'hui";
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OffreDetailPage(recommendation: recommendation),
          ),
        );
      },
      child: Container(
        height: 110,
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black12)],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                imageUrl,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 70,
                    height: 70,
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, color: Colors.grey, size: 30),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: 70,
                    height: 70,
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  );
                },
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          recommendation.typeCultureLibelle ?? "Inconnu",
                          style: AppTextStyles.body.copyWith(fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.favorite_border, size: 18, color: Colors.black45),
                    ],
                  ),
                  Text(
                    "${recommendation.prixKg ?? 0} FCFA/kg",
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 11, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          recommendation.parcelleAdresse ?? "Non renseignée",
                          style: AppTextStyles.body.copyWith(fontSize: 10, color: Colors.grey),
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
                          const Icon(Icons.access_time, size: 11, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            getTimeText(),
                            style: AppTextStyles.body.copyWith(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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