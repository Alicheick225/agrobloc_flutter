class Culture {
  final String id;
  final String libelle;
  final String type;
  final double prixBordChamp;

  Culture({
    required this.id,
    required this.libelle,
    required this.type,
    required this.prixBordChamp,
  });

  factory Culture.fromJson(Map<String, dynamic> json) {
    return Culture(
      id: json['id'] as String,
      libelle: json['libelle'] as String,
      type: json['type'] as String,
      prixBordChamp: (json['prix_bord_champ'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'libelle': libelle,
      'type': type,
      'prix_bord_champ': prixBordChamp,
    };
  }
}
