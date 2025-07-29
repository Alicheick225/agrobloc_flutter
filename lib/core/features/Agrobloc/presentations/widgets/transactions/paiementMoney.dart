import 'package:flutter/material.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/servicePayement.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/transactions/debitComplet.dart';

class MobileMoneyOrderPage extends StatefulWidget {
  final String selectedPayment;
  final double totalAmount;
  final String productName;
  final double unitPrice;
  final double quantity;
  final String unit;


  const MobileMoneyOrderPage({
    super.key,
    required this.selectedPayment,
    required this.totalAmount,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    required this.unit,
  });


  @override
  State<MobileMoneyOrderPage> createState() => _MobileMoneyOrderPageState();
}

class _MobileMoneyOrderPageState extends State<MobileMoneyOrderPage> {
  final TextEditingController phoneController =
      TextEditingController(text: "+225 ** *****76");
  final TextEditingController debitNumberController = TextEditingController();
  bool useNewNumber = false;
  bool isLoading = false;

  final FusionMoneyService paiementService = FusionMoneyService();

  String getPaiementProChannel() {
    if (widget.selectedPayment == "Orange Money") return "O";
    if (widget.selectedPayment == "MTN Mobile Money") return "M";
    return "C"; // Carte bancaire
  }

  @override
  void dispose() {
    phoneController.dispose();
    debitNumberController.dispose();
    super.dispose();
  }

  Future<void> _handlePayment() async {
    final numero = useNewNumber
        ? debitNumberController.text.trim()
        : phoneController.text.trim();

    if (numero.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez saisir un numéro valide")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await paiementService.makePayment(
        montant: widget.totalAmount,
        numeroClient: numero,
        nomClient: "Client Agrobloc",
        context: context,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => DebitCompletPage(
          nomProduit: widget.productName,
          unitPrice: widget.unitPrice,
          quantity: widget.quantity,
          unit: widget.unit,
          totalAmount: widget.totalAmount,
          productName: widget.productName, 
        )),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors du paiement : $e")),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text("Mode de paiement",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ✅ Affichage du mode de paiement choisi
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Image.asset(
                    widget.selectedPayment == "MTN Mobile Money"
                        ? "assets/images/MTN_Money.png"
                        : widget.selectedPayment == "Orange Money"
                            ? "assets/images/orange_money.png"
                            : "assets/images/carte_bancaire.png",
                    width: 24,
                  ),
                  const SizedBox(width: 10),
                  Text(widget.selectedPayment,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text("Sélectionnez ce numéro",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: "+225 ** *****76",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              enabled: !useNewNumber,
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: () {
                setState(() {
                  useNewNumber = !useNewNumber;
                });
              },
              child: const Row(
                children: [
                  Text("Payer via un autre numéro",
                      style: TextStyle(color: Colors.blue, fontSize: 14)),
                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blue),
                ],
              ),
            ),
            if (useNewNumber) ...[
              const SizedBox(height: 20),
              TextField(
                controller: debitNumberController,
                decoration: InputDecoration(
                  hintText: "Entrez le numéro à débiter",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: isLoading ? null : _handlePayment,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.green,
                  side: const BorderSide(color: Colors.green),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.green)
                    : const Text("Payer maintenant"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
