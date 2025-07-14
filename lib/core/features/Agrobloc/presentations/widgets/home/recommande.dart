import 'package:agrobloc/core/features/Agrobloc/data/models/AnnonceVenteModel.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/home/offreDetail.dart';
import 'package:agrobloc/core/themes/app_colors.dart';
import 'package:agrobloc/core/themes/app_text_styles.dart';
import 'package:flutter/material.dart';


class RecommendationCard extends StatelessWidget {
  final AnnonceVenteModel recommendation;

  const RecommendationCard({super.key, required this.recommendation});

  @override
  Widget build(BuildContext context) {
    final imageUrl = recommendation.photo.startsWith("http")
        ? recommendation.photo
        : "http://192.168.56.1:8000/uploads/${recommendation.photo}";

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
            // 📸 Image avec gestion d'erreur
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

            // 📝 Contenu
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 🔝 Titre + like
                  Row(
                    children: [
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            text: recommendation.typeCultureLibelle,
                            style: AppTextStyles.body.copyWith(fontSize: 13),
                            children: [
                              TextSpan(
                                text: " ${recommendation.quantite}",
                                style: AppTextStyles.body.copyWith(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {}, // Logique like à implémenter
                        child: const Icon(
                          Icons.favorite_border,
                          size: 18,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ),

                  // 💰 Prix
                  Text(
                    "${recommendation.prixKg} FCFA/kg",
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),

                  // 📍 Localisation
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 11, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          recommendation.parcelleAdresse,
                          style: AppTextStyles.body.copyWith(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  // ⏰ Temps + Statut
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 11, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            "Aujourd'hui", // Logique de date à implémenter
                            style: AppTextStyles.body.copyWith(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: recommendation.statut == "Disponible"
                                ? AppColors.primaryGreen
                                : Colors.blue,
                          ),
                        ),
                        child: Text(
                          recommendation.statut,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: recommendation.statut == "Disponible"
                                ? AppColors.primaryGreen
                                : Colors.blue,
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
