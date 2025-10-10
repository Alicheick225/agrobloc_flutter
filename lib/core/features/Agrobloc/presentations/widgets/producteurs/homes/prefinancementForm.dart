import 'dart:convert';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/userService.dart';
import 'package:flutter/material.dart';
import 'package:agrobloc/core/themes/app_colors.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/AnnoncePrefinancementService.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/parcelleService.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/cultureService.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/parcelleService.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/cultureModel.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/annoncePrefinancementModel.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/producteurs/homes/offreVentePage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefinancementForm extends StatefulWidget {
  final AnnoncePrefinancement? prefinancement; // Pour le mode édition

  const PrefinancementForm({super.key, this.prefinancement});

  @override
  State<PrefinancementForm> createState() => _PrefinancementFormState();
}

class _PrefinancementFormState extends State<PrefinancementForm> {
  final PrefinancementService service = PrefinancementService();
  final cultureService typeService = cultureService();
  final ParcelleService parcelleService = ParcelleService();

  final TextEditingController productionController = TextEditingController();
  final TextEditingController prixVenteController = TextEditingController();
  final TextEditingController montantController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  List<Culture> cultures = [];
  List<Culture> _allCultures = [];
  List<Parcelle> parcelles = [];

  Culture? culture;
  Parcelle? parcelle;
  String unite = "Kg"; // Kg ou T
  String? _typeProduit; // Type de culture: 'rente' ou 'vivriere'

  List<Map<String, dynamic>> _typesProduits = [];

  bool get isEditing => widget.prefinancement != null;

  // Remove duplicate isEditing getter
  // bool get isEditing => widget.prefinancement != null;

  @override
  void initState() {
    super.initState();
    _typesProduits = [
      {'id': 'rente', 'libelle': 'Culture de rente'},
      {'id': 'vivriere', 'libelle': 'Culture vivrière'},
    ];
    _chargerData();

    if (widget.prefinancement != null) {
      _populateFieldsForEditing();
    }
  }

  void _populateFieldsForEditing() {
    if (widget.prefinancement == null) return;

    final prefinancement = widget.prefinancement!;

    // Populate quantity
    productionController.text = prefinancement.quantite.toString();

    // Populate price
    prixVenteController.text = prefinancement.prixKgPref.toString();

    // Populate montant
    montantController.text = prefinancement.montantPref.toString();

    // Populate description
    descriptionController.text = prefinancement.description ?? '';

    // Set unit based on quantity (assuming if > 1000, it's in T)
    if (prefinancement.quantite >= 1000) {
      unite = "T";
      productionController.text = (prefinancement.quantite / 1000).toString();
    } else {
      unite = "Kg";
    }

    // Set typeProduit based on culture type (need to find culture first)
    Culture? foundCulture;
    try {
      foundCulture = _allCultures.firstWhere((c) => c.id == prefinancement.cultureId);
    } catch (e) {
      try {
        foundCulture = _allCultures.firstWhere((c) => c.libelle == prefinancement.libelle);
      } catch (e) {
        foundCulture = null;
      }
    }

    if (foundCulture != null) {
      _typeProduit = (foundCulture.type ?? '').toLowerCase() == 'vivrière' ? 'vivriere' : (foundCulture.type ?? '').toLowerCase();
      culture = foundCulture;
      // Reload cultures filtered by type
      cultures = _allCultures.where((c) {
        String normalizedType = (c.type ?? '').toLowerCase() == 'vivrière' ? 'vivriere' : (c.type ?? '').toLowerCase();
        return normalizedType == _typeProduit;
      }).toList();
    } else {
      culture = null;
      _typeProduit = null;
    }

    // Set parcelle based on parcelleId (try id first, then adresse)
    try {
      parcelle = parcelles.firstWhere((p) => p.id == prefinancement.parcelleId);
    } catch (e) {
      try {
        parcelle = parcelles.firstWhere((p) => p.adresse == prefinancement.parcelleId);
      } catch (e) {
        parcelle = null;
      }
    }

    // Update UI
    setState(() {});
  }

  Future<void> _chargerData() async {
    try {
      final allCultures = await typeService.getAllCulture();
      final p = await parcelleService.getAllParcelles();
      setState(() {
        _allCultures = allCultures;
        if (_typeProduit != null) {
          cultures = allCultures.where((c) {
            String normalizedType = (c.type ?? '').toLowerCase() == 'vivrière' ? 'vivriere' : (c.type ?? '').toLowerCase();
            return normalizedType == _typeProduit;
          }).toList();
        } else {
          cultures = [];
        }
        parcelles = p;
      });
      // Populate fields after data is loaded if editing
      if (widget.prefinancement != null) {
        _populateFieldsForEditing();
      }
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
          const SnackBar(
              content:
                  Text("Veuillez sélectionner une culture et une parcelle")),
        );
        return;
      }

