import 'package:agrobloc/core/features/Agrobloc/data/dataSources/AnnoncePrefinancementService.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/acheteurs/home/detailFinancement.dart';
import 'package:agrobloc/core/themes/app_colors.dart';
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
        backgroundColor: AppColors.primaryGreen,
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
      margin: const EdgeInsets.symmetric(vertical: 4, ),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre principal
            Text(
              'Culture de ${data.libelle.isNotEmpty ? data.libelle : "N/A"}',
              style: const TextStyle(
                color: AppColors.primaryGreen,
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
                        data.nom.isNotEmpty ? data.nom : "Nom non disponible",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                     
                    ],
                  ),
                ),
               
              ],
            ),
            const SizedBox(height: 6),

            // Détails du financement
            _buildRow("Superficie :", "${data.surface ?? 0} ha"),
            //_buildRow("Quantité estimée :", "${data.quantite ?? 0} kg"),
            //_buildRow("Prix préférentiel :", "${data.prixKgPref ?? 0} FCFA/kg"),
            _buildRow(
                "Montant à préfinancer :", "${data.montantPref ?? 0} FCFA"),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.grey, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      data.adresse ?? 'Adresse non disponible',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
                  ' ${_service.formatDate(data.createdAt)}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
              ),
            ),

            // Bouton Voir plus
         
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
                color: Color.fromARGB(255, 69, 68, 68),
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

class _service {
  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    final minutes = difference.inMinutes;
    final hours = difference.inHours;
    final days = difference.inDays;

    if (minutes < 1) {
      return 'à l\'instant';
    } else if (minutes < 60) {
      return 'il y a $minutes ${minutes == 1 ? 'minute' : 'minutes'}';
    } else if (hours < 24) {
      return 'il y a $hours ${hours == 1 ? 'heure' : 'heures'}';
    } else if (days == 1) {
      return 'hier';
    } else if (days < 7) {
      return 'il y a $days ${days == 1 ? 'jour' : 'jours'}';
    } else if (days < 14) {
      return 'il y a 1 semaine';
    } else if (days < 28) {
      final weeks = (days / 7).floor();
      return 'Il y a $weeks semaines';
    } else {
      // Format complet: "11 Août 2025"
      final monthNames = [
        'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
        'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
      ];
      final day = date.day;
      final month = date.month;
      final year = date.year;
      return '$day ${monthNames[month - 1]} $year';
    }
  }
}
