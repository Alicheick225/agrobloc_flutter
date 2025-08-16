import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
