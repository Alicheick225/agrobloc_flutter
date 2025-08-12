class CommandeModel {
  final String id;
  final String acheteurId;
  final double quantite;
  final double prixTotal;
  final String modePaiementId;
  final String statut;
  final DateTime createdAt;
  final String typeCulture;

  CommandeModel({
    required this.id,
    required this.acheteurId,
    required this.quantite,
    required this.prixTotal,
    required this.modePaiementId,
    required this.statut,
    required this.createdAt,
    required this.typeCulture,
  });

  factory CommandeModel.fromJson(Map<String, dynamic> json) {
    return CommandeModel(
      id: json['id'],
      acheteurId: json['acheteur_id'],
      quantite: (json['quantite'] is int)
          ? (json['quantite'] as int).toDouble()
          : (json['quantite'] as num).toDouble(),
      prixTotal: (json['prix_total'] is int)
          ? (json['prix_total'] as int).toDouble()
          : (json['prix_total'] as num).toDouble(),
      modePaiementId: json['types_paiement_id'],
      statut: json['statut'],
      createdAt: DateTime.parse(json['created_at']),
      typeCulture: json['type_culture'],
    );
  }
}
