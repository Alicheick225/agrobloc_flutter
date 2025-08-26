import 'package:flutter/material.dart';
import 'package:location_manager/location_manager.dart';

class LocalisationPage extends StatefulWidget {
  const LocalisationPage({super.key});

  @override
  State<LocalisationPage> createState() => _LocalisationPageState();
}

class _LocalisationPageState extends State<LocalisationPage> {
  String _address = "Localisation en cours...";

  @override
  void initState() {
    super.initState();
    _getAddress();
  }

  Future<void> _getAddress() async {
    try {
      LocationManager locationManager = LocationManager();
      AddressComponent? address = await locationManager.getAddressFromGPS();

      if (address != null) {
        setState(() {
          _address =
              "${address.address1 ?? ''}, ${address.city ?? ''}, ${address.country ?? ''}";
        });
      } else {
        setState(() {
          _address = "Impossible de récupérer l'adresse.";
        });
      }
    } catch (e) {
      setState(() {
        _address = "Erreur : $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ma Localisation")),
      body: Center(
        child: Text(
          _address,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
