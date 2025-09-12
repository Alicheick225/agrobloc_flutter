import 'package:agrobloc/core/features/Agrobloc/data/models/commande_vente.dart';
import 'package:flutter/material.dart';

class ImprimerWidget extends StatelessWidget {
  final VoidCallback? onPressed;
  final String buttonText;
  final bool isLoading;

  const ImprimerWidget({
    super.key,
    this.onPressed,
    this.buttonText = 'Imprimer votre reçu de paiement',
    this.isLoading = false, required CommandeStatus commandeStatus,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : (onPressed ?? _defaultPrintAction),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.green[700],
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.green[700]!),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green[700]!),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.print, size: 20),
                  SizedBox(width: 8),
                  Text(
                    buttonText,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _defaultPrintAction() {
    // Action par défaut si aucune fonction n'est fournie
    print('Impression du reçu en cours...');
  }
}
