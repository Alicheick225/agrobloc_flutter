import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/producteurs/transactions/card.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/producteurs/transactions/filter.dart';
import 'package:flutter/material.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/commandeService.dart';
import 'package:agrobloc/core/features/Agrobloc/data/models/commandeModel.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/producteurs/transactions/nav.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/producteurs/transactions/order%20tracking/Trackingpage.dart';
import 'package:agrobloc/core/features/Agrobloc/presentations/widgets/layout/navBarProducteur.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/annonceVenteService.dart';
import 'package:agrobloc/core/features/Agrobloc/data/dataSources/userService.dart';

class TransactionProducteur extends StatefulWidget {
  const TransactionProducteur({super.key, required Text child});

  @override
  State<TransactionProducteur> createState() => _TransactionProducteurState();
}

class _TransactionProducteurState extends State<TransactionProducteur> {
  CommandeStatus? _selectedStatus;
  int selectedFilter = 0;
  late Future<List<CommandeModel>> _future;
  final CommandeService _commandeService = CommandeService();
  final AnnonceService _annonceService = AnnonceService();
  final UserService _userService = UserService();
  List<CommandeModel> commandes = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadLatestCommandes();
  }

  Future<void> _loadLatestCommandes() async {
    setState(() => isLoading = true);
    try {
      final userId = _userService.userId;
      if (userId == null) {
        setState(() => isLoading = false);
        return;
      }
      final userAnnonces = await _annonceService.fetchAnnoncesByUser();
      final annonceIds = userAnnonces.map((a) => a.id).toSet();
      final allCommandes = await _commandeService.getAllCommandes();
      final filteredCommandes = allCommandes.where((c) => annonceIds.contains(c.annoncesVenteId)).toList();
      // Sort by createdAt descending
      filteredCommandes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      setState(() {
        // Filter commandes to only those related to a single producer's products
        commandes = filteredCommandes;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des commandes: $e')),
      );
    }
  }

  void _onStatusChanged(CommandeStatus? status) {
    setState(() {
      _selectedStatus = status;
      // Tu peux aussi déclencher un reload si besoin :
      // _loadCommandes();
    });
  }

  void _onNavBarTap(int index) {
    if (index != 2) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFCFC),
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 100.0), // Reduced bottom padding from 120.0 to 100.0
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const NavTransactionWidget(),
              const SizedBox(height: 16),

              /// Boutons de filtres
              FilterTransactionButtons(
                selectedIndex: selectedFilter,
                onFilterSelected: (index) {
                  setState(() => selectedFilter = index);
                },
              ),
              const SizedBox(height: 16),
              //FILTRE PAR STATUT
              //FilterStatus(
              //   selectedStatus: _selectedStatus,
              // onStatusChanged: (status) {
              //  setState(() {
              //  _selectedStatus = status;
              //      });
              //  },
              //  ),
              const SizedBox(height: 16),

              const SizedBox(height: 16),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : commandes.isEmpty
                        ? const Center(child: Text('Aucune commande.'))
                        : ListView.builder(
                            itemCount: commandes.length,
                            itemBuilder: (_, i) {
                              final commande = commandes[i];
                              if (_selectedStatus != null && commande.statut != _selectedStatus) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0), // Add spacing between cards
                                child: TransactionCard(
                                  commande: commande,
                                  onDetails: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => OrderTrackingScreen(
                                          orderId: commande.id, commande: commande),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomBarProducteur(
        selectedIndex: 2,
        onTap: _onNavBarTap,
      ),
    );
  }
}
