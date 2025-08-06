import 'package:flutter/material.dart';

class AnnonceAchatPage extends StatelessWidget {
  const AnnonceAchatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Annonce Achat'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Page Annonce Achat',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement navigation or functionality
              },
              child: const Text('Créer une annonce'),
            ),
          ],
        ),
      ),
    );
  }
}
