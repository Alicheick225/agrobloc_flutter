import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

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
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _address = "Permission refusée");
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() => _address = "Permission refusée définitivement");
        return;
      }

      Position position =
          await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);

      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _address =
              "${place.street ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}";
        });
      } else {
        setState(() => _address = "Adresse introuvable");
      }
    } catch (e) {
      setState(() => _address = "Erreur localisation : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ma Localisation")),
      body: Stack(
        children: [
          Center(
            child: Text(
              _address,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: Icon(Icons.location_on, color: Colors.red, size: 36),
          ),
        ],
      ),
    );
  }
}