      final userService = UserService();

    // Vérifier l'authentification en chargeant les données utilisateur si nécessaire
    final isAuthenticated = await userService.isUserAuthenticated();
    if (!isAuthenticated) {
      throw Exception("Utilisateur non connecté ou token manquant");
    }

    final userId = userService.userId!;

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
      cultureId: culture!.id,
      parcelleId: parcelle!.id,
      quantite: quantite,
      prix: prix,
      description: description,

    );


    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('✅'),
          content: const Text('Votre demande de préfinancement a été enregistrée.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Retour'),
              onPressed: () {
                Navigator.of(context).pop(); // Fermer le modal
                // Reset form fields
                setState(() {
                  culture = null;
                  parcelle = null;
                  productionController.clear();
                  prixVenteController.clear();
                  montantController.clear();
                  descriptionController.clear();
                  unite = "Kg";
                });
              },
            ),
            TextButton(
              child: const Text('Voir ma demande'),
              onPressed: () {
                Navigator.of(context).pop(); // Fermer le modal
                // Naviguer vers la page OffreVentePage avec l'onglet Financement sélectionné
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const OffreVentePage(initialTabIndex: 2),
                  ),
                );
              },
            ),
          ],
        );
      },
    );

    print("Réponse API : ${jsonEncode(annonce.toJson())}");
  } catch (e) {
    print("Erreur API : $e");

    // Gestion spécifique des erreurs d'authentification
    String errorMessage = "Une erreur inattendue s'est produite";

    if (e.toString().contains("Token manquant") ||
        e.toString().contains("Utilisateur non connecté") ||
        e.toString().contains("token manquant")) {
      errorMessage = "Session expirée. Veuillez vous reconnecter.";
    } else if (e.toString().contains("Identifiant utilisateur invalide") ||
               e.toString().contains("authentification") ||
               e.toString().contains("Authentication")) {
      errorMessage = "Problème d'authentification. Veuillez vous reconnecter.";
    } else if (e.toString().contains("Impossible de rafraîchir le token")) {
      errorMessage = "Session expirée. Veuillez vous reconnecter pour continuer.";
    } else if (e.toString().contains("Erreur lors de la création du préfinancement")) {
      errorMessage = "Erreur lors de l'envoi de la demande. Veuillez réessayer.";
    } else if (e.toString().contains("réseau") ||
               e.toString().contains("network") ||
               e.toString().contains("connection")) {
      errorMessage = "Problème de connexion. Vérifiez votre connexion internet.";
    } else {
      // Pour les autres erreurs, afficher un message générique mais plus user-friendly
      errorMessage = "Une erreur s'est produite. Veuillez réessayer.";
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        duration: const Duration(seconds: 4),
        action: (errorMessage.contains("reconnecter") ||
                 errorMessage.contains("Session expirée"))
            ? SnackBarAction(
                label: "Se connecter",
                onPressed: () {
                  // Navigation vers la page de connexion
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login',
                    (route) => false,
                  );
                },
              )
            : null,
      ),
    );
  }
}




  void _updateDemande() async {
    try {
      if (culture == null || parcelle == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Veuillez sélectionner une culture et une parcelle")),
        );
        return;
      }

      // Quantité
      double quantite = double.tryParse(productionController.text) ?? 0;
      if (unite == "T") quantite *= 1000; // Conversion T -> Kg

      // Prix de vente
      double prix = double.tryParse(prixVenteController.text) ?? 0;

      // Description par défaut
      final description = descriptionController.text.trim().isEmpty
          ? "Pas de description"
          : descriptionController.text.trim();

      // Mise à jour du préfinancement
      final annonce = await service.updatePrefinancement(
        id: widget.prefinancement!.id,
        cultureId: culture!.id,
        parcelleId: parcelle!.id,
        quantite: quantite,
        prix: prix,
        description: description,
      );

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('✅'),
            content: const Text('Votre demande de préfinancement a été mise à jour.'),
            actions: <Widget>[
              TextButton(
                child: const Text('Retour'),
                onPressed: () {
                  Navigator.of(context).pop(); // Fermer le modal
                  Navigator.of(context).pop(); // Retour à la page précédente
                },
              ),
            ],
          );
        },
      );

      print("Réponse API mise à jour : ${jsonEncode(annonce.toJson())}");
    } catch (e) {
      print("Erreur API mise à jour : $e");

      // Gestion spécifique des erreurs d'authentification
      String errorMessage = "Une erreur inattendue s'est produite";

      if (e.toString().contains("Token manquant") ||
          e.toString().contains("Utilisateur non connecté") ||
          e.toString().contains("token manquant")) {
        errorMessage = "Session expirée. Veuillez vous reconnecter.";
      } else if (e.toString().contains("Identifiant utilisateur invalide") ||
                 e.toString().contains("authentification") ||
                 e.toString().contains("Authentication")) {
        errorMessage = "Problème d'authentification. Veuillez vous reconnecter.";
      } else if (e.toString().contains("Impossible de rafraîchir le token")) {
        errorMessage = "Session expirée. Veuillez vous reconnecter pour continuer.";
      } else if (e.toString().contains("Erreur lors de la mise à jour du préfinancement")) {
        errorMessage = "Erreur lors de la mise à jour de la demande. Veuillez réessayer.";
      } else if (e.toString().contains("réseau") ||
                 e.toString().contains("network") ||
                 e.toString().contains("connection")) {
        errorMessage = "Problème de connexion. Vérifiez votre connexion internet.";
      } else {
        // Pour les autres erreurs, afficher un message générique mais plus user-friendly
        errorMessage = "Une erreur s'est produite. Veuillez réessayer.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          duration: const Duration(seconds: 4),
          action: (errorMessage.contains("reconnecter") ||
                   errorMessage.contains("Session expirée"))
              ? SnackBarAction(
                  label: "Se connecter",
                  onPressed: () {
                    // Navigation vers la page de connexion
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/login',
                      (route) => false,
                    );
                  },
                )
              : null,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        title: Text(
          isEditing ? "Modifier la demande de préfinancement" : "Faire une demande de préfinancement",
          style: const TextStyle(color: Colors.black, fontSize: 16),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _allCultures.isEmpty || parcelles.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
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
                        const SizedBox(height: 8),
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
                              culture = null; // Reset culture when type changes
                            });
                            _chargerData(); // Reload cultures filtered by type
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
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
                          'Choix de la culture',
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
                          value: culture,
                          menuMaxHeight: 200.0,
                          items: cultures.isNotEmpty
                              ? cultures
                                  .map((c) => DropdownMenuItem<Culture>(
                                        value: c,
                                        child: Text(c.libelle ?? ''),
                                      ))
                                  .toList()
                              : null,
                          onChanged: cultures.isNotEmpty
                              ? (val) {
                                  setState(() => culture = val);
                                }
                              : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
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
                          'Production estimée',
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
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: productionController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: "10",
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.all(8),
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
                              borderColor: AppColors.primaryGreen,
                              selectedBorderColor: AppColors.primaryGreen,
                              borderRadius: BorderRadius.circular(8),
                              selectedColor: Colors.white,
                              fillColor: AppColors.primaryGreen,
                              color: AppColors.primaryGreen,
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
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
                          'Choix de la parcelle',
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
                        DropdownButtonFormField<Parcelle>(
                          decoration: InputDecoration(
                            hintText: 'Sélectionner une parcelle',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          value: parcelle,
                          menuMaxHeight: 200.0,
                          items: parcelles
                              .map((p) => DropdownMenuItem<Parcelle>(
                                    value: p,
                                    child: Text(p.libelle),
                                  ))
                              .toList(),
                          onChanged: (val) => setState(() => parcelle = val),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                 

                  _buildNumberField("Prix de vente", prixVenteController, "FCFA"),
                  const SizedBox(height: 16),
                  _buildNumberField(
                      "Montant à préfinancer", montantController, "FCFA"),
                  const SizedBox(height: 16),
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
                        TextField(
                          controller: descriptionController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: "Donnez les détails de votre demande",
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: isEditing ? _updateDemande : _envoyerDemande,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.primaryGreen),
                        foregroundColor: AppColors.primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        isEditing ? "Modifier la demande de préfinancement" : "Faire une demande de préfinancement",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildNumberField(
      String title, TextEditingController controller, String unit) {
    return Container(
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
            title,
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
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(8),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primaryGreen),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(unit, style: TextStyle(color: AppColors.primaryGreen)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
