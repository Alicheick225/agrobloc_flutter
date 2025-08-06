import 'package:agrobloc/core/features/Agrobloc/data/dataSources/AnnoncePrefinancement.dart';
import 'package:flutter/material.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/financementModel.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/home/commande_enregistree.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/home/detailFinancement.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/AnnonceVenteModel.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/annonceService.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/home/offreCard.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/home/financementCard.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/home/recommande.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/home/statut_commande.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/layout/filter_boutton.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/layout/nav_bar.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/layout/recherche_bar.dart';
import 'package:agrobloc/core/themes/app_colors.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/pages/transactionPage.dart';
// Import du widget PropositionCard
// import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/home/propositioncard.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/propositionachat.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/propositionachat.dart' as PropositionModel;

/// Page principale affichant les différentes sections et la navigation
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

/// Page principale affichant les différentes sections et la navigation
class _HomePageState extends State<HomePage> {
  // Index de l'onglet sélectionné dans la barre de navigation inférieure
  int _selectedIndex = 0;

  // Index du filtre sélectionné (0 = annonces, 1 = financements, 2 = mes offres)
  int _selectedFilterIndex = 0;

  // Page courante pour la pagination
  int _currentPage = 0;

  // Nombre d'éléments par page pour la pagination
  final int _pageSize = 2;

  // Liste complète des annonces de vente
  List<AnnonceVente> annonces = [];

  // Liste complète des financements
  List<AnnonceFinancement> financements = [];

  // Liste complète des propositions d'achat
  List<PropositionModel.PropositionAchat> propositions = [];

  // Sous-liste paginée des annonces affichées
  List<AnnonceVente> paginatedAnnonces = [];

  // Sous-liste paginée des financements affichés
  List<AnnonceFinancement> paginatedFinancements = [];

  // Sous-liste paginée des propositions affichées
  List<PropositionModel.PropositionAchat> paginatedPropositions = [];

  // Indicateur de chargement des données
  bool isLoading = true;

  // Indicateur de chargement spécifique aux propositions
  bool isLoadingPropositions = false;

