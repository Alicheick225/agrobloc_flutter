// lib/widgets/fusion_money_widget.dart
import 'package:flutter/material.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/FusionMoneyService.dart';

class FusionMoneyWidget extends StatefulWidget {
  final double montant;
  final String numeroClient;
  final String nomClient;

  const FusionMoneyWidget({
    super.key,
    required this.montant,
    required this.numeroClient,
    required this.nomClient,
  });

  @override
  State<FusionMoneyWidget> createState() => _FusionMoneyWidgetState();
}

class _FusionMoneyWidgetState extends State<FusionMoneyWidget> {
  final FusionMoneyService _fusionMoneyService = FusionMoneyService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          "Paiement avec FusionMoney",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 20),
        Center(
          child: _isLoading
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: () async {
                    setState(() => _isLoading = true);
                    try {
                      await _fusionMoneyService.makePayment(
                        context: context,
                        montant: widget.montant,
                        numeroClient: widget.numeroClient,
                        nomClient: widget.nomClient,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Paiement réussi ✅")),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Erreur : $e")),
                      );
                    } finally {
                      setState(() => _isLoading = false);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24, // ✅ réduit la largeur
                      vertical: 12, // ✅ réduit la hauteur
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(8), // ✅ coins arrondis légers
                    ),
                  ),
                  child: const Text(
                    "Confirmer le paiement",
                    style: TextStyle(fontSize: 14), // ✅ texte plus compact
                  ),
                ),
        ),
      ],
    );
  }
}
