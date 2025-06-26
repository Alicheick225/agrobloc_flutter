import 'package:agrobloc/core/feactures/Agrobloc/data/models/offreModels.dart';
import 'package:agrobloc/core/feactures/Agrobloc/presentations/pages/offreDetail.dart';
import 'package:agrobloc/core/themes/app_colors.dart';
import 'package:agrobloc/core/themes/app_text_styles.dart';
import 'package:flutter/material.dart';

class TopOffersCard extends StatefulWidget {
  final OfferModel offer;

  const TopOffersCard({super.key, required this.offer});

  @override
  State<TopOffersCard> createState() => _TopOffersCardState();
}

class _TopOffersCardState extends State<TopOffersCard> {
  bool isLiked = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OffreDetailPage(topOffer: widget.offer),

          ),
        );
      },
      child: Container(
        width: 170,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.cardBackground,
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
              blurRadius: 1,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image + badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.asset(
                    widget.offer.image,
                    width: double.maxFinite,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: widget.offer.type == "Disponible"
                          ? Colors.white
                          : AppColors.tagBlue,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: widget.offer.type == "Disponible"
                            ? AppColors.primaryGreen
                            : AppColors.border,
                      ),
                    ),
                    child: Text(
                      widget.offer.type,
                      style: AppTextStyles.price.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: () => setState(() => isLiked = !isLiked),
                    child: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? Colors.red : Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            // Infos
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 6),
                    Text(widget.offer.price, style: AppTextStyles.price),
                    const SizedBox(height: 6),
                    Text(
                      "${widget.offer.product} • ${widget.offer.quantity}",
                      style: AppTextStyles.body,
                    ),
                    const SizedBox(height: 6),
                    Text(widget.offer.location, style: AppTextStyles.subheading),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
