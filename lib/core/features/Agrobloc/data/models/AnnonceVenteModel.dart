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
  final String typeCultureId;
  final String parcelleAdresse;
  final String? createdAt;
  final double? note;

  // ➜ NOUVEAUX CHAMPS
  final String typeProduit; // "Vivrière" ou "de rente"
  final double? prixBordChamp; // prix depuis la BD

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
    required this.typeCultureId,
    required this.parcelleAdresse,
    this.createdAt,
    this.note,
    // ➜ NOUVEAUX
    required this.typeProduit,
    this.prixBordChamp,
  });

  factory AnnonceVente.fromJson(Map<String, dynamic> json) {
    return AnnonceVente(
      id: json['id']?.toString() ?? '',
      photo: json['photo'],
      statut: json['statut'] ?? 'Indisponible',
      description: json['description'] ?? '',
      prixKg: (json['prix_kg'] as num?)?.toDouble() ?? 0,
      prixUnite: json['devise'] ?? 'FCFA', // ← clé JSON corrigée
      quantite: (json['quantite'] as num?)?.toDouble() ?? 0,
      quantiteUnite: json['unite'] ?? 'kg', // ← clé JSON corrigée
      userNom: json['nom'] ?? '',
      typeCultureLibelle: json['libelle'] ?? '',
      typeCultureId: json['type_culture_id']?.toString() ?? '',
      parcelleAdresse: json['adresse'] ?? '',
      createdAt: json['created_at']?.toString(),
      note: (json['note'] as num?)?.toDouble(),
      // ➜ NOUVEAUX
      typeProduit: json['type'] ?? 'Vivrière', // "Vivrière" ou "de rente"
      prixBordChamp: (json['prix_bord_champ'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'photo': photo,
      'statut': statut,
      'description': description,
      'prix_kg': prixKg,
      'devise': prixUnite, // ← clé JSON corrigée
      'quantite': quantite,
      'unite': quantiteUnite, // ← clé JSON corrigée
      'nom': userNom,
      'libelle': typeCultureLibelle,
      'type_culture_id': typeCultureId,
      'adresse': parcelleAdresse,
      'created_at': createdAt,
      'note': note,
      // ➜ NOUVEAUX
      'type': typeProduit,
      'prix_bord_champ': prixBordChamp,
    };
  }
}
