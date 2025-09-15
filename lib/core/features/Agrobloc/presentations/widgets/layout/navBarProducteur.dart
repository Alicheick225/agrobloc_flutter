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
    return SizedBox(
      height: 80.h, // Increased height to prevent overflow
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          BottomAppBar(
            shape: const CircularNotchedRectangle(),
            notchMargin: 10.0, // Increased notch margin
            child: Container(
              height: 70.h,
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(Icons.home_outlined, "Accueil", 0),
                  _buildNavItem(Icons.message_outlined, "Messages", 1),
                  SizedBox(width: 70.w), // Increased space for the floating button
                  _buildNavItem(Icons.sync_alt_outlined, "Transactions", 2),
                  _buildNavItem(Icons.person_rounded, "Profil", 3),
                ],
              ),
            ),
          ),

          // FloatingActionButton au centre, flottant au-dessus de la BottomNavigationBar
          Positioned(
            top: -20.h, // Adjusted positioning to reduce overflow
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 50.w,
                height: 50.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 10.r,
                      offset: Offset(0, 5.h),
                    ),
                  ],
                ),
                child: FloatingActionButton(
                  backgroundColor: const Color(0xFF5d9643),
                  elevation: 0, // Remove default elevation since we have custom shadow
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AnnonceForm(),
                      ),
                    );
                  },
                  child: Icon(Icons.add, size: 26.r, color: Colors.white), // Slightly larger plus icon
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isSelected = selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40.w,
              height: 30.h,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF527E3F) : Colors.transparent,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey,
                size: 28.r, // Increased size of other icons
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF527E3F) : Colors.grey,
                fontSize: 10.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
