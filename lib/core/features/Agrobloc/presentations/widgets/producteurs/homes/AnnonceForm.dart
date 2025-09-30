import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/producteurs/homes/annonce_widget/formRente.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/producteurs/homes/annonce_widget/formVivrier.dart';
import 'package:flutter/material.dart';

class DynamicAnnonceForm extends StatefulWidget {
  const DynamicAnnonceForm({super.key});

  @override
  _DynamicAnnonceFormState createState() => _DynamicAnnonceFormState();
}

class _DynamicAnnonceFormState extends State<DynamicAnnonceForm> {
  String? _typeProduit; // "rente" ou "vivriere"
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nouvelle annonce"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Sélectionnez le type de culture",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              RadioListTile<String>(
                title: const Text("Culture de rente"),
                value: "rente",
                groupValue: _typeProduit,
                onChanged: (value) {
                  setState(() {
                    _typeProduit = value;
                  });
                },
              ),
              RadioListTile<String>(
                title: const Text("Culture vivrière"),
                value: "vivriere",
                groupValue: _typeProduit,
                onChanged: (value) {
                  setState(() {
                    _typeProduit = value;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Champs dynamiques selon le type choisi
              if (_typeProduit == "rente") ...[
                const SizedBox(height: 10),
                const CultureRenteForm(), // ✅ Ici on appelle notre formulaire
              ] else if (_typeProduit == "vivriere") ...[
                const CultureVivriereForm()
                // Ici tu pourras mettre ton formulaire vivrière plus tard
              ] else ...[
                const Text(
                  "⚠️ Veuillez sélectionner un type de produit pour continuer",
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
