import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/producteurs/homes/AnnonceForm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BottomBarProducteur extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const BottomBarProducteur({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // BottomAppBar avec arrondi
        BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 8.0,
          child: SizedBox(
            height: 65.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home_outlined, "Accueil", 0),
                _buildNavItem(Icons.message, "Messages", 1),
                const SizedBox(width: 40), // espace pour le bouton flottant
                _buildNavItem(Icons.sync_alt_outlined, "Transactions", 3),
                _buildNavItem(Icons.person_rounded, "Profil", 4),
              ],
            ),
          ),
        ),

        // FloatingActionButton au centre
        Positioned(
          top: -10,
          left: 0,
          right: 0,
          child: Center(
            child: Transform.translate(
              offset: const Offset(0, 8),
              child: FloatingActionButton(
                backgroundColor: const Color(0xFF5d9643),
                elevation: 6,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AnnonceForm(),
                    ),
                  );
                },
                child: Icon(Icons.add, size: 32.r, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: EdgeInsets.all(6.r),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFe6f4ea) : Colors.transparent,
              shape: BoxShape.circle,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : [],
            ),
            child: Icon(
              icon,
              color: isSelected ? const Color(0xFF5d9643) : Colors.grey,
              size: 22.r,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? const Color(0xFF5d9643) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
