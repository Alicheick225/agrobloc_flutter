class AnnonceVenteModel {
  final String id;
  final String photo;
  final String statut;
  final String description;
  final double prixKg;
  final int quantite;
  final String userNom;
  final String typeCultureLibelle;
  final String parcelleAdresse;

  AnnonceVenteModel({
    required this.id,
    required this.photo,
    required this.statut,
    required this.description,
    required this.prixKg,
    required this.quantite,
    required this.userNom,
    required this.typeCultureLibelle,
    required this.parcelleAdresse,
  });

  factory AnnonceVenteModel.fromJson(Map<String, dynamic> json) {
    return AnnonceVenteModel(
      id: json['id'],
      photo: json['photo'],
      statut: json['statut'],
      description: json['description'],
      prixKg: (json['prix_kg'] as num).toDouble(),
      quantite: json['quantite'],
      userNom: json['user_nom'],
      typeCultureLibelle: json['type_culture_libelle'],
      parcelleAdresse: json['parcelle_adresse'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'photo': photo,
      'statut': statut,
      'description': description,
      'prix_kg': prixKg,
      'quantite': quantite,
      'user_nom': userNom,
      'type_culture_libelle': typeCultureLibelle,
      'parcelle_adresse': parcelleAdresse,
    };
  }
}
