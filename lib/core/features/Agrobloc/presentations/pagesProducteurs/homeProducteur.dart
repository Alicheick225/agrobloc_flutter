import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/layout/navBarProducteur.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/producteurs/homes/AnnonceForm.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/producteurs/homes/prefinancementForm.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/producteurs/homes/annoncePage.dart';

void main() {
  runApp(const MaterialApp(home: HomeProducteur()));
}

class HomeProducteur extends StatefulWidget {
  const HomeProducteur({super.key});

  @override
  State<HomeProducteur> createState() => _HomeProducteurState();
}

class _HomeProducteurState extends State<HomeProducteur> {
  int _selectedIndex = 0;

  /// Liste des pages reliées à la navbar
  final List<Widget> pages = [
    const AnnonceAchatPage(),
    const Center(child: Text("Messages")),
    const AnnonceForm(),
    const Center(child: Text("Transactions")),
    const Center(child: Text("Profil")),
  ];

  /// Méthode de changement de page
  void _onNavBarTap(int index) {
    setState(() {
      if (index >= 0 && index < pages.length) {
        _selectedIndex = index;
      } else {
        debugPrint("⚠️ Index $index invalide !");
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    // Initialisation de ScreenUtil (nécessaire si pas déjà fait)
    ScreenUtil.init(
      context,
      designSize: const Size(375, 812), // Adapter à ta maquette
      minTextAdapt: true,
    );

    return Scaffold(

      // --- HEADER FIXE ---
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.h),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          elevation: 0,
          flexibleSpace: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Partie gauche
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: const Color(0xFF527E3F),
                        radius: 24.r,
                        child: Icon(Icons.eco, color: const Color.fromARGB(255, 255, 255, 255), size: 28.sp),
                      ),
                      SizedBox(width: 8.w),
                      RichText(
                        text: TextSpan(
                          text: 'Bonjour, ',
                          style: TextStyle(color: const Color(0xFF527E3F), fontSize: 12.sp),
                          children: [
                            TextSpan(
                              text: 'Kouassi Bernard',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Partie droite : icônes
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.search, color: const Color(0xFF527E3F), size: 28.sp),
                        onPressed: () {
                          // Action recherche
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.notifications_none, color: const Color(0xFF527E3F), size: 28.sp),
                        onPressed: () {
                          // Action notifications
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      // --- CONTENU DÉFILANT ---
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 16.h),

            // Exemple de carte solde
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Container(
                decoration: BoxDecoration(
                  color:  Color(0xFF527E3F), // Fond blanc
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Solde total', style: TextStyle(color: const Color.fromARGB(255, 255, 255, 255), fontSize: 14.sp)),
                        Icon(Icons.remove_red_eye, color: const Color.fromARGB(255, 255, 255, 255), size: 20.sp),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text('CFA --',
                        style: TextStyle(color: const Color.fromARGB(255, 255, 255, 255), fontSize: 24.sp, fontWeight: FontWeight.bold)),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Solde Disponible', style: TextStyle(color: const Color.fromARGB(255, 255, 255, 255), fontSize: 12.sp)),
                              Text('CFA 0.00',
                                  style: TextStyle(color: const Color.fromARGB(255, 255, 255, 255), fontSize: 14.sp, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        Container(width: 1.w, color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.3), height: 30.h),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Valeur du portefeuille', style: TextStyle(color: const Color.fromARGB(255, 255, 255, 255), fontSize: 12.sp)),
                              Text('CFA 0.00',
                                  style: TextStyle(color: const Color.fromARGB(255, 255, 255, 255), fontSize: 14.sp, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),


            SizedBox(height: 24.h),

            Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children: [
                _buildCard(
                  title: "Offre de vente",
                  description:
                      "Saisissez les détails de votre récolte pour mieux la valoriser",
                  buttonText: "Entamez une offre de vente",
                  icon: Icons.house_outlined,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AnnonceForm(),
                      ),
                    );
                  },
                ),
                SizedBox(height: 20.h),
                _buildCard(
                  title: "Demande de préfinancement",
                  description:
                      "Demandez un soutien pour vos cultures et bénéficiez d'un appui financier",
                  buttonText: "Faire une demande de préfinancement",
                  icon: Icons.phone_android_outlined,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PrefinancementForm(),
                      ),
                    );
                  },
                ),
                SizedBox(height: 20.h),
                _buildCard(
                  title: "Voir annonces",
                  description:
                      "Consultez les annonces disponibles et trouvez des opportunités",
                  buttonText: "Consulter les annonces",
                  icon: Icons.campaign_outlined,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AnnonceAchatPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          SizedBox(height: 30.h),
        ],
      ),
    ),
    );
  }

  /// Méthode de création de carte réutilisable
  Widget _buildCard({
    required String title,
    required String description,
    required String buttonText,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: const Color(0xFF527E3F),
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: onPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF527E3F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.r),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                  ),
                  child: Text(
                    buttonText,
                    style: TextStyle(fontSize: 14.sp, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Icon(
              icon,
              size: 50.sp,
              color: const Color(0xFF527E3F),
            ),
          )
        ],
      ),
    );
  }
            
}
