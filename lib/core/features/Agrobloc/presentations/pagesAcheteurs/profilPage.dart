import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/acheteurs/transactions/order%20tracking/sequestre.dart';
import 'package:flutter/material.dart';
import 'package:agrobloc/core/themes/app_colors.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/userService.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/authentificationModel.dart';

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
    user = UserService().currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ==== HEADER ====
          Container(
            color: AppColors.primaryGreen,
            padding: const EdgeInsets.only(top: 40, left: 8, right: 8, bottom: 16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                const Expanded(
                  child: Text(
                    "Mon Profil",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.settings, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CompteSequestrePage()),
                    );
                  },
                ),
              ],
            ),
          ),

          // ==== PROFIL ====
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
                Text(
                  user?.nom ?? "Nom d'utilisateur",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  "#${user?.profilId ?? "Agrobloc-1ZKZKE"}",
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  child: const Text(
                    "Modifier mon profil",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          // ==== OPTIONS ====
          Expanded(
            child: ListView(
              children: [
                _buildOptionItem(Icons.article_outlined, "Mes informations"),
                _buildOptionItem(Icons.favorite_border, "Mes favoris"),
                _buildOptionItem(Icons.history, "Historique transactions"),
                _buildOptionItem(Icons.payments_outlined, "Moyens de paiement"),
                _buildOptionItem(Icons.description_outlined, "Conditions d’utilisation et politique de confidentialité"),
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
      onTap: () {},
    );
  }
}
