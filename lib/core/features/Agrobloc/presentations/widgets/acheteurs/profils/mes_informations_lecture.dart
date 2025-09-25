import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agrobloc/core/themes/app_colors.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/profil_service.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/profil_model.dart';

class MesInformationsLecture extends StatefulWidget {
  const MesInformationsLecture({super.key});

  @override
  State<MesInformationsLecture> createState() => _MesInformationsLectureState();
}

class _MesInformationsLectureState extends State<MesInformationsLecture> {
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

  /// Récupère l'ID de l'utilisateur connecté
  Future<String?> _getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('userId');
    } catch (e) {
      return null;
    }
  }

  /// Charge les données utilisateur depuis l'API
  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final userId = await _getUserId();
      
      if (userId == null || userId.isEmpty) {
        setState(() {
          _errorMessage = 'Utilisateur non identifié. Veuillez vous reconnecter.';
          _isLoading = false;
        });
        return;
      }

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

  Widget _buildInfoRowReadOnly(String label, String value, {IconData? icon}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 1,
      color: Colors.grey[50], // Couleur grisée pour indiquer lecture seule
      child: ListTile(
        enabled: false, // Désactive l'interaction
        leading: icon != null ? Icon(icon, color: Colors.grey[400]) : null,
        title: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey, // Texte grisé
            fontSize: 14,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.grey, // Valeur grisée
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

  Widget _buildUserInfoReadOnly() {
    if (_currentUser == null) return const SizedBox.shrink();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Photo de profil (désactivée)
        Center(
          child: Column(
            children: [
              Stack(
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
                  // Overlay gris pour indiquer que la photo n'est pas modifiable
                  Positioned.fill(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey.withOpacity(0.3),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                _currentUser!.displayName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey, // Texte grisé
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
            color: Colors.grey[100], // Fond grisé
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Informations personnelles',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey, // Texte grisé
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Ces informations sont en lecture seule. Utilisez "Modifier mon profil" pour les changer.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Infos utilisateur depuis l'API (en lecture seule)
        _buildInfoRowReadOnly("Nom complet", _currentUser!.displayName, icon: Icons.person),
        _buildInfoRowReadOnly("Adresse email", _currentUser!.displayEmail, icon: Icons.email),
        _buildInfoRowReadOnly("Téléphone", _currentUser!.telephoneFormate, icon: Icons.phone),
        _buildInfoRowReadOnly("Localisation", _currentUser!.displayAdresse, icon: Icons.location_on),
        _buildInfoRowReadOnly("Cultures", _currentUser!.culturesFormatted, icon: Icons.agriculture),
        _buildInfoRowReadOnly("Coopérative affiliée", _currentUser!.displayCooperative, icon: Icons.business),

        const SizedBox(height: 32),

        // Note explicative au lieu des options spéciales
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline,
                size: 40,
                color: Colors.blue[600],
              ),
              const SizedBox(height: 12),
              const Text(
                'Mode consultation',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Vous consultez vos informations en mode lecture seule.\nPour modifier ces données, utilisez le bouton "Modifier mon profil" depuis la page principale.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
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
              : _buildUserInfoReadOnly(),
    );
  }

  @override
  void dispose() {
    _userService.dispose();
    super.dispose();
  }
}