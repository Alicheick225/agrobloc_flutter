import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agrobloc/core/themes/app_colors.dart';

class ParametresPage extends StatefulWidget {
  final ValueChanged<bool> onThemeChanged;

  const ParametresPage({super.key, required this.onThemeChanged, required bool modeSombreActuel});

  @override
  State<ParametresPage> createState() => _ParametresPageState();
}

class _ParametresPageState extends State<ParametresPage> {
  bool notificationsActive = true;
  bool modeSombre = false;

  @override
  void initState() {
    super.initState();
    _chargerPreferences();
  }

  Future<void> _chargerPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      notificationsActive = prefs.getBool('notifications') ?? true;
      modeSombre = prefs.getBool('modeSombre') ?? false;
    });
  }

  Future<void> _sauvegarderPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', notificationsActive);
    await prefs.setBool('modeSombre', modeSombre);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        title: const Text(
          "Paramètres",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        children: [
          _buildSectionTitle("Compte"),
          _buildOptionItem(
            icon: Icons.lock_outline,
            title: "Changer le mot de passe",
            onTap: () {},
          ),
          _buildOptionItem(
            icon: Icons.person_outline,
            title: "Modifier mes informations",
            onTap: () {},
          ),

          _buildSectionTitle("Préférences"),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_none),
            title: const Text("Notifications"),
            value: notificationsActive,
            activeColor: AppColors.primaryGreen,
            onChanged: (val) {
              setState(() {
                notificationsActive = val;
              });
              _sauvegarderPreferences();
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode_outlined),
            title: const Text("Mode sombre"),
            value: modeSombre,
            activeColor: AppColors.primaryGreen,
            onChanged: (val) {
              setState(() {
                modeSombre = val;
              });
              widget.onThemeChanged(modeSombre);
              _sauvegarderPreferences();
            },
          ),

          _buildSectionTitle("Autres"),
          _buildOptionItem(
            icon: Icons.language,
            title: "Langue",
            onTap: () {},
          ),
          _buildOptionItem(
            icon: Icons.help_outline,
            title: "Aide et support",
            onTap: () {},
          ),
          _buildOptionItem(
            icon: Icons.description_outlined,
            title: "Conditions d’utilisation",
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}

