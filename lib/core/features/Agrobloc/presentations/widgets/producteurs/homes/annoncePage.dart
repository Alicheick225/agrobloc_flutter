import 'package:flutter/material.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/AnnonceAchat.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/userService.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/AnnonceAchatModel.dart';
import 'package:agrobloc/core/themes/app_colors.dart';
import 'package:agrobloc/core/themes/app_text_styles.dart';

class AnnonceAchatPage extends StatefulWidget {
  const AnnonceAchatPage({super.key});

  @override
  State<AnnonceAchatPage> createState() => _AnnonceAchatPageState();
}

class _AnnonceAchatPageState extends State<AnnonceAchatPage> {
  int _selectedButtonIndex = -1; // Track which button is selected

  final AnnonceAchatService _service = AnnonceAchatService();
  final UserService _userService = UserService();

  final List<AnnonceAchat> _annonces = [];
  final List<AnnonceAchat> _filteredAnnonces = [];

  bool _isLoading = true;
  String _userName = ''; // Variable to hold the user's name

  @override
  void initState() {
    super.initState();
    _loadAnnonces();
    _loadUserName(); // Load the user's name
  }

  /// Load the user's name
  Future<void> _loadUserName() async {
    final user = _userService.currentUser;
    if (user != null) {
      setState(() {
        _userName = user.nom; // Assuming 'nom' is the field for the user's name
      });
    }
  }

  /// Charge toutes les annonces d'achat
  Future<void> _loadAnnonces() async {
    try {
      setState(() => _isLoading = true);
      
      // Vérifier d'abord si l'utilisateur est authentifié
      final isAuthenticated = await _userService.isUserAuthenticated();
      
      if (!isAuthenticated) {
        debugPrint("⚠️ Utilisateur non authentifié - redirection vers la connexion");
        if (!mounted) return;
        setState(() => _isLoading = false);
        
        // Rediriger vers la page de connexion après un court délai
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/login');
          }
        });
        return;
      }

      final annonces = await _service.fetchAnnonces();

      if (!mounted) return;
      setState(() {
        _annonces
          ..clear()
          ..addAll(annonces);
        _filteredAnnonces
          ..clear()
          ..addAll(annonces);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      
      // Distinguer les différents types d'erreurs
      String errorMessage = 'Erreur lors du chargement des annonces';
      Color backgroundColor = AppColors.primaryGreen;
      
      if (e.toString().contains('Utilisateur non authentifié') || 
          e.toString().contains('401')) {
        errorMessage = 'Session expirée. Veuillez vous reconnecter';
        backgroundColor = Colors.orange;
      } else if (e.toString().contains('Pas de connexion Internet')) {
        errorMessage = 'Pas de connexion Internet';
        backgroundColor = Colors.red;
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: backgroundColor,
        ),
      );
    }
  }

  /// Get background color for avatar - using the primary green color of the site
  Color _getAvatarBackgroundColor(String firstLetter) {
    return const Color(0xFF4CAF50); // Primary green color used in the app
  }

  // Méthode pour formater la date avec format relatif
  String _formatDate(String dateString) {
    if (dateString.isEmpty) return '';
    
    try {
      final parts = dateString.split(' ');
      if (parts.isEmpty) return dateString;
      
      final dateParts = parts[0].split('-');
      if (dateParts.length != 3) return dateString;
      
      final year = int.tryParse(dateParts[0]) ?? 0;
      final month = int.tryParse(dateParts[1]) ?? 0;
      final day = int.tryParse(dateParts[2]) ?? 0;
      
      if (year == 0 || month == 0 || day == 0) return dateString;
      
      final date = DateTime(year, month, day);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = DateTime(now.year, now.month, now.day - 1);
      final dateOnly = DateTime(date.year, date.month, date.day);
      
      final difference = today.difference(dateOnly).inDays;
      
      if (dateOnly == today) {
        return 'Aujourd\'hui';
      } else if (dateOnly == yesterday) {
        return 'Hier';
      } else if (difference < 7) {
        return 'Il y a $difference ${difference == 1 ? 'jour' : 'jours'}';
      } else if (difference < 28) {
        final weeks = (difference / 7).floor();
        return 'Il y a $weeks ${weeks == 1 ? 'semaine' : 'semaines'}';
      } else {
        // Format complet: "11 Août 2025"
        final monthNames = [
          'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
          'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
        ];
        return '$day ${monthNames[month - 1]} $year';
      }
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Toutes les Offres d\'Achat',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.primaryGreen,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Adding specific buttons
               
                     
                     
                Expanded(
                  child: _filteredAnnonces.isEmpty
                      ? Center(
                          child: Text(
                            'Aucune annonce disponible',
                            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredAnnonces.length,
                          itemBuilder: (context, index) {
                            final annonce = _filteredAnnonces[index];
                            final isValidated = annonce.statut.toLowerCase() == 'validé';

                            return Card(
                              color: Colors.white,
                              elevation: 2,
                              margin: const EdgeInsets.only(bottom: 16),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Avatar avec couleur basée sur le nom
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: _getAvatarBackgroundColor(annonce.userNom.isNotEmpty ? annonce.userNom[0] : '?'),
                                      child: Text(
                                        annonce.userNom.isNotEmpty ? annonce.userNom[0].toUpperCase() : '?',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Display the buyer's name
                                          Text(
                                            annonce.userNom.isNotEmpty 
                                              ? annonce.userNom
                                              : 'Nom de l\'utilisateur',
                                            style: AppTextStyles.heading.copyWith(
                                              fontSize: 16,
                                              color: AppColors.primaryGreen,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text.rich(
                                            TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: 'Culture: ',
                                                  style: TextStyle(color: Colors.grey[700]),
                                                ),
                                                TextSpan(
                                                  text: '${annonce.typeCultureLibelle}',
                                                  style: const TextStyle(
                                                    color: Color.fromARGB(255, 55, 55, 55),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text.rich(
                                            TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: 'Quantité: ',
                                                  style: TextStyle(color: Colors.grey[700]),
                                                ),
                                                TextSpan(
                                                  text: annonce.formattedQuantity,
                                                  style: const TextStyle(
                                                    color: Color.fromARGB(255, 55, 55, 55),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text.rich(
                                            TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: 'Prix / kg: ',
                                                  style: TextStyle(color: Colors.grey[700]),
                                                ),
                                                TextSpan(
                                                  text: annonce.formattedPrice,
                                                  style: const TextStyle(
                                                    color: Color.fromARGB(255, 55, 55, 55),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          // Statut et Date sur la même ligne
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text.rich(
                                                TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: 'Statut: ',
                                                      style: TextStyle(color: Colors.grey[700]),
                                                    ),
                                                    TextSpan(
                                                      text: annonce.statut,
                                                      style: TextStyle(
                                                        color: isValidated
                                                            ? Colors.green
                                                            : const Color.fromARGB(255, 99, 169, 248),
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              // Date alignée à droite
                                              Text(
                                                _formatDate(annonce.createdAt),
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    // "Voir Plus" icon button avec date en dessous
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            // Navigate to the detailed view of the announcement
                                            // Implement the navigation logic here
                                          },
                                          icon: Icon(
                                            Icons.visibility,
                                            color: AppColors.primaryGreen, // Always green
                                            size: 24,
                                          ),
                                          tooltip: "Voir plus de détails",
                                        ),
                                        // Espace vide pour aligner avec la date
                                        const SizedBox(height: 20),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
