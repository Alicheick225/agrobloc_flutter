class AnnonceVenteModel {
  final String id;
  final String userId;
  final String typeCultureId;
  final String parcelleId;
  final String photo;
  final String statut;
  final int quantite;
  final double prixKg;
  final DateTime createdAt;

  AnnonceVenteModel({
    required this.id,
    required this.userId,
    required this.typeCultureId,
    required this.parcelleId,
    required this.photo,
    required this.statut,
    required this.quantite,
    required this.prixKg,
    required this.createdAt,
  });

  factory AnnonceVenteModel.fromJson(Map<String, dynamic> json) {
    return AnnonceVenteModel(
      id: json['id'],
      userId: json['user_id'],
      typeCultureId: json['type_culture_id'],
      parcelleId: json['parcelle_id'],
      photo: json['photo'],
      statut: json['statut'],
      quantite: json['quantite'],
      prixKg: (json['prix_kg'] as num).toDouble(),
      createdAt: DateTime.parse(json['créé_a']),
    );
  }
}
