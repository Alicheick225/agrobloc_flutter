import 'package:agrobloc/core/features/Agrobloc/data/dataSources/AnnoncePrefinancementService.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/acheteurs/home/detailFinancement.dart';
import 'package:flutter/material.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/annoncePrefinancementModel.dart';

class ListePrefinancementsPage extends StatelessWidget {
  const ListePrefinancementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = PrefinancementService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Préfinancements"),
        backgroundColor: Colors.green,
      ),
      body: FutureBuilder<List<AnnoncePrefinancement>>(
        future: service.fetchPrefinancements(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Erreur : ${snapshot.error}"),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Aucun préfinancement trouvé"));
          }

          final annonces = snapshot.data!;
          return ListView.builder(
            itemCount: annonces.length,
            itemBuilder: (context, index) {
              return FinancementCard(data: annonces[index]);
            },
          );
        },
      ),
    );
  }
}

class FinancementCard extends StatelessWidget {
  final AnnoncePrefinancement data;

  const FinancementCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre principal
            Text(
              'Préfinancement demandé - Culture de ${data.libelle ?? "N/A"}',
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),

            // Nom + Adresse + Voir profil
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.nom ?? "Nom non disponible",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        data.adresse ?? "Adresse non renseignée",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Voir profil...")),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.remove_red_eye_outlined, color: Colors.green),
                      SizedBox(width: 4),
                      Text(
                        "Voir profil",
                        style: TextStyle(color: Colors.green, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Détails du financement
            _buildRow("Superficie :", "${data.surface ?? 0} ha"),
            _buildRow("Quantité estimée :", "${data.quantite ?? 0} kg"),
            _buildRow("Prix préférentiel :", "${data.prixKgPref ?? 0} FCFA/kg"),
            _buildRow(
                "Montant à préfinancer :", "${data.montantPref ?? 0} FCFA"),
            const SizedBox(height: 16),

            // Bouton Voir plus
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FinancementDetailsPage(data: data),
                    ),
                  );
                },
                child: const Text(
                  "Voir plus",
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: "$label ",
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
