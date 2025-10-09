class Culture {
  final String? type; // 'rente' ou 'vivrière' (optionnel)
  final String id;
  final String libelle;
  final double prixBordChamp;

  Culture({
    required this.type,
    required this.id,
    required this.libelle,
    required this.prixBordChamp,
  });

  factory Culture.fromJson(Map<String, dynamic> json) {
    return Culture(
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
