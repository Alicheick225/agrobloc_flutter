import 'package:flutter/material.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/AnnonceAchatModel.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DetailOffreVente extends StatelessWidget {
  final AnnonceAchat annonce;

  DetailOffreVente({Key? key, required this.annonce}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
      context,
      designSize: const Size(375, 812),
      minTextAdapt: true,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de l\'offre'),
        backgroundColor: const Color(0xFF4CAF50),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 30.r,
              backgroundColor: const Color(0xFF4CAF50),
              child: Text(
                annonce.userNom.isNotEmpty ? annonce.userNom[0].toUpperCase() : '?',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              annonce.userNom.isNotEmpty ? annonce.userNom : 'Nom de l\'utilisateur',
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: const Color(0xFF4CAF50)),
            ),
            SizedBox(height: 12.h),
            Text('Culture: ${annonce.typeCultureLibelle}', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Quantité: ${annonce.formattedQuantity}', style: TextStyle(fontSize: 16.sp)),
            const SizedBox(height: 8),
            Text('Prix / kg: ${annonce.formattedPrice}', style: TextStyle(fontSize: 16.sp)),
            const SizedBox(height: 8),
            // Text(
            //   '// Statut: ${annonce.statut}',
            //   style: TextStyle(
            //     fontSize: 14.sp,
            //     color: Colors.grey[600],
            //     fontStyle: FontStyle.italic,
            //     fontFamily: 'monospace',
            //   ),
            // ),
            // SizedBox(height: 8.h),
            // Text(
            //   '// Date: ${annonce.createdAt}',
            //   style: TextStyle(
            //     fontSize: 12.sp,
            //     color: Colors.grey[500],
            //     fontStyle: FontStyle.italic,
            //     fontFamily: 'monospace',
            //   ),
            // ),
            const SizedBox(height: 16),
            Text('Description:', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(annonce.description.isNotEmpty ? annonce.description : 'Pas de description', style: TextStyle(fontSize: 14.sp)),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        color: Colors.white,
        child: OutlinedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  content: Text('Votre candidature a été enregistrée avec succès'),
                  actions: <Widget>[
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.green,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );
          },
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFF4CAF50)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: Text(
            'Candidatez à l\'achat',
            style: TextStyle(
              color: const Color(0xFF4CAF50),
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
