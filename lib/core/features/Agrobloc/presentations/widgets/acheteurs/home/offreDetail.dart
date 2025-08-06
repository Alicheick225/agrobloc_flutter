import 'package:flutter/material.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/acheteurs/transactions/commandesProduit.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/AnnonceVenteModel.dart';

class OffreDetailPage extends StatelessWidget {
  final AnnonceVente recommendation;
    final String acheteurId; // 👈 à ajouter



  const OffreDetailPage({
    super.key,
    required this.recommendation,
    required this.acheteurId , // 👈 à initialiser
  });

  @override
  Widget build(BuildContext context) {
    final image = recommendation.photo ?? "";
    final product = recommendation.typeCultureLibelle.isNotEmpty
        ? recommendation.typeCultureLibelle
        : "Produit inconnu";
    final description = recommendation.description.isNotEmpty
        ? recommendation.description
        : "Aucune description disponible";
    final price = recommendation.prixKg;
    final quantity = recommendation.quantite;
    final location = recommendation.parcelleAdresse.isNotEmpty
        ? recommendation.parcelleAdresse
        : "Non renseignée";
    final statut = (recommendation.statut).toLowerCase();
    final nomVendeur = recommendation.userNom.isNotEmpty
        ? recommendation.userNom
        : "Nom inconnu";

    final note = recommendation.note?.toDouble() ?? 0.0;

    return Scaffold(
      body: Column(
        children: [
          /// ✅ IMAGE + BOUTONS
          Stack(
            children: [
              (image.isNotEmpty &&
                      (image.startsWith('http') || image.startsWith('https')))
                  ? Image.network(
                      image,
                      width: double.infinity,
                      height: 280,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _imageErrorWidget(),
                    )
                  : Image.network(
                      "http://192.168.252.19:8080$image",
                      width: double.infinity,
                      height: 280,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _imageErrorWidget(),
                    ),

              /// ✅ Bouton retour
              Positioned(
                top: 40,
                left: 16,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Row(
                    children: const [
                      Icon(Icons.arrow_back, color: Colors.white),
                      SizedBox(width: 8),
                      Text("Retour",
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                    ],
                  ),
                ),
              ),

              /// ✅ Badge Statut
              Positioned(
                top: 40,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statut == "disponible" ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statut.capitalize(),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 14),
                  ),
                ),
              ),
            ],
          ),

          /// ✅ CONTENU DETAIL
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  /// ✅ Nom du produit
                  Text(
                    product,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  /// ✅ Description
                  Text(
                    description,
                    style: const TextStyle(
                        color: Colors.black87, fontSize: 14, height: 1.4),
                  ),
                  const SizedBox(height: 16),

                  /// ✅ Prix
                  Text(
                    "${price.toStringAsFixed(0)} FCFA / kg",
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
                  ),
                  const SizedBox(height: 8),

                  /// ✅ Stock
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: "Stock : ",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 14),
                        ),
                        TextSpan(
                          text: "$quantity tonnes",
                          style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  /// ✅ Nom du vendeur
                  Row(
                    children: [
                      const Icon(Icons.person, size: 18, color: Colors.grey),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          nomVendeur,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  /// ✅ Localisation
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 18, color: Colors.grey),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          location,
                          style: const TextStyle(
                              color: Colors.black87, fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),


                  Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < note.round()
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 18,
                          );
                        }),
                        const SizedBox(width: 6),
                        Text(
                          "(${note.toStringAsFixed(1)}/5)",
                          style: const TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                      ],
),

                  /// ✅ BOUTONS
                  Row(
                    children: [
                      /// ✅ Bouton Favoris
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            // ➡️ Logique pour ajouter aux favoris
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.green),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Icon(Icons.favorite_border,
                              color: Colors.green),
                        ),
                      ),
                      const SizedBox(width: 12),

                      /// ✅ Bouton Commande
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CommandeProduitPage(
                                  nomProduit: product,
                                  acheteurId: acheteurId.toString(), // ✅ Corrigé ici
                                  imageProduit: image.isNotEmpty
                                      ? (image.startsWith('http')
                                          ? image
                                          : "http://192.168.252.19:8080$image")
                                      : "",
                                  prixUnitaire: price.toDouble(),
                                  stockDisponible: quantity.toDouble(), 
                              ),
                              )
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            "Passer une commande",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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

  /// ✅ Widget Image en cas d'erreur
  Widget _imageErrorWidget() {
    return Container(
      width: double.infinity,
      height: 280,
      color: Colors.grey[300],
      child: const Icon(Icons.broken_image, size: 100, color: Colors.grey),
    );
  }
}

/// ✅ Extension pour mettre la première lettre en majuscule
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
