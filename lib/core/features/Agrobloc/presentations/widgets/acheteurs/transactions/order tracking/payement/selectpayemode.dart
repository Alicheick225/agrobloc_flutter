import 'package:agrobloc/core/features/Agrobloc/data/dataSources/mtn.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/commande_vente.dart';
import 'package:flutter/material.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/commandeModel.dart';

class MomoWidget extends StatefulWidget {
  final CommandeModel commande;

  const MomoWidget({super.key, required this.commande});

  @override
  State<MomoWidget> createState() => _MomoWidgetState();
}

class _MomoWidgetState extends State<MomoWidget> {
  final MomoService _momoService = MomoService();
  final TextEditingController _numeroController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _numeroController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          "Veillez entrez votre numero orange",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 16),
        Center(
          child: SizedBox(
            width: 250, // largeur réduite
            child: TextField(
              controller: _numeroController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Numéro de téléphone",
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                    vertical: 10, horizontal: 12), // champ plus compact
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: () async {
                  final numeroClient = _numeroController.text.trim();
                  if (numeroClient.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Veuillez entrer votre numéro MoMo"),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  setState(() => _isLoading = true);

                  try {
                    await _momoService.makePayment(
                      prixTotal: widget.commande.prixTotal,
                      numeroClient: numeroClient,
                      nomClient: "Client MoMo", // ou widget.commande.nomClient
                      context: context,
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Erreur paiement : $e"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } finally {
                    setState(() => _isLoading = false);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Confirmer le paiement"),
              ),
      ],
    );
  }
}
