import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/acheteurs/home/offreDetail.dart';
import 'package:agrobloc/core/utils/image.dart';
import 'package:flutter/material.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/AnnonceVenteModel.dart';
import 'package:agrobloc/core/themes/app_colors.dart';
import 'package:agrobloc/core/utils/app_text_styles.dart';

class OffreCard extends StatelessWidget {
  final AnnonceVente data;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;
  final bool isLiked;
  final AnnonceVente? recommendation;
  final String? acheteurId; // ID de l'acheteur pour les transactions

  const OffreCard({
    super.key,
    required this.data,
    this.onTap,
    this.onFavoriteToggle,
    this.isLiked = false,
    this.recommendation,
    this.acheteurId,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = getImageUrl(data.photo) ?? 'https://via.placeholder.com/400x200?text=No+Image';
    final statutLower = data.statut.toLowerCase();

    /// ✅ Date de publication en texte lisible
    String getTimeText() {
      if (data.createdAt == null) return "Aujourd'hui";
      try {
        final date = DateTime.parse(data.createdAt!);
        final daysAgo = DateTime.now().difference(date).inDays;
        return daysAgo == 0 ? "Aujourd'hui" : "Il y a $daysAgo jours";
      } catch (_) {
        return "Aujourd'hui";
      }
    }

    return GestureDetector(
      onTap: onTap ??
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OffreDetailPage(
                  recommendation: data,
                  acheteurId: acheteurId,
                ),
              ),
            );
          },
      child: Container(
        height: 116,
        constraints: const BoxConstraints(
          maxWidth: double.infinity,
        ),
        margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black12)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ IMAGE + ÉTIQUETTE + FAVORI
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: double.maxFinite,
                        height: 60,
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image,
                            size: 50, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
               
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? Colors.red : Colors.white,
                    ),
                    onPressed: onFavoriteToggle,
                  ),
                ),
              ],
            ),

            // ✅ CONTENU TEXTE
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ PRIX
                  Text(
                    "${data.prixKg.toStringAsFixed(0)} FCFA / kg",
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),

                  // ✅ TYPE + QUANTITÉ
                  Text(
                    data.cultureLibelle.isNotEmpty
                        ? "${data.cultureLibelle} ${data.quantite.toStringAsFixed(0)} ${data.quantiteUnite}"
                        : "Culture non spécifié",
                    style: AppTextStyles.body.copyWith(fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // ✅ ADRESSE
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 11, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          data.parcelleAdresse,
                          style: AppTextStyles.body.copyWith(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
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

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
