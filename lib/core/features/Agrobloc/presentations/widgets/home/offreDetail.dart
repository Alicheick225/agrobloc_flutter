import 'package:flutter/material.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/offreModels.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/AnnonceVenteModel.dart';

class OffreDetailPage extends StatelessWidget {
  final OfferModel? topOffer;
  final AnnonceVente? recommendation;

  const OffreDetailPage({
    super.key,
    this.topOffer,
    this.recommendation,
  });

  @override
  Widget build(BuildContext context) {
    final isTopOffer = topOffer != null;

    final image = isTopOffer ? (topOffer!.image ?? '') : (recommendation?.photo ?? '');
    final product = isTopOffer ? (topOffer!.product ?? "Produit inconnu") : (recommendation?.typeCultureLibelle ?? "Inconnu");
    final price = isTopOffer ? (topOffer!.price ?? 0) : (recommendation?.prixKg ?? 0);
    final quantity = isTopOffer ? (topOffer!.quantity ?? 0) : (recommendation?.quantite ?? 0);
    final location = isTopOffer ? (topOffer!.location ?? "Non renseignée") : (recommendation?.parcelleAdresse ?? "Non renseignée");
    final statut = (isTopOffer ? (topOffer!.type ?? "Indisponible") : (recommendation?.statut ?? "Indisponible")).toLowerCase();

    return Scaffold(
      body: Column(
        children: [
        Stack(
  children: [
    (image.isNotEmpty && (image.startsWith('http') || image.startsWith('https')))
        ? Image.network(
            image,
            width: double.infinity,
            height: 250,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.broken_image, size: 100),
          )
        : Image.network(
            "http://192.168.56.1:8000/uploads/$image",
            width: double.infinity,
            height: 250,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                Container(
                  width: double.infinity,
                  height: 250,
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, size: 100),
                ),
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
                    color: statut.toLowerCase() == "disponible" ? Colors.green : Colors.red,
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
          )
,
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
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text("Stock: ",
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      Text("$quantity", style: const TextStyle(color: Colors.green)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(location, style: const TextStyle(color: Colors.black87)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.favorite_border),
                          label: const Text("Favoris"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
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

// Petite extension pour mettre la première lettre en majuscule
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
