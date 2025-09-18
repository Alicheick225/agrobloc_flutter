import 'package:flutter/material.dart';
import 'package:agrobloc/core/themes/app_colors.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/profil_service.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/profil_model.dart';

class InformationsProfilPage extends StatefulWidget {
  const InformationsProfilPage({super.key});

  @override
  State<InformationsProfilPage> createState() => _InformationsProfilPageState();
}

class _InformationsProfilPageState extends State<InformationsProfilPage> {
  final ProfilService _userService = ProfilService();
  
  // Variables pour stocker les données utilisateur
  MesInformationsModel? _currentUser;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// Charge les données utilisateur depuis l'API
  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final String userId = 'your_user_id_here'; // Define userId with the actual user ID
      final response = await _userService.getProfilUtilisateur(userId);
      
      if (response.success && response.user != null) {
        setState(() {
          _currentUser = response.user;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.message ?? 'Erreur lors du chargement des données';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur de connexion: $e';
        _isLoading = false;
      });
    }
  }

  /// Actualise les données
  Future<void> _refreshUserData() async {
    await _loadUserData();
  }

  /// Affiche une erreur
  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Réessayer',
            textColor: Colors.white,
            onPressed: _loadUserData,
          ),
        ),
      );
    }
  }

  /// Affiche un succès
  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Navigue vers la page de changement vers compte producteur de rente
  void _naviguerVersCompteProducteur() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CompteProducteurRentePage(),
      ),
    );
  }

  /// Navigue vers la page de vérification de profil
  void _naviguerVersVerificationProfil() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const VerificationProfilPage(),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {IconData? icon}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 1,
      child: ListTile(
        leading: icon != null ? Icon(icon, color: AppColors.primaryGreen) : null,
        title: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontSize: 14,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primaryGreen),
          SizedBox(height: 16),
          Text(
            'Chargement de vos informations...',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'Erreur de chargement',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red[700]),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadUserData,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    if (_currentUser == null) return const SizedBox.shrink();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Photo de profil
        Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: _currentUser!.hasProfilePhoto
                    ? NetworkImage(_currentUser!.photoPlanteur!)
                    : const AssetImage("assets/images/profile_placeholder.png") as ImageProvider,
                onBackgroundImageError: _currentUser!.hasProfilePhoto
                    ? (exception, stackTrace) {
                        // En cas d'erreur de chargement, on garde l'image par défaut
                      }
                    : null,
              ),
              const SizedBox(height: 12),
              Text(
                _currentUser!.displayName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _currentUser!.displayEmail,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Section Informations personnelles
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Informations personnelles',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Ces informations sont utilisées pour votre identification sur la plateforme.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Infos utilisateur depuis l'API
        _buildInfoRow("Nom complet", _currentUser!.displayName, icon: Icons.person),
        _buildInfoRow("Adresse email", _currentUser!.displayEmail, icon: Icons.email),
        _buildInfoRow("Téléphone", _currentUser!.telephoneFormate, icon: Icons.phone),
        _buildInfoRow("Localisation", _currentUser!.displayAdresse, icon: Icons.location_on),
        _buildInfoRow("Cultures", _currentUser!.culturesFormatted, icon: Icons.agriculture),
        _buildInfoRow("Coopérative affiliée", _currentUser!.displayCooperative, icon: Icons.business),

        const SizedBox(height: 32),

        // Section Options spéciales
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green[200]!),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Options spéciales',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Améliorez votre expérience sur la plateforme',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Actions spéciales
        Card(
          elevation: 2,
          child: ListTile(
            leading: const Icon(
              Icons.upgrade,
              color: Colors.green,
            ),
            title: const Text(
              "Passer à un compte producteur de rente",
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: const Text(
              "Accédez à des fonctionnalités avancées",
              style: TextStyle(fontSize: 12),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: _naviguerVersCompteProducteur,
          ),
        ),

        const SizedBox(height: 8),

        Card(
          elevation: 2,
          child: ListTile(
            leading: const Icon(
              Icons.verified_user,
              color: Colors.green,
            ),
            title: const Text(
              "Montrer que mon profil est vérifié",
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: const Text(
              "Augmentez la confiance des acheteurs",
              style: TextStyle(fontSize: 12),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: _naviguerVersVerificationProfil,
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes informations"),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshUserData,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _errorMessage.isNotEmpty
              ? _buildErrorState()
              : _buildUserInfo(),
    );
  }

  @override
  void dispose() {
    _userService.dispose();
    super.dispose();
  }
}

// ==========================================
// PAGES DES OPTIONS SPÉCIALES
// ==========================================

class CompteProducteurRentePage extends StatelessWidget {
  const CompteProducteurRentePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Compte Producteur de Rente"),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green[400]!, Colors.green[600]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.upgrade, size: 40, color: Colors.white),
                  SizedBox(height: 12),
                  Text(
                    'Compte Producteur de Rente',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Maximisez vos revenus avec des fonctionnalités premium',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Avantages
            const Text(
              'Avantages inclus :',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _buildAdvantageItem(
              Icons.trending_up,
              'Analyse de marché avancée',
              'Suivez les tendances et optimisez vos prix',
            ),
            _buildAdvantageItem(
              Icons.priority_high,
              'Mise en avant prioritaire',
              'Vos produits apparaissent en premier',
            ),
            _buildAdvantageItem(
              Icons.analytics,
              'Rapports détaillés',
              'Statistiques complètes de vos ventes',
            ),
            _buildAdvantageItem(
              Icons.support_agent,
              'Support premium',
              'Assistance prioritaire 7j/7',
            ),

            const Spacer(),

            // Bouton d'action
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implémenter la logique de mise à niveau
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fonction de mise à niveau à implémenter'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Passer au compte producteur de rente',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvantageItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.green[600], size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class VerificationProfilPage extends StatelessWidget {
  const VerificationProfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vérification du Profil"),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[400]!, Colors.blue[600]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.verified_user, size: 40, color: Colors.white),
                  SizedBox(height: 12),
                  Text(
                    'Vérification du Profil',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Gagnez la confiance de vos acheteurs',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Étapes de vérification
            const Text(
              'Étapes de vérification :',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _buildVerificationStep(
              1,
              'Vérification d\'identité',
              'Téléchargez une pièce d\'identité valide',
              Icons.badge,
              false,
            ),
            _buildVerificationStep(
              2,
              'Vérification d\'activité',
              'Prouvez votre activité de producteur',
              Icons.agriculture,
              false,
            ),
            _buildVerificationStep(
              3,
              'Vérification d\'adresse',
              'Confirmez votre adresse de production',
              Icons.location_on,
              false,
            ),
            _buildVerificationStep(
              4,
              'Validation finale',
              'Notre équipe valide votre dossier',
              Icons.check_circle,
              false,
            ),

            const SizedBox(height: 24),

            // Avantages de la vérification
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Avantages de la vérification :',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildBenefitItem('Badge de confiance visible'),
                  _buildBenefitItem('Priorité dans les recherches'),
                  _buildBenefitItem('Accès à des acheteurs premium'),
                  _buildBenefitItem('Meilleure visibilité'),
                ],
              ),
            ),

            const Spacer(),

            // Bouton d'action
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implémenter le processus de vérification
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Processus de vérification à implémenter'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Commencer la vérification',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationStep(
    int stepNumber,
    String title,
    String description,
    IconData icon,
    bool isCompleted,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCompleted ? Colors.green[100] : Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isCompleted ? Colors.green : Colors.grey[300]!,
                width: 2,
              ),
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.green, size: 20)
                  : Text(
                      stepNumber.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isCompleted ? Colors.green : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Icon(
            icon,
            color: isCompleted ? Colors.green : Colors.grey[400],
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(String benefit) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.blue[600], size: 16),
          const SizedBox(width: 8),
          Text(
            benefit,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
    }