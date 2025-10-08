class TypeCulture {
  final String? type; // 'rente' ou 'vivrière' (optionnel)
  final String id;
  final String libelle;
  final double prixBordChamp;

  TypeCulture({
    required this.type,
    required this.id,
    required this.libelle,
    required this.prixBordChamp,
  });

  factory TypeCulture.fromJson(Map<String, dynamic> json) {
    return TypeCulture(
      type: json['type'] as String?,
      id: json['id'] as String,
      libelle: json['libelle'] as String,
      prixBordChamp: (json['prix_bord_champ'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'libelle': libelle,
      'prix_bord_champ': prixBordChamp,
    };
  }
}
