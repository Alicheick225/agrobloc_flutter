import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/producteurs/homes/AnnonceForm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BottomBarProducteur extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const BottomBarProducteur({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  State<BottomBarProducteur> createState() => _BottomBarProducteurState();
}

class _BottomBarProducteurState extends State<BottomBarProducteur> {

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Container(
        height: 70.h, // Adjusted height to prevent overflow
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildNavItem(Icons.home_outlined, "Accueil", 0),
            _buildNavItem(Icons.message_outlined, "Messages", 1),
            _buildVenteItem(),
            _buildNavItem(Icons.sync_alt_outlined, "Transactions", 2),
            _buildNavItem(Icons.person_rounded, "Profil", 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isSelected = widget.selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => widget.onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF527E3F) : Colors.grey,
              size: 22.r, // Slightly smaller to fit better
            ),
            SizedBox(height: 2.h), // Reduced spacing to prevent overflow
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF527E3F) : Colors.grey,
                fontSize: 8.sp, // Smaller font to fit
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

  Widget _buildVenteItem() {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DynamicAnnonceForm(),
            ),
          );
        },
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 28.r,
              height: 28.r,
              decoration: BoxDecoration(
                color: const Color(0xFF5d9643),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add,
                color: Colors.white,
                size: 16.r,
              ),
            ),
            SizedBox(height: 2.h), // Reduced spacing to prevent overflow
            Text(
              "Vente",
              style: TextStyle(
                color: const Color(0xFF5d9643),
                fontSize: 8.sp, // Consistent with other items
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
