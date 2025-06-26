import 'package:agrobloc/core/feactures/Agrobloc/data/models/offreModels.dart';
import 'package:flutter/material.dart';
import 'package:agrobloc/core/feactures/Agrobloc/data/models/offreRecommandeModels.dart';

class OffreDetailPage extends StatelessWidget {
  final OfferModel? topOffer;
  final RecommendationModel? recommendation;

  const OffreDetailPage({
    super.key,
    this.topOffer,
    this.recommendation,
  });

  @override
  Widget build(BuildContext context) {
    final isTopOffer = topOffer != null;
    final image = isTopOffer ? topOffer!.image : recommendation!.image;
    final product = isTopOffer ? topOffer!.product : recommendation!.name;
    final price = isTopOffer ? topOffer!.price : recommendation!.price;
    final quantity = isTopOffer ? topOffer!.quantity : recommendation!.quantity;
    final location = isTopOffer ? topOffer!.location : recommendation!.location;

    return Scaffold(
      body: Column(
        children: [
          // Image & retour
          Stack(
            children: [
              Image.asset(
                image,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
              ),
              Positioned(
                top: 40,
                left: 16,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Row(
                    children: const [
                      Icon(Icons.arrow_back, color: Colors.white),
                      SizedBox(width: 8),
                      Text("Retour", style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 40,
                right: 16,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isTopOffer
                        ? topOffer!.type
                        : recommendation!.status,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),

          // Détails
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: ListView(
                children: [
                  Row(
                    children: [
                      Text(
                        product,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.star, color: Colors.green, size: 20),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    price,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text(
                        "Stock: ",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        quantity,
                        style: const TextStyle(color: Colors.green),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 5),
                      Text(
                        location,
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            
                          ),
                          icon: const Icon(Icons.favorite_border),
                          label: const Text(""),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: const Text("Passer une commande"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
