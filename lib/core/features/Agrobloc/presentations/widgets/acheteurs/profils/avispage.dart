import 'package:flutter/material.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/commande_vente.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/commande_vente_service.dart';
// Correction de l'import, la classe s'appelle EvaluationVentePage
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/acheteurs/profils/evaluationVentePage.dart'; 
import 'package:agrobloc/core/themes/app_colors.dart';

class AvisPage extends StatefulWidget {
  const AvisPage({super.key});

  @override
  State<AvisPage> createState() => _AvisPageState();
}

class _AvisPageState extends State<AvisPage> {
  final CommandeVenteService service = CommandeVenteService();
  late Future<List<CommandeVente>> commandesFuture;

  @override
  void initState() {
    super.initState();
    _fetchCommandes();
  }

  // Méthode pour récupérer les commandes et rafraîchir l'interface
  Future<void> _fetchCommandes() async {
    setState(() {
      commandesFuture = service.getCommandesEnCours();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        title: FutureBuilder<List<CommandeVente>>(
          future: commandesFuture,
          builder: (context, snapshot) {
            int count = snapshot.hasData ? snapshot.data!.length : 0;
            return Text("Vos avis en attente ($count)");
          },
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<CommandeVente>>(
        future: commandesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryGreen,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Erreur : ${snapshot.error}",
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchCommandes,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Réessayer"),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.thumb_up_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Aucune commande terminée à évaluer",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Vos commandes terminées apparaîtront ici\npour que vous puissiez les évaluer",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final commandes = snapshot.data!;

          return RefreshIndicator(
            color: AppColors.primaryGreen,
            onRefresh: _fetchCommandes,
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: commandes.length,
              itemBuilder: (context, index) {
                final commande = commandes[index];
                return AvisCard(
                  commande: commande,
                  onEvaluationSubmitted: _fetchCommandes,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class AvisCard extends StatelessWidget {
  final CommandeVente commande;
  final VoidCallback onEvaluationSubmitted; // Callback pour rafraîchir la liste

  const AvisCard({
    super.key,
    required this.commande,
    required this.onEvaluationSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Image placeholder du produit
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  "https://via.placeholder.com/80x80/4CAF50/FFFFFF?text=Produit",
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.primaryGreen.withOpacity(0.1),
                      child: const Icon(
                        Icons.agriculture,
                        color: AppColors.primaryGreen,
                        size: 32,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Infos commande
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Commande n°${commande.id}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Quantité: ${commande.quantite.toInt()} kg",
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Total: ${commande.prixTotal.toInt()} F CFA",
                    style: const TextStyle(
                      color: AppColors.primaryGreen,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Terminée le ${commande.createdAt.day}/${commande.createdAt.month}/${commande.createdAt.year}",
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Badge de statut et bouton "Evaluer"
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: commande.statut.color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: commande.statut.color),
                        ),
                        child: Text(
                          commande.statut.name.toUpperCase(),
                          style: TextStyle(
                            color: commande.statut.color,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              // Utilisation du bon nom de classe
                              builder: (_) => EvaluationVentePage(
                                annoncesVenteId: commande.id,
                                produitNom: "Produit de la commande n°${commande.id}",
                                produitPhoto: null, // Si votre modèle CommandeVente n'a pas de photo
                                userToken: null, // Remplacer par le vrai token utilisateur
                                userName: "Votre Nom", // Remplacer par le nom de l'utilisateur
                              ),
                            ),
                          );
                          
                          // Si un résultat est retourné (avis créé), rafraîchir la liste
                          if (result != null) {
                            onEvaluationSubmitted();
                          }
                        },
                        icon: const Icon(Icons.star_outline, size: 16),
                        label: const Text(
                          "Évaluer",
                          style: TextStyle(fontSize: 12),
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