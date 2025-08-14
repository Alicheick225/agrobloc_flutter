class AnnonceVente {
  final String id;
  final String? photo;
  final String statut;
  final String description;
  final double prixKg;
  final double quantite;
  final String userNom;
  final String typeCultureLibelle;
  final String parcelleAdresse;
  final String? datePublication; 
  final double? note; 


  AnnonceVente({
    required this.id,
    this.photo,
    required this.statut,
    required this.description,
    required this.prixKg,
    required this.quantite,
    required this.userNom,
    required this.typeCultureLibelle,
    required this.parcelleAdresse,
    this.datePublication,
    this.note,
  });

  factory AnnonceVente.fromJson(Map<String, dynamic> json) {
    return AnnonceVente(
      id: json['id'].toString(),
      photo: json['photo'],
      statut: json['statut'] ?? 'Indisponible'?? 'previsionnel', 
      description: json['description'] ?? '',
      prixKg: (json['prix_kg'] as num?)?.toDouble() ?? 0,
      quantite: (json['quantite'] as num?)?.toDouble() ?? 0,
      userNom: json['nom'] ?? '', 
      typeCultureLibelle: json['libelle'] ?? '', 
      parcelleAdresse: json['adresse'] ?? '', 
      datePublication: json['date_publication'], 
      note: (json['note'] as num?)?.toDouble(), 
    );
  }

  get parcelleId => null;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'photo': photo,
      'statut': statut,
      'description': description,
      'prix_kg': prixKg,
      'quantite': quantite,
      'nom': userNom,
      'libelle': typeCultureLibelle,
      'adresse': parcelleAdresse,
      'date_publication': datePublication,
      'note': note,
    };
  }
}
