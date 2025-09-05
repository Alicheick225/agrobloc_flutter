import 'package:agrobloc/core/features/Agrobloc/data/dataSources/AnnonceAchat.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/userService.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/AnnonceAchatModel.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/pagesAcheteurs/transactionPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/layout/navBarProducteur.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/producteurs/homes/AnnonceForm.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/producteurs/homes/prefinancementForm.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/producteurs/homes/annoncePage.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/producteurs/homes/detailOffreVente.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/producteurs/homes/offreVentePage.dart';

void main() {
  runApp(MaterialApp(
    home: const HomeProducteur(),
    routes: {
      '/detailOffreVente': (context) {
        final args = ModalRoute.of(context)!.settings.arguments as AnnonceAchat;
        return DetailOffreVente(annonce: args);
      },
    },
  ));
}

class HomeProducteur extends StatefulWidget {
  const HomeProducteur({super.key});

  @override
  State<HomeProducteur> createState() => _HomeProducteurState();
}

class _HomeProducteurState extends State<HomeProducteur> {
  int _selectedIndex = 0;
  List<AnnonceAchat> annonces = [];
  bool isLoading = true;
  final UserService _userService = UserService();
  final AnnonceAchatService _annonceAchatService = AnnonceAchatService();

  /// Format date string to relative date like "Il y a 4 jours"
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
        // Format complet: "11 Août 2025"
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

  /// Liste des pages reliées à la navbar
  final List<Widget> pages = [
    const HomeProducteur(),
    const Center(child: Text("Messages")),
    const AnnonceForm(),
    const TransactionPage(child: Text("Transactions")),
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
  void initState() {
    super.initState();
    _loadAnnonces();
  }

  Future<void> _loadAnnonces() async {
    try {
      // Vérifier d'abord si l'utilisateur est authentifié
      final isAuthenticated = await _userService.isUserAuthenticated();
      
      if (!isAuthenticated) {
        debugPrint("⚠️ Utilisateur non authentifié - redirection vers la connexion");
        setState(() => isLoading = false);
        
        // Rediriger vers la page de connexion après un court délai
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/login');
          }
        });
        return;
      }

      // Charger l'utilisateur depuis le service
      final userLoaded = await _userService.loadUser();
      if (userLoaded) {
        final user = _userService.currentUser;
        debugPrint("✅ Utilisateur chargé: ${user?.nom}");
      } else {
        debugPrint("⚠️ Échec du chargement de l'utilisateur");
        setState(() => isLoading = false);
        return;
      }
      
      // Récupérer les annonces seulement si l'utilisateur est authentifié
      final data = await _annonceAchatService.fetchAnnonces();
      setState(() {
        annonces = data.take(3).toList(); // On limite à 3 annonces
        isLoading = false;
      });
    } catch (e) {
      debugPrint("❌ Erreur lors du chargement des annonces : $e");
      setState(() => isLoading = false);
      
      // Afficher un message d'erreur à l'utilisateur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de chargement: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
      context,
      designSize: const Size(375, 812),
      minTextAdapt: true,
    );

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.h),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
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
                        backgroundColor: const Color(0xFF4CAF50),
                        radius: 24.r,
                        child: Icon(Icons.eco, color: Colors.white, size: 28.sp),
                      ),
                      SizedBox(width: 8.w),
                      RichText(
                        text: TextSpan(
                          text: 'Bonjour, ',
                          style: TextStyle(color: const Color(0xFF4CAF50), fontSize: 12.sp),
                          children: [
                            TextSpan(
                              text: 'Kouassi Bernard',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Partie droite
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.search, color: const Color(0xFF4CAF50), size: 28.sp),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Icon(Icons.notifications_none, color: const Color(0xFF4CAF50), size: 28.sp),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      bottomNavigationBar: BottomBarProducteur(
        selectedIndex: _selectedIndex,
        onTap: _onNavBarTap,
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 16.h),

            // --- Carte solde ---
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('Solde total', style: TextStyle(color: Colors.white, fontSize: 14.sp)),
                      Icon(Icons.remove_red_eye, color: Colors.white, size: 20.sp),
                    ]),
                    SizedBox(height: 8.h),
                    Text('CFA 1 000 000', style: TextStyle(color: Colors.white, fontSize: 24.sp, fontWeight: FontWeight.bold)),
                    SizedBox(height: 16.h),
                    Row(children: [
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Solde Disponible', style: TextStyle(color: Colors.white, fontSize: 12.sp)),
                          Text('CFA 200 000', style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold)),
                        ]),
                      ),
                      Container(width: 1.w, color: Colors.white.withOpacity(0.3), height: 30.h),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Valeur du portefeuille', style: TextStyle(color: Colors.white, fontSize: 12.sp)),
                          Text('CFA 50 000', style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold)),
                        ]),
                      ),
                    ])
                  ],
                ),
              ),
            ),

            SizedBox(height: 24.h),

            // --- Boutons rapides ---
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const OffreVentePage(initialTabIndex: 1)));
                      },
                      label: Text("Mes demandes d'offre", style: TextStyle(color: const Color(0xFF4CAF50), fontSize: 14.sp)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          side: const BorderSide(color: Color(0xFF4CAF50), width: 1),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const PrefinancementForm()));
                      },
                      icon: Icon(Icons.add, color: Colors.white, size: 20.sp),
                      label: Text("Préfinancement", style: TextStyle(color: Colors.white, fontSize: 14.sp)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // --- Dernières annonces ---
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Dernières annonces d'achat", style: TextStyle(fontSize: 15.sp,  color: const Color.fromARGB(255, 7, 7, 7))),
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
      ),
    );
  }

  /// --- Carte annonce réutilisée ---
  Widget _buildAnnonceCard(AnnonceAchat annonce) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/detailOffreVente', arguments: annonce);
        },
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6.r, offset: Offset(0, 3.h))],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(text: annonce.typeCultureLibelle, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: const Color(0xFF4CAF50))),
                            ],
                          ),
                        ),
                        Spacer(),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(text: annonce.formattedQuantity, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 7, 7, 7))),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // Date and favorite icon on the same line
                    Row(
                      children: [
                        Text(
                          _formatDate(annonce.createdAt),
                          style: TextStyle(color: Colors.grey[600], fontSize: 12.sp),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(
                            Icons.favorite_border,
                            color: Color(0xFF4CAF50),
                            size: 20,
                          ),
                          onPressed: () {
                            // TODO: Implement favorite functionality
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              
            ],
          ),
        ),
      ),
    );
  }
}
