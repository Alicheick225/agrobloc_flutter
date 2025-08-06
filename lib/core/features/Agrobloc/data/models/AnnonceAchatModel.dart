class AnnonceAchat {
  final String id;
  final String statut;
  final String description;
  final double quantite;
  final String userNom;
  final String typeCultureLibelle;

  AnnonceAchat({
    required this.id,
    required this.statut,
    required this.description,
    required this.quantite,
    required this.userNom,
    required this.typeCultureLibelle,
  });

  factory AnnonceAchat.fromJson(Map<String, dynamic> json) {
    return AnnonceAchat(
        id: json['id']?.toString() ?? '',
        statut: json['statut'] ?? '',
        description: json['description'] ?? '',
        quantite: (json['quantite'] as num?)?.toDouble() ?? 0.0,
        userNom: json['nom'] ?? '',
        typeCultureLibelle: json['libelle'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'Statut': statut,
      'Description': description,
      'Quantite': quantite,
      'nom': userNom,
      'libelle': typeCultureLibelle,
    };
  }

  AnnonceAchat copyWith({
    String? id,
    String? statut,
    String? description,
    double? quantite,
    String? userNom,
    String? typeCultureLibelle,
    String? typeCultureId,
  }) {
    return AnnonceAchat(
      id: id ?? this.id,
      statut: statut ?? this.statut,
      description: description ?? this.description,
      quantite: quantite ?? this.quantite,
      userNom: userNom ?? this.userNom,
      typeCultureLibelle: typeCultureLibelle ?? this.typeCultureLibelle,
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
          userNom == other.userNom &&
          typeCultureLibelle == other.typeCultureLibelle;

  @override
  int get hashCode =>
      id.hashCode ^
      statut.hashCode ^
      description.hashCode ^
      quantite.hashCode ^
      userNom.hashCode ^
      typeCultureLibelle.hashCode;
}
