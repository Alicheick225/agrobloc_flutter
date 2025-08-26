// lib/core/features/Agrobloc/presentations/dialogs/logout_dialog.dart

import 'package:flutter/material.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/userService.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/connexion/login.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/pagesAcheteurs/homePage.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/pagesProducteurs/homeProducteur.dart';

/// Affiche une boîte de dialogue de confirmation et gère la déconnexion
void showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              final userService = UserService();
              final storedProfileId = await userService.getStoredProfileId();
              
              await userService.logoutUser();
              
              Navigator.of(dialogContext).pop();

              if (storedProfileId == 'f23423d4-ca9e-409b-b3fb-26126ab66581') {
                // ID du profil producteur
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/loginProducteur',
                  (route) => false,
                );
              } else if (storedProfileId == '7b74a4f6-67b6-474a-9bf5-d63e04d2a804') {
                // ID du profil acheteur
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/loginAcheteur',
                  (route) => false,
                );
              } else {
                // Fallback si le profil n'est pas reconnu
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              }
            },
            child: const Text(
              'Se déconnecter',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      );
    },
  );
}