// lib/pages/commande_produit_page.dart
import 'package:flutter/material.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/AnnonceVenteModel.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/commandeService.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/annonceVenteService.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/acheteurs/transactions/order tracking/Trackingpage.dart';


class CommandeProduitPage extends StatefulWidget {
  final String nomProduit;
  final String imageProduit;
  final double prixUnitaire;
  final double stockDisponible;
  final AnnonceVente annonce;

  const CommandeProduitPage({
    super.key,
    required this.nomProduit,
    required this.imageProduit,
    required this.prixUnitaire,
    required this.stockDisponible,
    required this.annonce,
  });

  @override
  State<CommandeProduitPage> createState() => _CommandeProduitPageState();
}

class _CommandeProduitPageState extends State<CommandeProduitPage> {
  int quantite = 1;
  String unite = "Kg";

  double get totalPrix {
    final qteKg = unite == "T" ? quantite * 1000 : quantite.toDouble();
    return widget.prixUnitaire * qteKg;
  }



// Dans _CommandeProduitPageState
  Future<void> _enregistrerCommande() async {
    if (quantite < 1) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Quantité minimale : 1")),
      );
      return;
    }

    // ✅ Validation: Vérifier en temps réel que l'annonce existe et est disponible
    try {
      print('🔍 Vérification en temps réel de l\'annonce ${widget.annonce.id} avant commande...');
      final annonceService = AnnonceService();
      final annonceActualisee = await annonceService.getAnnonceByID(widget.annonce.id);

      if (annonceActualisee.statut.toLowerCase() != "disponible") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Cette annonce n'est plus disponible (statut: ${annonceActualisee.statut})")),
        );
        // Navigate back after showing the message
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) Navigator.pop(context);
        });
        return;
      }
    } catch (e) {
      print('❌ Erreur vérification annonce avant commande: $e');
      if (!mounted) return;

      String errorMessage = "Erreur lors de la vérification de l'annonce";
      bool shouldNavigateBack = false;

      if (e.toString().contains("404") || e.toString().contains("n'existe plus")) {
        errorMessage = "Cette annonce n'existe plus ou a été supprimée. Elle n'est plus disponible pour commande.";
        shouldNavigateBack = true;
      } else if (e.toString().contains('User not logged in') ||
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
          action: (e.toString().contains('User not logged in') ||
                   e.toString().contains('Token') ||
                   e.toString().contains('authentification'))
              ? SnackBarAction(
                  label: 'Se connecter',
                  textColor: Colors.white,
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                )
              : null,
        ),
      );

      if (shouldNavigateBack) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) Navigator.pop(context);
        });
      }
      return;
    }

    try {
      // ✅ Logging pour debug
      print('🛒 Tentative de commande - Annonce ID: ${widget.annonce.id}, Statut: ${widget.annonce.statut}');

      final quantiteKg = unite == "T" ? quantite * 1000 : quantite.toDouble();
      final commande = await CommandeService().enregistrerCommande(
        annonceId: widget.annonce.id,
        quantite: quantiteKg.toDouble(),
        unite: unite,
        modePaiementId: null,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Commande ${commande.id} enregistrée ✅")),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OrderTrackingScreen(
            orderId: commande.id.toString(),
            commande: commande,
          ),
        ),
      );
    } catch (e) {
      // ✅ Gestion d'erreur améliorée
      String errorMessage = "Erreur inconnue";
      if (e.toString().contains("Cette annonce n'existe plus ou a été supprimée") ||
          e.toString().contains("Annonce non trouvée") ||
          e.toString().contains("404")) {
        errorMessage = "Cette annonce n'existe plus ou a été supprimée. Elle n'est plus disponible pour commande.";
        // Navigate back after showing the message
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) Navigator.pop(context);
        });
      } else if (e.toString().contains("n'est plus disponible")) {
        errorMessage = "Cette annonce n'est plus disponible pour commande.";
      } else if (e.toString().contains("Quantité insuffisante")) {
        errorMessage = "Quantité insuffisante en stock pour cette annonce.";
      } else {
        errorMessage = "Erreur lors de la commande: $e";
      }

      print('❌ Erreur commande: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Commander le produit',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        "Prix  FCFA ${totalPrix.toStringAsFixed(0)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: widget.imageProduit.startsWith("http")
                                ? Image.network(widget.imageProduit,
                                    width: 50, height: 50, fit: BoxFit.cover)
                                : Image.asset(widget.imageProduit,
                                    width: 50, height: 50, fit: BoxFit.cover),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            widget.nomProduit,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Quantité",
                                    style: TextStyle(color: Colors.grey)),
                                TextFormField(
                                  initialValue: quantite.toString(),
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                      border: InputBorder.none),
                                  style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
                                  onChanged: (val) {
                                    setState(() {
                                      quantite = int.tryParse(val) ?? 1;
                                      if (quantite < 1) quantite = 1;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          ToggleButtons(
                            isSelected: [unite == "Kg", unite == "T"],
                            onPressed: (index) {
                              setState(() {
                                unite = index == 0 ? "Kg" : "T";
                              });
                            },
                            borderRadius: BorderRadius.circular(10),
                            selectedColor: Colors.white,
                            fillColor: Colors.green,
                            children: const [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Text("Kg"),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Text("T"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _enregistrerCommande,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.green,
                          side: const BorderSide(color: Colors.green),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("Enregistrer ma commande"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
