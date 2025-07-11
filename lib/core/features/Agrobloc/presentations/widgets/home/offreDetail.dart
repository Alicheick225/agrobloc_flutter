import 'package:agrobloc/core/features/Agrobloc/data/models/offreModels.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/AnnonceVenteModel.dart';
import 'package:flutter/material.dart';

class OffreDetailPage extends StatelessWidget {
  final OfferModel? topOffer;
  final AnnonceVenteModel? recommendation;

  const OffreDetailPage({
    super.key,
    this.topOffer,
    this.recommendation,
  });

  @override
  Widget build(BuildContext context) {
    final isTopOffer = topOffer != null;

    final image = isTopOffer ? topOffer!.image : recommendation!.photo;
    final product = isTopOffer ? topOffer!.product : recommendation!.typeCultureId;
    final price = isTopOffer ? topOffer!.price : recommendation!.prixKg;
    final quantity = isTopOffer ? topOffer!.quantity : recommendation!.quantite;
    final location = isTopOffer ? topOffer!.location : recommendation!.parcelleId;
    final statut = isTopOffer ? topOffer!.type : recommendation!.statut;

    return Scaffold(
      body: Column(
        children: [
          // Image & retour
          Stack(
            children: [
              isTopOffer
                  ? Image.asset(
                      image,
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                    )
                  : Image.network(
                      image,
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, size: 100),
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statut == "disponible" ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    statut,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
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
                      Expanded(
                        child: Text(
                          product,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Icon(Icons.star, color: Colors.green, size: 20),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    "$price FCFA / Kg",
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
                        quantity.toString(),
                        style: const TextStyle(color: Colors.green),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          location,
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // TODO: gérer ajout aux favoris
                          },
                          icon: const Icon(Icons.favorite_border),
                          label: const Text("Favoris"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: logique pour passer une commande
                          },
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
