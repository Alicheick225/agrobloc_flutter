import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class CompteSequestrePage extends StatefulWidget {
  const CompteSequestrePage({super.key});

  @override
  State<CompteSequestrePage> createState() => _CompteSequestrePageState();
}

class _CompteSequestrePageState extends State<CompteSequestrePage> {
  late final DateFormat _dateFormat;
  late Timer _timer;

  List<Map<String, dynamic>> transactions = [
    {
      "id": 1,
      "produit": "Maïs Jaune",
      "montant": 150000,
      "acheteur": "Jean Dupont",
      "date": DateTime.now().subtract(const Duration(days: 1)),
      "statut": "EN_ATTENTE"
    },
    {
      "id": 2,
      "produit": "Riz Local",
      "montant": 200000,
      "acheteur": "Fatou Keita",
      "date": DateTime.now().subtract(const Duration(days: 3)),
      "statut": "LIBERE"
    },
    {
      "id": 3,
      "produit": "Soja",
      "montant": 75000,
      "acheteur": "Paul Yao",
      "date": DateTime.now().subtract(const Duration(days: 5)),
      "statut": "REMBOURSE"
    },
  ];

  @override
  void initState() {
    super.initState();
    _dateFormat = DateFormat.yMMMd('fr_FR');
    
    // Timer pour vérifier toutes les 5 secondes (ou selon ton besoin)
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      _updateStatuses();
    });
  }

  void _updateStatuses() {
    final now = DateTime.now();
    setState(() {
      for (var tx in transactions) {
        if (tx["statut"] == "EN_ATTENTE") {
          // Exemple : libérer automatiquement après 2 jours
          if (now.difference(tx["date"]).inDays >= 2) {
            tx["statut"] = "LIBERE";
          }
        }
      }
    });
  }

  double get soldeSequestre => transactions
      .where((t) => t["statut"] == "EN_ATTENTE")
      .fold(0.0, (sum, t) => sum + t["montant"]);

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat("#,###", "fr_FR");

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Compte Séquestre"),
        backgroundColor: Colors.green.shade700,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.green.shade700,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Solde Séquestré",
                    style: TextStyle(color: Colors.white70, fontSize: 16)),
                const SizedBox(height: 8),
                Text(
                  "${format.format(soldeSequestre)} FCFA",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final tx = transactions[index];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: const Offset(0, 4))
                      ]),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.green.shade100,
                        child: const Icon(Icons.shopping_bag,
                            color: Colors.green),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tx["produit"],
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text("Acheteur: ${tx["acheteur"]}",
                                style: TextStyle(
                                    color: Colors.grey.shade600, fontSize: 13)),
                            Text(
                              "Montant: ${format.format(tx["montant"])} FCFA",
                              style: TextStyle(
                                  color: Colors.grey.shade800,
                                  fontWeight: FontWeight.w500),
                            ),
                            Text(
                              "Date: ${_dateFormat.format(tx["date"])}",
                              style: TextStyle(
                                  color: Colors.grey.shade500, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      // Statut affiché avec Chip
                      _buildStatusChip(tx["statut"]),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String statut) {
    switch (statut) {
      case "EN_ATTENTE":
        return Chip(
          label: const Text("En attente"),
          backgroundColor: Colors.orange.shade400,
          labelStyle: const TextStyle(color: Colors.white),
        );
      case "LIBERE":
        return Chip(
          label: const Text("Libéré"),
          backgroundColor: Colors.green.shade600,
          labelStyle: const TextStyle(color: Colors.white),
        );
      case "REMBOURSE":
        return Chip(
          label: const Text("Remboursé"),
          backgroundColor: Colors.red.shade600,
          labelStyle: const TextStyle(color: Colors.white),
        );
      default:
        return const SizedBox();
    }
  }
}
