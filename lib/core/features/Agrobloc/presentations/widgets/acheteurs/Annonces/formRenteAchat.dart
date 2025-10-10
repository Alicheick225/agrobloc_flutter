import 'package:agrobloc/core/features/Agrobloc/data/dataSources/AnnonceAchat.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/cultureService.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/userService.dart';
import 'package:agrobloc/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FormRenteAchat extends StatefulWidget {
  const FormRenteAchat({super.key});

  @override
  State<FormRenteAchat> createState() => _FormRenteAchatState();
}

class _FormRenteAchatState extends State<FormRenteAchat> {
  final _formKey = GlobalKey<FormState>();
  final AnnonceAchatService _service = AnnonceAchatService();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _prixController = TextEditingController();

  List<Map<String, dynamic>> _cultures = [];
  String? _selectedCultureId;
  double _quantity = 1;
  String _quantityUnit = 'Kg';
  bool _isLoading = false;

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
    _loadCultures();
  }

  Future<void> _loadCultures() async {
    setState(() => _isLoading = true);
    try {
      final allCultures = await cultureService().getAllCulture();
      final cultures = allCultures.where((c) => c.type?.toLowerCase() == 'rente').toList();
      setState(() {
        _cultures = cultures.map((c) => {'id': c.id, 'libelle': c.libelle, 'prix_bord_champ': c.prixBordChamp}).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur chargement cultures : $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCultureId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sélectionnez une culture')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final isAuthenticated = await UserService().isUserAuthenticated();
      if (!isAuthenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session expirée. Veuillez vous reconnecter.')),
        );
        return;
      }

      double quantityInKg = _quantityUnit == 'T' ? _quantity * 1000 : _quantity;
      double prix = double.tryParse(_prixController.text) ?? 0;

      await _service.createAnnonceAchat(
        statut: 'active',
        description: _descriptionController.text.trim(),
        cultureId: _selectedCultureId!,
        quantite: quantityInKg,
        unite: _quantityUnit,
        prix: prix,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Annonce créée avec succès'), backgroundColor: AppColors.primaryGreen),
      );

      // Reset form
      _formKey.currentState!.reset();
      _descriptionController.clear();
      _prixController.clear();
      setState(() {
        _selectedCultureId = null;
        _quantity = 1;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildCultureDropdown() {
    return InkWell(
      onTap: _isLoading
          ? null
          : () {
              HapticFeedback.lightImpact();
            },
      child: Container(
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
              'Culture de rente',
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
              menuMaxHeight: 200.0, // Limite la hauteur à environ 5 éléments et active le scroll
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('Sélectionner une culture'),
                ),
                ..._cultures.map((culture) {
                  return DropdownMenuItem<String>(
                    value: culture['id'],
                    child: Text(
                      culture['libelle'],
                      style: const TextStyle(fontSize: 16),
                    ),
                  );
                }),
              ],
              onChanged: _isLoading
                  ? null
                  : (value) {
                      setState(() {
                        _selectedCultureId = value;
                        if (value != null) {
                          final selectedCulture = _cultures.firstWhere((c) => c['id'] == value);
                          _prixController.text = selectedCulture['prix_bord_champ'].toString();
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

  Widget _buildPrixInput() {
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
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityInput() {
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
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(width: 40),
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
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('Kg'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('T'),
                  ),
                ],
              ),
            ],
          ),
          Slider(
            value: _quantity,
            min: 0,
            max: 10000,
            divisions: 10000,
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
            maxLines: 3,
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

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildCultureDropdown(),
          const SizedBox(height: 12),
          _buildPrixInput(),
          const SizedBox(height: 12),
          _buildQuantityInput(),
          const SizedBox(height: 12),
          _buildDescriptionInput(),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _isLoading ? null : _submit,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: primaryColor),
              foregroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 12),
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
                : Text(
                    'Publier l\'annonce',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
