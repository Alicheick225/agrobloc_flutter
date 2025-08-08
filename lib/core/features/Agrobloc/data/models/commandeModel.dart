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
      quantite: double.parse(json['quantite']),
      prixTotal: double.parse(json['prix_total']),
      modePaiementId: json['mode_paiement_id'],
      statut: json['statut'],
      createdAt: DateTime.parse(json['created_at']),
      typeCulture: json['type_culture'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'acheteur_id': acheteurId,
      'quantite': quantite.toString(),
      'prix_total': prixTotal.toString(),
      'mode_paiement_id': modePaiementId,
      'statut': statut,
      'created_at': createdAt.toIso8601String(),
      'type_culture': typeCulture,
    };
  }
}
