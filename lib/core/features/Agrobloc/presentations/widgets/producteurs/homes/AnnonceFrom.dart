import 'dart:io';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/annonceVenteService.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/tyoeCultureService.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/parcelleService.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/parcelleService.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/typecultureModel.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AnnonceForm extends StatefulWidget {
  const AnnonceForm({super.key});

  @override
  State<AnnonceForm> createState() => _AnnonceFormState();
}

class _AnnonceFormState extends State<AnnonceForm> {
  String? selectedCulture;
  String? selectedParcelle;
  double quantity = 10;
  double prixKg = 0;
  String availability = "Disponible";
  XFile? photo;
  String description = "";
  bool isSubmitting = false;

  final picker = ImagePicker();
  final AnnonceService service = AnnonceService();
  final TypeCultureService typeCultureService = TypeCultureService();
  final ParcelleService parcelleService = ParcelleService();

  List<TypeCulture> typeCultures = [];
  List<Parcelle> parcellesList = [];

  @override
  void initState() {
    super.initState();
    _fetchCultures();
    _fetchParcelles();
  }

  Future<void> _fetchCultures() async {
    try {
      typeCultures = await typeCultureService.getAllTypes();
      setState(() {});
      print("Cultures récupérées: $typeCultures");
    } catch (e, stackTrace) {
      print("Erreur _fetchCultures: $e");
      print(stackTrace);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors du chargement des cultures: $e")),
      );
    }
  }

  Future<void> _fetchParcelles() async {
    try {
      parcellesList = await parcelleService.getAllParcelles();
      setState(() {});
      print("Parcelles récupérées: $parcellesList");
    } catch (e, stackTrace) {
      print("Erreur _fetchParcelles: $e");
      print(stackTrace);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors du chargement des parcelles: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Faire une offre de vente"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildDropdownField(
              label: "Choix de la culture",
              hint: "Sélectionner une culture",
              value: selectedCulture,
              items: typeCultures.map((c) => c.libelle).toList(),
              onChanged: (val) => setState(() => selectedCulture = val),
            ),
            const SizedBox(height: 16),
            _buildDropdownField(
              label: "Choix de la parcelle",
              hint: "Sélectionner une parcelle",
              value: selectedParcelle,
              items: parcellesList.map((p) => p.libelle).toList(),
              onChanged: (val) => setState(() => selectedParcelle = val),
            ),
            const SizedBox(height: 16),
            _buildQuantityField(),
            const SizedBox(height: 16),
            _buildPrixKgField(),
            const SizedBox(height: 16),
            _buildAvailabilityField(),
            const SizedBox(height: 16),
            _buildImagePicker(),
            const SizedBox(height: 16),
            _buildDescriptionField(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : _submitAnnonce,
                child: isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Faire une offre de vente"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String hint,
    String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButton<String>(
            value: value,
            hint: Text(hint, style: const TextStyle(color: Colors.grey)),
            isExpanded: true,
            underline: const SizedBox(),
            onChanged: onChanged,
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityField() => TextField(
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: "Quantité",
          border: OutlineInputBorder(),
        ),
        onChanged: (val) => quantity = double.tryParse(val) ?? 10,
      );

  Widget _buildPrixKgField() => TextField(
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: "Prix par Kg",
          border: OutlineInputBorder(),
        ),
        onChanged: (val) => prixKg = double.tryParse(val) ?? 0,
      );

  Widget _buildAvailabilityField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Disponibilité culture", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                title: const Text("Disponible"),
                value: "Disponible",
                groupValue: availability,
                onChanged: (val) => setState(() => availability = val!),
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                title: const Text("Prévisionnel"),
                value: "Prévisionnel",
                groupValue: availability,
                onChanged: (val) => setState(() => availability = val!),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImagePicker() => GestureDetector(
        onTap: _pickImage,
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: photo == null
                ? const Icon(Icons.add, color: Colors.green)
                : Image.file(File(photo!.path), fit: BoxFit.cover),
          ),
        ),
      );

  Future<void> _pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => photo = picked);
  }

  Widget _buildDescriptionField() => TextField(
        maxLines: 3,
        decoration: const InputDecoration(
          labelText: "Description",
          border: OutlineInputBorder(),
        ),
        onChanged: (val) => description = val,
      );

  Future<void> _submitAnnonce() async {
    if (selectedCulture == null || selectedParcelle == null || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs")),
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      final selectedTypeCulture = typeCultures.firstWhere((c) => c.libelle == selectedCulture);
      final typeCultureId = selectedTypeCulture.id;

      print("TypeCulture sélectionné: $selectedCulture, id: $typeCultureId");

      final selectedParcelleObj = parcellesList.firstWhere((p) => p.libelle == selectedParcelle);
      final parcelleId = selectedParcelleObj.id;

      final annonce = await service.createAnnonce(
        typeCultureId: typeCultureId,
        parcelleId: parcelleId,
        statut: availability,
        description: description,
        quantite: quantity,
        prixKg: prixKg,
        photo: photo, userId: '',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Annonce créée avec succès")),
      );

      setState(() {
        selectedCulture = null;
        selectedParcelle = null;
        quantity = 10;
        prixKg = 0;
        availability = "Disponible";
        photo = null;
        description = "";
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur: $e")),
      );
    } finally {
      setState(() => isSubmitting = false);
    }
  }
}
