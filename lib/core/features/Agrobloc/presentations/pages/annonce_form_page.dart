import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/dataSources/AnnonceAchat.dart';
import '../../data/models/AnnonceAchatModel.dart';

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
  String _quantityUnit = 'Kg';
  final TextEditingController _descriptionController = TextEditingController();
  String _statut = 'en attente';

  bool _isLoading = false;
  bool _isEditMode = false;

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
    _statut = annonce.statut;
    _selectedCultureLibelle = annonce.typeCultureLibelle;

    // Find culture ID by libelle
    _selectedCultureId = _cultures
        .firstWhere(
          (c) => c['libelle'] == annonce.typeCultureLibelle,
          orElse: () => {'id': ''},
        )['id']
        .toString();
  }

  Future<void> _fetchCultures() async {
    setState(() => _isLoading = true);
    try {
      final cultures = await _service.fetchCultures();
      setState(() {
        _cultures = cultures;
        if (_isEditMode && _selectedCultureId != null) {
          // Ensure the culture exists in the list
          final existingCulture = cultures.firstWhere(
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
        SnackBar(content: Text('Erreur chargement cultures: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Convert quantity to base unit (Kg)
      double quantityInKg = _quantityUnit == 'T' ? _quantity * 1000 : _quantity;

      if (_isEditMode) {
        await _service.updateAnnonceAchat(
          id: widget.annonceToEdit!.id,
          statut: _statut,
          description: _descriptionController.text.trim(),
          userId: '1', // TODO: Replace with actual user ID
          typeCultureId: _selectedCultureId!,
          quantite: quantityInKg,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Annonce mise à jour avec succès')),
        );
      } else {
        await _service.createAnnonceAchat(
          statut: _statut,
          description: _descriptionController.text.trim(),
          userId: '1', // TODO: Replace with actual user ID
          typeCultureId: _selectedCultureId!,
          quantite: quantityInKg,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Annonce créée avec succès')),
        );
      }

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildCultureDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Type de culture',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      value: _selectedCultureId,
      items: _cultures.map((culture) {
        return DropdownMenuItem<String>(
          value: culture['id'].toString(),
          child: Text(culture['libelle']),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCultureId = value;
          _selectedCultureLibelle = _cultures.firstWhere(
            (c) => c['id'].toString() == value,
          )['libelle'];
        });
      },
      validator: (value) => value == null ? 'Sélectionnez une culture' : null,
    );
  }

  Widget _buildQuantityInput() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            initialValue: _quantity.toString(),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: 'Quantité',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onChanged: (value) {
              setState(() {
                _quantity = double.tryParse(value) ?? 0;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) return 'Entrez une quantité';
              if (double.tryParse(value) == null) return 'Quantité invalide';
              return null;
            },
          ),
        ),
        const SizedBox(width: 10),
        DropdownButton<String>(
          value: _quantityUnit,
          items: const [
            DropdownMenuItem(value: 'Kg', child: Text('Kg')),
            DropdownMenuItem(value: 'T', child: Text('T')),
          ],
          onChanged: (value) {
            setState(() => _quantityUnit = value!);
          },
        ),
      ],
    );
  }

  Widget _buildDescriptionInput() {
    return TextFormField(
      controller: _descriptionController,
      maxLines: 4,
      decoration: InputDecoration(
        labelText: 'Description',
        hintText: 'Décrivez votre annonce...',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Entrez une description';
        }
        return null;
      },
    );
  }

  Widget _buildStatusDropdown() {
    final statusItems = [
      const DropdownMenuItem(value: 'en attente', child: Text('En attente')),
      const DropdownMenuItem(value: 'active', child: Text('Active')),
      const DropdownMenuItem(value: 'validé', child: Text('Validé')),
      const DropdownMenuItem(value: 'terminee', child: Text('Terminée')),
    ];

    // Ensure _statut is valid and matches one of the items
    final currentValue =
        statusItems.any((item) => item.value == _statut) ? _statut : null;

    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Statut',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      value: currentValue,
      items: statusItems,
      onChanged: (value) => setState(() => _statut = value!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Modifier l\'annonce' : 'Créer une annonce'),
      ),
      body: _isLoading && _cultures.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildCultureDropdown(),
                      const SizedBox(height: 16),
                      _buildQuantityInput(),
                      const SizedBox(height: 16),
                      _buildDescriptionInput(),
                      const SizedBox(height: 16),
                      _buildStatusDropdown(),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitForm,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              _isEditMode ? 'Mettre à jour' : 'Créer',
                              style: const TextStyle(fontSize: 16),
                            ),
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
