import 'package:flutter/material.dart';
import 'package:agrobloc/core/themes/app_colors.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/modificationprofil_service.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/modificationprofil_model.dart';

// Pages à décommenter quand elles existent
// import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/acheteurs/profils/options_speciales.dart';

class ModifierProfilPage extends StatefulWidget {
  const ModifierProfilPage({super.key});

  @override
  State<ModifierProfilPage> createState() => _ModifierProfilPageState();
}

class _ModifierProfilPageState extends State<ModifierProfilPage> {
  final ModifierProfilService _userService = ModifierProfilService();

  ModificationProfilModel? _currentUser;
  bool _isLoading = true;
  String _errorMessage = '';
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthenticationAndLoadData();
  }

  Future<void> _checkAuthenticationAndLoadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Vérifier d'abord l'authentification
      _isAuthenticated = await _userService.isAuthenticated();
      
      if (!_isAuthenticated) {
        setState(() {
          _errorMessage = 'Vous devez vous connecter pour accéder à vos informations.';
          _isLoading = false;
        });
        _redirectToLogin();
        return;
      }

      // Charger les données utilisateur
      await _loadUserData();
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur de connexion: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUserData() async {
    try {
      final response = await _userService.getProfilUtilisateur();

      if (response.success && response.user != null) {
        setState(() {
          _currentUser = response.user;
          _isLoading = false;
          _errorMessage = '';
        });
      } else {
        setState(() {
          _errorMessage = response.message ?? 'Erreur lors du chargement des données';
          _isLoading = false;
        });

        // Si l'erreur indique une session expirée, rediriger vers la connexion
        if (response.message?.contains('Session expirée') == true ||
            response.message?.contains('reconnecter') == true) {
          _redirectToLogin();
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur de connexion: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshUserData() async {
    await _checkAuthenticationAndLoadData();
  }

  void _redirectToLogin() {
    // Rediriger vers la page de connexion
    // Navigator.pushReplacementNamed(context, '/login');
    
    // Ou afficher un dialogue pour reconnecter
    _showLoginDialog();
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Session expirée'),
          content: const Text('Votre session a expiré. Veuillez vous reconnecter.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text('Se reconnecter'),
            ),
          ],
        );
      },
    );
  }

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
            onPressed: _refreshUserData,
          ),
        ),
      );
    }
  }

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

  void _naviguerVersCompteProducteur() {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => const CompteProducteurRentePage()),
    // );
    _showErrorSnackBar('Fonctionnalité en cours de développement');
  }

  void _naviguerVersVerificationProfil() {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => const VerificationProfilPage()),
    // );
    _showErrorSnackBar('Fonctionnalité en cours de développement');
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
          Icon(
            _isAuthenticated ? Icons.error_outline : Icons.lock_outline,
            size: 64,
            color: _isAuthenticated ? Colors.red : Colors.orange,
          ),
          const SizedBox(height: 16),
          Text(
            _isAuthenticated ? 'Erreur de chargement' : 'Authentification requise',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: _isAuthenticated ? Colors.red[50] : Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _isAuthenticated ? Colors.red[200]! : Colors.orange[200]!,
              ),
            ),
            child: Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _isAuthenticated ? Colors.red[700] : Colors.orange[700],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_isAuthenticated)
            ElevatedButton(
              onPressed: _refreshUserData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
              ),
              child: const Text('Réessayer'),
            )
          else
            ElevatedButton(
              onPressed: _redirectToLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Se connecter'),
            ),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    final user = _currentUser;
    if (user == null) return const SizedBox.shrink();

    return RefreshIndicator(
      onRefresh: _refreshUserData,
      color: AppColors.primaryGreen,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: user.hasProfilePhoto
                      ? NetworkImage(user.photoPlanteur!)
                      : const AssetImage("assets/images/profile_placeholder.png") as ImageProvider,
                ),
                const SizedBox(height: 12),
                Text(
                  user.displayName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.displayEmail,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

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

          _buildInfoRow("Nom complet", user.displayName, icon: Icons.person),
          _buildInfoRow("Adresse email", user.displayEmail, icon: Icons.email),
          _buildInfoRow("Téléphone", user.telephoneFormate, icon: Icons.phone),
          _buildInfoRow("Localisation", user.displayAdresse, icon: Icons.location_on),
          _buildInfoRow("Cultures", user.culturesFormatted, icon: Icons.agriculture),
          _buildInfoRow("Coopérative affiliée", user.displayCooperative, icon: Icons.business),

          const SizedBox(height: 32),

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

          Card(
            elevation: 2,
            child: ListTile(
              leading: const Icon(Icons.upgrade, color: Colors.green),
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
              leading: const Icon(Icons.verified_user, color: Colors.green),
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
      ),
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
          if (_isAuthenticated)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await _userService.logout();
                _redirectToLogin();
              },
              tooltip: 'Se déconnecter',
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