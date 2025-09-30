import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:agrobloc/core/themes/app_colors.dart';

class CultureVivriereForm extends StatefulWidget {
  const CultureVivriereForm({super.key});

  @override
  State<CultureVivriereForm> createState() => _CultureVivriereFormState();
}

class _CultureVivriereFormState extends State<CultureVivriereForm> {
  final _formKey = GlobalKey<FormState>();

  String? _nomCulture;
  double? _prix;
  int? _quantite;
  String? _description;
  File? _image;

  final ImagePicker _picker = ImagePicker();

  // Simule liste depuis ta BD (tu remplacera par ton service)
  final List<String> _culturesDispos = [
    "Manioc",
    "Igname",
    "Patate",
    "Maïs",
    "Haricot",
    "Tomate",
    "Poivron"
  ];

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

    // TODO : brancher ton AnnonceService ici

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Annonce Culture vivrière envoyée ✅")),
    );

    _formKey.currentState!.reset();
    setState(() => _image = null);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nom culture (autocompletion)
          Autocomplete<String>(
            optionsBuilder: (TextEditingValue val) {
              if (val.text.isEmpty) return const Iterable<String>.empty();
              return _culturesDispos.where(
                  (c) => c.toLowerCase().contains(val.text.toLowerCase()));
            },
            onSelected: (val) => _nomCulture = val,
            fieldViewBuilder:
                (context, controller, focusNode, onFieldSubmitted) {
              return TextFormField(
                controller: controller,
                focusNode: focusNode,
                decoration: InputDecoration(
                  labelText: "Nom de la culture",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
                onChanged: (val) => _nomCulture = val,
                validator: (v) =>
                    v == null || v.isEmpty ? "Indiquez le nom" : null,
              );
            },
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
            onChanged: (val) => _prix = double.tryParse(val),
            validator: (v) =>
                v == null || v.isEmpty ? "Indiquez le prix" : null,
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
