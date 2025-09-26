import 'package:flutter/material.dart';
import 'package:agrobloc/core/themes/app_colors.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/modificationprofil_service.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/modificationprofil_model.dart';

class ModifierProfilPage extends StatefulWidget {
  const ModifierProfilPage({super.key});

  @override
  State<ModifierProfilPage> createState() => _ModifierProfilPageState();
}

class _ModifierProfilPageState extends State<ModifierProfilPage> {
  final ModifierProfilService _userService = ModifierProfilService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _adresseController = TextEditingController();
  final TextEditingController _culturesController = TextEditingController();
  final TextEditingController _cooperativeController = TextEditingController();

  ModificationProfilModel? _currentUser;
  bool _isLoading = true;
  String _errorMessage = '';
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthenticationAndLoadData();
  }

  @override
  void dispose() {
    _nomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _adresseController.dispose();
    _culturesController.dispose();
    _cooperativeController.dispose();
    _userService.dispose();
    super.dispose();
  }

  Future<void> _checkAuthenticationAndLoadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      _isAuthenticated = await _userService.isAuthenticated();

      if (!_isAuthenticated) {
        setState(() {
          _errorMessage = 'Vous devez vous connecter pour accéder à vos informations.';
          _isLoading = false;
        });
        _redirectToLogin();
        return;
      }

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
        _currentUser = response.user;
        _nomController.text = _currentUser!.nom ?? '';
        _emailController.text = _currentUser!.email ?? '';
        _telephoneController.text = _currentUser!.numeroTel ?? '';
        _adresseController.text = _currentUser!.adresse ?? '';
        _culturesController.text = _currentUser!.cultures?.join(', ') ?? '';
        _cooperativeController.text = _currentUser!.cooperative ?? '';
        
        setState(() {
          _isLoading = false;
          _errorMessage = '';
        });
      } else {
        setState(() {
          _errorMessage = response.message ?? 'Erreur lors du chargement des données';
          _isLoading = false;
        });

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

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final Map<String, dynamic> updatedData = {
        "nom": _nomController.text.trim(),
        "email": _emailController.text.trim(),
        "telephone": _telephoneController.text.trim(),
        "adresse": _adresseController.text.trim(),
        "cultures": _culturesController.text.trim(),
        "cooperative": _cooperativeController.text.trim(),
      };

      try {
        final response = await _userService.modifierProfilUtilisateur(updatedData);

        if (response.success) {
          _showSuccessSnackBar('Profil mis à jour avec succès !');
          // Recharge les données après la sauvegarde
          await _loadUserData();
        } else {
          _showErrorSnackBar(response.message ?? 'Échec de la mise à jour du profil.');
        }
      } catch (e) {
        _showErrorSnackBar('Erreur lors de la mise à jour : $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _refreshUserData() async {
    await _checkAuthenticationAndLoadData();
  }

  void _redirectToLogin() {
    // Implémentez votre logique de redirection vers la page de connexion ici.
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
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

  Widget _buildTextField(
      String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.primaryGreen),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.primaryGreen),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.primaryGreen),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Ce champ ne peut pas être vide';
          }
          return null;
        },
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
          ElevatedButton(
            onPressed: _refreshUserData,
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

  Widget _buildUserInfoForm() {
    if (_currentUser == null) return const SizedBox.shrink();

    return RefreshIndicator(
      onRefresh: _refreshUserData,
      color: AppColors.primaryGreen,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Informations de base (non modifiables ici)
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: _currentUser!.hasProfilePhoto
                          ? NetworkImage(_currentUser!.photoPlanteur!)
                          : const AssetImage("assets/images/profile_placeholder.png") as ImageProvider,
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

              // Champs de formulaire pour la modification
              _buildTextField("Nom complet", _nomController),
              _buildTextField("Adresse email", _emailController, keyboardType: TextInputType.emailAddress),
              _buildTextField("Téléphone", _telephoneController, keyboardType: TextInputType.phone),
              _buildTextField("Adresse", _adresseController),
              _buildTextField("Cultures (séparées par des virgules)", _culturesController),
              _buildTextField("Coopérative affiliée", _cooperativeController),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _isLoading ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text("Enregistrer les modifications", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Modifier mes informations"),
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
              : _buildUserInfoForm(),
    );
  }
}