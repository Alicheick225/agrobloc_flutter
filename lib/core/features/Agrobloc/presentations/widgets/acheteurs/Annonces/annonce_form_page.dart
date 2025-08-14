import 'package:agrobloc/core/features/Agrobloc/data/dataSources/AnnonceAchat.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/userService.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/AnnonceAchatModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:agrobloc/core/themes/app_colors.dart';
import 'package:agrobloc/core/themes/app_text_styles.dart';

class AnnonceFormPage extends StatefulWidget {
  final AnnonceAchat? annonceToEdit;

  const AnnonceFormPage({Key? key, this.annonceToEdit}) : super(key: key);

  @override
  _AnnonceFormPageState createState() => _AnnonceFormPageState();
}

class _AnnonceFormPageState extends State<AnnonceFormPage> {
  final AnnonceAchatService _service = AnnonceAchatService();
  final _formKey = GlobalKey<FormState>();

  // Form fields
  List<Map<String, dynamic>> _cultures = [];
  String? _selectedCultureId;
  String? _selectedCultureLibelle;
  double _quantity = 1;
  double _prix = 0;
  String _quantityUnit = 'Kg';
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _prixController = TextEditingController();

  bool _isLoading = false;
  bool _isEditMode = false;

  // Color scheme
  final Color primaryColor = const Color(0xFF2E7D32);
  final Color secondaryColor = const Color(0xFF4CAF50);
  final Color accentColor = const Color(0xFF8BC34A);
  final Color errorColor = const Color(0xFFD32F2F);
  final Color backgroundColor = const Color(0xFFF5F5F5);
  final Color cardColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.annonceToEdit != null;
    _fetchCultures();
    if (_isEditMode) {
      _populateForm();
    }
  }

  void _populateForm() {
    final annonce = widget.annonceToEdit!;
    _descriptionController.text = annonce.description;
    _quantity = annonce.quantite;
    _prix = annonce.prix ?? 0;
    _prixController.text = _prix.toString();

    // Attendre que les cultures soient chargées avant de définir la culture
    if (_cultures.isNotEmpty) {
      _setCultureFromLibelle(annonce.typeCultureLibelle);
    }
  }

  void _setCultureFromLibelle(String libelle) {
    final matchingCulture = _cultures.firstWhere(
      (c) => c['libelle'] == libelle,
      orElse: () => {'id': '', 'libelle': ''},
    );

    if (matchingCulture['id'] != '') {
      setState(() {
        _selectedCultureId = matchingCulture['id'].toString();
        _selectedCultureLibelle = matchingCulture['libelle'];
      });
    }
  }

  Future<void> _fetchCultures() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final cultures = await _service.fetchCultures();

      // Remove duplicates by id
      final uniqueCultures = <String, Map<String, dynamic>>{};
      for (var culture in cultures) {
        uniqueCultures[culture['id'].toString()] = culture;
      }

      setState(() {
        _cultures = uniqueCultures.values.toList();

        // Set _selectedCultureId only if in edit mode and _selectedCultureId is null
        if (_isEditMode &&
            (_selectedCultureId == null || _selectedCultureId!.isEmpty)) {
          final existingCulture = _cultures.firstWhere(
            (c) => c['libelle'] == widget.annonceToEdit?.typeCultureLibelle,
            orElse: () => {'id': '', 'libelle': ''},
          );
          if (existingCulture['id'] != '') {
            _selectedCultureId = existingCulture['id'].toString();
          }
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur chargement cultures: $e'),
          backgroundColor: errorColor,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    // Vérifier si l'utilisateur est connecté avant de soumettre
    final userId = UserService().userId;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vous devez être connecté pour proposer une offre.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      double quantityInKg = _quantityUnit == 'T' ? _quantity * 1000 : _quantity;

      if (_isEditMode) {
        await _service.updateAnnonceAchat(
          id: widget.annonceToEdit!.id,
          description: _descriptionController.text.trim(),
          typeCultureId: _selectedCultureId!,
          quantite: quantityInKg,
          prix: _prix,
          statut: 'active',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Annonce mise à jour avec succès'),
            backgroundColor: primaryColor,
          ),
        );
      } else {
        await _service.createAnnonceAchat(
          description: _descriptionController.text.trim(),
          typeCultureId: _selectedCultureId!,
          quantite: quantityInKg,
          prix: _prix,
          statut: 'active',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Annonce créée avec succès'),
            backgroundColor: primaryColor,
          ),
        );
      }

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: errorColor,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<String> _getUserId() async {
    final userId = UserService().userId;
    if (userId == null) {
      // Afficher un message d'erreur plus clair et rediriger vers la page de connexion
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vous devez être connecté pour proposer une offre.'),
          backgroundColor: Colors.red,
        ),
      );
      throw Exception('Utilisateur non connecté');
    }
    return userId;
  }

  Widget _buildCultureDropdown() {
    return InkWell(
      onTap: _isLoading
          ? null
          : () {
              HapticFeedback.lightImpact();
            },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                color: primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 4),
              height: 2,
              width: 40,
              color: primaryColor,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                hintText: 'Sélectionner une culture',
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              value: _selectedCultureId,
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('Sélectionner une culture'),
                ),
                ..._cultures.map((culture) {
                  return DropdownMenuItem<String>(
                    value: culture['id'].toString(),
                    child: Text(
                      culture['libelle'],
                      style: const TextStyle(fontSize: 16),
                    ),
                  );
                }).toList(),
              ],
              onChanged: _isLoading
                  ? null
                  : (value) {
                      setState(() {
                        _selectedCultureId = value;
                        if (value != null) {
                          _selectedCultureLibelle = _cultures.firstWhere(
                            (c) => c['id'].toString() == value,
                            orElse: () => {'libelle': ''},
                          )['libelle'];
                        } else {
                          _selectedCultureLibelle = null;
                        }
                      });
                    },
              validator: (value) =>
                  value == null ? 'Sélectionnez une culture' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            'Quantité',
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 4, bottom: 8),
            height: 2,
            width: 40,
            color: primaryColor,
          ),
          Row(
            children: [
              Text(
                _quantity.toStringAsFixed(0),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(width: 16),
              ToggleButtons(
                borderColor: primaryColor,
                selectedBorderColor: primaryColor,
                borderRadius: BorderRadius.circular(8),
                selectedColor: Colors.white,
                fillColor: primaryColor,
                color: primaryColor,
                isSelected: [_quantityUnit == 'Kg', _quantityUnit == 'T'],
                onPressed: (index) {
                  setState(() {
                    _quantityUnit = index == 0 ? 'Kg' : 'T';
                  });
                },
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('Kg'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('T'),
                  ),
                ],
              ),
            ],
          ),
          Slider(
            value: _quantity,
            min: 0,
            max: 1000,
            divisions: 1000,
            label: _quantity.toStringAsFixed(0),
            onChanged: (value) {
              setState(() {
                _quantity = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              color: primaryColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 4, bottom: 8),
            height: 2,
            width: 40,
            color: primaryColor,
          ),
          TextFormField(
            controller: _descriptionController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText:
                  'Faites une brève description de ce que vous voulez ...',
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(8),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Entrez une description';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  // Removed the userId display widget as userId is not a form field and is obtained from UserService directly.

  Widget _buildPrixInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            'Prix',
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 4, bottom: 8),
            height: 2,
            width: 40,
            color: primaryColor,
          ),
          TextFormField(
            controller: _prixController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Entrez le prix',
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(8),
              prefixText: 'FCFA ',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Entrez un prix';
              }
              final prix = double.tryParse(value);
              if (prix == null || prix < 0) {
                return 'Entrez un prix valide';
              }
              return null;
            },
            onChanged: (value) {
              final prix = double.tryParse(value) ?? 0;
              setState(() {
                _prix = prix;
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'Modifier l\'annonce' : 'Faire une offre',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: _isLoading && _cultures.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: primaryColor),
                  const SizedBox(height: 16),
                  Text(
                    'Chargement des cultures...',
                    style: TextStyle(color: primaryColor, fontSize: 16),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildCultureDropdown(),
                      const SizedBox(height: 20),
                      _buildQuantityInput(),
                      const SizedBox(height: 20),
                      _buildPrixInput(),
                      const SizedBox(height: 20),
                      _buildDescriptionInput(),
                      const SizedBox(height: 20),
                      // _buildStatusDropdown(),
                      // const SizedBox(height: 32),
                      OutlinedButton(
                        onPressed: _isLoading ? null : _submitForm,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: primaryColor),
                          foregroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Proposer une offre d\'achat',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
