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
    // Extraire le libellé depuis l'objet type_culture s'il existe
    final typeCulture = json['type_culture'] as Map<String, dynamic>?;
    final typeCultureLibelle = typeCulture?['libelle']?.toString() ?? '';
    
    // Extraire le nom utilisateur depuis l'objet users s'il existe
    final users = json['users'] as Map<String, dynamic>?;
    final userNom = users?['nom']?.toString() ?? json['nom']?.toString() ?? '';
    
    return AnnonceAchat(
      id: json['id']?.toString() ?? '',
      statut: json['statut'] ?? '',
      description: json['description'] ?? '',
      quantite: (json['quantite'] as num?)?.toDouble() ?? 0.0,
      prix: (json['prix_kg'] as num?)?.toDouble() ?? 0.0,
      userId: json['user_id']?.toString() ?? '',
      userNom: userNom,
      typeCultureLibelle: typeCultureLibelle,
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
      'user_id': userId,
      'nom': userNom,
      'type_culture_id': typeCultureId,
      // Note: type_culture est un objet séparé dans la réponse API,
      // donc nous ne l'incluons pas ici dans la requête
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
