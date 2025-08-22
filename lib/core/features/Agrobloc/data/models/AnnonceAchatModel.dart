class AnnonceAchat {
  final String id;
  final String statut;
  final String description;
  final double quantite;
  final double prix;
  final String userId; // ID de l'utilisateur qui a créé l'annonce
  final String userNom;
  final String typeCultureLibelle;
  final String typeCultureId;

  AnnonceAchat({
    required this.id,
    required this.statut,
    required this.description,
    required this.quantite,
    required this.prix,
    required this.userId,
    required this.userNom,
    required this.typeCultureLibelle,
    required this.typeCultureId,
  });

  factory AnnonceAchat.fromJson(Map<String, dynamic> json) {
    return AnnonceAchat(
      id: json['id']?.toString() ?? '',
      statut: json['statut'] ?? '',
      description: json['description'] ?? '',
      quantite: (json['quantite'] as num?)?.toDouble() ?? 0.0,
      prix: (json['prix_kg'] as num?)?.toDouble() ?? 0.0,
      userId: json['user_id']?.toString() ?? '', // Nouveau champ
      userNom: json['nom'] ?? '',
      typeCultureLibelle: json['libelle'] ?? '',
      typeCultureId: json['type_culture_id']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'statut': statut,
      'description': description,
      'quantite': quantite,
      'prix_kg': prix,
      'user_id': userId, // Nouveau champ
      'nom': userNom,
      'libelle': typeCultureLibelle,
      'type_culture_id': typeCultureId,
    };
  }

  AnnonceAchat copyWith({
    String? id,
    String? statut,
    String? description,
    double? quantite,
    double? prix,
    String? userId,
    String? userNom,
    String? typeCultureLibelle,
    String? typeCultureId,
  }) {
    return AnnonceAchat(
      id: id ?? this.id,
      statut: statut ?? this.statut,
      description: description ?? this.description,
      quantite: quantite ?? this.quantite,
      prix: prix ?? this.prix,
      userId: userId ?? this.userId,
      userNom: userNom ?? this.userNom,
      typeCultureLibelle: typeCultureLibelle ?? this.typeCultureLibelle,
      typeCultureId: typeCultureId ?? this.typeCultureId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnnonceAchat &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          statut == other.statut &&
          description == other.description &&
          quantite == other.quantite &&
          userId == other.userId &&
          userNom == other.userNom &&
          typeCultureLibelle == other.typeCultureLibelle &&
          typeCultureId == other.typeCultureId;

  @override
  int get hashCode =>
      id.hashCode ^
      statut.hashCode ^
      description.hashCode ^
      quantite.hashCode ^
      userId.hashCode ^
      userNom.hashCode ^
      typeCultureLibelle.hashCode ^
      typeCultureId.hashCode;
}
