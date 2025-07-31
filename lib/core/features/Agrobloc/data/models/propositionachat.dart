
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