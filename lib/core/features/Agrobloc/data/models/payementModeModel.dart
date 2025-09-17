class PayementModel {
  final String id;
  final String libelle;
  final String? logo;

  PayementModel({
    required this.id,
    required this.libelle,
    this.logo,
  });

  factory PayementModel.fromJson(Map<String, dynamic> json) {
    return PayementModel(
      id: json["id"],
      libelle: json["libelle"],
      logo: json["logo"],
    );
  }
}
