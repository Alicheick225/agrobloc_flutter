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
  final String cultureId;
  final String cultureType;
  final String parcelleId;
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
    required this.cultureId,
    required this.cultureType,
    required this.parcelleId,
    required this.parcelleAdresse,
    this.createdAt,
    this.note,
    this.culturePrixBordChamp,
  });

  factory AnnonceVente.fromJson(Map<String, dynamic> json) {
    // Extract parcelleId
    String parcelleId = '';
    if (json['parcelle_id'] != null) {
      parcelleId = json['parcelle_id'].toString();
    } else if (json['parcelleId'] != null) {
      parcelleId = json['parcelleId'].toString();
    } else if (json['parcelle'] != null && json['parcelle'] is Map<String, dynamic>) {
      final parcelle = json['parcelle'] as Map<String, dynamic>;
      parcelleId = parcelle['id']?.toString() ?? '';
    }

    return AnnonceVente(
      id: json['id']?.toString() ?? '',
      photo: json['photo'],
      statut: (json['statut'] as String?)?.isNotEmpty == true ? json['statut'] : 'Disponible',
      description: json['description'] ?? '',
      prixKg: (json['prix_kg'] as num?)?.toDouble() ?? 0,
      prixUnite: json['devise'] ?? json['prix_unite'] ?? 'FCFA',
      quantite: (json['quantite'] as num?)?.toDouble() ?? 0,
      quantiteUnite: json['unite'] ?? json['quantite_unite'] ?? 'kg',
      userNom: json['nom']?.toString() ?? json['user_nom']?.toString() ?? json['UserNom']?.toString() ?? '',
      cultureLibelle: json['libelle']?.toString() ?? json['culture_libelle']?.toString() ?? json['CultureLibelle']?.toString() ?? '',
      cultureId: json['culture_id']?.toString() ?? json['cultureId']?.toString() ?? '',
      cultureType: json['type']?.toString() ?? json['culture_type']?.toString() ?? json['cultureType']?.toString() ?? 'vivriere',
      parcelleId: parcelleId,
      parcelleAdresse: json['adresse']?.toString() ?? json['parcelle_adresse']?.toString() ?? json['ParcelleAdresse']?.toString() ?? '',
      createdAt: json['created_at']?.toString(),
      note: (json['note'] as num?)?.toDouble(),
      culturePrixBordChamp: (json['prix_bord_champ'] as num?)?.toDouble() ?? (json['culture_prix_bord_champ'] as num?)?.toDouble(),
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
      'libelle': cultureLibelle,
      'culture_id': cultureId,
      'type': cultureType,
      'parcelle_id': parcelleId,
      'adresse': parcelleAdresse,
      'created_at': createdAt,
      'note': note,
      'prix_bord_champ': culturePrixBordChamp,
    };
  }
}
