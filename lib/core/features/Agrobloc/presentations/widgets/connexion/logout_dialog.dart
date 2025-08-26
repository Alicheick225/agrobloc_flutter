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
                if (profileId == "producteur") {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    "/loginProducteur",
                    (route) => false,
                  );
                } else if (profileId == "acheteur") {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    "/loginAcheteur",
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
