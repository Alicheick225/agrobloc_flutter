import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:agrobloc/core/themes/app_colors.dart';

class CultureRenteForm extends StatefulWidget {
  const CultureRenteForm({super.key});

  @override
  State<CultureRenteForm> createState() => _CultureRenteFormState();
}

class _CultureRenteFormState extends State<CultureRenteForm> {
  final _formKey = GlobalKey<FormState>();

  String? _nomCulture;
  String? _parcelle;
  int? _quantite;
  double? _prix;
  String? _description;
  File? _image;

  final ImagePicker _picker = ImagePicker();

  // Simule chargement depuis ta BD
  final List<String> _cultures = [
    "Café",
    "Cacao",
    "Palmier à huile",
    "Banane plantain"
  ];
  final Map<String, double> _prixCultures = {
    "Café": 2000,
    "Cacao": 3000,
    "Palmier à huile": 1500,
    "Banane plantain": 500,
  };

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _image = File(picked.path));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez ajouter une image")),
      );
      return;
    }

    // TODO : remplace par ton appel backend
    // Ex. await annonceService.createAnnonce(...)

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Annonce Culture de rente envoyée ✅")),
    );

    // Reset
    _formKey.currentState!.reset();
    setState(() {
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
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: "Nom de la culture",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
            items: _cultures
                .map((nom) => DropdownMenuItem(value: nom, child: Text(nom)))
                .toList(),
            onChanged: (val) {
              setState(() {
                _nomCulture = val;
                _prix = _prixCultures[val];
              });
            },
            validator: (v) => v == null ? "Choisissez une culture" : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: InputDecoration(
              labelText: "Parcelle",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
            onChanged: (val) => _parcelle = val,
            validator: (v) =>
                v == null || v.isEmpty ? "Indiquez la parcelle" : null,
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
            decoration: InputDecoration(
              labelText: "Prix (FCFA/kg)",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
            keyboardType: TextInputType.number,
            initialValue: _prix?.toString(),
            onChanged: (val) => _prix = double.tryParse(val),
            validator: (v) =>
                v == null || v.isEmpty ? "Indiquez le prix" : null,
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
