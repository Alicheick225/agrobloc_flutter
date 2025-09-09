import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:agrobloc/core/themes/app_colors.dart';

class MesInformationsPage extends StatefulWidget {
  const MesInformationsPage({super.key});

  @override
  State<MesInformationsPage> createState() => _MesInformationsPageState();
}

class _MesInformationsPageState extends State<MesInformationsPage> {
  String _adresse = "Chargement...";
  String _nom = "Gawa Ashley Priscille";
  String _email = "ashleygawa63@gmail.com";
  String _telephone = "+225 07 07 07 07 07";
  String _cultures = "Banane, Manioc";
  String _cooperative = "Borussia Monchengladbach";

  @override
  void initState() {
    super.initState();
    _getAddress();
  }

  /// 📍 Récupère l’adresse GPS avec Geolocator
  Future<void> _getAddress() async {
    try {
      // Vérifie la permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _adresse = "Permission refusée");
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() => _adresse = "Permission refusée définitivement");
        return;
      }

      // Récupère la position GPS
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // Transforme en adresse
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _adresse = "${place.locality ?? 'Inconnu'}, ${place.country ?? ''}";
        });
      } else {
        setState(() => _adresse = "Adresse introuvable");
      }
    } catch (e) {
      setState(() => _adresse = "Erreur localisation");
    }
  }

  Widget _buildInfoRow(String label, String value,
      {bool showArrow = false, IconData? icon}) {
    return ListTile(
      leading: icon != null ? Icon(icon, color: Colors.grey[600]) : null,
      title: Text(label,
          style: const TextStyle(
              fontWeight: FontWeight.w600, color: Colors.black87)),
      subtitle: Text(value, style: const TextStyle(color: Colors.black54)),
      trailing:
          showArrow ? const Icon(Icons.chevron_right, color: Colors.grey) : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes Informations"),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),

          // Photo de profil
          Center(
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 45,
                  backgroundImage:
                      AssetImage("assets/images/profile_placeholder.png"),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    // TODO: ouvrir la galerie et uploader la photo
                  },
                  child: const Text("Modifier la photo de profil",
                      style: TextStyle(color: Colors.black87)),
                ),
              ],
            ),
          ),

          const Divider(),

          // Infos utilisateur
          _buildInfoRow("Nom", _nom),
          _buildInfoRow("Adresse email", _email),
          _buildInfoRow("Téléphone", _telephone),
          _buildInfoRow("Localisation", _adresse,
              showArrow: true, icon: Icons.location_on),
          _buildInfoRow("Cultures", _cultures, showArrow: true),
          _buildInfoRow("Coopérative affiliée", _cooperative),

          const Divider(),

          // Actions spéciales
          ListTile(
            title: const Text(
              "Passer à un compte producteur de rente",
              style: TextStyle(color: Colors.green),
            ),
            onTap: () {},
          ),
          ListTile(
            title: const Text(
              "Montrer que mon profil est vérifié",
              style: TextStyle(color: Colors.green),
            ),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
