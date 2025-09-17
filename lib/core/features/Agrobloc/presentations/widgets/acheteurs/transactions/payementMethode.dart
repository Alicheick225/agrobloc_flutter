import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/acheteurs/transactions/paiementMoney.dart';
import 'package:flutter/material.dart';
import 'debitComplet.dart';

class PaymentMethodPage extends StatefulWidget {
  final String selectedPayment;
  final double totalAmount;
  final String productName;
  final double unitPrice;
  final double quantity;
  final String unit;

  const PaymentMethodPage({
    super.key,
    required this.selectedPayment,
    required this.totalAmount,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    required this.unit,
  });

  @override
  State<PaymentMethodPage> createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends State<PaymentMethodPage> {
  final TextEditingController cardHolderController = TextEditingController();
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController expDateController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();

  @override
  void dispose() {
    cardHolderController.dispose();
    cardNumberController.dispose();
    expDateController.dispose();
    cvvController.dispose();
    super.dispose();
  }

  void _confirmPayment() {
    final selectedLower = widget.selectedPayment.toLowerCase();

    final isMobileMoney = [
      "orange money",
      "mtn mobile money",
      "wave",
      "moov money",
    ].contains(selectedLower);

    if (isMobileMoney) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Redirection vers l'interface ${widget.selectedPayment}...",
          ),
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MobileMoneyOrderPage(
            selectedPayment: widget.selectedPayment,
            totalAmount: widget.totalAmount,
            unitPrice: widget.unitPrice,
            quantity: widget.quantity,
            unit: widget.unit,
            productName: widget.productName,
          ),
        ),
      );
      return;
    }

    // Validation carte bancaire
    if (cardHolderController.text.trim().isEmpty ||
        cardNumberController.text.trim().isEmpty ||
        expDateController.text.trim().isEmpty ||
        cvvController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez remplir toutes les informations de la carte"),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DebitCompletPage(
          nomProduit: widget.productName,
          unitPrice: widget.unitPrice,
          quantity: widget.quantity,
          unit: widget.unit,
          totalAmount: widget.totalAmount,
          productName: widget.productName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedLower = widget.selectedPayment.toLowerCase();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Mode de paiement",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.payment, color: Colors.green),
                title: Text("Mode sélectionné : ${widget.selectedPayment}"),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Montant à payer : ${widget.totalAmount.toStringAsFixed(0)} FCFA",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.green,
              ),
            ),
            const Divider(),
            if (selectedLower == "carte bancaire" ||
                selectedLower == "virement bancaire") ...[
              const Text(
                "Payer via une nouvelle carte",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: cardHolderController,
                decoration: InputDecoration(
                  hintText: "Nom du titulaire",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
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
                      controller: cardNumberController,
                      decoration: const InputDecoration(
                        hintText: "Numéro de carte",
                        prefixIcon: Icon(Icons.credit_card),
                        border: InputBorder.none,
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const Divider(),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: expDateController,
                            decoration: const InputDecoration(
                              hintText: "MM/AA",
                              border: InputBorder.none,
                            ),
                            keyboardType: TextInputType.datetime,
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: cvvController,
                            decoration: const InputDecoration(
                              hintText: "CVC",
                              border: InputBorder.none,
                            ),
                            obscureText: true,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ] else ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "Vous serez redirigé vers l'interface de paiement ${widget.selectedPayment}.",
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _confirmPayment,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.green,
                  side: const BorderSide(color: Colors.green),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text("Confirmer le paiement"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
