class MoyenPaiement {
  final String id;
  final String libelle;
  final String logo;

  MoyenPaiement({
    required this.id,
    required this.libelle,
    required this.logo,
  });

  factory MoyenPaiement.fromJson(Map<String, dynamic> json) {
    return MoyenPaiement(
      id: json['id'],
      libelle: json['libelle'],
      logo: json['logo'],
    );
  }
}
