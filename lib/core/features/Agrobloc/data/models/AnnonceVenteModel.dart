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
  final String cultureLibelle;
  final String cultureType;
  final String parcelleAdresse;
  final String? createdAt;
  final double? note;
  final double? culturePrixBordChamp;

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
    required this.cultureLibelle,
    required this.cultureType,
    required this.parcelleAdresse,
    this.createdAt,
    this.note,
    this.culturePrixBordChamp,
  });

  factory AnnonceVente.fromJson(Map<String, dynamic> json) {
    return AnnonceVente(
      id: json['id']?.toString() ?? '',
      photo: json['photo'],
      statut: AnnonceVente.normalizeStatut(json['statut'] ?? ''),
      description: json['description'] ?? '',
      prixKg: (json['prix_kg'] as num?)?.toDouble() ?? 0,
      prixUnite: json['prix_unite'] ?? 'FCFA',
      quantite: (json['quantite'] as num?)?.toDouble() ?? 0,
      quantiteUnite: json['quantite_unite'] ?? 'kg',
      userNom: json['user_nom'] ?? '',
      cultureLibelle: json['culture_libelle'] ?? '',
      cultureType: json['culture_type'] ?? 'vivriere',
      parcelleAdresse: json['parcelle_adresse'] ?? '',
      createdAt: json['created_at']?.toString(),
      note: (json['note'] as num?)?.toDouble(),
      culturePrixBordChamp: (json['culture_prix_bord_champ'] as num?)?.toDouble(),
    );
  }
  
  static String normalizeStatut(String s) => s;

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
      'culture_libelle': cultureLibelle,
      'culture_type': cultureType,
      'parcelle_adresse': parcelleAdresse,
      'created_at': createdAt,
      'note': note,
      'culture_prix_bord_champ': culturePrixBordChamp,
    };
  }
}
