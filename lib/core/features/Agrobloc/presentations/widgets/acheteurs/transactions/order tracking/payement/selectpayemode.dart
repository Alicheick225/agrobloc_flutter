import 'package:flutter/material.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/servicePayement.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/payementModeModel.dart';

class TypePayementWidget extends StatefulWidget {
  final Function(String id)? onModeChanged;
  final VoidCallback onConfirm;
  final TextEditingController cardHolderController;
  final TextEditingController cardNumberController;
  final TextEditingController expDateController;
  final TextEditingController cvvController;

  const TypePayementWidget({
    super.key,
    this.onModeChanged,
    required this.onConfirm,
    required this.cardHolderController,
    required this.cardNumberController,
    required this.expDateController,
    required this.cvvController,
  });

  @override
  State<TypePayementWidget> createState() => _TypePayementWidgetState();
}

class _TypePayementWidgetState extends State<TypePayementWidget> {
  String? _selectedId;
  List<PayementModel> _modes = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadModes();
  }

  Future<void> _loadModes() async {
    try {
      _modes = await PayementService().fetchModes();
    } catch (e) {
      _error = 'Erreur serveur : ${e.toString()}';
    }
    setState(() {});
  }

  bool get _isCard => _modes.any(
      (e) => e.id == _selectedId && e.libelle.toLowerCase().contains('carte'));

  bool get _isMobile => _modes.any(
      (e) => e.id == _selectedId && !e.libelle.toLowerCase().contains('carte'));

  /* 1. LISTE DE SÉLECTION (sans loading) */
  Widget _buildModeSelector() {
    if (_modes.isEmpty) {
      // premier appel asynchrone
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadModes());
      return const SizedBox.shrink();
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(height: 8),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadModes,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 24, right: 24, top: 10),
          child: Text(
            'Sélectionnez le mode de paiement',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        const SizedBox(height: 8),
        ..._modes.map(
          (m) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
            child: Card(
              child: ListTile(
                leading: const Icon(Icons.payment, color: Colors.grey),
                title: Text(m.libelle),
                onTap: () => setState(() {
                  _selectedId = m.id;
                  widget.onModeChanged?.call(m.id);
                }),
                selected: _selectedId == m.id,
                selectedColor: Colors.green,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /* 2. FORMULAIRE CARTE */
  List<Widget> _buildCardForm() => [
        const Center(
          child: Text(
            'Payer via une nouvelle carte',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: TextField(
            controller: widget.cardHolderController,
            decoration: InputDecoration(
              hintText: 'Nom du titulaire',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                TextField(
                  controller: widget.cardNumberController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Numéro de carte',
                    prefixIcon: Icon(Icons.credit_card),
                    border: InputBorder.none,
                  ),
                ),
                const Divider(),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: widget.expDateController,
                        keyboardType: TextInputType.datetime,
                        decoration: const InputDecoration(
                            hintText: 'MM/AA', border: InputBorder.none),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: widget.cvvController,
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        decoration: const InputDecoration(
                            hintText: 'CVC', border: InputBorder.none),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ];

  /* 3. INFO MOBILE MONEY */
  List<Widget> _buildMobileInfo() => [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            "Vous serez redirigé vers l'interface de paiement ${_modes.firstWhere((e) => e.id == _selectedId).libelle}.",
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ];

  /* 4. BUILD PRINCIPAL */
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _selectedId == null
            ? _buildModeSelector()
            : Column(
                children: [
                  if (_isCard) ..._buildCardForm(),
                  if (_isMobile) ..._buildMobileInfo(),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: widget.onConfirm,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: const Color(0xFF2E7D32),
                              side: const BorderSide(color: Color(0xFF2E7D32)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text(
                              'Confirmer le paiement',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        TextButton(
                          onPressed: () => setState(() => _selectedId = null),
                          child: const Text('Changer'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ],
    );
  }
}
