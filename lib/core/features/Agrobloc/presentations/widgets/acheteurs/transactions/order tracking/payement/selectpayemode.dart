import 'package:flutter/material.dart';

class TypePayementWidget extends StatefulWidget {
  final Function(String mode)? onModeChanged;
  final VoidCallback onConfirm;

  // Controllers partagés
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
  String? _selected; // null = pas encore choisi

  final List<String> _modes = [
    'Carte Bancaire',
    'Virement Bancaire',
    'Orange Money',
    'MTN Mobile Money',
    'Wave',
    'Moov Money',
  ];

  bool get _isCard =>
      _selected?.toLowerCase() == 'carte bancaire' ||
      _selected?.toLowerCase() == 'virement bancaire';

  bool get _isMobile => {
        'orange money',
        'mtn mobile money',
        'wave',
        'moov money'
      }.contains(_selected?.toLowerCase());

  /* --------------------------------------------------------
     1. LISTE DE SÉLECTION
  -------------------------------------------------------- */
  Widget _buildModeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 10),
          child: Text(
            'Sélectionnez le mode de paiement',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 8),
        ..._modes.map((mode) => ListTile(
              title: Text(mode),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                setState(() => _selected = mode);
                widget.onModeChanged?.call(mode);
              },
            )),
      ],
    );
  }

  /* --------------------------------------------------------
     2. FORMULAIRE CARTE
  -------------------------------------------------------- */
  List<Widget> _buildCardForm() => [
        const Text(
          'Payer via une nouvelle carte',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: widget.cardHolderController,
          decoration: InputDecoration(
            hintText: 'Nom du titulaire',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 12),
        Container(
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
      ];

  /* --------------------------------------------------------
     3. INFO MOBILE MONEY
  -------------------------------------------------------- */
  List<Widget> _buildMobileInfo() => [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            "Vous serez redirigé vers l'interface de paiement $_selected.",
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ];

  /* --------------------------------------------------------
     4. BUILD PRINCIPAL
  -------------------------------------------------------- */
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ÉTAPE 1 : sélection
        if (_selected == null) _buildModeSelector(),

        // ÉTAPE 2 : formulaire ou info
        if (_selected != null) ...[
          if (_isCard) ..._buildCardForm(),
          if (_isMobile) ..._buildMobileInfo(),
          const SizedBox(height: 20),

          // Bouton « Confirmer » + « Changer de mode »
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onConfirm,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green,
                    side: const BorderSide(color: Colors.green),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Confirmer le paiement'),
                ),
              ),
              const SizedBox(width: 12),
              TextButton.icon(
                icon: const Icon(Icons.arrow_back, size: 18),
                label: const Text('Changer'),
                onPressed: () => setState(() => _selected = null),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
