import 'package:flutter/material.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/userService.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/authentificationModel.dart';
import 'package:agrobloc/core/themes/app_colors.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  AuthentificationModel? user;

  @override
  void initState() {
    super.initState();
    user = UserService().currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header with back button
              _buildHeader(),
              
              // Profile picture and basic info
              _buildProfileHeader(),
              
              // Profile details section
              _buildProfileDetails(),
              
              // Action buttons
              _buildActionButtons(),
              
              // Additional options
              _buildAdditionalOptions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Mon Profil",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                ),
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.grey),
            onPressed: () {
              // Navigate to settings page
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        children: [
          // Profile picture
          CircleAvatar(
            radius: 50,
            backgroundImage: const AssetImage('assets/images/avatar.jpg'),
            backgroundColor: Colors.grey[300],
            child: user?.nom.isEmpty ?? true
                ? const Icon(Icons.person, size: 50, color: Colors.white)
                : null,
          ),
          const SizedBox(height: 16),
          
          // User name
          Text(
            user?.nom ?? "Utilisateur",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          
          // User email
          if (user?.email != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                user!.email!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ),
          
          // User phone
          if (user?.numeroTel != null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                user!.numeroTel!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileDetails() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Informations du compte",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          
          // ID
          _buildDetailRow("ID", user?.id ?? "N/A"),
          
          // Profile ID
          _buildDetailRow("Profil ID", user?.profilId ?? "N/A"),
          
          // Wallet Address
          if (user?.walletAdress != null)
            _buildDetailRow("Adresse Wallet", user!.walletAdress!),
          
          // Profile Completion Status
          _buildDetailRow(
            "Profil complété", 
            (user?.isProfileCompleted ?? false) ? "Oui" : "Non"
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        children: [
          // Edit Profile Button
          ElevatedButton(
            onPressed: () {
              // Navigate to edit profile page
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Modifier le profil",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Change Password Button
          OutlinedButton(
            onPressed: () {
              // Navigate to change password page
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              side: BorderSide(color: AppColors.primaryGreen),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              "Changer le mot de passe",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalOptions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Options supplémentaires",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          
          // Notifications
          _buildOptionItem(
            icon: Icons.notifications,
            title: "Notifications",
            onTap: () {
              // Navigate to notifications settings
            },
          ),
          
          const Divider(height: 32),
          
          // Privacy Policy
          _buildOptionItem(
            icon: Icons.privacy_tip,
            title: "Politique de confidentialité",
            onTap: () {
              // Navigate to privacy policy
            },
          ),
          
          const Divider(height: 32),
          
          // Terms of Service
          _buildOptionItem(
            icon: Icons.description,
            title: "Conditions d'utilisation",
            onTap: () {
              // Navigate to terms of service
            },
          ),
          
          const Divider(height: 32),
          
          // Help & Support
          _buildOptionItem(
            icon: Icons.help,
            title: "Aide et support",
            onTap: () {
              // Navigate to help & support
            },
          ),
          
          const Divider(height: 32),
          
          // Logout
          _buildOptionItem(
            icon: Icons.logout,
            title: "Déconnexion",
            textColor: Colors.red,
            onTap: () {
              // Handle logout
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: textColor ?? AppColors.primaryGreen),
          const SizedBox(width: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: textColor ?? Colors.black,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const Spacer(),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}
