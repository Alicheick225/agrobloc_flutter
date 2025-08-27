class AnnonceAchat {
  final String id;
  final String statut;
  final String description;
  final double quantite; // toujours en kg après conversion
  final double prix;     // en FCFA
  final String userId; // peut rester vide si l'API ne l'envoie pas
  final String userNom;
  final String typeCultureLibelle;
  final String typeCultureId; // peut rester vide si l'API ne l'envoie pas
  final String? unite; // unité originale de l'API (kg ou T)
  final String createdAt; // date de création

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
    this.unite,
    required this.createdAt,
  });

  factory AnnonceAchat.fromJson(Map<String, dynamic> json) {
    // Gestion de la conversion d'unités
    double quantiteValue = (json['quantite'] as num?)?.toDouble() ?? 0.0;
    final String unite = json['unite']?.toString()?.toUpperCase() ?? 'KG';
    
    // Conversion des tonnes en kg si nécessaire
    if (unite == 'T') {
      quantiteValue *= 1000;
    }

    return AnnonceAchat(
      id: json['id']?.toString() ?? '',
      statut: json['statut']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      quantite: quantiteValue,
      prix: (json['prix_kg'] as num?)?.toDouble() ?? 0.0,
      userId: json['user_id']?.toString() ?? '',            // reste vide si absent
      userNom: json['nom']?.toString() ?? '',               // directement depuis JSON
      typeCultureLibelle: json['libelle']?.toString() ?? '', // directement depuis JSON
      typeCultureId: json['type_culture_id']?.toString() ?? '', // reste vide si absent
      unite: unite,
      createdAt: json['created_at']?.toString() ?? '',      // date de création
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
      'libelle': typeCultureLibelle,
      'unite': unite ?? 'KG',
      'created_at': createdAt,
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
    String? unite,
    String? createdAt,
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
      unite: unite ?? this.unite,
      createdAt: createdAt ?? this.createdAt,
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
          typeCultureId == other.typeCultureId &&
          unite == other.unite && // Include unite in equality check
          createdAt == other.createdAt; // Include createdAt in equality check

  @override
  int get hashCode =>
      id.hashCode ^
      statut.hashCode ^
      description.hashCode ^
      quantite.hashCode ^
      userId.hashCode ^
      userNom.hashCode ^
      typeCultureLibelle.hashCode ^
      typeCultureId.hashCode ^
      (unite?.hashCode ?? 0) ^ // Include unite in hashCode
      createdAt.hashCode; // Include createdAt in hashCode

  // Méthode utilitaire pour formater la quantité avec l'unité appropriée
  String get formattedQuantity {
    if (quantite >= 1000) {
      return '${(quantite / 1000).toStringAsFixed(1)} T';
    }
    return '${quantite.toStringAsFixed(0)} kg';
  }

  // Méthode utilitaire pour formater le prix avec devise
  String get formattedPrice {
    return '$prix FCFA';
  }
}
