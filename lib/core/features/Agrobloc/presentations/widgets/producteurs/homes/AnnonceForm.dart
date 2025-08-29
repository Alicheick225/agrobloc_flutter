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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors du chargement des cultures: $e")),
      );
    }
  }

  Future<void> _fetchParcelles() async {
    try {
      parcellesList = await parcelleService.getAllParcelles();
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors du chargement des parcelles: $e")),
      );
    }
  }

  Future<void> _pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        photo = picked;
      });
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
            _buildDropdownStyled(
              label: "Choix de la culture",
              value: selectedCulture,
              items: typeCultures.map((c) => c.libelle).toList(),
              onChanged: (val) => setState(() => selectedCulture = val),
            ),
            const SizedBox(height: 16),
            _buildDropdownStyled(
              label: "Choix de la parcelle",
              value: selectedParcelle,
              items: parcellesList.map((p) => p.libelle).toList(),
              onChanged: (val) => setState(() => selectedParcelle = val),
            ),
            const SizedBox(height: 16),
            _buildQuantityStyled(),
            const SizedBox(height: 16),
            _buildPrixKgStyled(),         
            const SizedBox(height: 16),
            _buildImageUpload(),
            const SizedBox(height: 16),
            _buildDescriptionStyled(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: isSubmitting ? null : _submitAnnonce,
                child: isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Faire une offre de vente",
                        style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildDropdownStyled({
    required String label,
    String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(label),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButton<String>(
            value: value,
            hint: const Text("Sélectionner", style: TextStyle(color: Colors.grey)),
            isExpanded: true,
            underline: const SizedBox(),
            onChanged: onChanged,
            items: items
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityStyled() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Quantité"),
        TextField(
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: "0",
          ),
          onChanged: (val) => quantity = double.tryParse(val) ?? 0,
        ),
      ],
    );
  }

  Widget _buildPrixKgStyled() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Prix par Kg"),
        TextField(
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: "0",
          ),
          onChanged: (val) => prixKg = double.tryParse(val) ?? 0,
        ),
      ],
    );
  }

  

  Widget _buildImageUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Image"),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: photo == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.add_a_photo, color: Colors.green),
                        SizedBox(height: 4),
                        Text("Ajouter une image"),
                      ],
                    )
                  : Image.file(File(photo!.path), fit: BoxFit.cover),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionStyled() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Description"),
        TextField(
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: "Decrivez votre produit en quelques mots",
            border: OutlineInputBorder(),
          ),
          onChanged: (val) => description = val,
        ),
      ],
    );
  }

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
      final selectedParcelleObj = parcellesList.firstWhere((p) => p.libelle == selectedParcelle);

      await service.createAnnonce(
        typeCultureId: selectedTypeCulture.id,
        parcelleId: selectedParcelleObj.id,
        statut: availability,
        description: description,
        quantite: quantity,
        prixKg: prixKg,
        photo: photo,
        userId: '',
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
