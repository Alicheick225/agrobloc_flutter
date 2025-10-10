import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:image_picker/image_picker.dart';
import 'package:agrobloc/core/themes/app_colors.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/cultureModel.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/cultureService.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/annonceVenteService.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/userService.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/AnnonceVenteModel.dart';

// ---------- EXTENSION ----------
extension FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

class CultureVivriereForm extends StatefulWidget {
  final AnnonceVente? annonceToEdit;

  const CultureVivriereForm({super.key, this.annonceToEdit});

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
    if (widget.annonceToEdit != null) {
      _populateForm();
    }
  }

  void _populateForm() {
    final annonce = widget.annonceToEdit!;
    _prixController.text = annonce.prixKg.toString();
    _quantiteController.text = annonce.quantite.toString();
    _descriptionController.text = annonce.description;
    // Note: _selectedCulture will be set after cultures are loaded
    // _image cannot be populated from URL easily, user will need to re-upload if editing
  }

  Future<void> _loadCultures() async {
    try {
      final all = await cultureService().getAllCulture();
      final vivrieres =
          all.where((c) => c?.type?.toLowerCase() == 'vivrière').toList();
      setState(() => _cultures = vivrieres);

      // If editing, set the selected culture
      if (widget.annonceToEdit != null) {
        final annonce = widget.annonceToEdit!;
        _selectedCulture = vivrieres.where((c) => c.id == annonce.cultureId).firstOrNull;
        setState(() {});
      }

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

    if (widget.annonceToEdit == null && _image == null) {
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
      if (widget.annonceToEdit != null) {
        // Update existing annonce
        await AnnonceService().updateAnnonce(
          id: widget.annonceToEdit!.id,
          statut: widget.annonceToEdit!.statut,
          description: _descriptionController.text.trim(),
          cultureId: _selectedCulture!.id,
          parcelleId: widget.annonceToEdit!.parcelleAdresse, // Assuming parcelleId is stored here
          quantite: quantite,
          quantiteUnite: "kg",
          prixKg: prix,
          photo: _image != null ? XFile(_image!.path) : null,
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Annonce vivrière modifiée ✅')),
        );
      } else {
        // Create new annonce
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
      }
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sélectionnez une culture vivrière',
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  height: 2,
                  width: 40,
                  color: AppColors.primaryGreen,
                ),
                const SizedBox(height: 8),
                DropdownSearch<Culture>(
                  items: (filter, loadProps) async => _cultures,
                  itemAsString: (c) => c.libelle,
                  selectedItem: _selectedCulture,
                  compareFn: (a, b) => a.id == b.id,
                  onChanged: (v) => setState(() => _selectedCulture = v),
                  validator: (v) =>
                      v == null ? "Choisissez une culture vivrière" : null,
                  decoratorProps: const DropDownDecoratorProps(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  popupProps: PopupProps.menu(
                    showSearchBox: true,
                    constraints: BoxConstraints(maxHeight: 200),
                    searchFieldProps: TextFieldProps(
                      decoration: InputDecoration(hintText: "Rechercher..."),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          /// 💰 Prix manuel
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Prix (FCFA/kg)',
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  height: 2,
                  width: 40,
                  color: AppColors.primaryGreen,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _prixController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(8),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                      v == null || v.isEmpty ? "Indiquez le prix" : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          /// ⚖️ Quantité
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quantité (kg)',
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  height: 2,
                  width: 40,
                  color: AppColors.primaryGreen,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _quantiteController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(8),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                      v == null || v.isEmpty ? "Indiquez la quantité" : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          /// 🖼️ Image
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Image',
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  height: 2,
                  width: 40,
                  color: AppColors.primaryGreen,
                ),
                const SizedBox(height: 8),
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
              ],
            ),
          ),
          const SizedBox(height: 12),

          /// 📝 Description
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Description',
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  height: 2,
                  width: 40,
                  color: AppColors.primaryGreen,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(8),
                  ),
                  maxLines: 2,
                  validator: (v) =>
                      v == null || v.isEmpty ? "Indiquez une description" : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          /// 🚀 Bouton de publication
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _isLoading ? null : _submit,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.primaryGreen),
                foregroundColor: AppColors.primaryGreen,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: AppColors.primaryGreen, strokeWidth: 2))
                  : Text(
                      widget.annonceToEdit != null ? "Modifier l'annonce" : "Publier l'annonce",
                      style: const TextStyle(fontSize: 16),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
