import 'package:flutter/material.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/userService.dart';

Future<void> showLogoutDialog(BuildContext context, String profileId) async {
  showDialog(
    context: context,
    builder: (BuildContext ctx) {
      return AlertDialog(
        title: const Text("Déconnexion"),
        content: const Text("Voulez-vous vraiment vous déconnecter ?"),
        actions: [
          TextButton(
            child: const Text("Annuler"),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: const Text("Déconnexion"),
            onPressed: () async {
              Navigator.of(ctx).pop(); // ferme le popup

              try {
                // Déconnexion côté local + serveur (si token présent)
                await UserService().logoutUser();

                // 🔀 Redirection en fonction du rôle
                if (profileId == "producteur" || profileId == "f23423d4-ca9e-409b-b3fb-26126ab66581") {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    "/loginProducteur",
                    (route) => false,
                  );
                } else if (profileId == "acheteur" || profileId == "35a3c32a-17f8-4771-a0d8-9295b1bc5917") {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    "/loginAcheteur",
                    (route) => false,
                  );
                } else if (profileId == "cooperative" || profileId == "7b74a4f6-67b6-474a-9bf5-d63e04d2a804") {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    "/loginCooperative",
                    (route) => false,
                  );
                } else {
                  // fallback si profileId inconnu
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    "/login",
                    (route) => false,
                  );
                }
              } catch (e) {
                debugPrint("❌ Erreur lors de la déconnexion: $e");
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Erreur lors de la déconnexion"),
                  ),
                );
              }
            },
          ),
        ],
      );
    },
  );
}
