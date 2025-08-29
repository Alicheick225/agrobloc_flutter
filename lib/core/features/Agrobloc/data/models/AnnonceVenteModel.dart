class AnnonceVente {
  final String id;
  final String? photo;
  final String statut;
  final String description;
  final double prixKg;
  final String prixUnite;
  final double quantite;
  final String quantiteUnite;
  final String userNom;
  final String typeCultureLibelle;
  final String parcelleAdresse;
  final String? createdAt;
  final double? note;

  AnnonceVente({
    required this.id,
    this.photo,
    required this.statut,
    required this.description,
    required this.prixKg,
    required this.prixUnite,
    required this.quantite,
    required this.quantiteUnite,
    required this.userNom,
    required this.typeCultureLibelle,
    required this.parcelleAdresse,
    this.createdAt,
    this.note,
  });

  factory AnnonceVente.fromJson(Map<String, dynamic> json) {
    return AnnonceVente(
      id: json['id']?.toString() ?? '',
      photo: json['photo'],
      statut: json['statut'] ?? 'Indisponible',
      description: json['description'] ?? '',
      prixKg: (json['prix_kg'] as num?)?.toDouble() ?? 0,
      prixUnite: json['prix_unite'] ?? 'FCFA',
      quantite: (json['quantite'] as num?)?.toDouble() ?? 0,
      quantiteUnite: json['quantite_unite'] ?? 'kg',
      userNom: json['user_nom'] ?? '',
      typeCultureLibelle: json['type_culture_libelle'] ?? '',
      parcelleAdresse: json['parcelle_adresse'] ?? '',
      createdAt: json['created_at']?.toString(),
      note: (json['note'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'photo': photo,
      'statut': statut,
      'description': description,
      'prix_kg': prixKg,
      'prix_unite': prixUnite,
      'quantite': quantite,
      'quantite_unite': quantiteUnite,
      'user_nom': userNom,
      'type_culture_libelle': typeCultureLibelle,
      'parcelle_adresse': parcelleAdresse,
      'created_at': createdAt,
      'note': note,
    };
  }
}
