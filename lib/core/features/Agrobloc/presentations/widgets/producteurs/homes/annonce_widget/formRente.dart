import 'dart:io';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/cultureService.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:agrobloc/core/themes/app_colors.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/cultureModel.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/cultureService.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/annonceVenteService.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/parcelleService.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/userService.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/AnnonceVenteModel.dart';

class CultureRenteForm extends StatefulWidget {
  final AnnonceVente? annonceToEdit;

  const CultureRenteForm({super.key, this.annonceToEdit});

  @override
  State<CultureRenteForm> createState() => _CultureRenteFormState();
}

class _CultureRenteFormState extends State<CultureRenteForm> {
  final _formKey = GlobalKey<FormState>();

  String? _nomCulture;
  File? _image;

  final ImagePicker _picker = ImagePicker();
  final TextEditingController _prixController = TextEditingController();
  final TextEditingController _quantiteController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  List<Culture> _cultures = [];
  List<Map<String, dynamic>> _parcelles = [];
  Culture? _selectedCulture;
  Map<String, dynamic>? _selectedParcelle;

  @override
  void initState() {
    super.initState();
    _loadCultures();
    _loadParcelles();
    if (widget.annonceToEdit != null) {
      _populateForm();
    }
  }

  void _populateForm() {
    final annonce = widget.annonceToEdit!;
    _prixController.text = annonce.prixKg.toString();
    _quantiteController.text = annonce.quantite.toString();
    _descriptionController.text = annonce.description;
    // Note: _selectedCulture and _selectedParcelle will be set after loading
  }

  Future<void> _loadCultures() async {
    try {
      final allCultures = await cultureService().getAllCulture();
      final cultures =
          allCultures.where((c) => c.type?.toLowerCase() == 'rente').toList();
      setState(() => _cultures = cultures);

      // If editing, set the selected culture
      if (widget.annonceToEdit != null) {
        final annonce = widget.annonceToEdit!;
        _selectedCulture = cultures.where((c) => c.id == annonce.cultureId).firstOrNull;
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur chargement cultures : $e")),
        );
      }
    }
  }

  Future<void> _loadParcelles() async {
    try {
      final parcelles = await ParcelleService().getAllParcelles();
      setState(() {
        _parcelles =
            parcelles.map((p) => {'id': p.id, 'adresse': p.adresse}).toList();
      });

      // If editing, set the selected parcelle
      if (widget.annonceToEdit != null) {
        final annonce = widget.annonceToEdit!;
        _selectedParcelle = _parcelles.where((p) => p['adresse'] == annonce.parcelleAdresse).firstOrNull;
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur chargement parcelles : $e")),
        );
      }
    }
  }

  @override
  void dispose() {
    _prixController.dispose();
    _quantiteController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _image = File(picked.path));
  }

  Future<void> _submit() async {
    // 1. validations classiques
    if (!_formKey.currentState!.validate()) return;
    if (widget.annonceToEdit == null && _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez ajouter une image')),
      );
      return;
    }
    if (_selectedCulture == null || _selectedParcelle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Culture et parcelle requises')),
      );
      return;
    }

    final cultureId = _selectedCulture!.id;
    final parcelleId = _selectedParcelle!['id'].toString();

    if (cultureId.length != 36 || parcelleId.length != 36) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID invalide (UUID 36 caractères)')),
      );
      return;
    }

    try {
      if (widget.annonceToEdit != null) {
        // Update existing annonce
        await AnnonceService().updateAnnonce(
          id: widget.annonceToEdit!.id,
          statut: widget.annonceToEdit!.statut,
          description: _descriptionController.text.trim(),
          cultureId: cultureId,
          parcelleId: parcelleId,
          quantite: double.tryParse(_quantiteController.text) ?? 0,
          quantiteUnite: "kg",
          prixKg: double.parse(_prixController.text),
          photo: _image != null ? XFile(_image!.path) : null,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Annonce modifiée ✅')),
        );
      } else {
        // Create new annonce
        final userId = await UserService().userId ?? '';
        if (userId.length != 36) throw Exception('userId invalide');

        // upload image → URL
        final photoFile = _image != null ? XFile(_image!.path) : null;

        // appel service MULTIPART
        await AnnonceService().createAnnonce(
          userId: userId,
          cultureId: cultureId,
          parcelleId: parcelleId,
          statut: "Disponible",
          description: _descriptionController.text.trim(),
          quantite: double.tryParse(_quantiteController.text) ?? 0,
          quantiteUnite: "kg",
          prixKg: double.parse(_prixController.text),
          photo: photoFile,
          type: "de rente",
          prixBordChamp: _selectedCulture!.prixBordChamp,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Annonce créée ✅')),
        );

        // reset
        _formKey.currentState!.reset();
        _prixController.clear();
        _quantiteController.clear();
        _descriptionController.clear();
        setState(() {
          _image = null;
          _selectedCulture = null;
          _selectedParcelle = null;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  'Nom de la culture',
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
                DropdownButtonFormField<Culture>(
                  decoration: InputDecoration(
                    hintText: 'Sélectionner une culture',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  value: _selectedCulture,
                  menuMaxHeight: 200.0,
                  items: _cultures
                      .map((c) => DropdownMenuItem<Culture>(
                            value: c,
                            child: Text(c.libelle),
                          ))
                      .toList(),
                  onChanged: (culture) {
                    if (culture == null) return;
                    setState(() {
                      _selectedCulture = culture;
                      _prixController.text = culture.prixBordChamp.toStringAsFixed(0);
                    });
                  },
                  validator: (c) => c == null ? "Choisissez une culture" : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
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
                  'Parcelle',
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
                DropdownButtonFormField<Map<String, dynamic>>(
                  decoration: InputDecoration(
                    hintText: 'Sélectionner une parcelle',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  value: _selectedParcelle,
                  items: _parcelles
                      .map((p) => DropdownMenuItem<Map<String, dynamic>>(
                            value: p,
                            child: Text(p['adresse']),
                          ))
                      .toList(),
                  onChanged: (p) => setState(() => _selectedParcelle = p),
                  validator: (p) => p == null ? "Choisissez une parcelle" : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // CHAMP QUANTITÉ
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
                  readOnly: true,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(8),
                  ),
                  validator: (_) =>
                      _prixController.text == '0' ? "Prix non disponible" : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
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
          // CHAMP DESCRIPTION
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
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _submit,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.primaryGreen),
                foregroundColor: AppColors.primaryGreen,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
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
