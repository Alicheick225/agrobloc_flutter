import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:agrobloc/core/themes/app_colors.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/typecultureModel.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/typeCultureService.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/annonceVenteService.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/parcelleService.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/userService.dart';

class CultureRenteForm extends StatefulWidget {
  const CultureRenteForm({super.key});

  @override
  State<CultureRenteForm> createState() => _CultureRenteFormState();
}

class _CultureRenteFormState extends State<CultureRenteForm> {
  final _formKey = GlobalKey<FormState>();

  String? _nomCulture;
  String? _description;
  File? _image;
  int? _quantite;

  final ImagePicker _picker = ImagePicker();
  final TextEditingController _prixController = TextEditingController();

  List<TypeCulture> _cultures = [];
  List<Map<String, dynamic>> _parcelles = [];
  TypeCulture? _selectedCulture;
  Map<String, dynamic>? _selectedParcelle;

  @override
  void initState() {
    super.initState();
    _loadCultures();
    _loadParcelles();
  }

  Future<void> _loadCultures() async {
    try {
      final allCultures = await TypeCultureService().getAllTypes();
      final cultures =
          allCultures.where((c) => c.type?.toLowerCase() == 'rente').toList();
      setState(() => _cultures = cultures);
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
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _image = File(picked.path));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez ajouter une image")),
      );
      return;
    }
    if (_selectedCulture == null || _selectedParcelle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Culture et parcelle requises")),
      );
      return;
    }

    try {
      final userId = await UserService().userId ?? '';
      final photoFile = _image != null ? XFile(_image!.path) : null;

      await AnnonceService().createAnnonce(
        userId: userId,
        typeCultureId: _selectedCulture!.id,
        parcelleId: _selectedParcelle!['id'],
        statut: "Disponible",
        description: _description ?? '',
        quantite: (_quantite ?? 0).toDouble(),
        prixKg: double.parse(_prixController.text),
        photo: photoFile,
        type: "rente",
        prixBordChamp: _selectedCulture!.prixBordChamp,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Annonce créée ✅")),
      );

      _formKey.currentState!.reset();
      _prixController.clear();
      setState(() {
        _image = null;
        _selectedCulture = null;
        _selectedParcelle = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : $e")),
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
          DropdownButtonFormField<TypeCulture>(
            decoration: InputDecoration(
              labelText: "Nom de la culture",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
            value: _selectedCulture,
            items: _cultures
                .map((c) => DropdownMenuItem<TypeCulture>(
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
          const SizedBox(height: 16),
          DropdownButtonFormField<Map<String, dynamic>>(
            decoration: InputDecoration(
              labelText: "Parcelle",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
          const SizedBox(height: 16),
          TextFormField(
            decoration: InputDecoration(
              labelText: "Quantité (kg)",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
            keyboardType: TextInputType.number,
            onChanged: (val) => _quantite = int.tryParse(val),
            validator: (v) =>
                v == null || v.isEmpty ? "Indiquez la quantité" : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _prixController,
            readOnly: true,
            decoration: InputDecoration(
              labelText: "Prix (FCFA/kg)",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
            validator: (_) =>
                _prixController.text == '0' ? "Prix non disponible" : null,
          ),
          const SizedBox(height: 16),
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
          TextFormField(
            decoration: InputDecoration(
              labelText: "Description",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
            maxLines: 3,
            onChanged: (val) => _description = val,
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6)),
              ),
              child: const Text(
                "Publier l’annonce",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
