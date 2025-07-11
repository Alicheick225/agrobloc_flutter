import 'package:agrobloc/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primaryGreen,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      items: [
        _buildItem(Icons.home_rounded, "Accueil", 0),
        _buildItem(Icons.campaign_rounded, "Annonces", 1),
        _buildItem(Icons.sync_alt_rounded, "Transactions", 2),
        _buildItem(Icons.person_rounded, "Profil", 3),
      ],
    );
  }

  BottomNavigationBarItem _buildItem(IconData icon, String label, int index) {
    bool isSelected = index == currentIndex;
    return BottomNavigationBarItem(
      label: label,
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreen.withOpacity(0.1) : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isSelected ? AppColors.primaryGreen : Colors.grey,
        ),
      ),
    );
  }
}
