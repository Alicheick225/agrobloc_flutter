import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/producteurs/homes/AnnonceForm.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/producteurs/homes/prefinancementForm.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/producteurs/homes/annoncePage.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/producteurs/homes/offreVentePage.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/pagesProducteurs/transactionProducteur.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/layout/navBarProducteur.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/AnnonceAchat.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/AnnonceAchatModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// Importez le fichier MessagePage.dart
import 'package:agrobloc/core/features/Agrobloc/presentations/pagesProducteurs/MessagePage.dart';
// Importez la page de profil
import 'package:agrobloc/core/features/Agrobloc/presentations/pagesProducteurs/profilPage.dart';

void main() {
  runApp(const MaterialApp(home: HomeProducteur()));
}

class HomeProducteur extends StatefulWidget {
  const HomeProducteur({super.key});

  @override
  State<HomeProducteur> createState() => _HomeProducteurState();
}

class _HomeProducteurState extends State<HomeProducteur> {
  late int _selectedIndex;
  late List<Widget> pages;

  @override
  void initState() {
    super.initState();
    _selectedIndex = 0;
    // Mise à jour de la liste 'pages' avec les pages réelles
    pages = [
      const HomeProducteurContent(),
      MessagesListPage(currentUserId: "user123"),
      const TransactionProducteur(child: Text("Transactions")),
      const ProfilPage(),
    ];
  }

  void _onNavBarTap(int index) {
    // Si l'index est 2 (Transactions), naviguez vers une nouvelle page.
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const TransactionProducteur(child: Text("Transactions")),
        ),
      );
    } else {
      // Sinon, changez simplement l'index de la page affichée
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: pages[_selectedIndex],
          bottomNavigationBar: BottomBarProducteur(
            selectedIndex: _selectedIndex,
            onTap: _onNavBarTap,
          ),
        );
      },
    );
  }
}

class HomeProducteurContent extends StatefulWidget {
  const HomeProducteurContent({super.key});

  @override
  State<HomeProducteurContent> createState() => _HomeProducteurContentState();
}

class _HomeProducteurContentState extends State<HomeProducteurContent> {
  bool isLoading = false;
  List<AnnonceAchat> annonces = [];
  final AnnonceAchatService _annonceService = AnnonceAchatService();

  @override
  void initState() {
    super.initState();
    _loadLatestAnnonces();
  }

  @override
  void dispose() {
    // Cela empêche l'erreur "setState() called after dispose()"
    super.dispose();
  }

  Future<void> _loadLatestAnnonces() async {
    // Vérifier si le widget est monté avant de mettre à jour l'état
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final allAnnonces = await _annonceService.fetchAnnonces();
      allAnnonces.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final latestAnnonces = allAnnonces.take(3).toList();
      if (mounted) {
        setState(() {
          annonces = latestAnnonces;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des annonces: $e')),
      );
    }
  }

  String _formatDate(String dateString) {
    if (dateString.isEmpty) return '';

    try {
      final parts = dateString.split(' ');
      if (parts.isEmpty) return dateString;

      final dateParts = parts[0].split('-');
      if (dateParts.length != 3) return dateString;

      final year = int.tryParse(dateParts[0]) ?? 0;
      final month = int.tryParse(dateParts[1]) ?? 0;
      final day = int.tryParse(dateParts[2]) ?? 0;

      if (year == 0 || month == 0 || day == 0) return dateString;

      final date = DateTime(year, month, day);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = DateTime(now.year, now.month, now.day - 1);
      final dateOnly = DateTime(date.year, date.month, date.day);

      final difference = today.difference(dateOnly).inDays;

      if (dateOnly == today) {
        return 'Aujourd\'hui';
      } else if (dateOnly == yesterday) {
        return 'Hier';
      } else if (difference < 7) {
        return 'Il y a $difference ${difference == 1 ? 'jour' : 'jours'}';
      } else if (difference < 28) {
        final weeks = (difference / 7).floor();
        return 'Il y a $weeks ${weeks == 1 ? 'semaine' : 'semaines'}';
      } else {
        final monthNames = [
          'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
          'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
        ];
        return '$day ${monthNames[month - 1]} $year';
      }
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildHomeContent();
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 255, 255),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20.r),
                bottomRight: Radius.circular(20.r),
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 24.r,
                            child: Icon(Icons.eco, color: const Color(0xFF4CAF50), size: 28.sp),
                          ),
                          SizedBox(width: 12.w),
                          RichText(
                            text: TextSpan(
                              text: 'Bonjour, ',
                              style: TextStyle(color: const Color(0xFF4CAF50), fontSize: 14.sp),
                              children: [
                                TextSpan(
                                  text: 'Kouassi Bernard',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.sp,
                                    color: const Color(0xFF4CAF50),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.search, color: const Color(0xFF4CAF50), size: 28.sp),
                          SizedBox(width: 20.w),
                          Icon(Icons.notifications, color: const Color(0xFF4CAF50), size: 28.sp),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Container(
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Solde total',
                          style: TextStyle(color: Colors.white, fontSize: 14.sp),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'CFA 1 000 000',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Solde Disponible',
                                  style: TextStyle(color: Colors.white, fontSize: 14.sp),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'CFA 200 000',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.sp,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              height: 40.h,
                              width: 1.w,
                              color: Colors.white54,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Valeur du portefeuille',
                                  style: TextStyle(color: Colors.white, fontSize: 14.sp),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'CFA 50 000',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.sp,
                                  ),
                                ),
                              ],
                            ),
                            Icon(Icons.remove_red_eye, color: Colors.white, size: 24.sp),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const OffreVentePage(initialTabIndex: 1)));
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Color(0xFF4CAF50),
                            side: const BorderSide(color: Color.fromARGB(255, 255, 255, 255)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                          ),
                          child: Text(
                            "Mes demandes d'offre",
                            style: TextStyle(color: Colors.white, fontSize: 14.sp),
                          ),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const PrefinancementForm()));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: Color.fromARGB(255, 255, 255, 255)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                          ),
                          child: Text(
                            "+ Préfinancement",
                            style: TextStyle(color: const Color(0xFF4CAF50), fontSize: 14.sp),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16.h),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Dernières annonces d'achat", style: TextStyle(fontSize: 15.sp, color: const Color.fromARGB(255, 7, 7, 7))),
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const AnnonceAchatPage()));
                  },
                  child: Text("Voir tout", style: TextStyle(color: const Color(0xFF4CAF50))),
                ),
              ],
            ),
          ),

          if (isLoading)
            const CircularProgressIndicator()
          else
            ...annonces.map((annonce) => _buildAnnonceCard(annonce)).toList(),

          SizedBox(height: 30.h),
        ],
      ),
    );
  }

  Widget _buildAnnonceCard(AnnonceAchat annonce) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, '/detailOffreVente', arguments: annonce),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  annonce.typeCultureLibelle,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF4CAF50),
                  ),
                ),
                Text(
                  annonce.formattedPrice,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Quantité: ${annonce.formattedQuantity}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.favorite_border),
                  color: const Color(0xFF4CAF50),
                  onPressed: () {
                    // TODO: Implement favorite functionality
                  },
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Text(
              ' ${_formatDate(annonce.createdAt)}',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}