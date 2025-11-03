class PayementModel {
  final String id;
  final String? libelle;
  final String? logo;

  PayementModel({
    required this.id,
    this.libelle,
    this.logo,
  });

  factory PayementModel.fromJson(Map<String, dynamic> json) {
    return PayementModel(
      id: json["id"]?.toString() ?? '',
      libelle: json["libelle"]?.toString(),
      logo: json["logo"]?.toString(),
    );
  }
}
