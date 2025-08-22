class TypeCulture {
  final String id;
  final String libelle;
  final double prixBordChamp;

  TypeCulture({
    required this.id,
    required this.libelle,
    required this.prixBordChamp,
  });

  factory TypeCulture.fromJson(Map<String, dynamic> json) {
    return TypeCulture(
      id: json['id'] as String,
      libelle: json['libelle'] as String,
      prixBordChamp: (json['prix_bord_champ'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'libelle': libelle,
      'prix_bord_champ': prixBordChamp,
    };
  }
}
