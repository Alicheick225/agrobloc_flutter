import 'package:agrobloc/core/feactures/Agrobloc/data/models/financementModel.dart';
import 'package:flutter/material.dart';

class FinancementCard extends StatelessWidget {
  final FinancementModel data;

  const FinancementCard({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Préfinancement demandé  -  Culture de ${data.culture}',
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                CircleAvatar(backgroundImage: AssetImage(data.avatar), radius: 24),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data.nom, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(data.region, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
                const Spacer(),
                Row(
                  children: const [
                    Icon(Icons.remove_red_eye_outlined, color: Colors.green),
                    SizedBox(width: 4),
                    Text("Voir profil", style: TextStyle(color: Colors.green)),
                  ],
                )
              ],
            ),
            const SizedBox(height: 12),
            _buildRow("Superficie :", data.superficie),
            _buildRow("Production estimée:", data.productionEstimee),
            _buildRow("Valeur de la production:", data.valeurProduction),
            _buildRow("Prix préférentiel:", data.prixPreferentiel),
            _buildRow("Montant à préfinancer:", data.montantPreFinancer),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {},
                child: const Text("Voir plus"),
              ),
            )
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
            TextSpan(text: "$label ", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            TextSpan(text: value, style: const TextStyle(color: Colors.black)),
          ],
        ),
      ),
    );
  }
}
