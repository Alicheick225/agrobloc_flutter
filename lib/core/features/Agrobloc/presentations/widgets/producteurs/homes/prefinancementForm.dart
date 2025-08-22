import 'dart:convert';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/userService.dart';
import 'package:flutter/material.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/AnnoncePrefinancementService.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/parcelleService.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/tyoeCultureService.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/parcelleService.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/typecultureModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefinancementForm extends StatefulWidget {
  const PrefinancementForm({super.key});

  @override
  State<PrefinancementForm> createState() => _PrefinancementFormState();
}

class _PrefinancementFormState extends State<PrefinancementForm> {
  final PrefinancementService service = PrefinancementService();
  final TypeCultureService typeService = TypeCultureService();
  final ParcelleService parcelleService = ParcelleService();

  final TextEditingController productionController = TextEditingController();
  final TextEditingController prixVenteController = TextEditingController();
  final TextEditingController montantController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  List<TypeCulture> cultures = [];
  List<Parcelle> parcelles = [];

  TypeCulture? culture;
  Parcelle? parcelle;
  String unite = "Kg"; // Kg ou T

  @override
  void initState() {
    super.initState();
    _chargerData();
  }

  Future<void> _chargerData() async {
    try {
      final c = await typeService.getAllTypes();
      final p = await parcelleService.getAllParcelles();
      setState(() {
        cultures = c;
        parcelles = p;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur de chargement : $e")),
      );
    }
  }
// Dans PrefinancementForm.dart
void _envoyerDemande() async {
  try {
    if (culture == null || parcelle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez sélectionner une culture et une parcelle")),
      );
      return;
    }

    final userService = UserService();

    if (!userService.isLoggedIn) {
      throw Exception("Utilisateur non connecté ou token manquant");
    }

    final userId = userService.userId!;
    final token = userService.token!;

    // Quantité
    double quantite = double.tryParse(productionController.text) ?? 0;
    if (unite == "T") quantite *= 1000; // Conversion T -> Kg

    // Prix de vente
    double prix = double.tryParse(prixVenteController.text) ?? 0;

    // Description par défaut
    final description = descriptionController.text.trim().isEmpty
        ? "Pas de description"
        : descriptionController.text.trim();

    // Création du préfinancement
    final annonce = await service.createPrefinancement(
      token: token,
      typeCultureId: culture!.id,
      parcelleId: parcelle!.id,
      quantite: quantite,
      prix: prix,
      description: description,

    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Demande envoyée avec succès ✅")),
    );

    print("Réponse API : ${jsonEncode(annonce.toJson())}");
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Erreur : $e")),
    );
    print("Erreur API : $e");
  }
}




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        title: const Text(
          "Faire une demande de préfinancement",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: cultures.isEmpty || parcelles.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<TypeCulture>(
                    decoration: const InputDecoration(
                      labelText: "Choix de la culture",
                      border: OutlineInputBorder(),
                    ),
                    value: culture,
                    items: cultures
                        .map((c) => DropdownMenuItem<TypeCulture>(
                              value: c,
                              child: Text(c.libelle),
                            ))
                        .toList(),
                    onChanged: (val) => setState(() => culture = val),
                  ),
                  const SizedBox(height: 16),

                  Text("Production estimée", style: TextStyle(fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: productionController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: "10",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ToggleButtons(
                        isSelected: [unite == "Kg", unite == "T"],
                        onPressed: (index) {
                          setState(() {
                            unite = index == 0 ? "Kg" : "T";
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        children: const [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text("Kg"),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text("T"),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<Parcelle>(
                    decoration: const InputDecoration(
                      labelText: "Choix de la parcelle",
                      border: OutlineInputBorder(),
                    ),
                    value: parcelle,
                    items: parcelles
                        .map((p) => DropdownMenuItem<Parcelle>(
                              value: p,
                              child: Text(p.libelle),
                            ))
                        .toList(),
                    onChanged: (val) => setState(() => parcelle = val),
                  ),
                  const SizedBox(height: 16),

                  if (parcelle != null) ...[
                    Text("Adresse : ${parcelle!.adresse}", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text("Surface : ${parcelle!.surface} hectares", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                  ],

                  _buildNumberField("Prix de vente", prixVenteController, "FCFA"),
                  const SizedBox(height: 16),

                  _buildNumberField("Montant à préfinancer", montantController, "FCFA"),
                  const SizedBox(height: 16),

                  Text("Description", style: TextStyle(fontWeight: FontWeight.bold)),
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: "Donnez les détails de votre demande",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _envoyerDemande,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Faire une demande de préfinancement",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildNumberField(String title, TextEditingController controller, String unit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(unit, style: const TextStyle(color: Colors.green)),
            ),
          ],
        ),
      ],
    );
  }
}
