// lib/models/payement_model.dart
class PayementModel {
  final String id;
  final String libelle;

  PayementModel({
    required this.id,
    required this.libelle,
  });

  factory PayementModel.fromJson(Map<String, dynamic> json) => PayementModel(
        id: json['id'],
        libelle: json['libelle'],
      );
}
