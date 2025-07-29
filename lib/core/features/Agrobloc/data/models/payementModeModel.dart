class PaymentModel {
  final String id;
  final String libelle;
  final String? logo;

  PaymentModel({
    required this.id,
    required this.libelle,
    this.logo,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json["id"],
      libelle: json["libelle"],
      logo: json["logo"],
    );
  }
}
