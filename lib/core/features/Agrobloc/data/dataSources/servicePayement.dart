import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
class FusionMoneyService {
  final String apiUrl =
      "https://www.pay.moneyfusion.net/agrobloc/9c9ab8caba916000/pay/";
  final String apiKey =
      "moneyfusion_v1_688207f0a9f807c27518daa0_4C9BF13BAAD20A620A813C7F139E64FE72C6D1EE5F979D0756AD9E83B2987DB4";

  /// ✅ Fonction de paiement
  Future<void> makePayment({
    required double montant,
    required String numeroClient,
    required String nomClient,
    required BuildContext context,
  }) async {
    final Map<String, dynamic> paymentData = {
      "totalPrice": montant,
      "article": [      
        {
          "produit": montant
        },
      ],
      "personal_Info": [
        {
          "userId": 1,
          "orderId": DateTime.now().millisecondsSinceEpoch,
        },
      ],
      "numeroSend": numeroClient,
      "nomclient": nomClient,
      "return_url": "https://ton-domaine.com/paiement-retour",
      "webhook_url": "https://ton-domaine.com/paiement-webhook",
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $apiKey",
        },
        body: jsonEncode(paymentData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint("✅ Réponse Fusion Money : $data");

        /// ✅ Vérifie si la requête est OK
        if (data['statut'] == true) {
          final paymentUrlString = data['url'] as String?;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? "Paiement en cours...")),
          );

          if (paymentUrlString != null) {
            final Uri paymentUrl = Uri.parse(paymentUrlString);
            if (await canLaunchUrl(paymentUrl)) {
              await launchUrl(paymentUrl,
                  mode: LaunchMode.externalApplication);
            } else {
              throw Exception("Impossible d'ouvrir l'URL de paiement.");
            }
          } else {
            throw Exception("URL de paiement manquante dans la réponse.");
          }
        } else {
          throw Exception("Erreur API: ${data['message'] ?? 'Paiement échoué'}");
        }
      } else {
        throw Exception(
            "Erreur serveur: ${response.statusCode} - ${response.reasonPhrase}");
      }
    } catch (e) {
      debugPrint("❌ Exception paiement : $e");
      rethrow;
    }
  }
}