class CommandeModel {
  final String id;
  final String annoncesVenteId;
  final String acheteurId;
  final int quantite; // en kg
  final double prixTotal;
  final String statut;
  final DateTime createdAt;

  CommandeModel({
    required this.id,
    required this.annoncesVenteId,
    required this.acheteurId,
    required this.quantite,
    required this.prixTotal,
    required this.statut,
    required this.createdAt,
  });

  factory CommandeModel.fromJson(Map<String, dynamic> json) {
    return CommandeModel(
      id: json['id'],
      annoncesVenteId: json['annonces_vente_id'],
      acheteurId: json['acheteur_id'],
      quantite: json['quantite'],
      prixTotal: (json['prix_total'] as num).toDouble(),
      statut: json['statut'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
