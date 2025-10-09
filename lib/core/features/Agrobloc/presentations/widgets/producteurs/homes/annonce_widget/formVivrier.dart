import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:image_picker/image_picker.dart';
import 'package:agrobloc/core/themes/app_colors.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/cultureModel.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/cultureService.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/annonceVenteService.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/userService.dart';

// ---------- EXTENSION ----------
extension FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

class CultureVivriereForm extends StatefulWidget {
  const CultureVivriereForm({super.key});

  @override
  State<CultureVivriereForm> createState() => _CultureVivriereFormState();
}

class _CultureVivriereFormState extends State<CultureVivriereForm> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _prixController = TextEditingController();
  final TextEditingController _quantiteController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  List<Culture> _cultures = [];
  Culture? _selectedCulture;
  File? _image;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCultures());
  }

  Future<void> _loadCultures() async {
    try {
      final all = await cultureService().getAllCulture();
      final vivrieres =
          all.where((c) => c?.type?.toLowerCase() == 'vivrière').toList();
      setState(() => _cultures = vivrieres);
      print(
          '🌾 cultures vivrières chargées : ${vivrieres.map((e) => e.libelle).toList()}');
    } catch (e) {
      _showError("Erreur lors du chargement des cultures : $e");
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _image = File(picked.path));
  }

  double? _parseDouble(String? s) {
    final val = double.tryParse(s ?? '');
    return (val == null || val <= 0) ? null : val;
  }

  // ---------- VALIDATION CROISÉE ----------
  Culture? _findCulture(String libelle) {
    final normalised = libelle.trim().toLowerCase();
    return _cultures
        .where((c) => c.libelle.toLowerCase() == normalised)
        .firstOrNull;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final culture = _findCulture(_selectedCulture?.libelle ?? '');
    if (culture == null) {
      _showError("Le nom saisi ne correspond à aucune culture existante.");
      return;
    }
    _selectedCulture = culture;

    if (_image == null) {
      _showError("Veuillez ajouter une image.");
      return;
    }

    final quantite = _parseDouble(_quantiteController.text);
    final prix = _parseDouble(_prixController.text);
    if (quantite == null || prix == null) {
      _showError("Quantité et prix doivent être > 0.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = await UserService().userId;
      if (userId == null || userId.isEmpty)
        throw Exception("Utilisateur non identifié.");

      await AnnonceService().createAnnonce(
        userId: userId,
        cultureId: _selectedCulture!.id,
        parcelleId: '',
        statut: "Disponible",
        description: _descriptionController.text.trim(),
        quantite: quantite,
        quantiteUnite: "kg",
        prixKg: prix,
        photo: XFile(_image!.path),
        type: "vivriere",
        prixBordChamp: null,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Annonce vivrière créée ✅')),
      );

      _resetForm();
    } catch (e) {
      _showError("Erreur : $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _prixController.clear();
    _quantiteController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedCulture = null;
      _image = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🌾 Sélection de la culture vivrière
          DropdownSearch<Culture>(
            items: (filter, loadProps) async => _cultures, // liste déjà filtrée
            itemAsString: (c) => c.libelle,
            selectedItem: _selectedCulture,
            compareFn: (a, b) => a.id == b.id,
            onChanged: (v) => setState(() => _selectedCulture = v),
            validator: (v) =>
                v == null ? "Choisissez une culture vivrière" : null,
            decoratorProps: const DropDownDecoratorProps(
              decoration: InputDecoration(
                labelText: "Sélectionnez une culture vivrière",
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
            ),
            popupProps: const PopupProps.menu(
              showSearchBox: true,
              searchFieldProps: TextFieldProps(
                decoration: InputDecoration(hintText: "Rechercher..."),
              ),
            ),
          ),
          const SizedBox(height: 16),

          /// 💰 Prix manuel
          TextFormField(
            controller: _prixController,
            decoration: InputDecoration(
              labelText: "Prix (FCFA/kg)",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
            keyboardType: TextInputType.number,
            validator: (v) =>
                v == null || v.isEmpty ? "Indiquez le prix" : null,
          ),
          const SizedBox(height: 16),

          /// ⚖️ Quantité
          TextFormField(
            controller: _quantiteController,
            decoration: InputDecoration(
              labelText: "Quantité (kg)",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
            keyboardType: TextInputType.number,
            validator: (v) =>
                v == null || v.isEmpty ? "Indiquez la quantité" : null,
          ),
          const SizedBox(height: 16),

          /// 🖼️ Image
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(6),
              ),
              child: _image == null
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                        SizedBox(height: 8),
                        Text("Ajouter une image",
                            style: TextStyle(color: Colors.grey)),
                      ],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.file(_image!, fit: BoxFit.cover),
                    ),
            ),
          ),
          const SizedBox(height: 16),

          /// 📝 Description
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: "Description",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
            maxLines: 3,
            validator: (v) =>
                v == null || v.isEmpty ? "Indiquez une description" : null,
          ),
          const SizedBox(height: 20),

          /// 🚀 Bouton de publication
          Center(
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6)),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text(
                      "Publier l’annonce",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
