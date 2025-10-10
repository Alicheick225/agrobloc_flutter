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

class EditAnnonceForm extends StatefulWidget {
  final AnnonceVente annonceToEdit;

  const EditAnnonceForm({super.key, required this.annonceToEdit});

  @override
  State<EditAnnonceForm> createState() => _EditAnnonceFormState();
}

class _EditAnnonceFormState extends State<EditAnnonceForm> {
  final _formKey = GlobalKey<FormState>();

  String? _typeProduit; // 'rente' ou 'vivriere'
  File? _image;

  final ImagePicker _picker = ImagePicker();
  final TextEditingController _prixController = TextEditingController();
  final TextEditingController _quantiteController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  List<Culture> _cultures = [];
  List<Map<String, dynamic>> _parcelles = [];
  Culture? _selectedCulture;
  Map<String, dynamic>? _selectedParcelle;

  List<Map<String, dynamic>> _typesProduits = [];

  bool _isLoadingCultures = true;
  bool _isLoadingParcelles = true;

  @override
  void initState() {
    super.initState();
    _typesProduits = [
      {'id': 'rente', 'libelle': 'Culture de rente'},
      {'id': 'vivriere', 'libelle': 'Culture vivrière'},
    ];
    String normAnnonce = widget.annonceToEdit.cultureType.toLowerCase();
    _typeProduit = normAnnonce == 'vivrière' ? 'vivriere' : normAnnonce;
    _loadCultures();
    _loadParcelles();
    _populateForm();
  }

  void _populateForm() {
    final annonce = widget.annonceToEdit;
    _prixController.text = annonce.prixKg.toString();
    _quantiteController.text = annonce.quantite.toString();
    _descriptionController.text = annonce.description;
    // Note: _selectedCulture and _selectedParcelle will be set after loading
  }

  List<Culture> _getFilteredCultures() {
    if (_typeProduit != null) {
      return _cultures.where((c) {
        String normalizedType = (c.type ?? '').toLowerCase() == 'vivrière' ? 'vivriere' : (c.type ?? '').toLowerCase();
        return normalizedType == _typeProduit;
      }).toList();
    }
    return [];
  }

  Future<void> _loadCultures() async {
    try {
      final allCultures = await cultureService().getAllCulture();
      setState(() {
        _cultures = allCultures;
        _isLoadingCultures = false;
      });

      Culture? cultureToSelect;
      try {
        cultureToSelect = allCultures.firstWhere((c) => c.id == widget.annonceToEdit.cultureId);
      } catch (_) {
        cultureToSelect = null;
      }

      if (cultureToSelect != null) {
        String norm = (cultureToSelect.type ?? '').toLowerCase();
        String normalizedType = norm == 'vivrière' ? 'vivriere' : norm;
        if (normalizedType == _typeProduit) {
          setState(() {
            _selectedCulture = cultureToSelect;
          });
          _prixController.text = cultureToSelect.prixBordChamp.toStringAsFixed(0);
        } else {
          // If types don't match, use culture's type and select it
          setState(() {
            _typeProduit = normalizedType;
            _selectedCulture = cultureToSelect;
          });
          _prixController.text = cultureToSelect.prixBordChamp.toStringAsFixed(0);
        }
      } else {
        setState(() {
          _selectedCulture = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur chargement cultures : $e")),
        );
        setState(() => _isLoadingCultures = false);
      }
    }
  }

  Future<void> _loadParcelles() async {
    try {
      final parcelles = await ParcelleService().getAllParcelles();
      setState(() {
        _parcelles =
            parcelles.map((p) => {'id': p.id, 'adresse': p.adresse}).toList();
        _isLoadingParcelles = false;
      });

      // Set the selected parcelle
      _selectedParcelle = _parcelles.where((p) => p['id'] == widget.annonceToEdit.parcelleId).firstOrNull;
      setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur chargement parcelles : $e")),
        );
        setState(() => _isLoadingParcelles = false);
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
      // Update existing annonce
      await AnnonceService().updateAnnonce(
        id: widget.annonceToEdit.id,
        statut: widget.annonceToEdit.statut,
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

      Navigator.of(context).pop(); // Return to previous screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLoading = _isLoadingCultures || _isLoadingParcelles;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
        title: const Text("Modifier l'annonce"),
      ),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Chargement des données...'),
                ],
              ),
            )
          : Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sélecteur de type de culture
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                              'Type de culture',
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
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                hintText: 'Sélectionner un type',
                                hintStyle: TextStyle(color: Colors.grey[400]),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              value: _typeProduit,
                              menuMaxHeight: 200.0,
                              items: _typesProduits
                                  .map((type) => DropdownMenuItem<String>(
                                        value: type['id'],
                                        child: Text(type['libelle']),
                                      ))
                                  .toList(),
                              onChanged: (val) {
                                setState(() {
                                  _typeProduit = val;
                                  _selectedCulture = null; // Reset selection when type changes
                                });
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Formulaire dynamique
                      if (_typeProduit != null) ...[
                  // Nom de la culture
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                        const SizedBox(height: 6),
                        DropdownButtonFormField<Culture>(
                          decoration: InputDecoration(
                            hintText: 'Sélectionner une culture',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          value: _selectedCulture != null && _getFilteredCultures().any((c) => c.id == _selectedCulture!.id) ? _selectedCulture : null,
                          menuMaxHeight: 200.0,
                          items: _getFilteredCultures()
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

                  // Parcelle
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                        const SizedBox(height: 6),
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

                  // Quantité
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _quantiteController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(6),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) =>
                              v == null || v.isEmpty ? "Indiquez la quantité" : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Prix
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _prixController,
                          readOnly: true,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(6),
                          ),
                          validator: (_) =>
                              _prixController.text == '0' ? "Prix non disponible" : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Image
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                        const SizedBox(height: 6),
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
                                ? (widget.annonceToEdit.photo != null
                                    ? Image.network(widget.annonceToEdit.photo!, fit: BoxFit.cover)
                                    : const Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                                          SizedBox(height: 6),
                                          Text("Changer l'image",
                                              style: TextStyle(color: Colors.grey)),
                                        ],
                                      ))
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

                  // Description
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(6),
                          ),
                          maxLines: 2,
                          validator: (v) =>
                              v == null || v.isEmpty ? "Indiquez une description" : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Bouton
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
                      child: const Text(
                        "Modifier l'annonce",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
