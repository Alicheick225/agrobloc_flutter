import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/producteurs/homes/AnnonceFrom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  runApp(const MaterialApp(home: HomePoducteur()));
}

class HomePoducteur extends StatefulWidget {
  const HomePoducteur({super.key});

  @override
  State<HomePoducteur> createState() => _HomeProducteurState();
}

class _HomeProducteurState extends State<HomePoducteur> {
  int _selectedIndex = 0;

  final List<Widget> pages = [
    const OffreDeVentePage(),
    const Center(child: Text("Messages")),
    const Center(child: Text("Transactions")),
    const Center(child: Text("Profil")),
  ];

  void _onNavBarTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
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

class BottomBarProducteur extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const BottomBarProducteur({
    Key? key,
    required this.selectedIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
      selectedItemColor: const Color(0xFF527E3F),
      unselectedItemColor: Colors.grey,
      onTap: onTap,
      items: [
        _buildNavItem(Icons.home_outlined, "Accueil", 0),
        _buildNavItem(Icons.message_outlined, "Messages", 1),
        _buildNavItem(Icons.sync_alt_outlined, "Transactions", 2),
        _buildNavItem(Icons.person_rounded, "Profil", 3),
      ],
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, String label, int index) {
    final bool isSelected = selectedIndex == index;

    return BottomNavigationBarItem(
      icon: Container(
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF527E3F) : Colors.transparent,
          borderRadius: BorderRadius.circular(15.r),
        ),
        padding: EdgeInsets.all(6.r),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.grey,
        ),
      ),
      label: label,
    );
  }
}

class OffreDeVentePage extends StatelessWidget {
  const OffreDeVentePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header vert
Container(
  width: double.infinity,
  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 40.h),
  decoration: BoxDecoration(
    color: const Color(0xFF527E3F),
    borderRadius: BorderRadius.only(
      bottomLeft: Radius.circular(40.r),
      bottomRight: Radius.circular(40.r),
    ),
  ),
  child: SafeArea(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.2),
              radius: 24.r,
              child: Icon(Icons.eco, color: Colors.white, size: 28.sp),
            ),
            SizedBox(width: 12.w),
            RichText(
              text: TextSpan(
                text: 'Bonjour, ',
                style: TextStyle(color: Colors.white, fontSize: 16.sp),
                children: [
                  TextSpan(
                    text: 'Mr Kouassi Bernard',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18.sp),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 20.h),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF9DB98B).withOpacity(0.4),
            borderRadius: BorderRadius.circular(30.r),
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: "Faire une recherche",
              prefixIcon: const Icon(Icons.search, color: Colors.white70),
              suffixIcon: const Icon(Icons.mic, color: Colors.white70),
              border: InputBorder.none,
              hintStyle: TextStyle(color: Colors.white70),
              contentPadding: EdgeInsets.symmetric(vertical: 12.h),
            ),
            style: const TextStyle(color: Colors.white),
            cursorColor: Colors.white,
          ),
        ),
      ],
    ),
  ),
),



          SizedBox(height: 16.h),

          SizedBox(height: 30.h),

          // Cartes blanches avec ombrage
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children: [
                _buildCard(
                  title: "Offre de vente",
                  description:
                      "Saisissez les détails de votre récolte pour mieux la valoriser",
                  buttonText: "entamez une offre de vente",
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
                      "Répondez à une demande pour vos produits et soyez récompensé pour votre contribution précieuse",
                  buttonText: "entamez une demande de prefinancement",
                  icon: Icons.phone_android_outlined,
                  onPressed: () {},
                ),
                SizedBox(height: 20.h),
                _buildCard(
                  title: "Voir annonces",
                  description:
                      "Répondez à une demande pour vos produits et soyez récompensé pour votre contribution précieuse",
                  buttonText: "Consulter les annonces",
                  icon: Icons.campaign_outlined,
                  onPressed: () {},
                ),
              ],
            ),
          ),

          SizedBox(height: 30.h),
        ],
      ),
    );
  }

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
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
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
