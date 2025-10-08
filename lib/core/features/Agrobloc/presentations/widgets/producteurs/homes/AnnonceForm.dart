import 'package:agrobloc/core/features/Agrobloc/data/dataSources/annonceVenteService.dart';
import 'package:flutter/material.dart';
import 'package:agrobloc/core/themes/app_colors.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/producteurs/homes/annonce_widget/formRente.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/producteurs/homes/annonce_widget/formVivrier.dart';

class DynamicAnnonceForm extends StatefulWidget {
  const DynamicAnnonceForm({super.key});

  @override
  _DynamicAnnonceFormState createState() => _DynamicAnnonceFormState();
}

class _DynamicAnnonceFormState extends State<DynamicAnnonceForm> {
  String? _typeProduit; // "de rente" ou "Vivrière"
  List<Map<String, dynamic>> _typesProduits = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTypesProduits();
  }

  Future<void> _loadTypesProduits() async {
    try {
      final cultures = await AnnonceService().fetchCultures();
      setState(() {
        _typesProduits = cultures;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur chargement types : $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        title: const Text("Nouvelle annonce"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Sélectionnez le type de culture",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    // Liste dynamique des types de produits
                    ..._typesProduits.map(
                      (type) => RadioListTile<Map<String, dynamic>>(
                        title: Text(type['libelle'] ?? "Sans libellé"),
                        value: type,
                        groupValue: _typeProduit != null
                            ? _typesProduits.firstWhere(
                                (e) => e['libelle'] == _typeProduit,
                                orElse: () => _typesProduits.first,
                              )
                            : null,
                        onChanged: (val) => setState(() => _typeProduit =
                            val?['libelle']?.toString() ?? 'Inconnu'),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Formulaire dynamique
                    if (_typeProduit == "Culture de rente") ...[
                      const CultureRenteForm(),
                    ] else if (_typeProduit == "Culture vivrière") ...[
                      const CultureVivriereForm(),
                    ] else if (_typeProduit != null) ...[
                      Text(
                        "⚠️ Type « $_typeProduit » non encore supporté",
                        style: const TextStyle(color: Colors.red),
                      ),
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
