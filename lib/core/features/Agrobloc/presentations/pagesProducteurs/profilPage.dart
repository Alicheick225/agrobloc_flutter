// lib/core/features/Agrobloc/presentations/pagesProducteurs/profilPage.dart

import 'package:flutter/material.dart';
import 'package:agrobloc/core/themes/app_colors.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/userService.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/authentificationModel.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/acheteurs/profils/avispage.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/connexion/logout_dialog.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/acheteurs/transactions/order%20tracking/sequestre.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/acheteurs/profils/mesinformations_page.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  AuthentificationModel? user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() {
    UserService().loadUser().then((_) {
      setState(() {
        user = UserService().currentUser;
      });
    });
  }

  void _handleOptionTap(String option) {
    switch (option) {
      case "Mes informations":
        Navigator.push(context, MaterialPageRoute(builder: (context) => const MesInformationsPage()));
        break;
      case "Mes favoris":
        Navigator.push(context, MaterialPageRoute(builder: (context) => const MesFavorisPage()));
        break;
      case "Avis":
        Navigator.push(context, MaterialPageRoute(builder: (context) => const AvisPage()));
        break;
      case "Historique transactions":
        Navigator.push(context, MaterialPageRoute(builder: (context) => const HistoriqueTransactionsPage()));
        break;
      case "Moyens de paiement":
        Navigator.push(context, MaterialPageRoute(builder: (context) => const MoyensPaiementPage()));
        break;
      case "Conditions d'utilisation et politique de confidentialité":
        Navigator.push(context, MaterialPageRoute(builder: (context) => const ConditionsPage()));
        break;
      case "Se déconnecter":
        // ✅ Ici on passe bien "producteur" comme profileId
        showLogoutDialog(context, "producteur");
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Option "$option" non implémentée'),
            backgroundColor: Colors.orange,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        title: const Text("Mon Profil", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const CompteSequestrePage()));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundImage: const AssetImage('assets/images/avatar.jpg'),
                      backgroundColor: Colors.grey[300],
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.camera_alt, size: 18, color: AppColors.primaryGreen),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(user?.nom ?? "Nom d'utilisateur", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text("#${user?.profilId ?? "Agrobloc-1ZKZKE"}", style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => _handleOptionTap("Mes informations"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  child: const Text("Modifier mon profil", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                _buildOptionItem(Icons.article_outlined, "Mes informations"),
                _buildOptionItem(Icons.favorite_border, "Mes favoris"),
                _buildOptionItem(Icons.thumb_up_off_alt, "Avis"),
                _buildOptionItem(Icons.history, "Historique transactions"),
                _buildOptionItem(Icons.payments_outlined, "Moyens de paiement"),
                _buildOptionItem(Icons.description_outlined, "Conditions d'utilisation et politique de confidentialité"),
                _buildOptionItem(Icons.logout, "Se déconnecter", color: Colors.red),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionItem(IconData icon, String title, {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.black87),
      title: Text(title, style: TextStyle(color: color ?? Colors.black)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () => _handleOptionTap(title),
    );
  }
}

// ⚠️ J’ai supprimé le doublon de `MesInformationsPage` ici !
// On garde seulement MesFavorisPage, HistoriqueTransactionsPage, MoyensPaiementPage, ConditionsPage

class MesFavorisPage extends StatelessWidget {
  const MesFavorisPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes Favoris'), backgroundColor: AppColors.primaryGreen, foregroundColor: Colors.white),
      body: const Center(child: Text('Page Mes Favoris')),
    );
  }
}

class HistoriqueTransactionsPage extends StatelessWidget {
  const HistoriqueTransactionsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historique des Transactions'), backgroundColor: AppColors.primaryGreen, foregroundColor: Colors.white),
      body: const Center(child: Text('Page Historique des Transactions')),
    );
  }
}

class MoyensPaiementPage extends StatelessWidget {
  const MoyensPaiementPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Moyens de Paiement'), backgroundColor: AppColors.primaryGreen, foregroundColor: Colors.white),
      body: const Center(child: Text('Page Moyens de Paiement')),
    );
  }
}

class ConditionsPage extends StatelessWidget {
  const ConditionsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Conditions d\'utilisation'), backgroundColor: AppColors.primaryGreen, foregroundColor: Colors.white),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Conditions d\'utilisation et Politique de confidentialité', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Text('Contenu des conditions d\'utilisation...'),
          ],
        ),
      ),
    );
  }
}
