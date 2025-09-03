import 'dart:io';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/annonceVenteService.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/tyoeCultureService.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/parcelleService.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/parcelleService.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/typecultureModel.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/AnnonceVenteModel.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AnnonceForm extends StatefulWidget {
  final AnnonceVente? annonce;

  const AnnonceForm({super.key, this.annonce});

  @override
  State<AnnonceForm> createState() => _AnnonceFormState();
}

class _AnnonceFormState extends State<AnnonceForm> {
  String? selectedCulture;
  String? selectedParcelle;
  double quantite = 10;
  double prixKg = 0;
  String statut = "Disponible";
  XFile? photo;
  String description = "";
  bool isSubmitting = false;
  bool isLoading = true;
  int loadedCount = 0;

  final picker = ImagePicker();
  final AnnonceService annonceService = AnnonceService();
  final TypeCultureService typeCultureService = TypeCultureService();
  final ParcelleService parcelleService = ParcelleService();

  List<TypeCulture> typeCultures = [];
  List<Parcelle> parcelles = [];

  @override
  void initState() {
    super.initState();
    isLoading = true;
    loadedCount = 0;

    // Si une annonce existe déjà, préremplir les champs
    if (widget.annonce != null) {
      selectedCulture = widget.annonce!.typeCultureLibelle;
      selectedParcelle = widget.annonce!.parcelleAdresse;
      quantite = widget.annonce!.quantite;
      prixKg = widget.annonce!.prixKg;
      statut = widget.annonce!.statut;
      description = widget.annonce!.description;
      // La photo n'est pas rechargée directement car il faut la récupérer depuis un fichier
    }

    _chargerCultures();
    _chargerParcelles();
  }

  Future<void> _chargerCultures() async {
    try {
      typeCultures = await typeCultureService.getAllTypes();
      if (selectedCulture != null) {
        // Find the culture that matches ignoring case
        final matchingCulture = typeCultures.firstWhere(
          (c) => c.libelle.toLowerCase() == selectedCulture!.toLowerCase(),
          orElse: () => TypeCulture(id: '-1', libelle: '', prixBordChamp: 0.0),
        );
        if (matchingCulture.id != '-1') {
          selectedCulture = matchingCulture.libelle;
        } else {
          selectedCulture = null;
        }
      }
      loadedCount++;
      if (loadedCount == 2) {
        setState(() => isLoading = false);
      } else {
        setState(() {});
      }
    } catch (e) {
      _afficherMessage("Erreur lors du chargement des cultures : $e");
      loadedCount++;
      if (loadedCount == 2) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _chargerParcelles() async {
    try {
      parcelles = await parcelleService.getAllParcelles();
      if (selectedParcelle != null) {
        // Find the parcelle that matches the adresse
        final matchingParcelle = parcelles.firstWhere(
          (p) => p.adresse == selectedParcelle,
          orElse: () => Parcelle(
            id: '-1',
            libelle: '',
            geolocalisation: '',
            surface: 0.0,
            adresse: '',
            userId: '',
            userNom: '',
          ),
        );
        if (matchingParcelle.id != '-1') {
          selectedParcelle = matchingParcelle.libelle;
        } else {
          selectedParcelle = null;
        }
      }
      loadedCount++;
      if (loadedCount == 2) {
        setState(() => isLoading = false);
      } else {
        setState(() {});
      }
    } catch (e) {
      _afficherMessage("Erreur lors du chargement des parcelles : $e");
      loadedCount++;
      if (loadedCount == 2) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _selectionnerImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => photo = picked);
    }
  }

  void _afficherMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Faire une offre de vente"),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
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
            _buildDropdown(
              label: "Choix de la culture",
              value: selectedCulture,
              items: typeCultures.map((c) => c.libelle).toList(),
              onChanged: (val) => setState(() => selectedCulture = val),
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              label: "Choix de la parcelle",
              value: selectedParcelle,
              items: parcelles.map((p) => p.libelle).toList(),
              onChanged: (val) => setState(() => selectedParcelle = val),
            ),
            const SizedBox(height: 16),
            _buildQuantite(),
            const SizedBox(height: 16),
            _buildPrixKg(),
            const SizedBox(height: 16),
            _buildUploadImage(),
            const SizedBox(height: 16),
            _buildDescription(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: isSubmitting ? null : _soumettreAnnonce,
                child: isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Soumettre l'annonce", style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTitreSection(String titre) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        titre,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    // Remove duplicates from items
    List<String> uniqueItems = items.toSet().toList();

    // Ensure the value is valid; if not, set to null
    String? adjustedValue = value;
    if (adjustedValue != null && !uniqueItems.contains(adjustedValue)) {
      adjustedValue = null;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitreSection(label),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButton<String>(
            value: adjustedValue,
            hint: const Text("Sélectionner", style: TextStyle(color: Colors.grey)),
            isExpanded: true,
            underline: const SizedBox(),
            onChanged: onChanged,
            items: uniqueItems
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildQuantite() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitreSection("Quantité"),
        TextField(
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: "0",
          ),
          onChanged: (val) => quantite = double.tryParse(val) ?? 0,
        ),
      ],
    );
  }

  Widget _buildPrixKg() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitreSection("Prix par Kg"),
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

  Widget _buildUploadImage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitreSection("Image"),
        GestureDetector(
          onTap: _selectionnerImage,
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

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitreSection("Description"),
        TextField(
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: "Décrivez votre produit en quelques mots",
            border: OutlineInputBorder(),
          ),
          onChanged: (val) => description = val,
        ),
      ],
    );
  }

  Future<void> _soumettreAnnonce() async {
    if (selectedCulture == null || selectedParcelle == null || description.isEmpty) {
      _afficherMessage("Veuillez remplir tous les champs");
      return;
    }

    setState(() => isSubmitting = true);

    try {
      final cultureChoisie = typeCultures.firstWhere((c) => c.libelle == selectedCulture);
      final parcelleChoisie = parcelles.firstWhere((p) => p.libelle == selectedParcelle);

      await annonceService.createAnnonce(
        typeCultureId: cultureChoisie.id,
        parcelleId: parcelleChoisie.id,
        statut: statut,
        description: description,
        quantite: quantite,
        prixKg: prixKg,
        photo: photo,
        userId: '', // À remplacer par l'ID utilisateur réel
      );

      _afficherMessage("Annonce créée avec succès");

      setState(() {
        selectedCulture = null;
        selectedParcelle = null;
        quantite = 10;
        prixKg = 0;
        statut = "Disponible";
        photo = null;
        description = "";
      });
    } catch (e) {
      _afficherMessage("Erreur : $e");
    } finally {
      setState(() => isSubmitting = false);
    }
  }
}
