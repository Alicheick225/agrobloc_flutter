// lib/core/features/Agrobloc/presentations/widgets/acheteurs/profils/evaluationVentePage.dart

import 'package:flutter/material.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/avisVenteModel.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/avisVenteService.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/userService.dart';
import 'package:agrobloc/core/themes/app_colors.dart';

class EvaluationVentePage extends StatefulWidget {
  final String annoncesVenteId;
  final String? produitNom;
  final String? produitPhoto;
  final String? userToken;
  final String? userName;

  const EvaluationVentePage({
    super.key,
    required this.annoncesVenteId,
    this.produitNom,
    this.produitPhoto,
    this.userToken,
    this.userName,
  });

  @override
  _EvaluationVentePageState createState() => _EvaluationVentePageState();
}

class _EvaluationVentePageState extends State<EvaluationVentePage> {
  final TextEditingController _noteurController = TextEditingController();
  final TextEditingController _titreController = TextEditingController();
  final TextEditingController _commentaireController = TextEditingController();

  int _rating = 0;
  bool _isSubmitting = false;
  bool _isLoading = true;

  final UserService _userService = UserService();
  final AvisVenteService _avisVenteService = AvisVenteService();

  @override
  void initState() {
    super.initState();
    _initializeUserData();
  }

  Future<void> _initializeUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.userName != null && widget.userName!.isNotEmpty) {
        _noteurController.text = widget.userName!;
      } else {
        // Appeler loadUser() pour s'assurer que l'utilisateur est bien chargé
        await _userService.loadUser(); 
        
        // Vérifier si l'utilisateur a été chargé avec succès
        if (_userService.isLoggedIn && _userService.currentUser != null) {
          _noteurController.text = _userService.currentUser!.nom; // Utilisez la propriété nom
        } else {
          _noteurController.text = "";
        }
      }
    } catch (e) {
      if (widget.userName != null && widget.userName!.isNotEmpty) {
        _noteurController.text = widget.userName!;
      } else {
        _noteurController.text = "";
      }
      print("Erreur lors de la récupération des données utilisateur: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _noteurController.dispose();
    _titreController.dispose();
    _commentaireController.dispose();
    super.dispose();
  }

  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _rating = index + 1;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              Icons.star,
              size: 40,
              color: index < _rating ? AppColors.primaryGreen : Colors.grey[300],
            ),
          ),
        );
      }),
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 5:
        return "j'adore";
      case 4:
        return "très bien";
      case 3:
        return "bien";
      case 2:
        return "moyen";
      case 1:
        return "décevant";
      default:
        return "";
    }
  }

  Future<void> _submitEvaluation() async {
    if (_rating == 0) {
      _showSnackBar("Veuillez sélectionner une note", isError: true);
      return;
    }
    if (_titreController.text.trim().isEmpty) {
      _showSnackBar("Veuillez ajouter un titre à votre commentaire", isError: true);
      return;
    }
    if (_noteurController.text.trim().isEmpty) {
      _showSnackBar("Veuillez saisir votre nom", isError: true);
      return;
    }
    if (widget.userToken == null || widget.userToken!.isEmpty) {
      _showSnackBar("Erreur d'authentification. Veuillez vous reconnecter.", isError: true);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final request = CreateAvisVenteRequest(
        note: _rating.toDouble(),
        titre: _titreController.text.trim(),
        commentaire: _commentaireController.text.trim().isEmpty
            ? null
            : _commentaireController.text.trim(),
        annoncesVenteId: widget.annoncesVenteId,
      );

      final response = await _avisVenteService.createAvisVente(
        request: request,
        token: widget.userToken!,
      );

      _showSnackBar("Évaluation envoyée avec succès !", isError: false);

      if (mounted) {
        Navigator.pop(context, response);
      }
    } catch (e) {
      String errorMessage = "Erreur lors de l'envoi de l'évaluation";

      if (e.toString().contains('Pas de connexion internet')) {
        errorMessage = "Pas de connexion internet. Vérifiez votre connexion.";
      } else if (e.toString().contains('Token d\'authentification invalide')) {
        errorMessage = "Session expirée. Veuillez vous reconnecter.";
      } else if (e.toString().contains('Données invalides')) {
        errorMessage = "Données invalides. Vérifiez vos informations.";
      } else if (e.toString().contains('Délai d\'attente dépassé')) {
        errorMessage = "Délai d'attente dépassé. Réessayez plus tard.";
      } else if (e.toString().contains('Vous avez déjà évalué')) {
        errorMessage = "Vous avez déjà évalué cette annonce.";
      }

      _showSnackBar(errorMessage, isError: true);
      print("Erreur détaillée: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : AppColors.primaryGreen,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          title: const Text(
            "Évaluer le produit",
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          "Évaluer le produit",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nom du noteur
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: "Nom du noteur",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextSpan(
                          text: " *",
                          style: TextStyle(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _noteurController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Votre nom",
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Section évaluation avec étoiles
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                children: [
                  const Text(
                    "Sélectionnez les étoiles pour évaluer le produit",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Image et nom du produit
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[200],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: widget.produitPhoto != null && widget.produitPhoto!.isNotEmpty
                              ? Image.network(
                                  widget.produitPhoto!,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      color: AppColors.primaryGreen.withOpacity(0.1),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress.expectedTotalBytes != null
                                              ? loadingProgress.cumulativeBytesLoaded /
                                                  loadingProgress.expectedTotalBytes!
                                              : null,
                                          strokeWidth: 2,
                                          valueColor: const AlwaysStoppedAnimation<Color>(
                                            AppColors.primaryGreen,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: AppColors.primaryGreen.withOpacity(0.1),
                                      child: const Icon(
                                        Icons.agriculture,
                                        color: AppColors.primaryGreen,
                                        size: 24,
                                      ),
                                    );
                                  },
                                )
                              : Container(
                                  color: AppColors.primaryGreen.withOpacity(0.1),
                                  child: const Icon(
                                    Icons.agriculture,
                                    color: AppColors.primaryGreen,
                                    size: 24,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.produitNom ?? "Produit",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Étoiles de notation
                  _buildStarRating(),

                  const SizedBox(height: 12),

                  if (_rating > 0)
                    Text(
                      _getRatingText(_rating),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Titre du commentaire
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: "Titre du commentaire",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextSpan(
                          text: " *",
                          style: TextStyle(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _titreController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "un produit de qualité / une texture médiocre",
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Commentaire détaillé
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Commentaire détaillé",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _commentaireController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Dites-nous plus sur le produit...",
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Bouton "Laisser un avis"
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitEvaluation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        "Laisser un avis",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}