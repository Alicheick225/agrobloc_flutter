import 'package:flutter/material.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/AnnonceAchatModel.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/AnnonceVenteModel.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DetailOffreVente extends StatelessWidget {
  final dynamic annonce;

  DetailOffreVente({Key? key, required this.annonce}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
      context,
      designSize: const Size(375, 812),
      minTextAdapt: true,
    );

    // Determine the type of annonce
    bool isAnnonceAchat = annonce is AnnonceAchat;
    bool isAnnonceVente = annonce is AnnonceVente;

    String userNom = '';
    String typeCultureLibelle = '';
    String formattedQuantity = '';
    String formattedPrice = '';
    String description = '';
    String statut = '';

    if (isAnnonceAchat) {
      AnnonceAchat a = annonce as AnnonceAchat;
      userNom = a.userNom;
      typeCultureLibelle = a.typeCultureLibelle;
      formattedQuantity = a.formattedQuantity;
      formattedPrice = '${a.prix} FCFA';
      description = a.description;
      statut = a.statut;
    } else if (isAnnonceVente) {
      AnnonceVente a = annonce as AnnonceVente;
      userNom = a.userNom;
      typeCultureLibelle = a.typeCultureLibelle;
      formattedQuantity = '${a.quantite} ${a.quantiteUnite}';
      formattedPrice = '${a.prixKg} ${a.prixUnite}';
      description = a.description;
      statut = a.statut;
    }

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
                userNom.isNotEmpty ? userNom[0].toUpperCase() : '?',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              userNom.isNotEmpty ? userNom : 'Nom de l\'utilisateur',
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: const Color(0xFF4CAF50)),
            ),
            SizedBox(height: 12.h),
            Text('Culture: $typeCultureLibelle', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Quantité: $formattedQuantity', style: TextStyle(fontSize: 16.sp)),
            const SizedBox(height: 8),
            Text('Prix / kg: $formattedPrice', style: TextStyle(fontSize: 16.sp)),
            const SizedBox(height: 8),
            Text('Statut: $statut', style: TextStyle(fontSize: 14.sp, color: Colors.grey[600])),
            const SizedBox(height: 16),
            Text('Description:', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(description.isNotEmpty ? description : 'Pas de description', style: TextStyle(fontSize: 14.sp)),
          ],
        ),
      ),
      bottomNavigationBar: isAnnonceAchat ? Container(
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
      ) : null,
    );
  }
}
