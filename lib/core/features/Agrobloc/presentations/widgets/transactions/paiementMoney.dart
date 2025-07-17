import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/transactions/debitComplet.dart';
import 'package:flutter/material.dart';

class MobileMoneyOrderPage extends StatefulWidget {
  final List<String> selectedPayments;

  const MobileMoneyOrderPage({super.key, required this.selectedPayments});

  @override
  State<MobileMoneyOrderPage> createState() => _MobileMoneyOrderPageState();
}

class _MobileMoneyOrderPageState extends State<MobileMoneyOrderPage> {
  final TextEditingController phoneController = TextEditingController(text: "+225 ** *****76");
  final TextEditingController debitNumberController = TextEditingController();
  late String selectedPayment;
  bool useNewNumber = false;

  @override
  void initState() {
    super.initState();
    selectedPayment = widget.selectedPayments.first;
  }

  @override
  void dispose() {
    phoneController.dispose();
    debitNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("12:30", style: TextStyle(color: Colors.black, fontSize: 16)),
            const SizedBox(width: 10),
            const Text("Mode de paiement", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Image.asset(
                    selectedPayment == "MTN Mobile Money"
                        ? "assets/images/MTN_Money.png"
                        : "assets/images/orange_money.png",
                    width: 24,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    selectedPayment,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Sélectionnez ce numéro",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: "+225 ** *****76",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                  Text(
                    "Payer via un autre numéro",
                    style: TextStyle(color: Colors.blue, fontSize: 14),
                  ),
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
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DebitCompletPage()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.green,
                  side: const BorderSide(color: Colors.green),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Suivant", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}