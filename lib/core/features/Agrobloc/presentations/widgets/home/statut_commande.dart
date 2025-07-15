import 'package:flutter/material.dart';

class StatutCommandePage extends StatelessWidget {
  const StatutCommandePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Statut Commande"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: const [
            _StepItem(
              step: 1,
              title: "Paiement initié",
              description:
                  "Conseils: Utilisez votre propre compte de paiement et assurez-vous que le nom sur le compte correspond au nom ...",
            ),
            _StepItem(
              step: 2,
              title: "Confirmation du paiement",
              description:
                  "N.B: Veuillez taper la syntaxe *144*82# pour confirmer le paiement ou télécharger l’application Maxit pour confirmer plus facilement",
            ),
            _StepItem(
              step: 3,
              title: "Livraison de la marchandise",
              description:
                  "Montant reçu et sécurisé sur le compte séquestre en attendant la livraison de votre marchandise",
            ),
            _StepItem(
              step: 4,
              title: "Confirmation de réception du produit",
              description: "",
              showButtons: true,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Accueil"),
          BottomNavigationBarItem(icon: Icon(Icons.campaign), label: "Annonces"),
          BottomNavigationBarItem(icon: Icon(Icons.swap_horiz), label: "Transactions"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
        onTap: (index) {
          // Gérer la navigation ici
        },
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final int step;
  final String title;
  final String description;
  final bool showButtons;

  const _StepItem({
    required this.step,
    required this.title,
    required this.description,
    this.showButtons = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rond numéroté vert
          CircleAvatar(
            backgroundColor: Colors.green,
            radius: 16,
            child: Text(
              step.toString(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 6),
                if (description.isNotEmpty)
                  Text(
                    description,
                    style: const TextStyle(color: Colors.grey),
                  ),
                if (showButtons) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Action confirmer
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: const Text("Oui je confirme"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Action pas encore reçu
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text("pas encore reçu"),
                        ),
                      ),
                    ],
                  )
                ]
              ],
            ),
          )
        ],
      ),
    );
  }
}
