import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapSelectionPage extends StatefulWidget {
  final LatLng initialPosition;
  const MapSelectionPage({super.key, required this.initialPosition});

  @override
  State<MapSelectionPage> createState() => _MapSelectionPageState();
}

class _MapSelectionPageState extends State<MapSelectionPage> {
  late GoogleMapController _mapController;
  LatLng? selectedPosition;

  @override
  void initState() {
    super.initState();
    selectedPosition = widget.initialPosition;
  }

  void _onMapTap(LatLng position) {
    setState(() => selectedPosition = position);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sélectionner localisation"),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              if (selectedPosition != null) Navigator.pop(context, selectedPosition);
            },
          )
        ],
        backgroundColor: Colors.green,
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: widget.initialPosition,
          zoom: 16,
        ),
        onMapCreated: (controller) => _mapController = controller,
        markers: selectedPosition != null
            ? {
                Marker(markerId: const MarkerId('selected'), position: selectedPosition!)
              }
            : {},
        onTap: _onMapTap,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}