  /// Charge toutes les données nécessaires (annonces et financements)
  Future<void> _loadAllData() async {
    setState(() => isLoading = true);
    try {
      final annonceService = AnnonceService();
      final ventesData = await annonceService.getAllAnnonces();
      final prefinancementService = PrefinancementService();
      final financementsData = await prefinancementService.fetchPrefinancements();

      setState(() {
        annonces = ventesData;
        financements = financementsData;
        _currentPage = 0;
        _updatePagination();
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Erreur de chargement des données : $e");
      setState(() => isLoading = false);
    }
  }

  /// Charge les propositions d'achat
  Future<void> _loadPropositions() async {
    setState(() => isLoadingPropositions = true);
    try {
      final propositionsData = await PropositionAchatService.fetchAllAnnoncesAchat();
      setState(() {
        propositions = propositionsData.cast<PropositionModel.PropositionAchat>();
        _currentPage = 0;
        _updatePagination();
        isLoadingPropositions = false;
      });
    } catch (e) {
      debugPrint("Erreur de chargement des propositions : $e");
      setState(() => isLoadingPropositions = false);
      // Afficher un message d'erreur à l'utilisateur
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Met à jour les sous-listes paginées en fonction de la page courante et du filtre sélectionné
  void _updatePagination() {
    final start = _currentPage * _pageSize;
    final end = (_currentPage + 1) * _pageSize;

    if (_selectedFilterIndex == 0) {
      paginatedAnnonces = annonces.sublist(
        start.clamp(0, annonces.length),
        end.clamp(0, annonces.length),
      );
    } else if (_selectedFilterIndex == 1) {
      paginatedFinancements = financements.sublist(
        start.clamp(0, financements.length),
        end.clamp(0, financements.length),
      );
    } else if (_selectedFilterIndex == 2) {
      paginatedPropositions = propositions.sublist(
        start.clamp(0, propositions.length),
        end.clamp(0, propositions.length),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  /// Liste des pages affichées dans le corps principal
  List<Widget> get pages => [
    _buildHomeContent(),
    _buildAnnoncesPage(),
    const TransactionPage(),
    const Center(child: Text("Profil", style: TextStyle(fontSize: 24))),
  ];

  /// Page affichant la section annonces avec boutons de navigation vers d'autres pages
  Widget _buildAnnoncesPage() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text("Section Annonces", style: TextStyle(fontSize: 24)),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CommandeEnregistreePage()),
              );
            },
            icon: const Icon(Icons.receipt),
            label: const Text("Voir Commande Enregistrée"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StatutCommandePage()),
              );
            },
            icon: const Icon(Icons.local_shipping),
            label: const Text("Voir Statut de Commande"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          ),
        ],
      ),
    );
  }

  /// Contenu principal de la page d'accueil avec barre de recherche et filtres
  Widget _buildHomeContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SearchBarWidget(),
            const SizedBox(height: 16),
            FilterButtons(
              onFilterSelected: (index) {
                setState(() {
                  _selectedFilterIndex = index;
                  _currentPage = 0;

                  // Charge les propositions si on sélectionne "Mes offres"
                  if (index == 2 && propositions.isEmpty) {
                    _loadPropositions();
                  } else {
                    _updatePagination();
                  }
                });
              },
            ),
            const SizedBox(height: 24),
            _buildFilteredContent(),
          ],
        ),
      ),
    );
  }

  /// Contenu filtré affiché selon le filtre sélectionné (annonces, financements ou propositions)
  Widget _buildFilteredContent() {
    switch (_selectedFilterIndex) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Top offres avec pagination
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Top offres", style: Theme.of(context).textTheme.titleLarge),
                TextButton(
                  onPressed: () {
                    if (annonces.isNotEmpty) {
                      setState(() {
                        final maxPage = (annonces.length / _pageSize).ceil();
                        _currentPage = (_currentPage + 1) % maxPage;
                        _updatePagination();
                      });
                    }
                  },
                  child: const Text(
                    "Suivant >",
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: paginatedAnnonces.isEmpty
                  ? const Center(child: Text("Aucune offre disponible"))
                  : ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: paginatedAnnonces.length,
                itemBuilder: (context, index) {
                  final annonce = paginatedAnnonces[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: SizedBox(
                      width: 160,
                      child: OffreCard(data: annonce),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 45),

            /// Section Recommandé
            Text("Recommandé", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 5),
            Column(
              children: annonces.map((annonce) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: RecommendationCard(recommendation: annonce),
                );
              }).toList(),
            ),
          ],
        );

      case 1:
        return paginatedFinancements.isEmpty
            ? const Center(child: Text("Aucun financement disponible"))
            : ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: paginatedFinancements.length,
          itemBuilder: (context, index) {
            final financement = paginatedFinancements[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FinancementDetailsPage(data: financement),
                    ),
                  );
                },
                child: FinancementCard(
                  key: ValueKey(financement.id),
                  data: financement,
                ),
              ),
            );
          },
        );

      case 2: // Mes offres (Propositions d'achat)
        return isLoadingPropositions
            ? const Center(child: CircularProgressIndicator())
            : propositions.isEmpty
            ? const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 64,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                'Aucune proposition trouvée',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Vos propositions d\'achat apparaîtront ici',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header avec bouton de pagination
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Mes Propositions", style: Theme.of(context).textTheme.titleLarge),
                TextButton(
                  onPressed: () {
                    if (propositions.isNotEmpty) {
                      setState(() {
                        final maxPage = (propositions.length / _pageSize).ceil();
                        _currentPage = (_currentPage + 1) % maxPage;
                        _updatePagination();
                      });
                    }
                  },
                  child: const Text(
                    "Suivant >",
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            /// Liste des propositions paginées
            ...paginatedPropositions.map((proposition) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header avec avatar et nom
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.grey[300],
                              child: Text(
                                proposition.userNom.isNotEmpty
                                    ? proposition.userNom[0].toUpperCase()
                                    : 'U',
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    proposition.userNom,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    'Affilié à Sacko', // Vous pouvez adapter ceci selon vos données
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.delete_outline,
                                color: Colors.grey[600],
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Culture
                        Row(
                          children: [
                            const Text(
                              'Culture : ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              proposition.typeCultureLibelle,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Quantité
                        Row(
                          children: [
                            const Text(
                              'Quantité : ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              '${proposition.quantite.toInt()} tonnes',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Prix unitaire avec icône d'édition
                        Row(
                          children: [
                            const Text(
                              'Prix unitaire: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              '${proposition.prixUnitaire.toStringAsFixed(0)} FCFA / Kg', // ✅ dynamique à partir du modèle
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                Icons.edit_outlined,
                                color: Colors.green[600],
                                size: 18,
                              ),
                            ),
                          ],
                        ),

                        // Description si elle existe
                        if (proposition.description.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            'Description: ${proposition.description}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],

                        // Statut
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: proposition.statut.toLowerCase() == 'validé'
                                ? Colors.green[100]
                                : proposition.statut.toLowerCase() == 'en cour'
                                ? Colors.red[100]
                                : Colors.orange[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            proposition.statut,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: proposition.statut.toLowerCase() == 'validé'
                                  ? Colors.green[700]
                                  : proposition.statut.toLowerCase() == 'en cour'
                                  ? Colors.red[700]
                                  : Colors.orange[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        );

      default:
        return const Center(child: Text("Contenu non disponible"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: pages[_selectedIndex],
        bottomNavigationBar: BottomNavBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
        ),
      ),
    );
  }
}