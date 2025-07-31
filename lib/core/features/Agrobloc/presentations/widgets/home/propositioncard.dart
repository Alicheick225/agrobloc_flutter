import 'package:flutter/material.dart';

/// Modèle de données pour une proposition d'achat
class PropositionAchat {
  final String id;
  final String nomVendeur;
  final String affiliation;
  final String culture;
  final String quantiteSouhaitee;
  final String prixUnitaire;
  final String statut; // "En attente", "Acceptée", "Refusée"
  final DateTime dateProposition;

  PropositionAchat({
    required this.id,
    required this.nomVendeur,
    required this.affiliation,
    required this.culture,
    required this.quantiteSouhaitee,
    required this.prixUnitaire,
    required this.statut,
    required this.dateProposition,
  });

  // Factory pour créer depuis JSON
  factory PropositionAchat.fromJson(Map<String, dynamic> json) {
    return PropositionAchat(
      id: json['id'] ?? '',
      nomVendeur: json['nomVendeur'] ?? '',
      affiliation: json['affiliation'] ?? '',
      culture: json['culture'] ?? '',
      quantiteSouhaitee: json['quantiteSouhaitee'] ?? '',
      prixUnitaire: json['prixUnitaire'] ?? '',
      statut: json['statut'] ?? 'En attente',
      dateProposition: DateTime.tryParse(json['dateProposition'] ?? '') ?? DateTime.now(),
    );
  }
}

/// Widget de carte pour afficher une proposition d'achat
class PropositionCard extends StatelessWidget {
  final PropositionAchat proposition;
  final VoidCallback? onTap;

  const PropositionCard({
    super.key,
    required this.proposition,
    this.onTap,
  });

  Color _getStatutColor() {
    switch (proposition.statut.toLowerCase()) {
      case 'acceptée':
      case 'acceptee':
        return Colors.green;
      case 'refusée':
      case 'refusee':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  IconData _getStatutIcon() {
    switch (proposition.statut.toLowerCase()) {
      case 'acceptée':
      case 'acceptee':
        return Icons.check_circle;
      case 'refusée':
      case 'refusee':
        return Icons.cancel;
      default:
        return Icons.schedule;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header avec nom du vendeur et statut
              Row(
                children: [
                  // Avatar du vendeur
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.green.shade100,
                    child: Text(
                      proposition.nomVendeur.isNotEmpty
                          ? proposition.nomVendeur[0].toUpperCase()
                          : 'V',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Nom et affiliation
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          proposition.nomVendeur,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Affilié à ${proposition.affiliation}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Statut
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatutColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatutIcon(),
                          size: 14,
                          color: _getStatutColor(),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          proposition.statut,
                          style: TextStyle(
                            color: _getStatutColor(),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bouton d'action (supprimer/modifier)
                  const SizedBox(width: 8),
                  Icon(
                    Icons.edit_outlined,
                    color: Colors.grey[400],
                    size: 20,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Informations de la proposition
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _buildInfoRow('Culture :', proposition.culture),
                    const SizedBox(height: 8),
                    _buildInfoRow('Quantité Souhaitée:', proposition.quantiteSouhaitee),
                    const SizedBox(height: 8),
                    _buildInfoRow('Prix unitaire:', proposition.prixUnitaire),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Date de proposition
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Proposé le ${_formatDate(proposition.dateProposition)}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}