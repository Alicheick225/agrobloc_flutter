import 'package:flutter/material.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/acheteurs/transactions/commandesProduit.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/AnnonceVenteModel.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/annonceVenteService.dart';
import 'package:agrobloc/core/utils/image.dart'; // ✅ pour getImageUrl

class OffreDetailPage extends StatefulWidget {
  final AnnonceVente recommendation;
  final String? acheteurId;

  const OffreDetailPage({
    super.key,
    this.acheteurId,
    required this.recommendation,
  });

  @override
  State<OffreDetailPage> createState() => _OffreDetailPageState();
}

class _OffreDetailPageState extends State<OffreDetailPage> {
  @override
  Widget build(BuildContext context) {
    final imageUrl = getImageUrl(widget.recommendation.photo) ?? 'https://via.placeholder.com/400x200?text=No+Image';
    final product = widget.recommendation.cultureLibelle.isNotEmpty
        ? widget.recommendation.cultureLibelle
        : "Produit inconnu";
    final description = widget.recommendation.description.isNotEmpty
        ? widget.recommendation.description
        : "Aucune description disponible";
    final price = widget.recommendation.prixKg;
    final quantity = widget.recommendation.quantite;
    final location = widget.recommendation.parcelleAdresse.isNotEmpty
        ? widget.recommendation.parcelleAdresse
        : "Non renseignée";
    final statut = (widget.recommendation.statut).toLowerCase();
    final nomVendeur = widget.recommendation.userNom.isNotEmpty
        ? widget.recommendation.userNom
        : "Nom inconnu";
    final note = widget.recommendation.note?.toDouble() ?? 0.0;

    return Scaffold(
      body: Column(
        children: [
          /// ✅ IMAGE + BOUTONS
          Stack(
            children: [
              Image.network(
                imageUrl,
                width: double.infinity,
                height: 280,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _imageErrorWidget(),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                          text: "$quantity ${widget.recommendation.quantiteUnite}",
                          style: const TextStyle(
                              color: Colors.green, fontWeight: FontWeight.w500),
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
                      const Icon(Icons.location_on,
                          size: 18, color: Colors.grey),
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

                  /// ✅ Note
                  Row(
                    children: [
                      ...List.generate(5, (index) {
                        return Icon(
                          index < note.round() ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 18,
                        );
                      }),
                      const SizedBox(width: 6),
                      Text(
                        "(${note.toStringAsFixed(1)}/5)",
                        style: const TextStyle(
                            fontSize: 13, color: Colors.black54),
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
                          onPressed: statut == "disponible" ? () async {
                            // ✅ Vérification en temps réel de l'état de l'annonce
                            try {
                              print('🔍 Vérification en temps réel de l\'annonce ${widget.recommendation.id}...');
                              final annonceService = AnnonceService();
                              final annonceActualisee = await annonceService.getAnnonceByID(widget.recommendation.id);

                              if (annonceActualisee.statut.toLowerCase() != "disponible") {
                                // L'annonce n'est plus disponible
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Cette annonce n'est plus disponible (statut: ${annonceActualisee.statut})"),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                                return;
                              }

                              // L'annonce est toujours disponible, procéder à la commande
                              if (mounted) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CommandeProduitPage(
                                        nomProduit: product,
                                        imageProduit: imageUrl,
                                        prixUnitaire: price.toDouble(),
                                        stockDisponible: quantity.toDouble(),
                                        annonce: annonceActualisee, // Utiliser les données actualisées
                                      ),
                                    ));
                              }
                            } catch (e) {
                              print('❌ Erreur vérification annonce: $e');
                              if (mounted) {
                                String errorMessage = "Erreur lors de la vérification de l'annonce";

                                // Vérifier si c'est une erreur d'authentification
                                if (e.toString().contains('User not logged in') ||
                                    e.toString().contains('Token') ||
                                    e.toString().contains('authentification')) {
                                  errorMessage = "Vous devez être connecté pour passer une commande. Veuillez vous reconnecter.";
                                } else {
                                  errorMessage = "Erreur lors de la vérification de l'annonce. Veuillez réessayer.";
                                }

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(errorMessage),
                                    backgroundColor: Colors.red,
                                    duration: const Duration(seconds: 4),
                                    action: SnackBarAction(
                                      label: 'Se connecter',
                                      textColor: Colors.white,
                                      onPressed: () {
                                        // Rediriger vers la page de connexion
                                        Navigator.pushNamed(context, '/login');
                                      },
                                    ),
                                  ),
                                );
                              }
                            }
                          } : null, // Désactiver si non disponible
                          style: ElevatedButton.styleFrom(
                            backgroundColor: statut == "disponible" ? Colors.green : Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(
                            statut == "disponible" ? "Passer une commande" : "Non disponible",
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
