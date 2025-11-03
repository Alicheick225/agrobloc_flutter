import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MomoService {
  final String apiUrl =
      "http://192.168.252.199:3004/debit"; // 🔥 backend Express local
  // final String apiUrl = "https://mtn-momo-backend.example.com/debit"; // 🔥 backend Express en ligne

  Future<void> makePayment({
    required double prixTotal,
    required String numeroClient,
    required String nomClient,
    required BuildContext context,
  }) async {
    // 🔹 Préparation des données à envoyer au backend
    final Map<String, dynamic> paymentData = {
      "amount": prixTotal.toStringAsFixed(0), // MTN attend une string
      "currency": "EUR",
      "externalId": DateTime.now().millisecondsSinceEpoch.toString(),
      "partyId": numeroClient, // Numéro du client ex : "46732123450"
    };

    // 🔹 Print pour vérifier que le montant et les données sont bien définis
    print("Données envoyées au backend: $paymentData");

    try {
      // 🔹 Appel HTTP POST vers le backend
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(paymentData),
      );

      // 🔹 Gestion de la réponse
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // 🔹 MTN renvoie referenceId et status
        final referenceId = data['referenceId'] ?? '';
        final status = data['status'] ?? '';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Paiement initié ✅ ReferenceId: $referenceId, Status: $status",
            ),
          ),
        );
      } else {
        // 🔴 Gestion claire des erreurs serveur
        String messageErreur;
        switch (response.statusCode) {
          case 502:
            messageErreur =
                "Le service MoMo est momentanément indisponible (502). Réessayez plus tard.";
            break;
          case 500:
            messageErreur = "Erreur interne du serveur MoMo (500).";
            break;
          case 404:
            messageErreur = "Service introuvable (404). Vérifiez l'URL.";
            break;
          default:
            messageErreur =
                "Erreur serveur: ${response.statusCode} - ${response.reasonPhrase}";
        }
        throw Exception(messageErreur);
      }
    } on http.ClientException catch (_) {
      throw Exception("Erreur réseau : impossible de contacter le serveur.");
    } on FormatException catch (_) {
      throw Exception("Erreur de format dans la réponse du serveur.");
    } catch (e) {
      throw Exception("Erreur inattendue : $e");
    }
  }
}
