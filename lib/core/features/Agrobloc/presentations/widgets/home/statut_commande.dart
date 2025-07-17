import 'package:flutter/material.dart';

class StatutCommandePage extends StatelessWidget {
  const StatutCommandePage({super.key});

  // Couleurs définies comme constantes
  static const Color green = Color(0xFF5D9643);
  static const Color grey = Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Statut Commande",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStep(
              number: 1,
              title: "Paiement initié",
              description:
                  "Conseils : Utilisez votre propre compte de paiement et assurez-vous que le nom sur le compte correspond au nom du bénéficiaire.",
              showLine: true,
            ),
            _buildStep(
              number: 2,
              title: "Confirmation du paiement",
              description:
                  "NB : Veuillez tapez la syntaxe *144*82# pour confirmer ou téléchargez l’application Maxit pour confirmer plus facilement.",
              showLine: true,
            ),
            _buildStep(
              number: 3,
              title: "Livraison de la marchandise",
              description:
                  "Montant reçu et sécurisé sur le compte séquestre en attendant la livraison de votre marchandise.",
              showLine: true,
            ),
            _buildStep(
              number: 4,
              title: "Confirmation de réception du produit",
              description: "",
              showLine: false,
              showButtons: true,
            ),
          ],
        ),
      ),
    );
  }

  /// Retourne un pas avec un losange, une ligne et le contenu textuel.
  Widget _buildStep({
    required int number,
    required String title,
    required String description,
    required bool showLine,
    bool showButtons = false,
  }) {
    // RichText pour les préfixes en gras
    Widget descWidget;
    if (description.startsWith('Conseils') || description.startsWith('NB')) {
      final parts = description.split(RegExp(r':\s*'));
      descWidget = RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.grey),
          children: [
            TextSpan(
              text: '${parts[0]}: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: parts.length > 1 ? parts[1] : '',
            ),
          ],
        ),
      );
    } else {
      descWidget = Text(
        description,
        style: const TextStyle(color: Colors.grey),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4), // même espacement entre chaque losange
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Transform.rotate(
                angle: 0.785398,
                child: Container(
                  width: 30,
                  height: 30,
                  color: green,
                  child: Center(
                    child: Transform.rotate(
                      angle: -0.785398,
                      child: Text(
                        number.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (showLine) ...[
                const SizedBox(height: 16),
                Container(
                  width: 2,
                  height: 60,
                  margin: const EdgeInsets.symmetric(horizontal: 14),
                  color: green,
                ),
                const SizedBox(height: 16),
              ],
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                if (description.isNotEmpty) descWidget,
                if (showButtons)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: green,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text("Oui je confirme"),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text("Pas encore reçu"),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
